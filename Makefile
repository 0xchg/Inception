# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mchingi <mchingi@student.42luanda.com>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/14 15:00:12 by mchingi           #+#    #+#              #
#    Updated: 2026/04/27 19:17:03 by mchingi          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

all:
	mkdir -p /home/$(USER)/data/wordpress
	mkdir -p /home/$(USER)/data/mariadb
	mkdir -p /home/$(USER)/data/portainer
	docker compose -f srcs/docker-compose.yml up -d --build
	
down:
	docker compose -f srcs/docker-compose.yml down

clean: down
	docker system prune -af
	sudo rm -rf /home/$(USER)/data

fclean: clean
	docker volume prune -f

re: down all

.PHONY: all down clean fclean re

