.PHONY: build
build:
	docker build -f Dockerfile . -t rawsockets

.PHONY: run
run: build
	docker run \
		-d \
		--privileged \
		--mount type=bind,src=/tmp,dst=/app/files \
		-P \
		--cap-add=NET_RAW \
		--cap-add=NET_ADMIN \
		--name rawsockets rawsockets

.PHONY: stop
stop:
	docker stop rawsockets
	docker rm rawsockets
	docker rmi rawsockets

.PHONY: sh
sh:
	docker exec -it rawsockets sh

.PHONY: logs
logs:
	docker logs -f rawsockets