package main

import (
	"log"
)

var global = struct {
	registerChannel chan registerData
	loginChannel    chan loginData
	findChannel     chan find

	byName    map[string]*Player
	bySession map[string]string
}{
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

func procRequests() {
	select {
	case s := <-global.registerChannel:
		if _, ok := global.byName[s.name]; ok {
			s.result <- ErrAlreadyTaken
		} else {
			global.byName[s.name] = &Player{
				PasswordHash: s.passwordHash,
				PasswordSalt: s.passwordSalt,
				Session:      s.session,
			}
			global.bySession[s.session] = s.name
			log.Printf("player %q registered 🎉", s.name)
		}
		close(s.result)
	case s := <-global.findChannel:
		findPlayer(s)
	case s := <-global.loginChannel:
		p, ok := global.byName[s.name]
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
