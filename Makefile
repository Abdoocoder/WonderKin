# Kids Adventure App - Makefile

.PHONY: doctor analyze test build-apk build-ipa clean get-deps icons gen-locales

# Default target
all: doctor

# Get dependencies
get-deps:
	flutter pub get

# Generate localization files
gen-locales:
	flutter gen-l10n

# Generate app icons
icons:
	flutter pub run flutter_launcher_icons:main

# Run analysis
analyze:
	flutter analyze

# Run tests
test:
	flutter test

# Full health check (analyze + test)
doctor: analyze test
	@echo "✅ All checks passed!"

# Build release APK
build-apk:
	flutter build apk --release --split-per-abi

# Build release iOS (requires macOS)
build-ipa:
	flutter build ipa --release

# Build for all platforms
build-all: build-apk build-ipa

# Clean build artifacts
clean:
	flutter clean
	flutter pub get

# Run in debug mode
run:
	flutter run

# Run on specific device
run-device:
	flutter run -d $(DEVICE)

# List devices
devices:
	flutter devices

# Check for outdated packages
outdated:
	flutter pub outdated

# Upgrade packages
upgrade:
	flutter pub upgrade

# Format code
format:
	dart format --line-length 100 lib/ test/

# Generate code (for drift, etc.)
generate:
	dart run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate
watch:
	dart run build_runner watch --delete-conflicting-outputs