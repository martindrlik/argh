package main

type Location struct {
	Description string
}

func (loc Location) String() string {
	return loc.Description
}
