package main

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/martindrlik/argh/payload"
	"github.com/martindrlik/argh/rands"
)

func register(rw http.ResponseWriter, r *http.Request) {
	p, ok := payload.TryDecode(rw, r, &struct {
		Name string
	}{})
	if !ok {
		return
	}
	password, ok := tryRegisterPlayer(rw, r, p.Name)
	if !ok {
		return
	}
	if !payload.TryEncode(rw, r, struct {
		Password string
	}{password}) {
		return
	}
}

type registerData struct {
	name         string
	session      Session
	passwordHash []byte
	passwordSalt string
	result       chan error
}

func tryRegisterPlayer(rw http.ResponseWriter, r *http.Request, name string) (string, bool) {
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	session := Session(rands.Random(16))
	password, salt, passwordHash, err := genPassword()
	if err != nil {
		log.Printf("%v: unable to generate session for new player %q: %v", r.URL, name, err)
		failedToRegisterNewPlayer(rw, r)
		return "", false
	}
	result := make(chan error)

	select {
	case global.registerChannel <- registerData{
		name,
		session,
		passwordHash,
		salt,
		result}:
	case <-ctx.Done():
		log.Printf("%v: register new player %q: %v", r.URL, name, ctx.Err())
		failedToRegisterNewPlayer(rw, r)
		return "", false
	}
	select {
	case err := <-result:
		if err == nil {
			return password, true
		}
		log.Printf("%v: register new player %q: %v", r.URL, name, err)
		failedToRegisterNewPlayer(rw, r)
	case <-ctx.Done():
		log.Printf("%v: register new player %q: %v", r.URL, name, ctx.Err())

	}
	return "", false
}

func failedToRegisterNewPlayer(rw http.ResponseWriter, r *http.Request) {
	payload.EncodeError(rw, r, "failed to register new player", http.StatusInternalServerError)
}
