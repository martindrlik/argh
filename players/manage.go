package main

import (
	"log"
)

var global = struct {
	registerChannel chan registerData
	loginChannel    chan loginData
	findChannel     chan find

	byName    map[string]*Player
	bySession map[Session]string
}{
	registerChannel: make(chan registerData),
	loginChannel:    make(chan loginData),
	findChannel:     make(chan find),

	byName:    map[string]*Player{},
	bySession: map[Session]string{},
}

func init() {
	go func() {
		for {
			select {
			case s := <-global.registerChannel:
				global.byName[s.name] = &Player{
					PasswordHash: s.passwordHash,
					PasswordSalt: s.passwordSalt,
					Session:      s.session,
				}
				global.bySession[s.session] = s.name
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
	}()
}
