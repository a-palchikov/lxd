.PHONY: all

CURRENT_DIR := $(realpath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
TOP_DIR := $(realpath $(CURRENT_DIR)/..)
BUILDDIR := $(CURRENT_DIR)/bin
DOCKERFILE ?= $(TOP_DIR)/Dockerfile

all: | $(BUILDDIR)
	docker buildx build \
		--platform=local \
		--output=type=local,dest=$(BUILDDIR) \
		--target=releaser \
		--file $(DOCKERFILE) \
		$(TOP_DIR)

$(BUILDDIR):
	mkdir -p $@
