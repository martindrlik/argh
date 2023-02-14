package main

import (
	"image"
	"time"
)

type Scene struct {
	Time time.Time
	Player
	*World

	IsAnimating bool
	IsQuiting   bool
}

func (scene Scene) Location(position image.Point) Location {
	return scene.Map[position.X][position.Y]
}

func (scene Scene) Cursor() image.Point {
	return scene.Player.State.Current.Position
}
