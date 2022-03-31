package main

import (
	"github.com/martindrlik/argh/rands"
	"golang.org/x/crypto/bcrypt"
)

func hashPassword(password string) (hash, salt []byte, err error) {
	s := rands.Random(5)
	salt = []byte(s)
	hash, err = bcrypt.GenerateFromPassword([]byte(password+s), 14)
	return
}

func checkPassword(password string, salt, passwordHash []byte) error {
	return bcrypt.CompareHashAndPassword(passwordHash, []byte(password+string(salt)))
}
