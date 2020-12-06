module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, src, style, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Image exposing (Image, imageListDecoder)



{- TYPES DECLARATION -}


type Msg
    = UserChangedInput String
    | UserClickedCloseButton
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

        UserClickedCloseButton ->
            ( { model | message = "" }, Cmd.none )

        UserSubmittedForm ->
            let
                httpCommand =
                    Http.get
                        { url = "http://localhost:9000/search/" ++ model.searchTerms
                        , expect = Http.expectJson ResponseReceived imageListDecoder
                        }
            in
            ( { model | message = "" }, httpCommand )

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
        , viewMessage model
        , viewResults model
        ]


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


viewMessage : Model -> Html Msg
viewMessage model =
    if model.message /= "" then
        div
            [ class "notification is-danger"
            , style "margin-top" "20px"
            ]
            [ button
                [ class "delete"
                , onClick UserClickedCloseButton
                ]
                []
            , text model.message
            ]

    else
        text ""


viewResults : Model -> Html Msg
viewResults model =
    div
        [ class "columns is-multiline"
        , style "margin-top" "20px"
        ]
        (List.map viewThumbnail model.images)


viewThumbnail : Image -> Html Msg
viewThumbnail image =
    img
        [ src <| "http://localhost:9000" ++ image.thumbnailUrl
        , class "column is-one-quarter"
        ]
        []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
