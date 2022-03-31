package main

import (
	"context"
	"log"
	"net/http"
	"time"
)

func tryFindPlayerBySession(r *http.Request) (string, *Player, bool) {
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	c, ok := tryGetCookie(r, "playerSession")
	if !ok {
		return "", nil, false
	}

	result := make(chan findResult)
	select {
	case global.findChannel <- find{
		session: c.Value,
		ctx:     ctx,
		result:  result}:
	case <-ctx.Done():
		return "", nil, false
	}
	select {
	case r := <-result:
		if r.name != "" {
			return r.name, r.player, true
		}
	case <-ctx.Done():
	}
	return "", nil, false
}

func findPlayer(f find) {
	defer close(f.result)
	if f.session != "" {
		name, ok := global.bySession[f.session]
		if ok {
			f.name = name
		}
	}
	if f.name != "" {
		p, ok := global.byName[f.name]
		if ok {
			select {
			case f.result <- findResult{f.name, p}:
			case <-f.ctx.Done():
				log.Printf("unable to find player %q in time: %v", f.name, f.ctx.Err())
			}
		}
	}
}

type findResult struct {
	name   string
	player *Player
}

type find struct {
	session string
	name    string
	ctx     context.Context
	result  chan findResult
}
