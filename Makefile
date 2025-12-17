PROTO_SRC_DIR := .
GO_OUT_DIR := pkg
PROTO_FILES := $(shell find $(PROTO_SRC_DIR) -name "*.proto")

.PHONY: all gen-proto

all: gen-proto

gen-proto:
	@echo "$(PROTO_FILES)"
	@protoc \
		--proto_path=$(PROTO_SRC_DIR) \
		--go_out=$(GO_OUT_DIR) \
		--go_opt=paths=source_relative \
		$(PROTO_FILES)

