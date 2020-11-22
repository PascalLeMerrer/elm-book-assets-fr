module Main exposing (main)

import Asteroids
import Playground exposing (..)
import Spaceship


type State
    = Home
    | Playing


type alias Model =
    { state : State
    , spaceship : Spaceship.Model
    , asteroids : Asteroids.Model
    , ticks : Int
    , seed : Int
    }


withSpaceship : Spaceship.Model -> Model -> Model
withSpaceship spaceship model =
    { model | spaceship = spaceship }


withAsteroids : Asteroids.Model -> Model -> Model
withAsteroids asteroids model =
    { model | asteroids = asteroids }


withState : State -> Model -> Model
withState state model =
    { model | state = state }


withSeed : Int -> Model -> Model
withSeed seed model =
    { model | seed = seed }


withNextTick : Model -> Model
withNextTick model =
    { model | ticks = model.ticks + 1 }


init : Model
init =
    { state = Home
    , spaceship = Spaceship.init
    , asteroids = Asteroids.init
    , ticks = 0
    , seed = 0
    }



-- UPDATE --


update : Computer -> Model -> Model
update computer model =
    let
        updatedSpaceship =
            Spaceship.update computer model.spaceship

        updatedAsteroids =
            Asteroids.update computer model.asteroids
                |> Asteroids.spawn computer model.ticks model.seed
    in
    model
        |> withSpaceship updatedSpaceship
        |> withAsteroids updatedAsteroids
        |> updateGameState computer


updateGameState : Computer -> Model -> Model
updateGameState computer model =
    case model.state of
        Home ->
            if computer.mouse.click then
                let
                    spaceshipNewY =
                        computer.screen.bottom + Spaceship.height / 2

                    randomValue =
                        computer.mouse.x * computer.mouse.y * toFloat model.ticks |> round
                in
                { model
                    | state = Playing
                    , spaceship =
                        model.spaceship
                            |> Spaceship.moveToY spaceshipNewY
                    , seed = randomValue
                }
                    |> withNextTick

            else
                model |> withNextTick

        _ ->
            model |> withNextTick



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
            , Asteroids.view model.asteroids
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
