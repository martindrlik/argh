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
		Name     string
		Password string
	}{})
	if !ok {
		return
	}
	session := rands.Random(48)
	if !tryRegisterPlayer(
		rw,
		r,
		p.Name,
		p.Password,
		session) {
		return
	}
	if err := g.producer.Produce("sessions", []byte(p.Name), []byte(session)); err != nil {
		log.Printf("unable to produce session message: %v", err)
		http.Error(rw, "", http.StatusInternalServerError)
		return
	}
	http.SetCookie(rw, &http.Cookie{
		Name:   "playerSession",
		MaxAge: 360,
		Value:  session,
	})
}

type registerData struct {
	name         string
	session      string
	passwordHash []byte
	passwordSalt []byte
	result       chan error
}

func tryRegisterPlayer(rw http.ResponseWriter, r *http.Request, name, password, session string) bool {
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	hash, salt, err := hashPassword(password)
	if err != nil {
		log.Printf("%v: unable to generate session for new player %q: %v", r.URL, name, err)
		failedToRegisterNewPlayer(rw, r)
		return false
	}
	result := make(chan error)

	select {
	case g.registerChannel <- registerData{
		name,
		session,
		hash,
		salt,
		result}:
	case <-ctx.Done():
		log.Printf("%v: register new player %q: %v", r.URL, name, ctx.Err())
		failedToRegisterNewPlayer(rw, r)
		return false
	}
	select {
	case err := <-result:
		if err == nil {
			return true
		}
		log.Printf("%v: register new player %q: %v", r.URL, name, err)
		payload.EncodeError(rw, r, err.Error(), http.StatusBadRequest)
	case <-ctx.Done():
		log.Printf("%v: register new player %q: %v", r.URL, name, ctx.Err())

	}
	return false
}

func failedToRegisterNewPlayer(rw http.ResponseWriter, r *http.Request) {
	payload.EncodeError(rw, r, "failed to register new player", http.StatusInternalServerError)
}
