module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onInput, onSubmit)
import Http
import Image exposing (Image, imageListDecoder)



{- TYPES DECLARATION -}


type Msg
    = UserChangedInput String
    | UserSubmittedForm
    | ResponseReceived (Result Http.Error (List Image))


type alias Model =
    { searchTerms : String
    , images : List Image
    , message : String
    }



{- initialisation of the model -}


init : () -> ( Model, Cmd Msg )
init _ =
    ( { searchTerms = ""
      , images = []
      , message = ""
      }
    , Cmd.none
    )



{- MAIN FUNCTION -}


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



{- UPDATE -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserChangedInput value ->
            ( { model | searchTerms = value }, Cmd.none )

        UserSubmittedForm ->
            let
                httpCommand =
                    Http.get
                        { url = "http://localhost:9000/search/" ++ model.searchTerms
                        , expect = Http.expectJson ResponseReceived imageListDecoder
                        }
            in
            ( model, httpCommand )

        ResponseReceived (Ok images) ->
            ( { model | images = images }, Cmd.none )

        ResponseReceived (Err err) ->
            ( { model | message = "La communication a échoué." }, Cmd.none )



{- VIEW -}


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [ class "title" ] [ text "elm image search" ]
        , viewForm
        , viewResponse model
        ]


viewResponse : Model -> Html Msg
viewResponse model =
    text model.message


viewForm : Html Msg
viewForm =
    form [ onSubmit UserSubmittedForm ]
        [ input
            [ type_ "text"
            , class "medium input"
            , onInput UserChangedInput
            ]
            []
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
