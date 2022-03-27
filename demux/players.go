package main

import (
	"net/http"
	"net/url"
)

var playersServers = newReverseProxy([]*url.URL{
	{
		Scheme: "http",
		Host:   "localhost:8091",
	}})

func players() http.HandlerFunc {
	return func(rw http.ResponseWriter, r *http.Request) {
		playersServers.ServeHTTP(rw, r)
	}
}
