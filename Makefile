# Makefile

NAME        = inception
COMPOSE     = docker compose -f srcs/docker-compose.yml --env-file srcs/.env

all: up

up:
	@mkdir -p /home/mnazar/data/wordpress
	@mkdir -p /home/mnazar/data/mariadb
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart:
	$(COMPOSE) restart

clean: down
	$(COMPOSE) down -v
	docker system prune -f

fclean: clean
	sudo rm -rf /home/mnazar/data/wordpress
	sudo rm -rf /home/mnazar/data/mariadb

re: fclean all

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

.PHONY: all up down stop start restart clean fclean re logs ps
