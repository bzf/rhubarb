module Github exposing (getIssuesForRepository, decodeIssues, Issue, PullRequest, Label, User)

import Http
import Json.Decode exposing (Decoder, list, maybe, int, string)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Task

-- Functions
getIssuesForRepository : String -> String -> String
getIssuesForRepository accessToken repository =
  "http://api.github.com/repos/" ++ repository ++ "/issues?access_token=" ++ accessToken

-- Parsers
decodeIssues : String -> Decoder (List Issue)
decodeIssues repositoryName =
  list <| decodeIssue repositoryName

decodeIssue : String ->Decoder Issue
decodeIssue repositoryName =
  decode Issue
    |> required "id" int
    |> required "url" string
    |> required "repository_url" string
    |> required "html_url" string
    |> required "state" string
    |> required "title" string
    |> required "user" decodeUser
    |> required "body" string
    |> optional "pull_request" (maybe decodePullRequest) Nothing
    |> required "labels" (list decodeLabel)
    |> required "comments" int
    |> required "created_at" string
    |> required "updated_at" string
    |> hardcoded repositoryName

decodePullRequest : Decoder PullRequest
decodePullRequest =
  decode PullRequest
    |> required "url" string
    |> required "html_url" string
    |> required "diff_url" string
    |> required "patch_url" string

decodeUser : Decoder User
decodeUser =
  decode User
    |> required "login" string
    |> required "id" int
    |> required "avatar_url" string
    |> required "url" string

decodeLabel : Decoder Label
decodeLabel =
  decode Label
    |> required "url" string
    |> required "name" string
    |> required "color" string

-- Types
type alias User =
  { login : String
  , id : Int
  , avatar_url : String
  , url : String
  }

type alias Label =
  { url : String
  , name : String
  , color : String
  }

type alias Issue =
  { id : Int
  , url : String
  , repository_url : String
  , html_url : String
  , state : String
  , title : String
  , user : User
  , body : String
  , pull_request : Maybe PullRequest
  , labels : List Label
  , comments : Int
  , created_at : String
  , updated_at : String
  , repositoryName : String
}

type alias PullRequest =
  { url : String
  , html_url : String
  , diff_url : String
  , patch_url : String
  }
