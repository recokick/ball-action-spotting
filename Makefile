NAME?=ball-action-spotting
COMMAND?=bash
OPTIONS?=

GPUS?=device=0  # gpu 0
ifeq ($(GPUS),none)
	GPUS_OPTION=
else
	GPUS_OPTION=--gpus $(GPUS)
endif

.PHONY: all
all: stop build run

.PHONY: build
build:
	docker build -t ball-container .

.PHONY: stop
stop:
	-docker stop ball-container
	-docker rm ball-container

.PHONY: run
run:
	docker run --rm -dit \
		--net=host \
		--ipc=host \
		-p 5678:5678 \
		$(OPTIONS) \
		$(GPUS_OPTION) \
		-v $(shell pwd):/workdir \
		--name=ball-container \
		ball-container \
		$(COMMAND)
	# docker attach ball-container

.PHONY: debug
debug: stop build
	docker run --rm -dit \
		-p 5678:5678 \
		$(OPTIONS) \
		$(GPUS_OPTION) \
		-v $(shell pwd):/workdir \
		--name=ball-container \
		ball-container \
		python -m debugpy --listen 0.0.0.0:5678 --wait-for-client scripts/ball_action/predict.py --experiment sampling_weights_001

.PHONY: attach
attach:
	docker attach ball-container

.PHONY: logs
logs:
	docker logs -f ball-container

.PHONY: exec
exec:
	docker exec -it $(OPTIONS) ball-container $(COMMAND)
