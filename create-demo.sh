#!/bin/bash

#
# Demo Recording Guide for QuickDev Setup
#
# This script provides a step-by-step guide for creating a high-quality
# demo GIF of the `quickdev-setup` tool.
#

echo "🎬 QuickDev Setup GIF Demo Guide"
echo "==================================="
echo "This guide outlines the steps to record a professional demo GIF."

echo ""
echo "## 1. Preparation"
echo "--------------------------"
echo "First, start your screen recording. We recommend using 'terminalizer'."
echo "Run this command to begin:"
echo ""
echo "    terminalizer record quickdev-demo"
echo ""
echo "Once recording, follow the steps below. Press CTRL+D when you're done."
echo ""

echo "## 2. Recording Sequence (The Action!)"
echo "-------------------------------------"
echo "🎯 Goal: Keep the final GIF between 30-45 seconds."
echo ""
echo "   a. Show the help menu first:"
echo "      quickdev-setup --help"
echo ""
echo "   b. Run the main application:"
echo "      quickdev-setup"
echo ""
echo "   c. Navigate to Language Runtimes:"
echo "      - Select option '2'."
echo "      - Briefly pause to show the language selection menu."
echo ""
echo "   d. Show CLI Tools & Status Indicators:"
echo "      - Go back, then select the 'CLI Tools' option."
echo "      - Pause to highlight the status indicators (e.g., [INSTALLED])."
echo ""
echo "   e. Exit Gracefully:"
echo "      - Navigate back to the main menu and select the 'Exit' option."
echo ""


echo "## 3. Finalizing the GIF"
echo "-------------------"
echo "After stopping the recording (CTRL+D), render it into a high-quality GIF."
echo "Use this command:"
echo ""
echo "    terminalizer render quickdev-demo -o ./screenshots/quickdev-setup-demo.gif"
echo ""


echo "✨ Your final GIF will showcase:"
echo "   ✅ A clean, colorful interface."
echo "   ✅ Smooth, interactive menu navigation."
echo "   ✅ Clear, real-time status indicators."
echo "   ✅ The overall professional design of the CLI."
echo ""
echo "Happy recording!"