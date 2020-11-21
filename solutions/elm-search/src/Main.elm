module Main exposing (main)

import Browser
import Html exposing (Html, div, h1, input, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onInput)


type Msg
    = UserChangedInput String


type alias Model =
    String


initialModel : Model
initialModel =
    ""


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [ class "title" ] [ text "elm image search" ]
        , input
            [ type_ "text"
            , class "medium input"
            , onInput UserChangedInput
            ]
            []
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        UserChangedInput value ->
            value


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
