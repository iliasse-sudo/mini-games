install:
	pip install -r requirements.txt

help:
	@echo "\033[1mHow to use:\033[0m"
	@echo "\tthis runs the first game \033[32mpython3 WASD_Square.py\033[0m"
	@echo "\tthis runs the second game \033[32mpython3 spawning_circle.py\033[0m"

.PHONY: install help
