module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onInput)



{- TYPES DECLARATION -}


type Msg
    = UserChangedInput String


type alias Model =
    String



{- initialisation of the model -}


initialModel : Model
initialModel =
    ""



{- MAIN FUNCTION -}


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }



{- UPDATE -}


update : Msg -> Model -> Model
update msg model =
    case msg of
        UserChangedInput value ->
            value



{- VIEW -}


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
