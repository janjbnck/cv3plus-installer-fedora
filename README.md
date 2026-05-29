# Dell ControlVault3 Plus Driver Installer for Fedora Linux

## Installation

Run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/janjbnck/cv3plus-installer-fedora/refs/heads/main/install.sh)"
```

If `curl` is not installed, clone the repository and run:

```bash
./install.sh
```

## Supported Hardware IDs

Run `lsusb` to check whether your device is supported by this driver using the list below:

- 5864
- 5865*
- 5866
- 5867

*\*5865 is currently the only hardware ID that this script has been thoroughly tested on. However, it should also work with the other IDs listed above.*

## Removal

To remove the installation, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/janjbnck/cv3plus-installer-fedora/refs/heads/main/uninstall.sh)"
```

If `curl` is not installed, clone the repository and run:

```bash
./uninstall.sh
```

## Credits

- [Silvanosky for the AUR package that helped with the installation logic](https://aur.archlinux.org/packages/libfprint-2-tod1-broadcom-cv3plus)
- [grahamwhiteuk for the `libfprint-tod` repository](https://copr.fedorainfracloud.org/coprs/grahamwhiteuk/libfprint-tod)
