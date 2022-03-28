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
	h.Handle("/script/", http.StripPrefix("/script/", http.FileServer(http.Dir("./public/scripts"))))
	h.Handle("/style/", http.StripPrefix("/style/", http.FileServer(http.Dir("./public/styles"))))

	h.HandleFunc("/", execute("main.html"))
	h.HandleFunc("/game.html", execute("game.html"))
	h.HandleFunc("/player-register.html", execute("player-register.html"))
	return h
}

func execute(name string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// for simple testing always parse
		templates := template.Must(template.ParseFiles(
			"templates/footer.html",
			"templates/game.html",
			"templates/main.html",
			"templates/player-register.html",
			"templates/scripts.html",
			"templates/stylesheets.html",
			"templates/title",
		))

		err := templates.ExecuteTemplate(w, name, nil)
		if err != nil {
			log.Printf("unable to execute %q template: %v", name, err)
		}
	}
}
