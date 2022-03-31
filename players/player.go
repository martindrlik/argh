package main

type Player struct {
	PasswordHash []byte
	PasswordSalt []byte
	Session      string
}
