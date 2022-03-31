package main

import "errors"

var (
	ErrAlreadyTaken = errors.New("player name already taken")
)
