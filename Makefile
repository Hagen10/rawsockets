
.PHONY: build
build:
	docker build --progress=plain -f Dockerfile . -t rawsockets

.PHONY: run
run: build
	docker run -d --privileged --name rawsockets rawsockets

.PHONY: stop
stop:
	docker stop rawsockets
	docker rm rawsockets