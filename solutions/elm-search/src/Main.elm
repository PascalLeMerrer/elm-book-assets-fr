module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, src, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Image exposing (Format(..), Image, imageListDecoder)



{- TYPES DECLARATION -}


type Msg
    = UserChangedFormat String
    | UserChangedInput String
    | UserClickedCloseButton
    | UserSubmittedForm
    | ResponseReceived (Result Http.Error (List Image))


type alias Model =
    { searchTerms : String
    , images : List Image
    , format : Format
    , message : String
    }



{- initialisation of the model -}


init : () -> ( Model, Cmd Msg )
init _ =
    ( { searchTerms = ""
      , images = []
      , format = Any
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

        UserChangedFormat selectedValue ->
            case selectedValue of
                "landscape" ->
                    ( { model | format = Landscape }, Cmd.none )

                "portrait" ->
                    ( { model | format = Portrait }, Cmd.none )

                _ ->
                    ( { model | format = Any }, Cmd.none )



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
        , div [ class "select" ]
            [ select
                [ onInput UserChangedFormat ]
                [ option [ value "any" ] [ text "Tous" ]
                , option [ value "landscape" ] [ text "Paysage" ]
                , option [ value "portrait" ] [ text "Portrait" ]
                ]
            ]
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
        (model.images
            |> filterImages model.format
            |> List.map viewThumbnail
        )


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
