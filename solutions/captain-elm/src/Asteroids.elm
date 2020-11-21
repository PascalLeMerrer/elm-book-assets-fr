module Asteroids exposing (..)

import Playground exposing (Shape, image, move)


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
    Asteroid


init =
    { x = 0
    , y = 300
    }


update : Model -> Model
update model =
    { model | y = model.y - speed }


view : Model -> Shape
view model =
    image width height "http://localhost:9000/captain/asteroid.png"
        |> move model.x model.y
