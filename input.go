package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func inputFunc() func(Scene) Scene {
	scanner := bufio.NewScanner(os.Stdin)
	ns := Stack[int]{}
	ss := Stack[string]{}
	var fields []string
	return func(scene Scene) Scene {
		if len(fields) == 0 {
			fmt.Print("> ")
			scanner.Scan()
			fields = strings.Fields(scanner.Text())
		}
		for i := 0; i < len(fields); i++ {
			s := fields[i]
			switch s {
			case "location", "loc":
				position := scene.Player.State.Current.Position
				location := scene.Location(position)
				fmt.Printf("%v %v\n", position, location)
			case "quit", "q":
				scene.IsQuiting = true
			case "move", "m":
				scene.Player.State.Desired.Position.Y = ns.Pop()
				scene.Player.State.Desired.Position.X = ns.Pop()
				fields = fields[i+1:]
				return scene
			case "place", "p":
				p := scene.Cursor()
				scene.World.Map[p.X][p.Y].Description = ss.Pop()
			case "+":
				ns.Push(ns.Pop() + ns.Pop())
			case ".":
				fmt.Println(ns.Pop())
			case "\"":
				fmt.Println(ss.Pop())
			default:
				n, err := strconv.ParseInt(s, 10, 32)
				if err == nil {
					ns.Push(int(n))
				} else if v := strings.TrimPrefix(s, "\""); v != s {
					ss.Push(v)
				}
			}
		}
		fields = fields[:0]
		return scene
	}
}
