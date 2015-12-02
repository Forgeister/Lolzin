{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}


module Main where

import           Control.Applicative
import           Control.Monad.Logger        (runStdoutLoggingT)
import           Data.Text
import           Database.Persist.Postgresql
import           DBAuth
import           Import
import           Text.Lucius
import           Yesod
import           Yesod.Static





mkYesodDispatch "Lolzin" pRoutes



formRole :: Form Role
formRole = renderDivs $ Role <$>
             areq textField FieldSettings{
                 fsId = Just("name"),
                 fsLabel = "",--Role name
                 fsTooltip = Nothing,
                 fsName = Just ("name"),
                 fsAttrs = [("placeholder","Role name")]
             } Nothing
formPlayer :: Form Player
formPlayer = renderDivs $ Player <$>
             areq textField FieldSettings{
                 fsId = Just("name"),
                 fsLabel = "",--Name
                 fsTooltip = Nothing,
                 fsName = Just ("name"),
                 fsAttrs = [("placeholder","Name")]
             } Nothing <*>
             areq textField FieldSettings{
                 fsId = Just("champ"),
                 fsLabel = "",--Champ
                 fsTooltip = Nothing,
                 fsName = Just ("champ"),
                 fsAttrs = [("placeholder","Champ")]
             } Nothing <*>
             areq (selectField roleK) FieldSettings{
                 fsId = Just("role"),
                 fsLabel = "",--Role
                 fsTooltip = Nothing,
                 fsName = Just ("role"),
                 fsAttrs = [("placeholder","Role")]
             } Nothing

roleK = do
        role <- runDB $ selectList [RoleName ==. "Role"] []
        entities <- runDB $ selectList [] [Asc RoleName]
        optionsPairs $ Prelude.map (\en -> (roleName $ entityVal en, entityKey en)) (role++entities)

widgetForm :: Enctype -> Widget -> Widget
widgetForm enctype widget = do
            setTitle "Register"
            toWidgetHead [hamlet|<link rel="shortcut icon" src="favicon.ico">|]
            [whamlet|
            ^{myCSS}
            <h1>
                Register your stuff
          <br />!! Role is purely aesthetic, after all who cares? !!
            <h2><form method=post action=@{RegR} enctype=#{enctype}>
                ^{widget}
                <input type="submit" value="Send">
            <br />
            <h2><a href=@{MainR}>Main
|]

widgetLog :: Enctype -> Widget -> Widget
widgetLog enctype widget = do
            setTitle "Login"
            toWidgetHead [hamlet|<link rel="shortcut icon" src="favicon.ico">|]
            [whamlet|
            ^{myCSS}
            <h1>
                Login
            <h2><form method=post action=@{LogR} enctype=#{enctype}>
                ^{widget}
                <input type="submit" value="Login">
            <br />
            <h2><a href=@{MainR}>Main
|]

widgetFormR :: Enctype -> Widget -> Widget
widgetFormR enctype widget = do
            setTitle "Add Role"
            toWidgetHead [hamlet|<link rel="shortcut icon" src="favicon.ico">|]
            mu <- lookupSession "_ID"
            [whamlet|
            ^{myCSS}
                $maybe m <- mu
                 <h1> Welcome #{m}
                <br />
                <h2>Register here a new role<br />
            <h2><form method=post action=@{CRoleR} enctype=#{enctype}>
                ^{widget}
                <input type="submit" value="Send">
            <br />
            <h2><a href=@{MainR}>Main
|]



getCRoleR :: Handler Html
getCRoleR = do
             (widget, enctype) <- generateFormPost formRole
             defaultLayout $ widgetFormR enctype widget

postCRoleR :: Handler Html
postCRoleR = do
                ((result, _), _) <- runFormPost formRole
                case result of
                    FormSuccess role -> do
                       runDB $ insert role
                       defaultLayout [whamlet|
                            ^{myCSS}
                           <h2> #{roleName role} successfully registered.
                           <br />
                           <h2><a href=@{CRoleR}>Back
                       |]
                    _ -> redirect CRoleR


getMainR :: Handler Html
getMainR = defaultLayout widgetMain

widgetMain :: Widget
widgetMain = do
                setTitle "Lolzin"
                toWidgetHead [hamlet|<link rel="icon" type="image/png" href="/src/favicon.png" sizes="16x16">
                                     <link rel="icon" type="image/png" href="/src/favicon.png" sizes="32x32">
                                     <link rel="favicon" type="favicon" href="/src/favicon.ico">
                                     <link rel="icon" type="icon" href="/src/favicon.ico">      |]
                mu <- lookupSession "_ID"
                case mu of
                    Nothing -> do
                                [whamlet|
                                ^{myCSS}
                                <h1> Welcome to the Lolzin!
                               Please, Login or Register
                                <h4><br /><a href=@{LogR}>Login
                                <h4><a href=@{RegR}>Register
                                |]
                    log -> do
                                [whamlet|
                                ^{myCSS}
                                $maybe m <- mu
                                    <h1> Welcome #{m}
                                <h4><br /><a href=@{LogoutR}>Logout
                                |]
                [whamlet|
                ^{myCSS}

                  <h4><br /><a href=@{ListR}>Players List
                  <h4><br /><a href=@{RoleR}>Roles List
                  <h4><a href=@{ChampR}>Champions List
                  <h4><a href=@{CRoleR}>Add Role (Admin only)
                |]

getLogoutR :: Handler Html
getLogoutR = do
               deleteSession "_ID"
               redirect MainR


getChampR :: Handler Html
getChampR = defaultLayout widgetChamp

widgetChamp :: Widget
widgetChamp = do
    setTitle "Champions"
    toWidgetHead [hamlet|<link rel="shortcut icon" src="favicon.ico">|]
    [whamlet|
^{myCSS}
<h1>Champions

    <h4>Annie
    <h4>Azir
    <h4>Darius
    <h4>Draven
    <h4>Garen
    <h4>Gangplank
    <h4>Katarina
    <h4>Kha'zix
    <h4>LeBlanc
    <h4>Lee Sin
    <h4>Mordekaiser
    <h4>Nasus
    <h4>Renekton
    <h4>Singer
    <h4>Thresh
    <h4>Vi
    <h4>Volibear
    <h4>Yasuo
    <h4>Zed
<br />
<h2><a href=@{MainR}>Main
|]



getRegR :: Handler Html
getRegR = do
             (widget, enctype) <- generateFormPost formPlayer
             defaultLayout $ widgetForm enctype widget

postRegR :: Handler Html
postRegR = do
                ((result, _), _) <- runFormPost formPlayer
                case result of
                    FormSuccess player -> do
                       runDB $ insert player
                       defaultLayout [whamlet|
                            ^{myCSS}
                           <h2> #{playerName player} successfully registered.
                           <br />
                           <h2><a href=@{RegR}>Back
                       |]
                    _ -> redirect RegR

getLogR :: Handler Html
getLogR = do
             (widget, enctype) <- generateFormPost formPlayer
             defaultLayout $ widgetLog enctype widget

postLogR :: Handler Html
postLogR = do
    ((result,_),_) <- runFormPost formPlayer
    case result of
        FormSuccess play -> do
            player <- runDB $ selectFirst [PlayerName ==. playerName play, PlayerChamp ==. playerChamp play ] []
            case player of
                Just (Entity uid play) -> do
                    setSession "_ID" (playerName play)
                    redirect MainR
                Nothing -> do
                    setMessage $ [shamlet| Invalid user |]
                    redirect LogR
        _ -> redirect LogR



getPlayerR :: PlayerId -> Handler Html
getPlayerR pid = do
             mu <- lookupSession "_ID"
             player <- runDB $ get404 pid
             play <- runDB $ selectList [PlayerName ==. playerName player] []
             role <- runDB $ get $ playerRole player
             case mu of _
                         | (Just "admin")==mu -> do
                                                  defaultLayout $ do
                                                    setTitle "Player"
                                                    toWidgetHead [hamlet|<link rel="shortcut icon" src="favicon.ico">|]
                                                    [whamlet|
                                                    ^{myCSS}
                                                    <h1> #{playerName player}
                                                    <h2><br /> The Player "#{playerName player}"
                                                    <h2> Favorite Champion is "#{playerChamp player}"
                                                    <h2> Playing in the role of #{show $ fmap roleName role}
                                                    <br />
                                                    <h2><a href=@{PlayerDelR pid}>Delete
                                                    <br />
                                                    <h2><a href=@{ListR}>Players List
                                                |]
                         | Just (playerName player) == mu  -> do
                                                 defaultLayout $ do
                                                    setTitle "Player"
                                                    toWidgetHead [hamlet|<link rel="shortcut icon" src="favicon.ico">|]
                                                    [whamlet|
                                                    ^{myCSS}
                                                    <h1> #{playerName player}
                                                    <h2><br /> The Player "#{playerName player}"
                                                    <h2> Favorite Champion is "#{playerChamp player}"
                                                    <h2> Playing in the role of #{show $ fmap roleName role}
                                                    <br />
                                                    <h2><a href=@{PlayerDelR pid}>Delete
                                                    <br />
                                                    <h2><a href=@{ListR}>Players List
                                                |]
                         | otherwise -> do
                                                defaultLayout $ do
                                                    setTitle "Player"
                                                    toWidgetHead [hamlet|<link rel="shortcut icon" src="favicon.ico">|]
                                                    [whamlet|
                                                    ^{myCSS}
                                                    <h1> #{playerName player}
                                                    <h2><br /> The Player "#{playerName player}"
                                                    <h2> Favorite Champion is "#{playerChamp player}"
                                                    <h2> Playing in the role of #{show $ fmap roleName role}
                                                    <br />
                                                    <h2><a href=@{ListR}>Players List
                                                |]

getPlayerDelR :: PlayerId -> Handler Html
getPlayerDelR pid = do
                 player <- runDB $ get404 pid
                 runDB $ delete $ pid
                 mu <- lookupSession "_ID"
                 case mu of
                     Just "admin" -> redirect ListR
                     Just _ -> do deleteSession "_ID"
                                  redirect MainR


getRoleR :: Handler Html
getRoleR = defaultLayout widgetRole

widgetRole :: Widget
widgetRole = do
            setTitle "Roles"
            toWidgetHead [hamlet|<link rel="shortcut icon" src="favicon.ico">|]
            [whamlet|
            ^{myCSS}
            <h1>Roles
                <h4>The usual roles are:
                <h4>Marksman
                <h4>Bruiser
                <h4>Tank
                <h4>Assassin
                <h4>Mage
                <h4>Support
            <br />
            <h2><a href=@{MainR}>Main
            |]

getListR :: Handler Html
getListR = do
             listP <- runDB $ selectList [PlayerName !=. "admin"] [Asc PlayerName]
             defaultLayout $ do
                 setTitle "List of Players"
                 toWidgetHead [hamlet|<link rel="shortcut icon" src="favicon.ico">|]
                 [whamlet|
                    ^{myCSS}
                 <h1> Players registered:
                 $forall Entity pid player <- listP
                    <h4><a href=@{PlayerR pid}> #{playerName player} <br />
             <br /><h2><a href=@{MainR}>Main

|]


        
myCSS =
    [lucius|
        input {
            position: relative;
            z-index: 1;
        }
        body {
            background-color: #000;
            color: #F00;
            text-align: center;
        }
        a {
            color: #F00;
        }
        h1 {
            color: #F00;
        }
        h4 {
            color: #F00;
            font-family: Verdana, Geneva, sans-serif;
            font-size: 12px;
            font-style: normal;
        }
        h2 {
            color: #F00;
            font-family: Verdana, Geneva, sans-serif;
            font-size: 14px;
            font-style: normal;
        }
    |]

connStr = "dbname=d6s1dno3olno9i host=ec2-54-83-53-120.compute-1.amazonaws.com user=omrkjkdpcceiqe password=4QhnscuCCZHWuJt8z8f15SQLPv port=5432"
--db heroku.com

main::IO()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
       runSqlPersistMPool (runMigration migrateAll) pool
       s <- static "."
       warpEnv (Lolzin pool s)
--warp 8080 (Lolzin pool)
