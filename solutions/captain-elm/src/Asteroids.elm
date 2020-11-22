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


type alias Model =
    List Asteroid


init =
    [ { x = 0
      , y = 300
      }
    , { x = 200
      , y = 300
      }
    ]


update : Computer -> Model -> Model
update computer model =
    List.map updateAsteroid model
        |> List.filter (\asteroid -> asteroid.y > computer.screen.bottom)


updateAsteroid : Asteroid -> Asteroid
updateAsteroid asteroid =
    { asteroid | y = asteroid.y - speed }


view : Model -> Shape
view model =
    group <|
        List.map viewAsteroid model


viewAsteroid : Asteroid -> Shape
viewAsteroid asteroid =
    image width height "http://localhost:9000/captain/asteroid.png"
        |> move asteroid.x asteroid.y
