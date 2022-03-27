package payload

import (
	"encoding/json"
	"log"
	"net/http"
)

func TryDecode[T any](rw http.ResponseWriter, r *http.Request, v T) (T, bool) {
	defer r.Body.Close()
	dec := json.NewDecoder(r.Body)
	if err := dec.Decode(v); err != nil {
		log.Printf("%v: unable to decode request: %v", r.URL, err)
		http.Error(rw, "", http.StatusBadRequest)
		return v, false
	}
	return v, true
}
