#!/bin/bash
# LGSM mods_available.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: List available mods for different games

local commandname="MODS"
local commandaction="List Mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

if [ "${engine}" == "source" ]&&[ "${gamename}" != "Garry's Mod" ]; then
read -r -d '' modslist <<- End
sm | sourcemod
mm | metamod
End
fi
