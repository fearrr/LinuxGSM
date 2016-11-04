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

## Useful variables
# Files and Directories
modstmpdir="${tmpdir}/mods"
modslockdir="${lgsmdir}/data"
modslockfile="mods-installed.txt"
modslockfilefullpath="${modslockdir}/${modslockfile}"
# Separator name
modseparator="MOD"

# Define mods information (required)
fn_mods_info(){
	# REQUIRED: mod_info_name=( MOD name shortname "Pretty Name" "URL" filename "${installdir}" "Supported Engines;" "Supported Games;" "Unsupported Games;" "AUTHOR_URL")
	# None of those values can be empty
	# [index]	| Usage
	# [0] 	| MOD is a separator and is value [O] of the array
	# [1] 	| name is the LGSM name for the mod
	# [2] 	| shortname is the lgsm shortname for the mod
	# [3] 	| "Pretty Name" is the common name people use to call the mod, should be in double quotes
	# [4] 	| URL to download the file. Can be a variable defined in fn_mods_nasty_urls, double quote is for a better look
	# [5] 	| The output filename, needed for fn_fetch_file
	# [6] 	| ${installdir} must use LGSM dir variables
	# [7] 	| List all "Supported Engines" according to LGSM ${engine} variable, all between double quotes, each one separated with a semicolon, or use NA to ignore the value (use either [7] or [8], not both, not none)
	# [8] 	| List all "Supported Games" according to LGSM ${gamename} variable, all between double quotes, each one separated with a semicolon, or use NA to ignore the value (use either [7] or [8], not both, not none)
	# [9]	| List all "Unsupported Games", all between double quotes, each one separated with a semicolon, or use NA to ignore the value (useful to exclude a game when using [7])
	# [10]	| "AUTHOR_URL" is the author's website, displayed when chosing mods to install, double quote is for a better look

	# Source mods
	mod_info_sourcemod=( MOD sourcemod sm "SourceMod" "https://sm.alliedmods.net/smdrop/1.8/sourcemod-1.8.0-git5948-linux.tar.gz" sourcemod-1.8.0-git5948-linux.tar.gz "${systemdir}" "source;" "NA" "NA" "http://www.sourcemod.net/" )
	mod_info_metamod=( MOD metamod mm "MetaMod" "http://cdn.probablyaserver.com/sourcemod/mmsource-1.10.6-linux.tar.gz" mmsource-1.10.6-linux.tar.gz "${systemdir}" "source;" "NA" "NA" "https://www.sourcemm.net/" )
	# Garry's Mod Addons
	mod_info_ulib=( MOD ulib ub "ULib" "https://codeload.github.com/TeamUlysses/ulib/zip/master" ulib-master.zip "${systemdir}/addons" "NA" "Garry's Mod;" "NA" "http://ulyssesmod.net/" )
	mod_info_ulx=( MOD ulx ux "ULX" "https://codeload.github.com/TeamUlysses/ulx/zip/master" ulx-master.zip "${systemdir}/addons" "NA" "Garry's Mod;" "NA" "http://ulyssesmod.net/" )
	# Oxidemod
	mod_info_rustoxide=( MOD rustoxide ro "Oxide for Rust" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Rust_Linux.zip" Oxide-Rust_Linux.zip "${systemdir}" "NA" "Rust;" "NA" "http://oxidemod.org/downloads/oxide-for-rust.1659/" )
	mod_info_hwoxide=( MOD hwoxide ho "Oxide for Hurtworld" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Hurtworld_Linux.zip" Oxide-Hurtworld_Linux.zip "${systemdir}" "NA" "Hurtworld;" "NA" "http://oxidemod.org/downloads/oxide-for-hurtworld.1332/" )
	mod_info_sdtdoxide=( MOD sdtdoxide so "Oxide for 7 Days To Die" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-7DaysToDie_Linux.zip" Oxide-7DaysToDie_Linux.zip "${systemdir}" "NA" "7 Days To Die;" "NA" "http://oxidemod.org/downloads/oxide-for-7-days-to-die.813/" )

	# REQUIRED: Set all mods info into one array for convenience
	mods_global_array=( "${mod_info_sourcemod[@]}" "${mod_info_metamod[@]}" "${mod_info_ulib[@]}" "${mod_info_ulx[@]}" "${mod_info_rustoxide[@]}" "${mod_info_hwoxide[@]}" "${mod_info_sdtdoxide[@]}" )
}

# Get a proper URL for mods that don't provide a good one (optional)
fn_mods_nasty_urls(){
# Sourcemod & metamod will come here
true;
}

# Define variables relative to index
# Once the index is set to a separator, variable location is allways the same relative to it
# We  can then get all useful values from mods
fn_var_rel_index(){
# If for some reason no index is set, none of this can work
if [ -z "$index" ]; then
	fn_print_error "index variable not set. Please report an issue to LGSM Team."
	echo "* https://github.com/GameServerManagers/LinuxGSM/issues"
	core_exit.sh
fi
	indexmodseparator=$((index+0))
	indexmodname=$((index+1))
	indexmodshortname=$((index+2))
	indexmodprettyname=$((index+3))
	indexmodurl=$((index+4))
	indexmodfilename=$((index+5))
	indexmodinstalldir=$((index+6))
	indexmodengines=$((index+7))
	indexmodgames=$((index+8))
	indexmodnotgames=$((index+9))
	indexmodsite=$((index+10))
}

# Define all variables from a mod at once when index is set to a separator
fn_mod_info(){
	fn_var_rel_index
	modname="${mods_global_array[indexmodname]}"
	modshortname="${mods_global_array[indexmodshortname]}"
	modprettyname="${mods_global_array[indexmodprettyname]}"
	modurl="${mods_global_array[indexmodurl]}"
	modfilename="${mods_global_array[indexmodfilename]}"
	modinstalldir="${mods_global_array[indexmodinstalldir]}"
	modengines="${mods_global_array[indexmodengines]}"
	modgames="${mods_global_array[indexmodgames]}"
	modnotgames="${mods_global_array[indexmodnotgames]}"
	modsite="${mods_global_array[indexmodsite]}"
}


# Find out if a game is compatible with a mod from a modgames (list of games supported by a mod) variable
fn_compatible_mod_games(){
	# Reset test value
	modcompatiblegame="0"
	# How many games we need to test
	gamesamount="$(echo "${modgames}" | awk -F ';' '{ print NF }')"
	# Test all subvalue of "modgames" using the ";" separator
	for ((gamevarindex=1; gamevarindex < ${gamesamount}; gamevarindex++)); do
		# Put current game name into modtest variable
		gamemodtest="$( echo "${modgames}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
		# If game name matches
		if [ "${gamemodtest}" == "${gamename}" ]; then
			# Mod is compatible !
			modcompatiblegame="1"
		fi
	done
}

# Find out is an engine is compatible with a mod from a modengines (list of engines supported by a mod) variable
#fn_compatible_mod_engines(){
#}

# Find out if a game is not compatible with a mod from a modnotgames (list of games not supported by a mod) variable
#fn_not_compatible_mod_games(){
#}

# Checks if a mod is compatibile for installation
# Provides available mods for installation
# Provides commands for mods installation
fn_mods_available(){
	# First, reset variables
	compatiblemodslist=""
	availablemodscommands=()
	# Find compatible games
	# Find separators through the global array
	for ((index="0"; index <= ${#mods_global_array[@]}; index++)); do
		# If current value is a separator; then
		if [ "${mods_global_array[index]}" == "${modseparator}" ]; then
			# Set mod variables
			fn_mod_info
			# Test if game is compatible
			fn_compatible_mod_games
			# If game is compatible
			if [ "${modcompatiblegame}" == "1" ]; then
				# Put it into the list to display to the user
				compatiblemodslist="${compatiblemodslist}${modprettyname} | ${modname} | ${modshortname} | ${modsite}\n"
				# Keep available commands in an array
				availablemodscommands+=( "${modprettyname}" "${modname}" "${modshortname}" )
			fi
		fi
	done
}

# Get details of a mod any (relevant and unique, such as full mod name or install command) value
fn_mod_get_all_info(){
	# Variable to know when job is done
	mod_get_all_info="0"
	# Find entry in global array
	for ((index=0; index <= ${#mods_global_array[@]}; index++)); do
		# When entry is found
		if [ "${mods_global_array[index]}" == "${currentmod}" ]; then
			# Go back to the previous "MOD" separator
			for ((index=index; index <= ${#mods_global_array[@]}; index--)); do
				# When "MOD" is found
				if [ "${mods_global_array[index]}" == "MOD" ]; then
					# Get info
					fn_mod_info
					mod_get_all_info="1"
					break
				fi
			done
		fi
		# Exit the loop if job is done
		if [ "${mod_get_all_info}" == "1" ]; then
			break
		fi
	done
}

# Requirements to install mods
fn_mods_install_checks(){
	# If no mods are found
	if [ -z "${compatiblemodslist}" ]; then
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

fn_mods_info
fn_mods_available
fn_mods_install_checks
fn_mods_nasty_urls