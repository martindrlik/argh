package main

import (
	"flag"
	"html/template"
	"log"
	"net/http"
)

var (
	addr = flag.String("addr", ":8081", "")
)

func main() {
	flag.Parse()
	log.Fatal(http.ListenAndServe(*addr, handler()))
}

func handler() http.Handler {
	h := http.NewServeMux()
	h.HandleFunc("/dark.css", static("css/dark.css"))
	h.HandleFunc("/size.css", static("css/size.css"))
	h.HandleFunc("/style.css", static("css/style.css"))
	h.HandleFunc("/cookie.js", static("js/cookie.js"))
	h.HandleFunc("/dom.js", static("js/dom.js"))
	h.HandleFunc("/game.js", static("js/game.js"))
	h.HandleFunc("/player.js", static("js/player.js"))
	h.HandleFunc("/", execute("main.html"))
	h.HandleFunc("/game.html", execute("game.html"))
	h.HandleFunc("/register-new-player.html", execute("register-new-player.html"))
	return h
}

func execute(name string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// for simple testing always parse
		templates := template.Must(template.ParseFiles(
			"html/footer.html",
			"html/game.html",
			"html/head.html",
			"html/header.html",
			"html/login.html",
			"html/main.html",
			"html/register-new-player.html",
			"html/title",
		))

		err := templates.ExecuteTemplate(w, name, nil)
		if err != nil {
			log.Printf("(error) unable to execute %q template: %v", name, err)
		}
	}
}

func static(name string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, name)
	}
}

func tryGetCookie(r *http.Request, name string) (*http.Cookie, bool) {
	v, err := r.Cookie(name)
	if err == nil {
		return v, true
	}
	if err != http.ErrNoCookie {
		log.Printf("%v: unable to get cookie %q: %v", r.URL, name, err)
	}
	return nil, false
}
