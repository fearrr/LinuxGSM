#!/bin/bash
# LGSM command_mods_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: List and installs available mods.

local commandname="MODS"
local commandaction="Install_Mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
mods_list.sh

if [ -z "${modslist}" ]; then
	fn_print_fail "No mods are currently available for ${gamename}."
	core_exit.sh
fi

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
		echo ""
		echo "(input exit to abort)"
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
echo ""
fn_print_dots "Installing ${currentmod_prettyname}"
fn_script_log "Initiating ${currentmod_prettyname} installation."

# Create mods directory if it doesn't exist
# Assuming the game is already installed as mods_list.sh checked for it.
if [ ! -d "${modsinstalldir}" ]; then
	fn_script_log_info "Creating mods directory: ${modsinstalldir}"
	fn_print_dots_nl "Creating mods directory"
	sleep 1
	mkdir -p "${modsinstalldir}"
	fn_print_ok "Created mods directory"
fi

