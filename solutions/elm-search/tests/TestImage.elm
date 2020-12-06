module TestImage exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Image exposing (Format(..), filterImages)
import Test exposing (..)


portraitImage1 =
    { height = 200
    , url = "url1"
    , thumbnailUrl = "thumbnailUrl1"
    , width = 100
    }


portraitImage2 =
    { height = 300
    , url = "url2"
    , thumbnailUrl = "thumbnailUrl2"
    , width = 200
    }


landscapeImage1 =
    { height = 300
    , url = "url3"
    , thumbnailUrl = "thumbnailUrl3"
    , width = 500
    }


landscapeImage2 =
    { height = 400
    , url = "url4"
    , thumbnailUrl = "thumbnailUrl4"
    , width = 1000
    }


squareImage =
    { height = 300
    , url = "url5"
    , thumbnailUrl = "thumbnailUrl5"
    , width = 300
    }


allImages =
    [ portraitImage1, portraitImage2, landscapeImage1, landscapeImage2, squareImage ]


suite : Test
suite =
    describe "The Image module"
        [ describe "filterImages"
            [ test "returns all images when format is Any" <|
                \_ ->
                    Expect.equal allImages (filterImages Any allImages)
            , test "returns portrait images when format is Portrait" <|
                \_ ->
                    Expect.equal [ portraitImage1, portraitImage2 ] (filterImages Portrait allImages)
            , test "returns landscape images when format is Landscape" <|
                \_ ->
                    Expect.equal [ landscapeImage1, landscapeImage2 ] (filterImages Landscape allImages)
            ]
        ]
