#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
julia --project="$SCRIPT_DIR" -e "include(\"$SCRIPT_DIR/src/L2F2_Dequantification_App.jl\"); L2F2_Dequantification_App.lancer()"