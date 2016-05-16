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
port updateArchivedIssues : (List Int, Int) -> Cmd msg

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
  , githubIssues : Dict Int Github.Issue
  , archivedGithubIssues : List Int
  , httpError : Maybe Http.Error
  }

type alias Flags =
  { configuration : Configuration
  , archivedIssues : List Int
  }

init : Flags -> (Model, Cmd Msg)
init { configuration, archivedIssues } =
    ({ configuration = configuration
     , githubIssues = Dict.empty
     , archivedGithubIssues = archivedIssues
     , httpError = Nothing
    }, loadEverything configuration
   )

view : Model -> Html Msg
view model =
  div []
    [ renderTitleBar
    , div [ class "container" ]
          [ model.githubIssues
              |> Dict.values
              |> List.filter (\x -> not <| List.member x.id model.archivedGithubIssues)
              |> renderGithubIssues
           ]
    ]

renderTitleBar : Html Msg
renderTitleBar =
  div [ class "title-bar" ]
      [ h1 [] [ text "Rhubarb" ] ]

renderGithubIssues : List Github.Issue -> Html Msg
renderGithubIssues issues =
  div [ class "github-issues" ]
      <| List.reverse <| List.map renderGithubIssue <| List.sortBy getDateFromIssue issues

getDateFromIssue : Github.Issue -> Float
getDateFromIssue issue =
  case Date.fromString issue.updated_at of
    Ok(date) -> Date.toTime date |> Time.inSeconds
    Err(_) -> 0

renderGithubIssue : Github.Issue -> Html Msg
renderGithubIssue issue =
  div [ class "github-issues-row" ]
      [ div [ class "github-issues-row-item" ]
            [ a [ attribute "href" issue.html_url, attribute "target" "_blank" ] [ text issue.title ]
            , div [ class "github-issues-row-item-description" ]
                  [ div [ class "github-issues-row-item-description-icon" ] []
                  , div []
                        [ i [] [ text issue.repositoryName ]
                        , text (" by " ++ issue.user.login)
                        ]
                  ]
            ]
      , div [ class "github-issues-row-archive" ]
            [ a [ attribute "href" "#" ]
                [ button [ onClick <| ArchiveGithubIssue issue.id ] [] ]
            ]
       ]

type Msg = Noop
         | LoadGithubIssues
         | LoadedGithubIssues (List Github.Issue)
         | LoadFailed Http.Error
         | Update
         | ArchiveGithubIssue Int

update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    Noop -> (model, Cmd.none)
    LoadedGithubIssues issues ->
      let
        newIssues = Dict.fromList <| List.map (\x -> (x.id, x)) issues
        nextIssues = Dict.union model.githubIssues newIssues
      in
        ({ model | githubIssues = nextIssues }, Cmd.none)
    LoadFailed error -> ({ model | httpError = Just error }, Cmd.none)
    Update -> (model, (loadEverything model.configuration))
    ArchiveGithubIssue issueId ->
      let
        archivedGithubIssues = model.archivedGithubIssues
        alreadyArchived = List.member issueId model.archivedGithubIssues
        appendIssue = if alreadyArchived then [] else [issueId]
        nextArchivedIssues = List.append archivedGithubIssues appendIssue
        issuesLeft = numberOfIssuesLeft model
      in
        ({ model | archivedGithubIssues = nextArchivedIssues },
         updateArchivedIssues (nextArchivedIssues, issuesLeft))
    _ -> (model, Cmd.none)

numberOfIssuesLeft : Model -> Int
numberOfIssuesLeft model =
  let
    numberOfIssues = Dict.size model.githubIssues
    numberOfArchivedIssues = List.length model.archivedGithubIssues
  in
    numberOfIssues - numberOfArchivedIssues - 1

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every minute (always Update)

loadEverything : Configuration -> Cmd Msg
loadEverything configuration =
  let
    accessToken = configuration.accessTokens.github
  in
    Cmd.batch <| List.map (loadGithubIssues accessToken) configuration.projects

loadGithubIssues : String -> Project -> Cmd Msg
loadGithubIssues accessToken project =
  let
    url = Github.getIssuesForRepository accessToken project.githubRepository
  in
    Task.perform LoadFailed LoadedGithubIssues (Http.get (Github.decodeIssues project.name) url)
