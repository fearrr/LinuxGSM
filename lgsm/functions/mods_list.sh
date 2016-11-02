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

# Useful variables
modstmpdir="${tmpdir}/mods"
modslockdir="${lgsmdir}/data"
modslockfile="mods-installed.txt"
modslockfilefullpath="${modslockdir}/${modslockfile}"

# Define mods information (required)
fn_mods_info(){
	# REQUIRED: mod_info_name=( MOD name shortname "Pretty Name" "URL" filename "${installdir}" "Supported Engines" "Supported Games" "AUTHOR_URL")
	# None of those values can be empty
	# [ ID] 	| Usage
	# [0] 	| MOD is a separator and is value [O] of the array
	# [1] 	| name is the LGSM name for the mod
	# [2] 	| shortname is the lgsm shortname for the mod
	# [3] 	| "Pretty Name" is the common name people use to call the mod, should be in double quotes
	# [4] 	| URL to download the file. Can be a variable defined in fn_mods_nasty_urls, double quote is for a better look
	# [5] 	| The output filename, needed for fn_fetch_file
	# [6] 	| ${installdir} must use LGSM dir variables
	# [7] 	| List all "Supported Engines" according to LGSM ${engine} variable, separated with a coma, or use NA to ignore the value (use either [7] or [8], not both, not none)
	# [8] 	| List all "Supported Games" according to LGSM ${gamename} variable, separated with a coma, or use NA to ignore the value (use either [7] or [8], not both, not none)
	# [9]	| "AUTHOR_URL" is the author's website, displayed when chosing mods to install, double quote is for a better look

	# Source mods
	mod_info_sourcemod=( MOD sourcemod sm "SourceMod" "https://sm.alliedmods.net/smdrop/1.8/sourcemod-1.8.0-git5948-linux.tar.gz" sourcemod-1.8.0-git5948-linux.tar.gz "${systemdir}" "source" "NA" "http://www.sourcemod.net/" )
	mod_info_metamod=( MOD metamod mm "MetaMod" "http://cdn.probablyaserver.com/sourcemod/mmsource-1.10.6-linux.tar.gz" mmsource-1.10.6-linux.tar.gz "${systemdir}" "source" "NA" "https://www.sourcemm.net/" )
	# Garry's Mod Addons
	mod_info_ulib=( MOD ulib ub "ULib" "https://codeload.github.com/TeamUlysses/ulib/zip/master" ulib-master.zip "${systemdir}/addons" "NA" "Garry's Mod" "http://ulyssesmod.net/" )
	mod_info_ulx=( MOD ulx ux "ULX" "https://codeload.github.com/TeamUlysses/ulx/zip/master" ulx-master.zip "${systemdir}/addons" "NA" "Garry's Mod" "http://ulyssesmod.net/" )
	# Oxidemod
	mod_info_rustoxide=( MOD rustoxide ro "Oxide for Rust" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Rust_Linux.zip" Oxide-Rust_Linux.zip "${systemdir}" "NA" "Rust" "http://oxidemod.org/downloads/oxide-for-rust.1659/" )
	mod_info_hwoxide=( MOD hwoxide ho "Oxide for Hurtworld" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Hurtworld_Linux.zip" Oxide-Hurtworld_Linux.zip "${systemdir}" "NA" "Hurtworld" "http://oxidemod.org/downloads/oxide-for-hurtworld.1332/" )
	mod_info_sdtdoxide=( MOD sdtdoxide so "Oxide for 7 Days To Die" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-7DaysToDie_Linux.zip" Oxide-7DaysToDie_Linux.zip "${systemdir}" "NA" "7 Days To Die" "http://oxidemod.org/downloads/oxide-for-7-days-to-die.813/" )

	# REQUIRED: Set all mods info into one array for convenience
	mods_global_array=( ${mod_info_sourcemod[@]} ${mod_info_metamod[@]} ${mod_info_ulib[@]} ${mod_info_ulx[@]} ${mod_info_rustoxide[@]} ${mod_info_hwoxide[@]} ${mod_info_sdtdoxide[@]} )
}

# Get a proper URL for mods that don't provide a good one (optional)
fn_mods_nasty_urls(){
# Sourcemod & metamod will come here
true;
}

# Define mods commands for installation
# DEV NOTE: This needs to be gotten from the array
fn_mods_available(){
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
		modsarray=( ulib ub ulx ux )
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

# Get prettyfied mod name
# Required for output during mod installation & update and for getting the URL
fn_mod_name_prettify(){
# Find entry in global array
for ((index=0; index <= ${#mods_global_array[@]}; index++)); do
	# When entry is found
	if [ "${mods_global_array[index]}" == "${currentmod}" ]; then
		# Go back to the previous "MOD" separator
		for ((index=index; index <= ${#mods_global_array[@]}; index--)); do
			# When "MOD" is found
			if [ "${mods_global_array[index]}" == "MOD" ]; then
				# Pretty name is then the third next value
				currentmod_prettyname="${mods_global_array[index+3]}"
				break
			fi
		done
	fi
	# Exit the loop if prettyname is found
	if [ -n "${currentmod_prettyname}" ]; then
			break
	fi
done
}

# Get URL from a currentmod_prettyname
# URL is the next value into the array after the Pretty Name
fn_mod_get_url(){
# Look through the array
for ((index=0; index <= ${#mods_global_array[@]}; index++)); do
	# When prettyname matches
	if [ "${mods_global_array[index]}" == "${currentmod_prettyname}" ]; then
		# prettyname found, next value is URL
		mod_url="${mods_global_array[index+1]}"
	fi
done
}

# Gets archive filename from a currentmod_prettyname
fn_mod_get_filename(){
# Look through the array
for ((index=0; index <= ${#mods_global_array[@]}; index++)); do
	# When prettyname matches
	if [ "${mods_global_array[index]}" == "${currentmod_prettyname}" ]; then
		# prettyname found, next next value is URL
		mod_filename="${mods_global_array[index+2]}"
	fi
done
}

# Set install directory depending on the mod structure
fn_mods_install_dir(){
# Look through the array
for ((index=0; index <= ${#mods_global_array[@]}; index++)); do
	# When prettyname matches
	if [ "${mods_global_array[index]}" == "${currentmod_prettyname}" ]; then
		# prettyname found, next next value is URL
		mod_destination="${mods_global_array[index+3]}"
	fi
done
}

# Requirements to install mods
fn_mods_install_checks(){
	# If no mods are found
	if [ -z "${modslist}" ]; then
		fn_print_fail "No mods are currently available for ${gamename}."
		core_exit.sh
	# If systemdir doesn't exist, then the game isn't installed
	elif [ ! -d "${systemdir}" ]; then
		fn_print_fail "${gamename} needs to be installed first."
		core_exit.sh
	# If tompdir variable doesn't exist, LGSM is too old
	elif [ -z "${tmpdir}" ]||[ -z "${lgsmdir}" ]; then
			fn_print_fail "Your LGSM version is too old."
			echo " * Please do a full update, including ${selfname} script."
			core_exit.sh
	fi
}

fn_mods_available
fn_mods_install_checks
fn_mods_nasty_urls
fn_mods_info