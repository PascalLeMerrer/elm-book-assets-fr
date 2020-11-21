module Spaceship exposing (Model, height, init, moveToY, update, view)

import Playground exposing (Computer, Shape, image, move)


height =
    94


width =
    100


speed =
    5


type alias Model =
    { x : Float
    , y : Float
    }


init =
    { x = 0
    , y = 0
    }


moveToY : Float -> Model -> Model
moveToY y spaceship =
    { spaceship | y = y }


leftMargin computer =
    computer.screen.left + width / 2


rightMargin computer =
    computer.screen.right - width / 2


view : Model -> Shape
view model =
    image width height "http://localhost:9000/captain/spaceship.png"
        |> move model.x model.y


update : Computer -> Model -> Model
update computer model =
    if computer.keyboard.left then
        moveLeft computer model

    else if computer.keyboard.right then
        moveRight computer model

    else
        model


moveLeft : Computer -> Model -> Model
moveLeft computer spaceship =
    if spaceship.x > leftMargin computer then
        { spaceship | x = spaceship.x - speed }

    else
        spaceship


moveRight : Computer -> Model -> Model
moveRight computer spaceship =
    if spaceship.x < rightMargin computer then
        { spaceship | x = spaceship.x + speed }

    else
        spaceship
