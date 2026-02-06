# Makefile for Project Chimera Factory
# Standardized commands for setup, testing, containerization and basic checks

.PHONY: help setup test docker-build docker-test spec-check clean

help: ## Show this help message
	@echo "Project Chimera Factory – Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Install dependencies using uv
	uv sync

test: ## Run pytest on the tests/ folder (expected to fail for TDD)
	uv run pytest tests/

docker-build: ## Build the Docker image
	docker build -t chimera-factory .

docker-test: ## Run tests inside Docker container
	docker run --rm chimera-factory make test

spec-check: ## Very basic check whether code references the specs/ folder
	@echo "Checking for spec references..."
	@if grep -r -q "specs/" . ; then echo "OK: Found spec references"; else echo "WARNING: No spec references found in code"; exit 1; fi

clean: ## Remove temporary files and caches
	rm -rf .pytest_cache __pycache__ *.egg-info .coverage
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} +

# Default target: show help
.DEFAULT_GOAL := help