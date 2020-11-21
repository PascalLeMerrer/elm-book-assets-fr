module Main exposing (main)

import Playground exposing (..)


type State
    = Home
    | Playing


type alias Model =
    { state : State
    }


init : Model
init =
    { state = Home
    }



-- UPDATE --


update : Computer -> Model -> Model
update computer model =
    updateGameState computer model


updateGameState : Computer -> Model -> Model
updateGameState computer model =
    case model.state of
        Home ->
            if computer.mouse.click then
                { model | state = Playing }

            else
                model

        _ ->
            model



-- VIEW --


view : Computer -> Model -> List Shape
view computer model =
    case model.state of
        Home ->
            [ viewBackground computer
            , viewTitle
            , viewSubtitle
            ]

        Playing ->
            [ viewBackground computer ]


viewBackground : Computer -> Shape
viewBackground computer =
    group
        [ rectangle black computer.screen.width computer.screen.height
        , image computer.screen.width
            computer.screen.height
            "http://localhost:9000/captain/starfield.png"
        ]


viewTitle : Shape
viewTitle =
    words white "Captain Elm et les astéroïdes de la mort"
        |> scale 3


viewSubtitle : Shape
viewSubtitle =
    words lightGrey "Cliquez pour démarrer la partie"
        |> moveDown 100


main =
    game view update init
