SRC_DIR := src
BUILD_DIR := build
DEPLOY_DIR := $(HOME)/Library/Application Scripts/com.devon-technologies.think

# Colors
CLR_RESET := \033[0m
CLR_GREEN := \033[1;32m
CLR_RED := \033[1;31m
CLR_BLUE := \033[1;34m

.PHONY: all clean deploy

all:
	@echo "$(CLR_BLUE)Compiling AppleScript files...$(CLR_RESET)"
	@echo ""
	@tmpfile=$$(mktemp); \
	find "$(SRC_DIR)" \( -type f -o -type l \) -name '*.applescript' | while IFS= read -r src_file; do \
		rel_path="$${src_file#$(SRC_DIR)/}"; \
		build_file="$(BUILD_DIR)/$${rel_path%.applescript}.scpt"; \
		build_dir="$$(dirname "$$build_file")"; \
		mkdir -p "$$build_dir"; \
		echo "$(CLR_BLUE)Compiling:$(CLR_RESET) $$src_file"; \
		if osacompile -o "$$build_file" "$$src_file" 2>&1; then \
			echo "$(CLR_GREEN)✓ Success$(CLR_RESET)"; \
		else \
			echo ""; \
			echo "$(CLR_RED)✗ Compilation failed for $$src_file$(CLR_RESET)"; \
			echo "1" > "$$tmpfile"; \
		fi; \
		echo ""; \
	done; \
	if [ -s "$$tmpfile" ]; then \
		rm -f "$$tmpfile"; \
		echo "$(CLR_RED)Compilation failed with errors$(CLR_RESET)"; \
		exit 1; \
	else \
		rm -f "$$tmpfile"; \
		echo "$(CLR_GREEN)Compilation complete$(CLR_RESET)"; \
	fi

clean:
	rm -rf $(BUILD_DIR)

deploy: all
	@echo "$(CLR_BLUE)Deploying scripts to DEVONthink...$(CLR_RESET)"
	@echo ""
	@find "$(BUILD_DIR)" -type f -name '*.scpt' | while IFS= read -r build_file; do \
		rel_path="$${build_file#$(BUILD_DIR)/}"; \
		dest_dir="$(DEPLOY_DIR)/$$(dirname "$$rel_path")"; \
		mkdir -p "$$dest_dir"; \
		echo "$(CLR_BLUE)Deploying:$(CLR_RESET) $$rel_path"; \
		cp "$$build_file" "$$dest_dir/"; \
		echo "$(CLR_GREEN)✓ Deployed$(CLR_RESET)"; \
		echo ""; \
	done
	@echo "$(CLR_GREEN)Deployment complete$(CLR_RESET)"