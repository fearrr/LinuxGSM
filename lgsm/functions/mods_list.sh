#!/bin/bash
# LGSM mods_available.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Lists and defines available mods for LGSM supported servers

local commandname="MODS"
local commandaction="List Mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

# Define mods names
# mod_name_name=( name shortname "Pretty Name" )
mod_name_sourcemod=( sourcemod sm "SourceMod" )
mod_name_metamod=( metamod mm "MetaMod" )
mod_name_ulib=( ulib ub "Ulib" )
mod_name_ulx=( ulx ux "ULX" )
mod_name_rustoxide=( rustoxide ro "Oxide for Rust" )
mod_name_hwoxide=( hwoxide ho "Oxide for Hurtworld" )
mod_name_sdtdoxide=( sdtdoxide so "Oxide for 7 Days To Die" )

# Define mods URLs
fn_mods_urls(){
	mod_url_sourcemod="http://sourcemod.net/latest.php?os=Linux&version=1.8"
	mod_url_metamod="http://cdn.probablyaserver.com/sourcemod/mmsource-1.10.6-linux.tar.gz"
	mod_url_ulib="https://codeload.github.com/TeamUlysses/ulib/zip/master"
	mod_url_ulx="https://codeload.github.com/TeamUlysses/ulx/zip/master"
	mod_url_rustoxide="https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Rust_Linux.zip"
	mod_url_hwoxide="https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Hurtworld_Linux.zip"
	mod_url_sdtdoxide="https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-7DaysToDie_Linux.zip"
}

# Set install directories
fn_mods_install_dir(){
# If systemdir doesn't exist, then the game isn't installed
if [ ! -d "${systemdir}" ]; then
	fn_print_fail "${gamename} needs to be installed first."
	core_exit.sh
fi

# Unity3D games 
if [ "${engine}" == "unity3d" ]; then
	modsinstalldir="${systemdir}"
# Source Games
elif [ "${engine}" == "source" ]; then
	modsinstalldir="${systemdir}/addons"
fi
}

# Define mods commands
fn_mods_commands(){
	# Source Games
	if [ "${engine}" == "source" ]&&[ "${gamename}" != "Garry's Mod" ]; then
		modsarray=( sm sourcemod mm metamod )
		read -r -d '' modslist <<- End
			sm | sourcemod | http://www.sourcemod.net/
			mm | metamod | https://www.sourcemm.net/
		End
	fi

	# Garry's Mod
	if [ "${gamename}" == "Garry's Mod" ]; then
		modsarray=( ulib ub ulx ux)
		read -r -d '' modslist <<- End
			ulib | ub | http://ulyssesmod.net/
			ulx | ux | http://ulyssesmod.net/
		End
	fi

	# Rust
	if [ "${gamename}" == "Rust" ]; then
		modsarray=( rustoxide ro )
		read -r -d '' modslist <<- End
			rustoxide | ro | http://oxidemod.org/downloads/oxide-for-rust.1659/
		End
	fi

	# Hurtworld
	if [ "${gamename}" == "Hurtworld" ]; then
		modsarray=( hwoxide ho )
		read -r -d '' modslist <<- End
			hwoxide | ho | http://oxidemod.org/downloads/oxide-for-hurtworld.1332/
		End
	fi

	# 7 Days to Die
	if [ "${gamename}" == "7 Days To Die" ]; then
		modsarray=( sdtdoxide so )
		read -r -d '' modslist <<- End
			sdtdoxide | so | http://oxidemod.org/downloads/oxide-for-7-days-to-die.813/
		End
	fi
}

# Prettify mod name
# For output during mod installation & update
fn_mod_name_prettify(){
if [ "${currentmod}" == "sourcemod" ]||[ "${currentmod}" == "sourcemod" ]; then
	currentmod_prettyname="${mod_name_sourcemod[2]}"
elif [ "${currentmod}" == "metamod" ]||[ "${currentmod}" == "mm" ]; then
	currentmod_prettyname="${mod_name_metamod[2]}"
elif [ "${currentmod}" == "ulib" ]||[ "${currentmod}" == "ub" ]; then
	currentmod_prettyname="${mod_name_ulib[2]}"
elif [ "${currentmod}" == "ulx" ]||[ "${currentmod}" == "ux" ]; then
	currentmod_prettyname="${mod_name_ulx[2]}"
elif [ "${currentmod}" == "rustoxide" ]||[ "${currentmod}" == "ro" ]; then
	currentmod_prettyname="${mod_name_rustoxide[2]}"
elif [ "${currentmod}" == "hwtoxide" ]||[ "${currentmod}" == "ho" ]; then
	currentmod_prettyname="${mod_name_hwoxide[2]}"
elif [ "${currentmod}" == "sdtdoxide" ]||[ "${currentmod}" == "so" ]; then
	currentmod_prettyname="${mod_name_sdtdoxide[2]}"
fi
}

fn_mods_install_dir
fn_mods_urls
fn_mods_commands