MACHINE=$(shell uname -m)
IMAGE=pi-k8s-fitches-elk
VERSION=0.1
TAG="$(VERSION)-$(MACHINE)"
ACCOUNT=gaf3
NAMESPACE=fitches
PORT=6870
VOLUMES=-v ${PWD}/storage:/var/lib/elasticsearch -v ${PWD}/log:/var/log

ifeq ($(MACHINE),armv7l)
BASE=arm32v7/ubuntu:18.04
else
BASE=ubuntu:18.04
endif

.PHONY: build shell start stop push create update delete create-dev update-dev delete-dev

build:
	docker build . --build-arg BASE=$(BASE) -t $(ACCOUNT)/$(IMAGE):$(TAG)

shell:
	docker run -it $(VOLUMES) $(ACCOUNT)/$(IMAGE):$(TAG) sh

start:
	docker run --name $(IMAGE)-$(VERSION) $(VARIABLES) $(VOLUMES) -d --rm -p 127.0.0.1:$(PORT):5601 -p 127.0.0.1:9200:9200 -p 127.0.0.1:5044:5044 -h $(IMAGE) $(ACCOUNT)/$(IMAGE):$(TAG)

stop:
	docker rm -f $(IMAGE)-$(VERSION)

push: build
	docker push $(ACCOUNT)/$(IMAGE):$(TAG)

create:
	kubectl --context=pi-k8s create -f k8s/pi-k8s.yaml

update:
	kubectl --context=pi-k8s replace -f k8s/pi-k8s.yaml

delete:
	kubectl --context=pi-k8s delete -f k8s/pi-k8s.yaml

create-dev:
	kubectl --context=minikube create -f k8s/minikube.yaml

update-dev:
	kubectl --context=minikube replace -f k8s/minikube.yaml

delete-dev:
	kubectl --context=minikube delete -f k8s/minikube.yaml
