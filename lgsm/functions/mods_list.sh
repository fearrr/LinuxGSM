#!/bin/bash
# LGSM mods_available.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Lists available mods for different games

local commandname="MODS"
local commandaction="List Mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

# Mods URLs
mod_url_sourcemod="http://sourcemod.net/latest.php?os=Linux&version=1.8"
mod_url_metamod="http://cdn.probablyaserver.com/sourcemod/mmsource-1.10.6-linux.tar.gz"
mod_url_ulib="https://codeload.github.com/TeamUlysses/ulib/zip/master"
mod_url_ulx="https://codeload.github.com/TeamUlysses/ulx/zip/master"
mod_url_rustoxide="https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Rust_Linux.zip"
mod_url_hwoxide="https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Hurtworld_Linux.zip"
mod_url_sdtdoxide="https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-7DaysToDie_Linux.zip"

# Prepare proper output for every game supported
if [ "${engine}" == "source" ]&&[ "${gamename}" != "Garry's Mod" ]; then
	read -r -d '' modslist <<- End
		sm | sourcemod | http://www.sourcemod.net/
		mm | metamod | https://www.sourcemm.net/
	End
fi

if [ "${gamename}" == "Garry's Mod" ]; then
	read -r -d '' modslist <<- End
		ulib | http://ulyssesmod.net/
		ulx | http://ulyssesmod.net/
	End
fi

if [ "${gamename}" == "Rust" ]; then
	read -r -d '' modslist <<- End
		rustoxide | http://oxidemod.org/downloads/oxide-for-rust.1659/
	End
fi

if [ "${gamename}" == "7 Days To Die" ]; then
	read -r -d '' modslist <<- End
		hwoxide | http://oxidemod.org/downloads/oxide-for-hurtworld.1332/
	End
fi

if [ "${gamename}" == "7 Days To Die" ]; then
	read -r -d '' modslist <<- End
		sdtdoxide | http://oxidemod.org/downloads/oxide-for-7-days-to-die.813/
	End
fi