include .env

CONTAINER=ut-php-8

build: kill
	docker-compose up --build -d
	make composer-install
	docker exec -it $(CONTAINER) php artisan key:generate
	docker exec -it $(CONTAINER) php artisan jwt:secret -n
	make config-cache
	make migrate-fresh

up: down
	docker-compose up --no-build -d
	sleep 2
	make config-cache
	make migrate

down:
	docker-compose down || true

kill:
	docker-compose kill || true

tty:
	docker exec -it $(CONTAINER) bash

migrate:
	docker exec -it $(CONTAINER) php artisan migrate --seed --seeder=RolesAndPermissionsSeeder

migrate-rollback:
	docker exec -it $(CONTAINER) php artisan migrate:rollback

migrate-fresh:
	docker exec -it $(CONTAINER) php artisan migrate:fresh --seed

composer-install:
	docker exec -it $(CONTAINER) composer install

composer-update:
	docker exec -it $(CONTAINER) composer update

composer-tests:
	docker exec -it $(CONTAINER) composer tests

config-cache:
	docker exec -it $(CONTAINER) php artisan config:cache
	docker exec -it $(CONTAINER) php artisan cache:clear

swagger:
	docker exec -it $(CONTAINER) composer swagger

code-check:
	docker exec -it $(CONTAINER) composer swagger-check
	docker exec -it $(CONTAINER) composer phpstan
	docker exec -it $(CONTAINER) composer phpcs

phpcbf:
	docker exec -it $(CONTAINER) composer phpcbf

repository-create:
	docker exec -it $(CONTAINER) php artisan repository:create $(model)

model-create:
	docker exec -it $(CONTAINER) php artisan code:models --table=$(table)