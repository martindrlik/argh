package main

import (
	"log"

	"github.com/martindrlik/argh/synapse"
)

var g = struct {
	consumer        *synapse.Consumer
	producer        *synapse.Producer
	registerChannel chan registerData
	loginChannel    chan loginData
	findChannel     chan find

	byName    map[string]*Player
	bySession map[string]string
}{
	consumer:        must(synapse.NewConsumer()),
	producer:        must(synapse.NewProducer()),
	registerChannel: make(chan registerData),
	loginChannel:    make(chan loginData),
	findChannel:     make(chan find),

	byName:    map[string]*Player{},
	bySession: map[string]string{},
}

func init() {
	go func() {
		for {
			procRequests()
		}
	}()
}

func must[T any](v T, err error) T {
	if err != nil {
		panic(err)
	}
	return v
}

func procRequests() {
	select {
	case s := <-g.registerChannel:
		if _, ok := g.byName[s.name]; ok {
			s.result <- ErrAlreadyTaken
		} else {
			g.byName[s.name] = &Player{
				PasswordHash: s.passwordHash,
				PasswordSalt: s.passwordSalt,
				Session:      s.session,
			}
			g.bySession[s.session] = s.name
			log.Printf("player %q registered 🎉", s.name)
		}
		close(s.result)
	case s := <-g.findChannel:
		findPlayer(s)
	case s := <-g.loginChannel:
		p, ok := g.byName[s.name]
		if !ok {
			log.Printf("unable to find player %q", s.name)
		} else if err := checkPassword(
			s.password,
			p.PasswordSalt,
			p.PasswordHash); err != nil {
			log.Printf("check password %q failed: %v", s.name, err)
		} else {
			s.result <- p.Session
		}
		close(s.result)
	}
}
