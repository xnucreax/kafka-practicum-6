package internal

import "github.com/google/uuid"

type Message struct {
	UUID  uuid.UUID
	Value int
}
