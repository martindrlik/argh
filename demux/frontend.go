package main

import (
	"net/http"
	"net/url"
)

var frontendServers = newReverseProxy([]*url.URL{
	{
		Scheme: "http",
		Host:   "localhost:8081",
	}})

func frontend() http.HandlerFunc {
	return func(rw http.ResponseWriter, r *http.Request) {
		frontendServers.ServeHTTP(rw, r)
	}
}
