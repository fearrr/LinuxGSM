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
	# REQUIRED: mod_info_name=( MOD modcommand "Pretty Name" "URL" filename "${installdir}" "Supported Engines;" "Supported Games;" "Unsupported Games;" "AUTHOR_URL")
	# None of those values can be empty
	# [index]	| Usage
	# [0] 	| MOD is a separator and is value [O] of the array
	# [1] 	| modcommand is the LGSM command and name for the mod (must be unique)
	# [2] 	| "Pretty Name" is the common name people use to call the mod, should be in double quotes
	# [3] 	| URL to download the file. Can be a variable defined in fn_mods_nasty_urls, double quote is for a better look
	# [4] 	| The output filename, needed for fn_fetch_file
	# [5] 	| ${installdir} must use LGSM dir variables
	# [6] 	| List all "Supported Engines" according to LGSM ${engine} variable, all between double quotes, each one separated with a semicolon, or use NA to ignore the value
	# [7] 	| List all "Supported Games" according to LGSM ${gamename} variable, all between double quotes, each one separated with a semicolon, or use NA to ignore the value 
	# [8]	| List all "Unsupported Games", all between double quotes, each one separated with a semicolon, or use NA to ignore the value (useful to exclude a game when using [7])
	# [9]	| "AUTHOR_URL" is the author's website, displayed when chosing mods to install, double quote is for a better look

	# Source mods
	mod_info_sourcemod=( MOD sourcemod "SourceMod" "${sourcemodurl}" "${sourcemodlatestfile}" "${systemdir}" "source;" "NA" "Garry's Mod;" "http://www.sourcemod.net/" )
	mod_info_metamod=( MOD metamod "MetaMod" "${metamodurl}" "${metamodlatestfile}" "${systemdir}" "source;" "NA" "Garry's Mod;" "https://www.sourcemm.net/" )
	# Garry's Mod Addons
	mod_info_ulib=( MOD ulib "ULib" "https://codeload.github.com/TeamUlysses/ulib/zip/master" ulib-master.zip "${systemdir}/addons" "NA" "Garry's Mod;" "NA" "http://ulyssesmod.net/" )
	mod_info_ulx=( MOD ulx "ULX" "https://codeload.github.com/TeamUlysses/ulx/zip/master" ulx-master.zip "${systemdir}/addons" "NA" "Garry's Mod;" "NA" "http://ulyssesmod.net/" )
	mod_info_utime=( MOD utime "UTime" "https://github.com/TeamUlysses/utime/archive/master.zip" utime-master.zip "${systemdir}/addons" "NA" "Garry's Mod;" "NA" "http://ulyssesmod.net/" )
	mod_info_uclip=( MOD uclip "UClib" "https://github.com/TeamUlysses/uclip/archive/master.zip" uclip-master.zip "${systemdir}/addons" "NA" "Garry's Mod;" "NA" "http://ulyssesmod.net/" )
	mod_info_acf=( MOD acf "Armoured Combat Framework" "https://github.com/nrlulz/ACF/archive/master.zip" acf-master.zip "${systemdir}/addons" "NA" "Garry's Mod;" "NA" "https://github.com/nrlulz/ACF" )
	# Oxidemod
	mod_info_rustoxide=( MOD rustoxide "Oxide for Rust" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Rust.zip" Oxide-Rust_Linux.zip "${systemdir}" "NA" "Rust;" "NA" "http://oxidemod.org/downloads/oxide-for-rust.1659/" )
	mod_info_hwoxide=( MOD hwoxide "Oxide for Hurtworld" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Hurtworld.zip" Oxide-Hurtworld_Linux.zip "${systemdir}" "NA" "Hurtworld;" "NA" "http://oxidemod.org/downloads/oxide-for-hurtworld.1332/" )
	mod_info_sdtdoxide=( MOD sdtdoxide "Oxide for 7 Days To Die" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-7DaysToDie.zip" Oxide-7DaysToDie_Linux.zip "${systemdir}" "NA" "7 Days To Die;" "NA" "http://oxidemod.org/downloads/oxide-for-7-days-to-die.813/" )

	# REQUIRED: Set all mods info into one array for convenience
	mods_global_array=( "${mod_info_sourcemod[@]}" "${mod_info_metamod[@]}" "${mod_info_ulib[@]}" "${mod_info_ulx[@]}" "${mod_info_utime[@]}" "${mod_info_uclip[@]}" "${mod_info_acf[@]}" "${mod_info_rustoxide[@]}" "${mod_info_hwoxide[@]}" "${mod_info_sdtdoxide[@]}" )
}

# Get a proper URL for mods that don't provide a good one (optional)
fn_mods_nasty_urls(){
	# Sourcemod
	sourcemodmversion="1.8"
	sourcemodscrapeurl="http://www.gsptalk.com/mirror/sourcemod"
	sourcemodlatestfile="$(wget "${sourcemodscrapeurl}/?MD" -q -O -| grep "sourcemod-" | grep "\-linux" | head -n1 | awk -F '>' '{ print $3 }' | awk -F '<' '{ print $1}')"
	sourcemodfasterurl="http://cdn.probablyaserver.com/sourcemod/"
	sourcemodurl="${sourcemodfasterurl}/${sourcemodlatestfile}"
	# Metamod
	metamodscrapeurl="http://www.gsptalk.com/mirror/sourcemod"
	metamodlatestfile="$(wget "${metamodscrapeurl}/?MD" -q -O -| grep "mmsource" | grep "\-linux" | head -n1 | awk -F '>' '{ print $3 }' | awk -F '<' '{ print $1}')"
	metamodfasterurl="http://cdn.probablyaserver.com/sourcemod/"
	metamodurl="${metamodfasterurl}/${metamodlatestfile}"
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
	indexmodcommand=$((index+1))
	indexmodprettyname=$((index+2))
	indexmodurl=$((index+3))
	indexmodfilename=$((index+4))
	indexmodinstalldir=$((index+5))
	indexmodengines=$((index+6))
	indexmodgames=$((index+7))
	indexmodexcludegames=$((index+8))
	indexmodsite=$((index+9))
}

# Define all variables from a mod at once when index is set to a separator
fn_mod_info(){
	fn_var_rel_index
	modcommand="${mods_global_array[indexmodcommand]}"
	modprettyname="${mods_global_array[indexmodprettyname]}"
	modurl="${mods_global_array[indexmodurl]}"
	modfilename="${mods_global_array[indexmodfilename]}"
	modinstalldir="${mods_global_array[indexmodinstalldir]}"
	modengines="${mods_global_array[indexmodengines]}"
	modgames="${mods_global_array[indexmodgames]}"
	modexcludegames="${mods_global_array[indexmodexcludegames]}"
	modsite="${mods_global_array[indexmodsite]}"
}


# Find out if a game is compatible with a mod from a modgames (list of games supported by a mod) variable
fn_compatible_mod_games(){
	# Reset test value
	modcompatiblegame="0"
	# If value is set to NA (ignore)
	if [ "${modgames}" != "NA" ]; then
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
	fi
}

# Find out if an engine is compatible with a mod from a modengines (list of engines supported by a mod) variable
fn_compatible_mod_engines(){
	# Reset test value
	modcompatibleengine="0"
	# If value is set to NA (ignore)
	if [ "${modengines}" != "NA" ]; then
		# How many engines we need to test
		enginesamount="$(echo "${modengines}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modengines" using the ";" separator
		for ((gamevarindex=1; gamevarindex < ${enginesamount}; gamevarindex++)); do
			# Put current engine name into modtest variable
			enginemodtest="$( echo "${modengines}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If engine name matches
			if [ "${enginemodtest}" == "${engine}" ]; then
				# Mod is compatible !
				modcompatibleengine="1"
			fi
		done
	fi
}

# Find out if a game is not compatible with a mod from a modnotgames (list of games not supported by a mod) variable
fn_not_compatible_mod_games(){
	# Reset test value
	modeincompatiblegame="0"
	# If value is set to NA (ignore)
	if [ "${modexcludegames}" != "NA" ]; then
		# How many engines we need to test
		excludegamesamount="$(echo "${modexcludegames}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modexcludegames" using the ";" separator
		for ((gamevarindex=1; gamevarindex < ${excludegamesamount}; gamevarindex++)); do
			# Put current engine name into modtest variable
			excludegamemodtest="$( echo "${modexcludegames}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If engine name matches
			if [ "${excludegamemodtest}" == "${gamename}" ]; then
				# Mod is compatible !
				modeincompatiblegame="1"
			fi
		done
	fi
}

# Sums up if a mod is compatible or not with modcompatibility=0/1
fn_mod_compatible_test(){
	# Test game and engine compatibility
	fn_compatible_mod_games
	fn_compatible_mod_engines
	fn_not_compatible_mod_games
	if [ "${modeincompatiblegame}" == "1" ]; then
		modcompatibility="0"
	elif [ "${modcompatibleengine}" == "1" ]||[ "${modcompatiblegame}" == "1" ]; then
		modcompatibility="1"
	else
		modcompatibility="0"
	fi
}

# Checks if a mod is compatibile for installation
# Provides available mods for installation
# Provides commands for mods installation
fn_mods_available(){
	# First, reset variables
	compatiblemodslist=()
	availablemodscommands=()
	# Find compatible games
	# Find separators through the global array
	for ((index="0"; index <= ${#mods_global_array[@]}; index++)); do
		# If current value is a separator; then
		if [ "${mods_global_array[index]}" == "${modseparator}" ]; then
			# Set mod variables
			fn_mod_info
			# Test if game is compatible
			fn_mod_compatible_test
			# If game is compatible
			if [ "${modcompatibility}" == "1" ]; then
				# Put it into the list to display to the user
				compatiblemodslist+=( "${modprettyname}" "${modsite}" "${modfilename}" "${modcommand}" )
				# Keep available commands in an array
				availablemodscommands+=( "${modcommand}" )
			fi
		fi
	done
}

# Output available mods in a nice way to the user
fn_mods_show_available(){
	compatiblemodslistindex=0
	while [ "${compatiblemodslistindex}" -lt "${#compatiblemodslist[@]}" ]; do
		echo -e "\e[1m${compatiblemodslist[compatiblemodslistindex]}\e[0m | ${compatiblemodslist[compatiblemodslistindex+1]} | ${compatiblemodslist[compatiblemodslistindex+2]} | Install Command: \e[36m${compatiblemodslist[compatiblemodslistindex+3]}\e[0m"
		let "compatiblemodslistindex+=4"
		echo ""
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

fn_mods_nasty_urls
fn_mods_info
fn_mods_available
fn_mods_install_checks