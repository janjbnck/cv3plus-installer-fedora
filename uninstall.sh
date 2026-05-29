#!/bin/bash
set -e

printf %"$(tput cols)"s | tr " " "-"
echo "Removing Dell ControlVault3 Plus Driver"
printf %"$(tput cols)"s | tr " " "-"
echo -e "\n"

read -p "Do you really want to delete the Dell ControlVault3 Plus driver? (y/N): " removal_confirmation

case $removal_confirmation in
    y | Y | yes | Yes | YES)
        echo ""

        sudo fprintd-delete "$USER"
        sudo systemctl stop fprintd

        sudo authselect disable-feature with-fingerprint
        sudo authselect apply-changes

        sudo rm /usr/lib64/libfprint-2/tod-1/libfprint-2-tod-1-broadcom-cv3plus.so
        sudo rm /usr/lib/udev/rules.d/60-libfprint-2-device-broadcom-cv3plus.rules
        sudo rm -r /var/lib/fprint/.broadcomCv3plusFW
        sudo rm -r /usr/share/licenses/libfprint-2-tod1-broadcom-cv3plus

        sudo udevadm control --reload-rules
        sudo udevadm trigger

        sudo dnf remove libfprint-tod -y
        sudo dnf copr remove grahamwhiteuk/libfprint-tod -y
        sudo dnf install fprintd -y

        sudo semodule -X 400 -r broadcom-fprintd

        sudo systemctl start fprintd

        echo -e "\n"
        echo "Done."
        ;;
    *)
        echo ""
        echo "Operation cancelled."
        exit 1
        ;;
esac
