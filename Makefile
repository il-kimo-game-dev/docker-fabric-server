# Target for creating .env file from .env.example
env_file:
	if [ ! -f .env ]; then \
		cp .env.example .env; \
	fi
	mkdir -p {mods,plugins}

# Target to launch docker-compose
server: env_file
	docker compose --env-file .env up --build

# Default target
all: server

.PHONY: env_file up all

