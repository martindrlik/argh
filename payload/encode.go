package payload

import (
	"encoding/json"
	"log"
	"net/http"
)

func TryEncode(rw http.ResponseWriter, r *http.Request, v any) bool {
	enc := json.NewEncoder(rw)
	if err := enc.Encode(v); err != nil {
		log.Printf("%v: unable to encode response: %v", r.URL, err)
		return false
	}
	return true
}

func EncodeError(rw http.ResponseWriter, r *http.Request, message string, code int) {
	rw.WriteHeader(code)
	enc := json.NewEncoder(rw)
	err := enc.Encode(struct {
		Error string
	}{message})
	if err != nil {
		log.Printf("%v: unable to encode error: %v", r.URL, err)
		return
	}
}
