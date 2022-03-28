package main

import (
	"flag"
	"log"
	"net/http"

	"github.com/martindrlik/argh/payload"
	"github.com/martindrlik/argh/rands"
)

var (
	addr = flag.String("addr", ":8091", "")
)

func main() {
	flag.Parse()
	log.Fatal(http.ListenAndServe(*addr, handler()))
}

func handler() http.Handler {
	h := http.NewServeMux()
	h.HandleFunc("/players/", players)
	h.HandleFunc("/players/random-password", func(rw http.ResponseWriter, r *http.Request) {
		payload.TryEncode(rw, r, struct {
			Value string
		}{
			Value: rands.Password(),
		})
	})
	h.HandleFunc("/players/register", register)
	return h
}
