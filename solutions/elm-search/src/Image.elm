module Image exposing (Format(..), Image, encodeImageList, filterImages, imageDecoder, imageListDecoder)

import Json.Decode as Decode exposing (Decoder, field, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode


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


encodeImageList : List Image -> Json.Encode.Value
encodeImageList images =
    Json.Encode.list encodeImage images


encodeImage : Image -> Json.Encode.Value
encodeImage image =
    Json.Encode.object
        [ ( "thumbnail", Json.Encode.string image.thumbnailUrl )
        , ( "large", Json.Encode.string image.url )
        , ( "width", Json.Encode.int image.width )
        , ( "height", Json.Encode.int image.height )
        ]


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
