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

fn_script_log "Entering mods installation"
echo "================================="
echo "${gamename} mods & addons installation"

# Continue prompting as long as the user input doesn't correspond to an available mod
while [[ ! " ${modsarray[@]} " =~ " ${moduserselect} " ]]
do
		echo ""
		echo "Available mods:"
		echo "${modslist}"	
		echo ""
		echo "(input exit to abort)"
		echo "Please, enter a valid mod or input exit to abort."
        read -r moduserselect
        if [ "${moduserselect}" == "exit" ]||[ "${moduserselect}" == "abort" ]; then
				fn_script_log "User aborted"
				echo "Aborted."
                core_exit.sh
		elif [[ ! " ${modsarray[@]} " =~ " ${moduserselect} " ]]; then
			fn_print_error2_nl "${moduserselect} is not a valid mod."
        fi
done

currentmod="${moduserselect}"
fn_mod_name_prettify
echo "You selected ${currentmod_prettyname}"
fn_script_log "Initiating ${currentmod_prettyname} installation."

# Create mods directory if it doesn't exist
# Assuming the game is already installed as mods_list.sh checked for it.
if [ ! -d "${modsinstalldir}" ]; then
	fn_script_log_info "Creating mods directory at ${modsinstalldir}"
	fn_print_dots "Creating mods directory: ${modsinstalldir}"
	sleep 1
	mkdir -p "${modsinstalldir}"
	fn_print_ok "Created mods directory: ${modsinstalldir}"
fi