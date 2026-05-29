#!/bin/bash
set -e

printf %"$(tput cols)"s | tr " " "-"
echo "Installing Dell ControlVault3 Plus Driver"
printf %"$(tput cols)"s | tr " " "-"
echo -e "\n"

read -p "Do you really want to install the latest Dell ControlVault3 Plus driver? (y/N): " confirmation

case $confirmation in
    y | Y | yes | Yes | YES)
        echo ""
        sudo dnf copr enable grahamwhiteuk/libfprint-tod -y
        sudo dnf install tar curl fprintd fprintd-pam libfprint-tod -y --allowerasing

        BASE_URL="https://packages.broadcom.com/artifactory/dell-controlvault-drivers"
        ARCHIVE="$(curl -fsSL $BASE_URL | grep 'brcm_linux_fp' | sed 's/<[^>]*>//g' | awk '{print $1;}' | sort | tail -n 1)"

        WORKDIR="$(mktemp -d)"
        cd $WORKDIR

        curl -LO "${BASE_URL}/${ARCHIVE}"
        tar -xf $ARCHIVE
        cd brcm_linux_fp

        sudo mkdir -p \
            /usr/lib64/libfprint-2/tod-1 \
            /usr/lib/udev/rules.d \
            /var/lib/fprint/.broadcomCv3plusFW \
            /usr/share/licenses/libfprint-2-tod1-broadcom-cv3plus

        sudo install -m 644 ./LICENCE.broadcom /usr/share/licenses/libfprint-2-tod1-broadcom-cv3plus/LICENSE

        sudo install -m 755 ./usr/lib/x86_64-linux-gnu/libfprint-2/tod-1/libfprint-2-tod-1-broadcom-cv3plus.so /usr/lib64/libfprint-2/tod-1/

        sudo install -m 644 ./lib/udev/rules.d/60-libfprint-2-device-broadcom-cv3plus.rules /usr/lib/udev/rules.d/
        sudo udevadm control --reload-rules
        sudo udevadm trigger

        cat > broadcom-fprintd.te <<'EOF'
module broadcom-fprintd 1.0;

require {
    type fprintd_t;
    type var_run_t;
    class dir { add_name write };
    class file { append create getattr read open write };
}

allow fprintd_t var_run_t:dir { add_name write };

allow fprintd_t var_run_t:file { append create getattr read open write };
EOF

        sudo checkmodule -M -m -o broadcom-fprintd.mod broadcom-fprintd.te
        sudo semodule_package -o broadcom-fprintd.pp -m broadcom-fprintd.mod
        sudo semodule -i broadcom-fprintd.pp

        sudo restorecon -Rv \
            /usr/lib64/libfprint-2/tod-1 \
            /usr/lib/udev/rules.d \
            /var/lib/fprint

        sudo systemctl restart fprintd
        fprintd-enroll

        sudo authselect enable-feature with-fingerprint
        sudo authselect apply-changes

        echo -e "\n"
        echo "Done."
        ;;
    *)
        echo ""
        echo "Operation cancelled."
        exit 1
        ;;
esac
