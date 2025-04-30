
DOCKER_COMPOSE = docker-compose -f srcs/inception.yaml

# --- Default Target (Help) ---
help:  ## help menu
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# --- Main Commands ---
build:  ## Only build containers
	@ mkdir -p -m=666 ${HOME}/data/mariadb
	@ mkdir -p -m=666 ${HOME}/data/wordpress
	@ mkdir -p -m=666 ${HOME}/data/redis
	@ mkdir -p -m=666 ${HOME}/data/portainer
	@$(DOCKER_COMPOSE) build

up:  ## Start with build/rebuild
	@ mkdir -p ${HOME}/data/mariadb
	@ mkdir -p ${HOME}/data/wordpress
	@ mkdir -p -m=666 ${HOME}/data/redis
	@ mkdir -p -m=666 ${HOME}/data/portainer
	@$(DOCKER_COMPOSE) up -d --build

down:  ## Stop and remove containers
	@$(DOCKER_COMPOSE) down

clean: down  ## Remove images
	@$(DOCKER_COMPOSE) down --rmi all --remove-orphans

fclean: clean ## remove volumes and build cache
	@$(DOCKER_COMPOSE) down -v 
	@docker network prune -f
	@docker system prune -a --volumes -f

clean_host_data: fclean ## removes host data; needs sudo
	@ rm -rf ${HOME}/data


# --- Checks and Monitoring ---

status: ## Extensive Info on containers
	@./srcs/utils/docker-status.sh

logs:  ## Tail container logs
	@$(DOCKER_COMPOSE) logs -f --tail=100

check: ## Check DB connectivity and health
	@echo "Database check:"
	@docker ps --format {{.Names}} | grep -q mariadb || (echo "mariadb not running"; exit 1)
	@docker inspect --format='{{.State.Health.Status}}' mariadb | grep -q healthy || (echo "DB not healthy"; exit 1)
	@echo  "database health: OK"
	@docker exec mariadb mysql -u n1smm -p$$(grep MYSQL_PASSWORD srcs/.env | cut -d '=' -f2) -e "SHOW DATABASES;"

re: down up  ## Rebuild and restart containers

# Makefile for Docker Compose management
.PHONY: help build up down clean status logs check re
