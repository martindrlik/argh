package main

import (
	"github.com/martindrlik/argh/rands"
	"golang.org/x/crypto/bcrypt"
)

func genPassword() (password, salt string, passwordHash []byte, err error) {
	password = rands.Password()
	salt = rands.Random(5)
	passwordHash, err = bcrypt.GenerateFromPassword([]byte(password+salt), 14)
	return
}

func checkPassword(password, salt string, passwordHash []byte) error {
	return bcrypt.CompareHashAndPassword(passwordHash, []byte(password+salt))
}
