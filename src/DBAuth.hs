{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleContexts,
             MultiParamTypeClasses, DeriveDataTypeable,
             GeneralizedNewtypeDeriving, ViewPatterns #-}

module DBAuth where

import Import
import Yesod
import Yesod.Static
import Data.Text
import Database.Persist.Postgresql
    ( ConnectionPool, SqlBackend, runSqlPool, runMigration )
  
data Lolzin = Lolzin { connPool :: ConnectionPool,
                     getStatic :: Static }

staticFiles "."

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Role
    name Text
    deriving Show
Player
   name Text
   champ Text
   role RoleId
   deriving Show
|]

mkYesodData "Lolzin" pRoutes

instance YesodPersist Lolzin where
   type YesodPersistBackend Lolzin = SqlBackend
   runDB f = do 
       master <- getYesod
       let pool = connPool master
       runSqlPool f pool

instance Yesod Lolzin where
    authRoute _ = Just $ MainR
    isAuthorized CRoleR _ = isAdmin
    isAuthorized ListR _ = isUser
    isAuthorized _ _ = return Authorized

isAdmin = do
    mu <- lookupSession "_ID"
    return $ case mu of
        Nothing -> AuthenticationRequired
        Just "admin" -> Authorized
        Just _ -> Unauthorized "Admin only, sorry"

isUser = do
    mu <- lookupSession "_ID"
    return $ case mu of
        Nothing -> AuthenticationRequired 
        Just _ -> Authorized

type Form a = Html -> MForm Handler (FormResult a, Widget)

instance RenderMessage Lolzin FormMessage where
    renderMessage _ _ = defaultFormMessage
