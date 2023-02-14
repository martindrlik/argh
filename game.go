package main

import (
	"fmt"
	"time"
)

func main() {
	scene := Scene{}
	scene.World = &World{}
	randomMap(&scene.Map)
	input := inputFunc()
	for !scene.IsQuiting {
		if scene.IsAnimating {
			time.Sleep(100 * time.Millisecond)
		} else {
			scene = input(scene)
		}
		scene = update(scene)
		present(scene)
	}
	fmt.Println("Good bye!")
}

func update(scene Scene) Scene {
	scene.IsAnimating = false
	if p, isAnimating := scene.Player.Update(); isAnimating {
		scene.Player = p
		scene.IsAnimating = true
	}
	return scene
}

func present(scene Scene) {
	if scene.IsAnimating {
		fmt.Printf("Player%v\n", scene.Player.State.Current.Position)
	}
}
