# Changelog - Clyde Code Installer

All notable changes to the Clyde Code Installer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-06

### Added
- VERSION file to track installer releases
- Version display in installer output header
- CHANGELOG.md for tracking installer changes
- Version history in install.sh header comments

### Fixed
- Authentication issues by using `gh repo clone` instead of `git clone`
- Removed problematic global git config modifications that caused credential helper conflicts
- Updated all references from `clide.sh` to `clyde.sh` for recent rebrand
- Improved error reporting to show actual git errors instead of suppressing them

### Changed
- Installer now requires GitHub CLI (gh) authentication for simplest user experience
- Falls back to git clone if gh is not available
- Updated branding from "Clide Code" to "Clyde Code Agent" throughout

## Pre-1.0.0 (Unversioned)

### 2025-10-05
- Initial public installer created
- Support for private repository cloning
- Basic authentication detection
- Project initialization and configuration setup
