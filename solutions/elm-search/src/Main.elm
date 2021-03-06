port module Main exposing (main)

import Browser
import Browser.Dom
import Html exposing (..)
import Html.Attributes exposing (class, id, src, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Icon
import Image exposing (Format(..), Image, encodeImageList, filterImages, imageDecoder, imageListDecoder)
import Json.Decode exposing (list)
import Json.Encode
import Task



{- OUTPUT PORT -}


port saveFavorites : Json.Encode.Value -> Cmd msg



{- INPUT PORT -}


port onFavoritesChanged : (Json.Encode.Value -> msg) -> Sub msg



{- TYPES DECLARATION -}


type Msg
    = AnotherTabModifiedFavorites (List Image)
    | UserChangedFormat String
    | UserChangedInput String
    | UserClickedBackLink
    | UserClickedCloseButton
    | UserClickedLike Image
    | UserClickedThumbnail Image
    | UserSubmittedForm
    | ResponseReceived (Result Http.Error (List Image))
    | NoOp


type alias Model =
    { searchTerms : String
    , images : List Image
    , format : Format
    , message : Notification
    , favorites : List Image
    , selectedImage : Maybe Image
    }


{-| Use custom types to represent the states of the app.
It allows the compiler to check the business logic.
-}
type Notification
    = Error String
    | Info String
    | None



{- initialisation of the model -}


type alias Flags =
    Json.Encode.Value


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        decodedFlags =
            Json.Decode.decodeValue (list imageDecoder) flags

        favorites =
            case decodedFlags of
                Ok images ->
                    images

                Err _ ->
                    []
    in
    ( { searchTerms = ""
      , images = []
      , format = Any
      , message = None
      , favorites = favorites
      , selectedImage = Nothing
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


main : Program Flags Model Msg
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
            ( { model | message = None }, Cmd.none )

        UserSubmittedForm ->
            let
                httpCommand =
                    Http.get
                        { url = "http://localhost:9000/search/" ++ model.searchTerms
                        , expect = Http.expectJson ResponseReceived imageListDecoder
                        }
            in
            ( { model | message = None }, httpCommand )

        ResponseReceived (Ok []) ->
            ( { model
                | images = []
                , message = Info "Aucune image ne correspond à cette recherche."
              }
            , Cmd.none
            )

        ResponseReceived (Ok images) ->
            ( { model | images = images }, Cmd.none )

        ResponseReceived (Err err) ->
            ( { model | message = Error "La communication a échoué." }, Cmd.none )

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

        AnotherTabModifiedFavorites favoriteImages ->
            ( { model | favorites = favoriteImages }
            , Cmd.none
            )

        UserClickedThumbnail image ->
            ( { model | selectedImage = Just image }
            , Cmd.none
            )

        UserClickedBackLink ->
            ( { model | selectedImage = Nothing }
            , Cmd.none
            )


isFavorite : Model -> Image -> Bool
isFavorite model image =
    List.member image model.favorites



{- VIEW -}


view : Model -> Html Msg
view model =
    div [ class "container" ] <|
        case model.selectedImage of
            Just image ->
                [ viewSelectedImage model image ]

            Nothing ->
                viewSearch model


viewSearch : Model -> List (Html Msg)
viewSearch model =
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
        Error errorMessage ->
            viewNotification errorMessage (class "is-danger")

        Info information ->
            viewNotification information (class "is-info")

        None ->
            text ""


{-| Defining the second parameter as an attribute instead
of a class name (i.e. a string) prevents confusions
in parameter order when invoking this function
-}
viewNotification : String -> Attribute Msg -> Html Msg
viewNotification label cssClass =
    div
        [ class "notification"
        , cssClass
        , style "margin-top" "20px"
        ]
        [ button
            [ class "delete"
            , onClick UserClickedCloseButton
            ]
            []
        , text label
        ]


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
            , onClick <| UserClickedThumbnail image
            ]
            []
        , viewHeart model image
        ]


viewSelectedImage : Model -> Image -> Html Msg
viewSelectedImage model image =
    div
        []
        [ div [ class "block" ] [ a [ onClick UserClickedBackLink ] [ text "Retour" ] ]
        , img
            [ src <| "http://localhost:9000" ++ image.url
            ]
            []
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
    onFavoritesChanged decodeModifiedFavorites


decodeModifiedFavorites : Json.Encode.Value -> Msg
decodeModifiedFavorites value =
    let
        decodedList =
            Json.Decode.decodeValue (list imageDecoder) value
    in
    case decodedList of
        Ok images ->
            AnotherTabModifiedFavorites images

        Err error ->
            NoOp
