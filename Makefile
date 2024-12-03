ifndef DOCKER_COMPOSE_CMD
    ifeq ($(shell command -v docker-compose 2>/dev/null),)
        ifeq ($(shell command -v docker 2>/dev/null),)
            $(error Docker is not installed. Please install Docker.)
        endif
        ifeq ($(shell docker compose 2>/dev/null),)
            $(error Docker Compose is not installed. Please install Docker Compose.)
        else
            DOCKER_COMPOSE_CMD = docker compose
        endif
    else
        DOCKER_COMPOSE_CMD = docker-compose
    endif
endif

start:
	$(DOCKER_COMPOSE_CMD) up -d

stop:
	$(DOCKER_COMPOSE_CMD) down

restart: stop start
