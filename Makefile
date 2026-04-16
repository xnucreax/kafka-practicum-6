.PHONY: up
run: build compose-up

.PHONY: build
build:
	docker compose build

.PHONY: compose-up
compose-up:
	docker compose up -d
