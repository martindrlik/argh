package main

import (
	"flag"
	"log"
	"net/http"
)

var (
	addr = flag.String("addr", ":8070", "")
)

func handler() http.Handler {
	h := http.NewServeMux()
	h.HandleFunc("/players/", players())
	h.HandleFunc("/", frontend())
	return h
}

func main() {
	flag.Parse()
	log.Fatal(http.ListenAndServe(*addr, handler()))
}
