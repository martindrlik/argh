package main

type Player struct {
	PasswordHash []byte
	PasswordSalt string
	Session      Session
}
