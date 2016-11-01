#!/bin/bash
# LGSM mods_list.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Lists and defines available mods for LGSM supported servers

local commandname="MODS"
local commandaction="List Mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

# Define mods names
# mod_info_name=( name shortname "Pretty Name" "URL" )
mod_info_sourcemod=( sourcemod sm "SourceMod" "http://sourcemod.net/latest.php?os=Linux&version=1.8" )
mod_info_metamod=( metamod mm "MetaMod" "http://cdn.probablyaserver.com/sourcemod/mmsource-1.10.6-linux.tar.gz" )
mod_info_ulib=( ulib ub "Ulib" "https://codeload.github.com/TeamUlysses/ulib/zip/master" )
mod_info_ulx=( ulx ux "ULX" "https://codeload.github.com/TeamUlysses/ulx/zip/master" )
mod_info_rustoxide=( rustoxide ro "Oxide for Rust" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Rust_Linux.zip" )
mod_info_hwoxide=( hwoxide ho "Oxide for Hurtworld" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Hurtworld_Linux.zip" )
mod_info_sdtdoxide=( sdtdoxide so "Oxide for 7 Days To Die" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-7DaysToDie_Linux.zip" )

# Set all mods info into one array for convenience
mods_global_array=( ${mod_info_sourcemod[@]} ${mod_info_metamod[@]} ${mod_info_ulib[@]} ${mod_info_ulx[@]} ${mod_info_rustoxide[@]} ${mod_info_hwoxide[@]} ${mod_info_sdtdoxide[@]} )

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

# Define mods commands for installation
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
if [ "${currentmod}" == "sourcemod" ]||[ "${currentmod}" == "sm" ]; then
	currentmod_prettyname="${mod_info_sourcemod[2]}"
elif [ "${currentmod}" == "metamod" ]||[ "${currentmod}" == "mm" ]; then
	currentmod_prettyname="${mod_info_metamod[2]}"
elif [ "${currentmod}" == "ulib" ]||[ "${currentmod}" == "ub" ]; then
	currentmod_prettyname="${mod_info_ulib[2]}"
elif [ "${currentmod}" == "ulx" ]||[ "${currentmod}" == "ux" ]; then
	currentmod_prettyname="${mod_info_ulx[2]}"
elif [ "${currentmod}" == "rustoxide" ]||[ "${currentmod}" == "ro" ]; then
	currentmod_prettyname="${mod_info_rustoxide[2]}"
elif [ "${currentmod}" == "hwtoxide" ]||[ "${currentmod}" == "ho" ]; then
	currentmod_prettyname="${mod_info_hwoxide[2]}"
elif [ "${currentmod}" == "sdtdoxide" ]||[ "${currentmod}" == "so" ]; then
	currentmod_prettyname="${mod_info_sdtdoxide[2]}"
fi
}

# Get URL from a mod prettyname
fn_mod_get_url(){
for ((index=0; index <= ${#mods_global_array[@]}; index++)); do
	if [ "${mods_global_array[index]}" == "${currentmod_prettyname}" ]; then
		mod_url="${mods_global_array[index+1]}"
	fi
done
}

fn_mods_install_dir
fn_mods_urls
fn_mods_commands