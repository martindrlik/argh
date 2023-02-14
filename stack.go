package main

type Stack[T any] []T

func (stack *Stack[T]) Push(t T) {
	*stack = append([]T(*stack), t)
}

func (stack *Stack[T]) Pop() (t T) {
	n := len(*stack) - 1
	if n == -1 {
		return t
	}
	t = []T(*stack)[n]
	*stack = []T(*stack)[:n]
	return
}
