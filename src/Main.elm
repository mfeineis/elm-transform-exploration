module Main exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Elm.Ast as Ast
import Html
import Url exposing (Url)


type alias Flags =
    {}


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequestedByLink
        , subscriptions = always Sub.none
        , update = \_ m -> ( m, Cmd.none )
        , view = view
        }


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    ( { navKey = navKey
      }
    , Cmd.none
    )


type alias Model =
    { navKey : Navigation.Key
    }


type Msg
    = UrlChanged Url
    | UrlRequestedByLink UrlRequest


view : Model -> Browser.Document Msg
view model =
    let
        code =
            """

module Main exposing (Union(..), some, stuff)

            """
    in
    { title = "Hello World!"
    , body =
        [ Html.pre [] [ Html.text code ]
        , Html.hr [] []
        , Html.text (Ast.toString (Ast.parse code))
        ]
    }
