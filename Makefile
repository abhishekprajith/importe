SHELL := /bin/bash

.ONESHELL:

SOLUTIONS  := $(shell find Prime* -type f -name Dockerfile -exec dirname {} \; | sed -e 's|^./||' | sort)
OUTPUT_DIR := $(shell mktemp -d)
ARCH_FILE  := ${shell case $$(uname -m) in x86_64) echo arch-amd64 ;; aarch64) echo arch-arm64 ;; esac}

all: report
	@echo "Output files available in $(OUTPUT_DIR)"

benchmark: $(SOLUTIONS)
	@for s in $(SOLUTIONS); do \
		NAME=$$(echo "$${s}" | sed -r 's/\//-/g' | tr '[:upper:]' '[:lower:]'); \
		ls $${s}/arch-* > /dev/null 2>&1 ; \
		if [[ -z "$${s}/$(ARCH_FILE)" || -f "$${s}/$(ARCH_FILE)" || "$$?" -ne 0 ]]; then \
			OUTPUT="$(OUTPUT_DIR)/$${NAME}.out"; \
			echo "[*] Running $${NAME}" && docker run --rm $$(docker build -q $$s) | tee "$${OUTPUT}"; \
		else \
			echo "[*] Skipping $${NAME} due to architecture mismatch"; \
		fi; \
	done

report: benchmark
	@docker run --rm -v "$(OUTPUT_DIR)":/opt/session $$(docker build -q _tools) report.py -d /opt/session