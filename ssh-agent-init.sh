#!/bin/sh

choice=1

# -------------------------------------------------------------------

switch() {
    mode='agent_and_keys'
    if [ ${choice} == 1 ]
    then
	mode='only_agent'
    fi
}

# -------------------------------------------------------------------
# Auto-start SSH Agent only, key loaded during first SSH call
# -------------------------------------------------------------------
launch_only_ssh_agent(){
    if [ -z "$SSH_AUTH_SOCK" ]; then
	eval "$(ssh-agent -s)" > /dev/null
    fi
}

# -------------------------------------------------------------------
# Auto-start SSH Agent & Load multiple VM Keys on Login
# Called from ${HOME}/.profile
# -------------------------------------------------------------------
launch_ssh_agent_add_keys() {   
    if [ -z "$SSH_AUTH_SOCK" ]; then
	# Start the agent process
	eval $(ssh-agent -s) > /dev/null
	
	echo "=================================================="
	echo "🔐  Unlocking VM SSH Keys for this session..."
	echo "=================================================="

	# List all the specific VM keys you want to load here (separated by spaces)
	# You can use standard names or custom filenames you created
	MY_KEYS="id_ed25519 id_rsa vm1_key _vm2_ed25519"

	for key in $MY_KEYS; do
            if [ -f "${HOME}/.ssh/${key}" ]; then
		echo "--> Loading key: ${key}"
		ssh-add "${HOME}/.ssh/${key}"
            fi
	done
	echo "=================================================="
    fi
}

# -------------------------------------------------------------------
# Main

main() {
    switch
    if [ ${mode} == 'only_agent' ]
    then
	launch_only_ssh_agent
    else
	launch_ssh_agent_add_keys
    fi
    return
}
# -------------------------------------------------------------------
# Call main

main
trap 'test -n "$SSH_AGENT_PID" && eval "$(ssh-agent -k)" > /dev/null' 0

# -------------------------------------------------------------------
# End
