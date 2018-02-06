IMAGE ?= quay.io/osb-starter-pack/servicebroker
TAG ?= $(shell git describe --tags --always)

build:
	go build -i github.com/pmorie/osb-starter-pack/cmd/servicebroker

test:
	go test -v $(shell go list ./... | grep -v /vendor/ | grep -v /test/)

linux:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 \
	go build --ldflags="-s" github.com/pmorie/osb-starter-pack/cmd/servicebroker

image: linux
	cp servicebroker image/
	docker build image/ -t "$(IMAGE):$(TAG)"

clean:
	rm -f servicebroker

push: image
	docker push "$(IMAGE):$(TAG)"

deploy-helm: image
	helm install charts/servicebroker \
	--name broker-skeleton --namespace broker-skeleton \
	--set imagePullPolicy=Never

deploy-openshift: image
	oc new-project osb-starter-pack
	oc process -f openshift/starter-pack.yaml | oc create -f -

.PHONY: build test linux image clean push deploy-help deploy-openshift
