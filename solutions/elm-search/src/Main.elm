module Main exposing (main)

import Html exposing (div, h1, input, text)
import Html.Attributes exposing (class, type_)


view =
    div [ class "container" ]
        [ h1 [ class "title" ] [ text "elm image search" ]
        , input [ type_ "text", class "medium input" ] []
        ]


main =
    view
