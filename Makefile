ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

.PHONY=run
run: migrate
	iex -S mix phx.server

.PHONY=migrate
migrate: db
	mix ecto.setup


.PHONY=db
db:
	docker-compose up --build -d
