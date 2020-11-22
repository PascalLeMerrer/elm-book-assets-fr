module Asteroids exposing (..)

import Playground exposing (Computer, Shape, group, image, move)


type alias Asteroid =
    { x : Float
    , y : Float
    }


height =
    92


width =
    89


speed =
    3


{-| The number of ticks between two asteroid apparitions
-}
intervalBetweenAsteroids =
    200


type alias Model =
    List Asteroid


init =
    []


update : Computer -> Model -> Model
update computer model =
    List.map updateAsteroid model
        |> List.filter (\asteroid -> asteroid.y > computer.screen.bottom)


updateAsteroid : Asteroid -> Asteroid
updateAsteroid asteroid =
    { asteroid | y = asteroid.y - speed }


{-| Adds a new asteroid at a pseudo-random place on top of the screen, at regular time intervals
-}
spawn : Computer -> Int -> Int -> Model -> Model
spawn computer ticks seed model =
    if modBy intervalBetweenAsteroids ticks == 0 then
        let
            x =
                (cos <| toFloat ticks * toFloat seed)
                    * (computer.screen.width / 2 - width * 2)
                    + width

            y =
                computer.screen.top - height

            newAsteroid =
                { x = x
                , y = y
                }
        in
        newAsteroid :: model

    else
        model


view : Model -> Shape
view model =
    group <|
        List.map viewAsteroid model


viewAsteroid : Asteroid -> Shape
viewAsteroid asteroid =
    image width height "http://localhost:9000/captain/asteroid.png"
        |> move asteroid.x asteroid.y
