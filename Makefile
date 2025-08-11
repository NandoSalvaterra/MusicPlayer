# Makefile - Tuist Shortcuts

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
CYAN := \033[0;36m
RESET := \033[0m

## Show available commands
help:
	@echo ""
	@echo "$(CYAN)Available commands:$(RESET)"
	@echo "  $(YELLOW)make edit$(RESET)     - Open the project in Tuist edit mode"
	@echo "  $(YELLOW)make project$(RESET) - Generate the Xcode project"
	@echo "  $(YELLOW)make clean$(RESET)    - Clean Tuist cache and temporary files"
	@echo "  $(YELLOW)make destroy$(RESET)  - Fully remove Tuist caches and build folders"
	@echo ""

## Open the project in Tuist edit mode
edit:
	@echo "$(GREEN)Opening Tuist edit mode...$(RESET)"
	tuist edit

## Generate the Xcode project
project:
	@echo "$(GREEN)Generating Xcode project...$(RESET)"
	tuist generate

## Clean Tuist cache and temporary files
clean:
	@echo "$(GREEN)Cleaning Tuist cache...$(RESET)"
	tuist clean
	tuist cache clean

## Fully remove Tuist caches and build folders
destroy:
	@echo "$(GREEN)Destroying all Tuist files and caches...$(RESET)"
	tuist clean
	tuist cache clean
	rm -rf DerivedData .tuist .build
