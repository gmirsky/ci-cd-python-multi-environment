PYTHON ?= python3
PIP ?= pip3
IMAGE ?= hello-world:latest
PLATFORMS ?= linux/amd64,linux/arm64

.PHONY: test docker-buildx docker-buildx-load

test:
	$(PYTHON) -m pip install --upgrade pip
	$(PIP) install -r requirements-dev.txt
	pytest

docker-buildx:
	docker buildx build --platform $(PLATFORMS) -t $(IMAGE) .

docker-buildx-load:
	docker buildx build --platform linux/amd64 -t $(IMAGE) --load .
