PROTO_DIR := core
PROTO_FILES := $(shell find $(PROTO_DIR) -name *.proto)

.PHONY: all gen-proto deps
all: gen-proto

gen-proto:
	@echo "Generating Protobuf files..."
	@protoc --proto_path=. \
		--go_out=pkg --go_opt=paths=source_relative \
		--go-grpc_out=pkg --go-grpc_opt=paths=source_relative \
		$(PROTO_FILES)
	@echo "Protobuf files generated successfully."

deps:
	@echo "Installing tools..."
	@mkdir -p $(LOCAL_BIN)
	@go install google.golang.org/protobuf/cmd/protoc-gen-go
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc
	@go mod tidy
	@echo "Tools installed successfully."