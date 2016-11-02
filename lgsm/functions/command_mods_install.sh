#!/bin/bash
# LGSM command_mods_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: List and installs available mods.

local commandname="MODS"
local commandaction="Mod Installation"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
mods_list.sh

fn_mods_install_checks(){
# Conditions to install mods: 
# If no mods are found
if [ -z "${modslist}" ]; then
	fn_print_fail "No mods are currently available for ${gamename}."
	core_exit.sh
# If systemdir doesn't exist, then the game isn't installed
elif [ ! -d "${systemdir}" ]; then
	fn_print_fail "${gamename} needs to be installed first."
	core_exit.sh
fi
}

fn_mods_install_init(){
	fn_script_log "Entering mods & addons installation"
	echo "================================="
	echo "${gamename} mods & addons installation"

	# Keep prompting as long as the user input doesn't correspond to an available mod
	while [[ ! " ${modsarray[@]} " =~ " ${moduserselect} " ]]
	do
			echo ""
			echo "Available mods:"
			# modslist comes from mods_list.sh depending on gamename or engine
			echo "${modslist}"	
			echo "(input exit to abort)"
			echo ""
			echo "Enter the mod you wish to install:"
			read -r moduserselect
			# Exit if user says exit or abort
			if [ "${moduserselect}" == "exit" ]||[ "${moduserselect}" == "abort" ]; then
					fn_script_log "User aborted."
					echo "Aborted."
					core_exit.sh
			# Supplementary output upon invalid user input 
			elif [[ ! " ${modsarray[@]} " =~ " ${moduserselect} " ]]; then
				fn_print_error2_nl "${moduserselect} is not a valid mod."
				echo " * Enter a valid mod or input exit to abort."
			fi
	done

	# Gives a pretty name to the user
	currentmod="${moduserselect}"
	fn_mod_name_prettify
	fn_print_dots_nl "Installing ${currentmod_prettyname}"
	fn_script_log "Installing ${currentmod_prettyname}."
}

# Create mods directory if it doesn't exist
# Assuming the game is already installed as mods_list.sh checked for it.
fn_mods_dir(){
if [ ! -d "${modsinstalldir}" ]; then
	fn_script_log_info "Creating mods directory: ${modsinstalldir}"
	fn_print_dots "Creating mods directory"
	sleep 1
	mkdir -p "${modsinstalldir}"
	fn_print_ok "Created mods directory"
fi
}

# Clear mod download directory so that there is only one file in it since we don't the file name and extention
fn_clear_tmp_mods(){
	rm -r "${modsdldir}/*"
	fn_script_log "Clearing temp mod download directory: ${modsdldir}"
}

# Download and extract the mod using core_dl.sh
fn_mod_installation(){
	# Create or clear lgsm/tmp/mods dir 
	if [ -n "${tmpdir}" ]; then
		modsdldir="${tmpdir}/mods"
		if [ ! -d "${modsdldir}" ]; then
			mkdir -p "${modsdldir}"
			fn_script_log "Creating temp mod download directory: ${modsdldir}"
		else
			fn_clear_tmp_mods
		fi
	else
		# tompdir variable doesn't exist, LGSM is too old.
		fn_print_fail "Your LGSM version is too old."
		echo " * Please make a full update, including ${selfname} script."
		core_exit.sh
	fi
	fn_mods_dir
	# Get URL as ${mod_url} from mods_list.sh
	fn_mod_get_url
	# Get mod filename from mods_list.sh function
	fn_mod_get_filename
	# Download mod
	# fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
	fileurl="${mod_url}"
	filedir="${modsdldir}"
	filename="${mod_filename}" 
	echo "Downloading mods to ${modsdldir}"
	fn_fetch_file "${fileurl}" "${filedir}" "${filename}"
	# Check if variable is valid checking if file has been downloaded and exists
	if [ ! -f "${modsdldir}/${mod_filename}" ]; then
		fn_print_fail "An issue occurred upon downloading ${currentmod_prettyname}"
		core_exit.sh
	fi
	# Extract the mod
	# fn_dl_extract "${filedir}" "${filename}" "${extractdir}"
	filename="${mod_filename}"
	extractdir="${modsinstalldir}"
	fn_dl_extract "${filedir}" "${filename}" "${extractdir}"
	fn_clear_tmp_mods
	fn_print_ok "${currentmod_prettyname} installed."
}

# Add the mod to the installed mods list
fn_mod_add_list(){
true; 
}

fn_mods_install_checks
fn_mods_install_init
fn_mods_dir
fn_mod_installation
fn_mod_add_list