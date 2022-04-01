package main

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/martindrlik/argh/payload"
)

func login(rw http.ResponseWriter, r *http.Request) {
	p, ok := payload.TryDecode(rw, r, &struct {
		Name     string
		Password string
	}{})
	if !ok {
		return
	}
	session, ok := tryLoginPlayer(rw, r, p.Name, p.Password)
	if !ok {
		return
	}
	if session == "" {
		failedToLoginPlayer(rw, r, http.StatusBadRequest)
		return
	}
}

type loginData struct {
	name     string
	password string
	result   chan string
}

func tryLoginPlayer(rw http.ResponseWriter, r *http.Request, name, password string) (string, bool) {
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	result := make(chan string)
	select {
	case g.loginChannel <- loginData{
		name,
		password,
		result}:
	case <-ctx.Done():
		log.Printf("%v: login player %q: %v", r.URL, name, ctx.Err())
		failedToLoginPlayer(rw, r, http.StatusInternalServerError)
		return "", false
	}
	select {
	case session := <-result:
		return session, true
	case <-ctx.Done():
		log.Printf("%v: login player %q: %v", r.URL, name, ctx.Err())
		failedToLoginPlayer(rw, r, http.StatusInternalServerError)
	}
	return "", false
}

func failedToLoginPlayer(rw http.ResponseWriter, r *http.Request, code int) {
	payload.EncodeError(rw, r, "failed to login", code)
}
