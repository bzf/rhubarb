port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html
import Html.Events exposing (onClick)
import List
import Date
import Dict exposing (Dict)
import String
import Time exposing (minute)

import Http
import Task
import Json.Decode as Json

import Github

-- Ports
port updateBadgeCount : (Int) -> Cmd msg

type alias AccessTokens =
  { github : String
  }

type alias Project =
  { name : String
  , githubRepository : String
  }

type alias Configuration =
  { accessTokens : AccessTokens
  , projects : List Project
  }

main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Model =
  { configuration : Configuration
  , notifications : List Github.Notification
  , httpError : Maybe Http.Error
  }

init : Configuration -> (Model, Cmd Msg)
init configuration =
    ({ configuration = configuration
     , notifications = []
     , httpError = Nothing
    }, (loadGithubNotifications configuration.accessTokens.github)
   )

view : Model -> Html Msg
view model =
  div []
    [ renderTitleBar
    , div [ class "container" ]
          [ renderGithubNotifications model.notifications ]
    ]

renderTitleBar : Html Msg
renderTitleBar =
  div [ class "title-bar" ]
      [ h1 [] [ text "Rhubarb" ] ]

renderGithubNotifications : List Github.Notification -> Html Msg
renderGithubNotifications notifications =
  div [ class "github-notifications" ]
      [ div [] <| List.map renderGithubNotification notifications
      ]

renderGithubNotification : Github.Notification -> Html Msg
renderGithubNotification notification =
  div [ class "github-notifications-row" ]
      [ div [ class "github-notifications-row-item" ]
            [ a [ attribute "href" notification.repository.html_url, attribute "target" "_blank" ]
                [ text notification.subject.title ]
            , div [ class "github-notifications-row-item-description" ]
                  [ div [ class "github-notifications-row-item-description-icon" ] []
                  , i [] [ text notification.repository.full_name ]
                  ]
            ]
      , div [ class "github-notifications-row-archive" ]
            [ a [ attribute "href" "#" ]
                [ button [ onClick (MarkNotification notification) ] [] ]
            ]
      ]

type Msg = Noop Int
         | LoadedGithubNotifications (List Github.Notification)
         | MarkNotification Github.Notification
         | SuccessfullyReadNotification Http.Response
         | LoadFailed Http.Error
         | LoadError Http.RawError
         | Update

update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    Noop _ -> (model, Cmd.none)
    LoadedGithubNotifications notifications ->
      ({ model | notifications = notifications },
       (updateBadgeCount <| List.length notifications))
    MarkNotification notification ->
      let
        accessToken = model.configuration.accessTokens.github
      in
        (model, markGithubNotificationAsRead accessToken notification)
    SuccessfullyReadNotification _ ->
      (model, (loadGithubNotifications model.configuration.accessTokens.github))
    LoadFailed error -> ({ model | httpError = Just error }, Cmd.none)
    LoadError _ -> (model, Cmd.none)
    Update -> (model, (loadGithubNotifications model.configuration.accessTokens.github))

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every minute (always Update)

loadGithubNotifications : String -> Cmd Msg
loadGithubNotifications accessToken =
  let
    url = Github.getNotifications accessToken
  in
    Task.perform LoadFailed LoadedGithubNotifications (Http.get Github.decodeNotifications url)

markGithubNotificationAsRead : String -> Github.Notification -> Cmd Msg
markGithubNotificationAsRead accessToken notification =
  let
    url = Github.markNotificationAsRead accessToken notification
    request = { verb = "PATCH"
              , url = url
              , body = Http.empty
              , headers = []
              }
  in
    Http.send Http.defaultSettings request
      |> Task.perform LoadError SuccessfullyReadNotification
