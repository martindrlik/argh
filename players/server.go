package main

import (
	"flag"
	"log"
	"net/http"
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
	h.HandleFunc("/players/login", login)
	h.HandleFunc("/players/register", register)
	return h
}
