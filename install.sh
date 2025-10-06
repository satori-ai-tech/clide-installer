#!/bin/bash

###############################################################################
# Clyde Code Installer v1.0.0
#
# Public installer for Clyde Code Agent - Digital Labor for software development.
# Clones the private clyde-code repository for customers with collaborator access.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/satori-ai-tech/clyde-installer/main/install.sh | bash
#
# Prerequisites:
#   - GitHub authentication (gh auth login recommended)
#   - Collaborator access to satori-ai-tech/clyde-code
#
# Version History:
#   v1.0.0 - Initial versioned release
#            - Fixed authentication using gh repo clone
#            - Updated for Clide → Clyde rebrand
#            - Added version tracking
#
###############################################################################

set -e

# Installer version
INSTALLER_VERSION="1.0.0"

REPO_URL="https://github.com/satori-ai-tech/clide-code.git"
TARGET_DIR=".claude"

echo "==========================================="
echo "Clyde Code Installer v${INSTALLER_VERSION}"
echo "==========================================="
echo ""
echo "Target directory: ${TARGET_DIR}"
echo "Repository: ${REPO_URL} (private)"
echo ""

# Check if target directory already exists
if [ -d "${TARGET_DIR}" ]; then
    echo "ERROR: Directory ${TARGET_DIR} already exists."
    echo ""
    echo "Options:"
    echo "1. Remove it: rm -rf ${TARGET_DIR}"
    echo "2. Use upgrade script: cd ${TARGET_DIR} && ./tools/upgrade.sh"
    echo ""
    exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "ERROR: git is not installed."
    echo "Install git and try again."
    exit 1
fi

# Check for gh CLI
GH_AVAILABLE=false
if command -v gh &> /dev/null; then
    echo "✓ GitHub CLI detected"
    GH_STATUS=$(gh auth status 2>&1 || echo "not authenticated")
    if echo "$GH_STATUS" | grep -q "Logged in"; then
        echo "✓ Authenticated with GitHub"
        GH_AVAILABLE=true
    else
        echo "⚠ Not authenticated with GitHub CLI"
        echo "  Run: gh auth login (select HTTPS)"
    fi
else
    echo "ℹ GitHub CLI not found (recommended)"
    echo "  Install: https://cli.github.com/"
fi

echo ""
echo "Step 1: Cloning Clide Code (private repository)..."
echo "  This requires authentication..."
echo ""

TEMP_CLONE="/tmp/clide-install-$$"

# Try to clone - use gh if available, otherwise fall back to git
if [ "$GH_AVAILABLE" = true ]; then
    # Use gh repo clone - it handles authentication natively
    CLONE_ERROR=$(gh repo clone satori-ai-tech/clyde-code "${TEMP_CLONE}" -- --depth 1 2>&1)
    CLONE_STATUS=$?
else
    # Fall back to git clone
    CLONE_ERROR=$(git clone --depth 1 "${REPO_URL}" "${TEMP_CLONE}" 2>&1)
    CLONE_STATUS=$?
fi

if [ $CLONE_STATUS -eq 0 ]; then
    echo "✓ Successfully cloned repository"
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ERROR: Failed to clone repository"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Error details:"
    echo "$CLONE_ERROR"
    echo ""
    echo "Possible reasons:"
    echo "1. You haven't been added as a collaborator"
    echo "2. You need to authenticate with GitHub"
    echo ""
    echo "Solutions:"
    echo ""
    echo "a) Authenticate with GitHub CLI (recommended):"
    echo "   gh auth login"
    echo "   Select: HTTPS protocol"
    echo "   Then run this installer again"
    echo ""
    echo "b) Or configure git credentials:"
    echo "   git config --global credential.helper store"
    echo "   Then run this installer again"
    echo ""
    echo "c) Contact support if you purchased access:"
    echo "   support@satori-ai-tech.com"
    echo ""
    exit 1
fi

echo ""
echo "Step 2: Installing to ${TARGET_DIR}..."
mv "${TEMP_CLONE}/.claude" "${TARGET_DIR}"
rm -rf "${TEMP_CLONE}"
echo "   ✓ Installed .claude directory"

echo ""
echo "Step 3: Setting up launcher script..."
# Copy clyde.sh to project root for easy access
cp "${TARGET_DIR}/clyde.sh" "./clyde.sh"
chmod +x "./clyde.sh"
echo "   ✓ Copied clyde.sh to project root"

echo ""
echo "Step 4: Initializing for new project..."
if [ -f "${TARGET_DIR}/tools/reset_db.sh" ]; then
    cd "${TARGET_DIR}"
    echo "yes" | ./tools/reset_db.sh > /dev/null 2>&1
    cd - > /dev/null
    echo "   ✓ Fresh memory bank initialized"
else
    echo "ERROR: reset_db.sh not found."
    exit 1
fi

echo ""
echo "Step 5: Creating default configuration..."
# Only create config if it doesn't exist
if [ ! -f "${TARGET_DIR}/clide.config.sh" ]; then
    cat > "${TARGET_DIR}/clide.config.sh" << 'CONFIGEOF'
#!/bin/bash
# Clide Code User Configuration
# Customize WHO you are and your company context

# User Identity
USER_NAME="User"
USER_ROLE="Developer"
USER_COMPANY="Your Company"
USER_GREETING="Sir"

# Company Context
COMPANY_MISSION="Building great software"
COMPANY_VALUES="Quality and reliability"
TECH_STACK="Your preferred stack"
CODE_STYLE="Clean and maintainable"
DEPLOYMENT_POLICY="Test before production"

# Communication
VOICE_ENABLED=true
VOICE_NAME="Lee"  # macOS voice (run 'say -v ?' to see all options)
# Popular voices: Lee, Alex, Daniel (male) | Samantha, Kate, Victoria (female)
COMMUNICATION_STYLE="Professional and concise"
ALERT_ON_MISALIGNMENT=true

# Memory & Context Verification
MEMORY_CHECK_KEY="Melkor is not wrong"
CONFIGEOF
    echo "   ✓ Created default config"
else
    echo "   ✓ Preserved existing config"
fi

# Read version
CLIDE_VERSION=$(cat "${TARGET_DIR}/VERSION" 2>/dev/null || echo "unknown")

echo ""
echo "==========================================="
echo "Clide Code v${CLIDE_VERSION} Installed!"
echo "==========================================="
echo ""
echo "Next Steps:"
echo "1. Edit .claude/clide.config.sh (your identity & company context)"
echo "2. Edit .claude/docs/proj.md (project details)"
echo "3. Launch Clyde:"
echo "   ./clyde.sh"
echo ""
echo "Add to .gitignore:"
echo "  .claude/tools/memory_bank.db"
echo "  .claude/clide-sessions.txt"
echo "  .claude/clide.config.sh"
echo "  clyde.sh"
echo ""
echo "Upgrade later:"
echo "  cd .claude && ./tools/upgrade.sh"
echo ""
