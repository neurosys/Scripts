#!/usr/bin/env bash

# 1. Creates user with a home directory in /home/<user_type>/<username>
# 2. Adds the user to the 'neurosys' group, 'sudo', and 'docker' groups.
# 3. Sets a password for the user.


# There is a high chance that this script works only on Debian-based systems.
if [ $UID -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

userName="$1"
myNormalUserGroup="neurosys"
# Types: work, personal, test
userType=${2:-personal}

if [[ -z "$userName" ]]; then
    echo -e "Usage:\n\t$0 <username> [<user_type>]"
    echo -e "Example:\n\t$0 john work"
    echo -e "\nUser type can be 'work', 'personal', or 'test'. Default is 'personal'."
    echo ""
    exit 1
fi

echo "Creating user '$userName' with group '$myNormalUserGroup'..."

sudo useradd \
    --create-home \
    --base-dir /home/$userType \
    --shell /bin/bash \
    --user-group \
    --groups ${myNormalUserGroup},sudo,docker \
    --comment "Project user $userName" \
    "$userName"

echo "Enter password for user '$userName':"

passwd "$userName"

