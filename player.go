package main

import "image"

type Player struct {
	State AnimationState[PlayerState]
}

type PlayerState struct {
	Position image.Point
}

func (p Player) Update() (Player, bool) {
	if p.State.Current == p.State.Desired {
		return p, false
	}
	if p.State.Current.Position.X > p.State.Desired.Position.X {
		p.State.Current.Position.X--
	} else if p.State.Current.Position.X < p.State.Desired.Position.X {
		p.State.Current.Position.X++
	}
	if p.State.Current.Position.Y > p.State.Desired.Position.Y {
		p.State.Current.Position.Y--
	} else if p.State.Current.Position.Y < p.State.Desired.Position.Y {
		p.State.Current.Position.Y++
	}
	return p, true
}
