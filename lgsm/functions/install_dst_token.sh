#!/bin/bash
# LGSM install_dst_token.sh function
# Author: Marvin Lehmann (marvinl97)
# Website: https://gameservermanagers.com
# Description: Configures dstserver cluster with given token.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

echo ""
echo "Enter ${gamename} Cluster Token"
echo "================================="
sleep 1
echo "A cluster token is required to run this server"
echo "Follow the instructions in this link to obtain this key:"
echo "https://gameservermanagers.com/dst-auth-token"
echo ""
if [ -z "${autoinstall}" ]; then
	echo "Once you have the cluster token, enter it below"
	echo -n "Cluster Token: "
	read token
	echo "${token}" > "${clustercfgdir}/cluster_token.ini"
	if [ -f "${clustercfgdir}/cluster_token.ini" ]; then
		fn_script_log_info "DST cluster token created"
	fi
else
	echo "You can add your cluster token using the following command"
	echo "./${selfname} cluster-token"
fi
echo ""