{-# LANGUAGE TemplateHaskell, QuasiQuotes #-}
module Import where

import Yesod
import Yesod.Static


pRoutes = [parseRoutes|
  / MainR GET
  /register RegR GET POST
  /role RoleR GET
  /player/#PlayerId PlayerR GET 
  /player/#PlayerId/delete PlayerDelR GET
  /champion ChampR GET
  /list ListR GET
  /crole CRoleR GET POST
  /login LogR GET POST
  /logout LogoutR GET
--  /favicon.ico FaviconR GET

|]