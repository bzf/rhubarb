module Github exposing (getNotifications, markNotificationAsRead, decodeNotifications, Notification, User)

import Http
import Json.Decode exposing (Decoder, list, maybe, int, string, bool)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Task

-- Functions
getNotifications : String -> String
getNotifications accessToken =
  "http://api.github.com/notifications?access_token=" ++ accessToken

-- https://developer.github.com/v3/activity/notifications/#mark-a-thread-as-read
markNotificationAsRead : String -> Notification -> String
markNotificationAsRead accessToken notification =
  let
    threadId = notification.id
  in
    "http://api.github.com/notifications/threads/" ++ threadId ++ "?access_token=" ++ accessToken


-- Parsers
decodeUser : Decoder User
decodeUser =
  decode User
    |> required "login" string
    |> required "id" int
    |> required "avatar_url" string
    |> required "url" string

decodeNotifications : Decoder (List Notification)
decodeNotifications =
  list <| decodeNotification

decodeNotification : Decoder Notification
decodeNotification =
  decode Notification
    |> required "id" string
    |> required "repository" decodeRepository
    |> required "subject" decodeSubject
    |> required "reason" string
    |> required "unread" bool
    |> required "updated_at" string
    |> required "last_read_at" (maybe string)
    |> required "url" string

decodeRepository : Decoder Repository
decodeRepository =
  decode Repository
    |> required "id" int
    |> required "owner" decodeUser
    |> required "name" string
    |> required "full_name" string
    |> required "description" string
    |> required "private" bool
    |> required "fork" bool
    |> required "url" string
    |> required "html_url" string

decodeSubject : Decoder Subject
decodeSubject =
  decode Subject
    |> required "title" string
    |> required "url" string
    |> required "latest_comment_url" (maybe string)

-- Types
type alias User =
  { login : String
  , id : Int
  , avatar_url : String
  , url : String
  }

type alias Repository =
  { id : Int
  , owner : User
  , name : String
  , full_name : String
  , description : String
  , private : Bool
  , fork : Bool
  , url : String
  , html_url : String
  }

type alias Subject =
  { title : String
  , url : String
  , latest_comment_url : Maybe String
  -- , type : String
  }

type alias Notification =
  { id : String
  , repository : Repository
  , subject : Subject
  , reason : String
  , unread : Bool
  , updated_at : String
  , last_read_at : Maybe String
  , url : String
  }
