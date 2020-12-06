module Image exposing (Format(..), Image, filterImages, imageListDecoder)

import Json.Decode as Decode exposing (Decoder, field, int, list, string)
import Json.Decode.Pipeline exposing (required)


type alias Image =
    { thumbnailUrl : String
    , url : String
    , width : Int
    , height : Int
    }


type Format
    = Portrait
    | Landscape
    | Any


imageDecoder : Decoder Image
imageDecoder =
    Decode.succeed Image
        |> required "thumbnail" string
        |> required "large" string
        |> required "width" int
        |> required "height" int


imageListDecoder : Decoder (List Image)
imageListDecoder =
    field "results" (list imageDecoder)


filterImages : Format -> List Image -> List Image
filterImages format images =
    List.filter (hasFormat format) images


hasFormat : Format -> Image -> Bool
hasFormat format image =
    case format of
        Portrait ->
            image.height > image.width

        Landscape ->
            image.width > image.height

        Any ->
            True
