#!/bin/bash
# LGSM command_mods_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: List and installs available mods along with mods_list.sh.

local commandname="MODS"
local commandaction="Mod Installation"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
mods_list.sh

fn_mods_install_init(){
	fn_script_log "Entering mods & addons installation"
	echo "================================="
	echo "${gamename} mods & addons installation"

	# Keep prompting as long as the user input doesn't correspond to an available mod
	while [[ ! " ${availablemodscommands[@]} " =~ " ${currentmod} " ]]; do
			echo ""
			echo "Available mods:"
			# compatiblemodslist comes from mods_list.sh depending on gamename or engine
			echo -en "${compatiblemodslist}"	
			echo "(input exit to abort)"
			echo ""
			echo "Enter the mod you wish to install:"
			read -r currentmod
			# Exit if user says exit or abort
			if [ "${currentmod}" == "exit" ]||[ "${currentmod}" == "abort" ]; then
					fn_script_log "User aborted."
					echo "Aborted."
					core_exit.sh
			# Supplementary output upon invalid user input 
			elif [[ ! " ${availablemodscommands[@]} " =~ " ${currentmod} " ]]; then
				fn_print_error2_nl "${currentmod} is not a valid mod."
				echo " * Enter a valid mod or input exit to abort."
			fi
	done

	# Gives a pretty name to the user and get all mod info
	fn_mod_get_all_info
	fn_print_dots "Installing ${modprettyname}"
	sleep 1
	fn_script_log "Installing ${modprettyname}."
}

# Create mods directory if it doesn't exist
# Assuming the game is already installed as mods_list.sh checked for it.
fn_mods_dir(){
	if [ ! -d "${modinstalldir}" ]; then
		fn_script_log_info "Creating mods directory: ${modinstalldir}"
		fn_print_dots "Creating mods directory"
		sleep 1
		mkdir -p "${modinstalldir}"
		fn_print_ok_nl "Created mods directory"
	fi
}

# Clear mod download directory so that there is only one file in it since we don't the file name and extention
fn_clear_tmp_mods(){
	if [ -d "${modstmpdir}" ]; then
		rm -r "${modstmpdir}"
		fn_script_log "Clearing temp mod download directory: ${modstmpdir}"
	fi
}

# Create tmp download mod directory
fn_mods_tmpdir(){
	if [ ! -d "${modstmpdir}" ]; then
			mkdir -p "${modstmpdir}"
			fn_script_log "Creating temp mod download directory: ${modstmpdir}"
	fi
}

# Add the mod to the installed mods list
fn_mod_add_list(){
	# Create lgsm/data directory
	if [ ! -d  "${modslockdir}" ]; then
		mkdir -p "${modslockdir}"
		fn_script_log "Created ${modslockdir}"
	fi
	# Create lgsm/data/${modslockfile}
	if [ ! -f "${modslockfilefullpath}" ]; then
		touch "${modslockfilefullpath}"
		fn_script_log "Created ${modslockfilefullpath}"
	fi
	# Input mod name to lockfile
	if [ ! -n "$(cat "${modslockfilefullpath}" | grep "${modprettyname}")" ]; then
		echo "${modprettyname}" >> "${modslockfilefullpath}"
		fn_script_log "${modprettyname} added to ${modslockfile}"
	fi
}

# Download and extract the mod using core_dl.sh
fn_mod_installation(){
	# Get mod info
	fn_mod_get_all_info
	# Clear lgsm/tmp/mods dir if exists then recreate it
	fn_clear_tmp_mods
	fn_mods_tmpdir
	# Download mod
	# fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
	fileurl="${modurl}"
	filedir="${modstmpdir}"
	filename="${modfilename}" 
	fn_script_log "Downloading mods to ${modstmpdir}"
	fn_fetch_file "${fileurl}" "${filedir}" "${filename}"
	# Check if variable is valid checking if file has been downloaded and exists
	if [ ! -f "${modstmpdir}/${modfilename}" ]; then
		fn_print_fail "An issue occurred upon downloading ${modprettyname}"
		core_exit.sh
	fi
	# Extract the mod
	# fn_dl_extract "${filedir}" "${filename}" "${extractdir}"
	filename="${modfilename}"
	extractdir="${modinstalldir}"
	fn_dl_extract "${filedir}" "${filename}" "${extractdir}"
	# Ending with installation routines
	fn_clear_tmp_mods
	fn_mod_add_list
	fn_print_ok_nl "${modprettyname} installed."
	fn_script_log "${modprettyname} installed."
}

fn_mods_install_checks
fn_mods_install_init
fn_mods_dir
fn_mod_installation
fn_mod_add_list