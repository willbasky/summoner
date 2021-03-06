{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE DeriveAnyClass       #-}
{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE KindSignatures       #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeOperators        #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE UndecidableInstances #-}

-- | Summoner configurations.

module Summoner.Config
       ( ConfigP (..)

       , PartialConfig
       , Config
       , defaultConfig
       , finalise

       , loadFileConfig
       ) where

import Relude

import Control.Exception (throwIO)
import Data.List (lookup)
import Data.Monoid (Last (..))
import Generics.Deriving.Monoid (GMonoid, gmemptydefault)
import Generics.Deriving.Semigroup (GSemigroup, gsappenddefault)
import Toml (AnyValue (..), BiToml, Key, Prism (..), dimap, (.=))

import Summoner.License (License (..))
import Summoner.ProjectData (CustomPrelude (..), Decision (..), GhcVer (..), parseGhcVer,
                             showGhcVer)
import Summoner.Validation (Validation (..))

import qualified Text.Show as Show
import qualified Toml

data Phase = Partial | Final

-- | Potentially incomplete configuration.
data ConfigP (p :: Phase) = Config
    { cOwner      :: p :- Text
    , cFullName   :: p :- Text
    , cEmail      :: p :- Text
    , cLicense    :: p :- License
    , cGhcVer     :: p :- [GhcVer]
    , cCabal      :: Decision
    , cStack      :: Decision
    , cGitHub     :: Decision
    , cTravis     :: Decision
    , cAppVey     :: Decision
    , cPrivate    :: Decision
    , cScript     :: Decision
    , cLib        :: Decision
    , cExe        :: Decision
    , cTest       :: Decision
    , cBench      :: Decision
    , cPrelude    :: Last CustomPrelude
    , cExtensions :: [Text]
    } deriving (Generic)

deriving instance (GSemigroup (p :- Text), GSemigroup (p :- License), GSemigroup (p :- [GhcVer])) => GSemigroup (ConfigP p)
deriving instance (GMonoid (p :- Text), GMonoid (p :- License), GMonoid (p :- [GhcVer])) => GMonoid (ConfigP p)

infixl 3 :-
type family phase :- field where
    'Partial :- field = Last field
    'Final   :- field = field

-- | Incomplete configurations.
type PartialConfig = ConfigP 'Partial

-- | Complete configurations.
type Config = ConfigP 'Final

instance Semigroup PartialConfig where
    (<>) = gsappenddefault

instance Monoid PartialConfig where
    mempty = gmemptydefault
    mappend = (<>)

-- | Default 'Config' configurations.
defaultConfig :: PartialConfig
defaultConfig = Config
    { cOwner    = Last (Just "kowainik")
    , cFullName = Last (Just "Kowainik")
    , cEmail    = Last (Just "xrom.xkov@gmail.com")
    , cLicense  = Last (Just $ License "MIT")
    , cGhcVer   = Last (Just [])
    , cCabal    = Idk
    , cStack    = Idk
    , cGitHub   = Idk
    , cTravis   = Idk
    , cAppVey   = Idk
    , cPrivate  = Idk
    , cScript   = Idk
    , cLib      = Idk
    , cExe      = Idk
    , cTest     = Idk
    , cBench    = Idk
    , cPrelude  = Last Nothing
    , cExtensions = []
    }

-- | Identifies how to read 'Config' data from the @.toml@ file.
configT :: BiToml PartialConfig
configT = Config
    <$> lastT Toml.text "owner"       .= cOwner
    <*> lastT Toml.text "fullName"    .= cFullName
    <*> lastT Toml.text "email"       .= cEmail
    <*> lastT license   "license"     .= cLicense
    <*> lastT ghcVerArr "ghcVersions" .= cGhcVer
    <*> decision        "cabal"       .= cCabal
    <*> decision        "stack"       .= cStack
    <*> decision        "github"      .= cGitHub
    <*> decision        "travis"      .= cTravis
    <*> decision        "appveyor"    .= cAppVey
    <*> decision        "private"     .= cPrivate
    <*> decision        "bscript"     .= cScript
    <*> decision        "lib"         .= cLib
    <*> decision        "exe"         .= cExe
    <*> decision        "test"        .= cTest
    <*> decision        "bench"       .= cBench
    <*> lastT (Toml.table preludeT) "prelude" .= cPrelude
    <*> extensions      "extensions"  .= cExtensions
  where
    lastT :: (Key -> BiToml a) -> Key -> BiToml (Last a)
    lastT f = dimap getLast Last . Toml.maybeT f

    _GhcVer :: Prism AnyValue GhcVer
    _GhcVer = Prism
        { preview = \(AnyValue t) -> Toml.matchText t >>= parseGhcVer
        , review = AnyValue . Toml.Text . showGhcVer
        }

    ghcVerArr :: Key -> BiToml [GhcVer]
    ghcVerArr = Toml.arrayOf _GhcVer

    license :: Key -> BiToml License
    license =  dimap unLicense License . Toml.text

    extensions :: Key -> BiToml [Text]
    extensions = dimap Just maybeToMonoid . Toml.maybeT (Toml.arrayOf Toml._Text)

    decision :: Key -> BiToml Decision
    decision = dimap fromDecision toDecision . Toml.maybeT Toml.bool

    decisionMaybe :: [(Decision, Maybe Bool)]
    decisionMaybe = [ (Idk, Nothing)
                    , (Yes, Just True)
                    , (Nop, Just False)
                    ]

    fromDecision :: Decision -> Maybe Bool
    fromDecision d = join $ lookup d decisionMaybe

    toDecision :: Maybe Bool -> Decision
    toDecision m = fromMaybe (error "Impossible") $ lookup m $ map swap decisionMaybe

    preludeT :: BiToml CustomPrelude
    preludeT = Prelude
        <$> Toml.text "package" .= cpPackage
        <*> Toml.text "module"  .= cpModule

-- | Make sure that all the required configurations options were specified.
finalise :: PartialConfig -> Validation [Text] Config
finalise Config{..} = Config
    <$> fin  "owner"      cOwner
    <*> fin  "fullName"   cFullName
    <*> fin  "email"      cEmail
    <*> fin  "license"    cLicense
    <*> fin  "ghcVersions" cGhcVer
    <*> pure cCabal
    <*> pure cStack
    <*> pure cGitHub
    <*> pure cTravis
    <*> pure cAppVey
    <*> pure cPrivate
    <*> pure cScript
    <*> pure cLib
    <*> pure cExe
    <*> pure cTest
    <*> pure cBench
    <*> pure cPrelude
    <*> pure cExtensions
  where
    fin name = maybe (Failure ["Missing field: " <> name]) Success . getLast

-- | Read configuration from the given file and return it in data type.
loadFileConfig :: MonadIO m => FilePath -> m PartialConfig
loadFileConfig filePath = (Toml.decode configT <$> readFile filePath) >>= liftIO . errorWhenLeft
  where
    errorWhenLeft :: Either Toml.DecodeException PartialConfig -> IO PartialConfig
    errorWhenLeft (Left e)   = throwIO $ LoadTomlException filePath $ Toml.prettyException e
    errorWhenLeft (Right pc) = pure pc

data LoadTomlException = LoadTomlException FilePath Text

instance Show.Show LoadTomlException where
    show (LoadTomlException filePath msg) = "Couldnt parse file " ++ filePath ++ ": " ++ show msg

instance Exception LoadTomlException
