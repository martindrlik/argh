package main

type AnimationState[T comparable] struct {
	Current, Desired T
}
