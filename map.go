package main

import "math/rand"

func randomMap(m *[100][100]Location) {
	for x := 0; x < 100; x++ {
		for y := 0; y < 100; y++ {
			m[x][y].Description = randomLocation()
		}
	}
}

func randomLocation() string {
	switch rand.Intn(4) {
	case 0:
		return "greenland"
	case 1:
		return "forest"
	case 2:
		return "lake"
	case 3:
		return "mountain"
	default:
		return ""
	}
}
