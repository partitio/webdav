PROJECT_NAME=webdav
PKG := github.com/partitio/$(PROJECT_NAME)
VERSION=0.0.1
GOPATH:=$(shell go env GOPATH)

.PHONY: proto tests docker srv

all: deps tests build ## Run all commands except docker
all-docker: deps tests docker push ## Run all docker commands


tests: ## Run test suite
	@go test -v ./... -cover

coverage: ## Generate global code coverage report
	@mkdir -p cover
	@touch cover/${PROJECT_NAME}cov
	go tool cover -html=cover/${PROJECT_NAME}cov -o coverage.html

docker: deps ## Build Docker images
	@docker build --build-arg PROJECT_NAME=${PROJECT_NAME} -t partitio/${PROJECT_NAME} -t partitio/${PROJECT_NAME}:${VERSION} .

push : ## Push Docker images
	@docker push partitio/${PROJECT_NAME}
	@docker push partitio/${PROJECT_NAME}:${VERSION}

deps: ## Get dependencies
	@govendor init
	@govendor sync
	@govendor add +external

build: ## Build service
	@go build -o ${PROJECT_NAME} cmd/${PROJECT_NAME}/main.go

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
