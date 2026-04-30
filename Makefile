# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mchingi <mchingi@student.42luanda.com>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/14 15:00:12 by mchingi           #+#    #+#              #
#    Updated: 2026/04/30 17:52:24 by mchingi          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

UP = docker compose -f srcs/docker-compose.yml up -d --build
DOWN = docker compose -f srcs/docker-compose.yml down

all:
	mkdir -p /home/$(USER)/data/wordpress
	mkdir -p /home/$(USER)/data/mariadb
	mkdir -p /home/$(USER)/data/portainer
	$(UP)

down:
	$(DOWN)

clean: 
	$(DOWN) --rmi all

fclean:
	sudo rm -rf /home/$(USER)/data
	$(DOWN) --volumes --rmi all
	docker system prune -af

re: fclean all

.PHONY: all down clean fclean re

