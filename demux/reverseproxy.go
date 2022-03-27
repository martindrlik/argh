package main

import (
	"net/http"
	"net/http/httputil"
	"net/url"
	"sync"
)

func newReverseProxy(targets []*url.URL) *httputil.ReverseProxy {
	selectTarget := func(l int) func() int {
		mu := sync.Mutex{}
		i := 0
		return func() int {
			defer mu.Unlock()
			mu.Lock()
			i++
			if i >= l {
				i = 0
			}
			return i
		}
	}(len(targets))
	director := func(r *http.Request) {
		target := targets[selectTarget()]
		r.URL.Scheme = target.Scheme
		r.URL.Host = target.Host
	}
	return &httputil.ReverseProxy{Director: director}
}
