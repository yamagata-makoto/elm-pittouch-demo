port module Main exposing (..)

import State exposing (State)
import Tuple
import Browser
import Time
import Result
import Http exposing (Response, Expect)
import TimeZone
import Xml.Decode as XD
import Html exposing (Html, text, div, p, span)
import Html.Attributes exposing (id, class)


-- Port: JS -> Elm
port touchEvent         : (String -> msg) -> Sub msg


type Msg
  = Tick Time.Posix
  | TouchEvent String
  | SettingLoaded (Result Http.Error Setting)


-- Application Model
type alias Model =
  { time : Time.Posix
  , zone : Time.Zone
  , ver  : String
  , idm  : String
  , name : String
  }


type alias Setting =
  { name : String
  }

type alias Flags =
  { ver : String
  }


-- MAIN
main =
  Browser.element
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


-- FUNCTIONS
init : Flags -> (Model, Cmd Msg)
init flags =
  ( initialModel flags
  , getProviderSetting SettingLoaded 
  )


initialModel : Flags -> Model
initialModel flags =
  { time = Time.millisToPosix 0
  , zone = TimeZone.asia__tokyo ()
  , ver = flags.ver
  , idm  = ""
  , name = ""
  }


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Time.every 1000 Tick
    , touchEvent TouchEvent
    ]


-- UPDATE
update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    TouchEvent arg    -> doTouchEvent model arg
    Tick arg          -> doTick model arg
    SettingLoaded arg -> doSettingLoaded model arg


-- VIEW
view : Model -> Html Msg
view model =
  div [ id "body" ]
    [ div [] [ p [] [ text <| model.ver ] ]
    , div [] [ p [] [ text <| formatDate model ] ]
    , div [] [ p [] [ text <| formatTime model ] ]
    , div [] [ p [] [ text <| model.idm ] ]
    ]


-- VIEW HELPER
monthToInt : Time.Month -> Int
monthToInt month =
    case month of
        Time.Jan -> 1
        Time.Feb -> 2
        Time.Mar -> 3
        Time.Apr -> 4
        Time.May -> 5
        Time.Jun -> 6
        Time.Jul -> 7
        Time.Aug -> 8
        Time.Sep -> 9
        Time.Oct -> 10
        Time.Nov -> 11
        Time.Dec -> 12


formatInt2 : Int -> String
formatInt2 n =
  String.padLeft 2 '0' (String.fromInt n)


formatInt3 : Int -> String
formatInt3 n =
  String.padLeft 3 '0' (String.fromInt n)


formatDate : Model -> String
formatDate model =
  [Time.toYear, \zone t -> (Time.toMonth zone >> monthToInt) t, Time.toDay]
    |> List.map (\f -> f model.zone model.time)
    |> List.map formatInt2
    |> String.join "/"


formatTime : Model -> String
formatTime model =
  [Time.toHour, Time.toMinute]
    |> List.map (\f -> f model.zone model.time)
    |> List.map formatInt2
    |> String.join ":"


-- EVENT FUNCTION
doTick : Model -> Time.Posix -> (Model, Cmd Msg)
doTick model newTime =
  ( { model | time = newTime }
    , Cmd.none
  )


doTouchEvent : Model -> String -> (Model, Cmd Msg)
doTouchEvent model idm =
  ( { model | idm = idm }
    , Cmd.none
  )


doSettingLoaded : Model -> (Result Http.Error Setting) -> (Model, Cmd Msg)
doSettingLoaded model result =
  case result of
    Ok setting ->
      ( { model | name = setting.name } 
        , Cmd.none
      )
    _ ->
      ( model, Cmd.none )


{-| -}
expectXml : (Result Http.Error a -> msg) -> XD.Decoder a -> Expect msg
expectXml toMsg decoder =
  let
    resolve :
      (body -> Result String a) -> Response body -> Result Http.Error a
    resolve toResult response =
      case response of
        Http.GoodStatus_ _ body -> Result.mapError Http.BadBody (toResult body)
        Http.BadUrl_ url        -> Err (Http.BadUrl url)
        Http.Timeout_           -> Err Http.Timeout
        Http.NetworkError_      -> Err Http.NetworkError
        Http.BadStatus_ meta _  -> Err (Http.BadStatus meta.statusCode)
  in
  Http.expectStringResponse toMsg <|
    resolve <| \a -> XD.decodeString decoder a


settingDecoder : XD.Decoder Setting
settingDecoder =
  XD.map Setting
      (XD.path [ "name" ] (XD.single XD.string))


getProviderSetting : (Result Http.Error Setting -> Msg) -> Cmd Msg
getProviderSetting toMsg =
  Http.get
    { url = "http://localhost/providersetting.xml"
    , expect = expectXml toMsg settingDecoder
    }
