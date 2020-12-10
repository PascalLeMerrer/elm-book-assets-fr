port module Main exposing (main)

import Browser
import Browser.Dom
import Html exposing (..)
import Html.Attributes exposing (class, id, src, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Icon
import Image exposing (Format(..), Image, encodeImageList, filterImages, imageListDecoder)
import Json.Encode
import Task


port saveFavorites : Json.Encode.Value -> Cmd msg



{- TYPES DECLARATION -}


type Msg
    = UserChangedFormat String
    | UserChangedInput String
    | UserClickedCloseButton
    | UserClickedLike Image
    | UserSubmittedForm
    | ResponseReceived (Result Http.Error (List Image))
    | NoOp


type alias Model =
    { searchTerms : String
    , images : List Image
    , format : Format
    , message : Maybe String
    , favorites : List Image
    }



{- initialisation of the model -}


init : () -> ( Model, Cmd Msg )
init _ =
    ( { searchTerms = ""
      , images = []
      , format = Any
      , message = Nothing
      , favorites = []
      }
    , focusOn inputId
    )


{-| Sets the focus on the element which Id is given,
then emits a NoOp message even if the element was not found
-}
focusOn : String -> Cmd Msg
focusOn elementId =
    Browser.Dom.focus elementId
        |> Task.attempt (\_ -> NoOp)



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
            ( { model | message = Nothing }, Cmd.none )

        UserSubmittedForm ->
            let
                httpCommand =
                    Http.get
                        { url = "http://localhost:9000/search/" ++ model.searchTerms
                        , expect = Http.expectJson ResponseReceived imageListDecoder
                        }
            in
            ( { model | message = Nothing }, httpCommand )

        ResponseReceived (Ok images) ->
            ( { model | images = images }, Cmd.none )

        ResponseReceived (Err err) ->
            ( { model | message = Just "La communication a échoué." }, Cmd.none )

        UserChangedFormat selectedValue ->
            case selectedValue of
                "landscape" ->
                    ( { model | format = Landscape }, Cmd.none )

                "portrait" ->
                    ( { model | format = Portrait }, Cmd.none )

                _ ->
                    ( { model | format = Any }, Cmd.none )

        UserClickedLike imageToToggle ->
            let
                favoriteImages =
                    if isFavorite model imageToToggle then
                        List.filter (\image -> image.url /= imageToToggle.url) model.favorites

                    else
                        imageToToggle :: model.favorites
            in
            ( { model | favorites = favoriteImages }
            , saveFavorites (encodeImageList favoriteImages)
            )

        NoOp ->
            ( model, Cmd.none )


isFavorite : Model -> Image -> Bool
isFavorite model image =
    List.member image model.favorites



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
            , id inputId
            ]
            []
        , div
            [ class "select"
            , style "margin-top" "20px"
            ]
            [ select
                [ onInput UserChangedFormat ]
                [ option [ value "any" ] [ text "Tous" ]
                , option [ value "landscape" ] [ text "Paysage" ]
                , option [ value "portrait" ] [ text "Portrait" ]
                ]
            ]
        ]


inputId =
    "searchInput"


viewMessage : Model -> Html Msg
viewMessage model =
    case model.message of
        Just message ->
            div
                [ class "notification is-danger"
                , style "margin-top" "20px"
                ]
                [ button
                    [ class "delete"
                    , onClick UserClickedCloseButton
                    ]
                    []
                , text message
                ]

        Nothing ->
            text ""


viewResults : Model -> Html Msg
viewResults model =
    div
        [ class "columns is-multiline"
        , style "margin-top" "20px"
        ]
        (model.images
            |> filterImages model.format
            |> List.map (viewThumbnail model)
        )


viewThumbnail : Model -> Image -> Html Msg
viewThumbnail model image =
    div
        [ class "column is-one-quarter" ]
        [ img
            [ src <| "http://localhost:9000" ++ image.thumbnailUrl
            ]
            []
        , viewHeart model image
        ]


viewHeart : Model -> Image -> Html Msg
viewHeart model image =
    span [ onClick (UserClickedLike image) ]
        [ if isFavorite model image then
            Icon.heartFilled

          else
            Icon.heartLine
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
