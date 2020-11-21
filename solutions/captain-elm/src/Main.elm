module Main exposing (main)

import Playground exposing (..)
import Spaceship


type State
    = Home
    | Playing


type alias Model =
    { state : State
    , spaceship : Spaceship.Model
    }


withSpaceship : Spaceship.Model -> Model -> Model
withSpaceship spaceship model =
    { model | spaceship = spaceship }


init : Model
init =
    { state = Home
    , spaceship = Spaceship.init
    }



-- UPDATE --


update : Computer -> Model -> Model
update computer model =
    let
        updatedSpaceship =
            Spaceship.update computer model.spaceship
    in
    model
        |> withSpaceship updatedSpaceship
        |> updateGameState computer


updateGameState : Computer -> Model -> Model
updateGameState computer model =
    case model.state of
        Home ->
            if computer.mouse.click then
                let
                    spaceshipNewY =
                        computer.screen.bottom + Spaceship.height / 2
                in
                { model
                    | state = Playing
                    , spaceship =
                        model.spaceship
                            |> Spaceship.moveToY spaceshipNewY
                }

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
            [ viewBackground computer
            , Spaceship.view model.spaceship
            ]


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
