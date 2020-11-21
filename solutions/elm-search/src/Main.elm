module Main exposing (main)

import Browser
import Html exposing (Html, div, form, h1, input, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onInput, onSubmit)
import Http


type Msg
    = UserChangedInput String
    | UserSubmittedForm
    | ResponseReceived (Result Http.Error String)


type alias Model =
    { searchTerms : String
    , response : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { searchTerms = ""
      , response = ""
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [ class "title" ] [ text "elm image search" ]
        , viewForm
        , viewResponse model
        ]


viewResponse : Model -> Html Msg
viewResponse model =
    text model.response


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserChangedInput value ->
            ( { model | searchTerms = value }
            , Cmd.none
            )

        UserSubmittedForm ->
            let
                httpCommand =
                    Http.get
                        { url = "http://localhost:9000/search/" ++ model.searchTerms
                        , expect = Http.expectString ResponseReceived
                        }
            in
            ( model, httpCommand )

        ResponseReceived (Ok jsonString) ->
            ( { model | response = jsonString }, Cmd.none )

        ResponseReceived (Err _) ->
            ( { model | response = "La communication avec le serveur a échoué." }, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
