.PHONY: persona backend frontend web help install install-air check-deps

# Variables
AIR := $(shell which air 2> /dev/null || echo $(HOME)/go/bin/air)
GO := $(shell which go 2> /dev/null)
NPM := $(shell which npm 2> /dev/null)
PYTHON := $(shell which python3 2> /dev/null)

help:
	@echo "Usage:"
	@echo "  make install   - Install all dependencies (npm, go mods, air)"
	@echo "  make persona   - Start the Persona evolutionary engine"
	@echo "  make backend   - Start the Web Backend (Go with air hot-reload)"
	@echo "  make frontend  - Start the Web Frontend (React/Vite)"
	@echo "  make web       - Start both Backend and Frontend in parallel"

check-deps:
	@echo "Checking dependencies..."
	@if [ -z "$(PYTHON)" ]; then echo "Error: python3 not found."; exit 1; fi
	@if [ -z "$(NPM)" ]; then echo "Error: npm not found."; exit 1; fi
	@if [ -z "$(GO)" ]; then echo "Error: go not found. Please install Go 1.22+"; exit 1; fi
	@echo "All core tools found."

install: check-deps
	@echo "Installing frontend dependencies..."
	cd apps/web/frontend && $(NPM) install
	@echo "Downloading backend modules..."
	cd apps/web/backend && $(GO) mod download
	@$(MAKE) install-air
	@echo "Installation complete."

install-air:
	@if [ ! -x "$(AIR)" ]; then \
		echo "Installing air for hot-reload..."; \
		$(GO) install github.com/air-verse/air@latest; \
	fi

persona: check-deps
	@echo "Starting Persona Engine..."
	$(PYTHON) -m snackPersona.main --generations 5 --population 10

backend: check-deps
	@echo "Starting Web Backend with air..."
	@if [ ! -x "$(AIR)" ]; then \
		if [ -x "$(HOME)/go/bin/air" ]; then \
			$(HOME)/go/bin/air; \
		else \
			echo "Error: air not found. Run 'make install' first."; \
			exit 1; \
		fi \
	else \
		$(AIR); \
	fi

frontend: check-deps
	@echo "Starting Web Frontend..."
	@if [ ! -d "apps/web/frontend/node_modules" ]; then echo "Error: node_modules missing. Run 'make install' first."; exit 1; fi
	cd apps/web/frontend && $(NPM) run dev

web:
	@echo "Starting Web (Backend + Frontend) in parallel..."
	@$(MAKE) -j2 backend frontend

stop:
	@echo "Stopping Web processes..."
	@# Kill backend (air or go server) on 13579
	@fuser -k 13579/tcp || echo "Backend already stopped."
	@# Kill frontend (vite) - default port 5173
	@fuser -k 5173/tcp || echo "Frontend already stopped."
	@echo "Cleanup complete."
