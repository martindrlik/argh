package main

import (
	"log"
	"net/http"

	"github.com/martindrlik/argh/payload"
)

func players(rw http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		name, _, ok := tryFindPlayerBySession(r)
		if !ok {
			payload.EncodeError(rw, r, "missing player session", http.StatusOK)
			return
		}
		if !payload.TryEncode(rw, r, struct {
			PlayerName string
		}{name}) {
			return
		}
	}
}

func tryGetCookie(r *http.Request, name string) (*http.Cookie, bool) {
	c, err := r.Cookie(name)
	if err == nil {
		return c, true
	}
	if err != http.ErrNoCookie {
		log.Printf("%v: unable to get cookie %q: %v", r.URL, name, err)
	}
	return nil, false
}
