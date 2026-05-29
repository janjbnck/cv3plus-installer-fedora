#!/bin/bash
set -e

COLS="$(tput cols 2>/dev/null || echo 80)"

printf '%*s' "$COLS" '' | tr ' ' '-'
echo "Removing Dell ControlVault3 Plus Driver"
printf '%*s' "$COLS" '' | tr ' ' '-'
echo -e "\n"

read -p "Do you really want to delete the Dell ControlVault3 Plus driver? (y/N): " removal_confirmation

case $removal_confirmation in
    y | Y | yes | Yes | YES)
        echo ""

        if [ -d /var/lib/fprint ]; then
            while IFS= read -r u; do sudo fprintd-delete "$u" || true; done < <(sudo find /var/lib/fprint -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
        fi
        sudo systemctl stop fprintd

        sudo authselect disable-feature with-fingerprint
        sudo authselect apply-changes

        sudo rm -f /usr/lib64/libfprint-2/tod-1/libfprint-2-tod-1-broadcom-cv3plus.so
        sudo rm -f /usr/lib/udev/rules.d/60-libfprint-2-device-broadcom-cv3plus.rules
        sudo rm -rf /var/lib/fprint/.broadcomCv3plusFW
        sudo rm -rf /usr/share/licenses/libfprint-2-tod1-broadcom-cv3plus

        sudo udevadm control --reload-rules
        sudo udevadm trigger

        sudo dnf remove libfprint-tod -y || true
        sudo dnf copr remove grahamwhiteuk/libfprint-tod -y || true
        sudo dnf install fprintd -y

        sudo semodule -X 400 -r broadcom-fprintd || true

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
