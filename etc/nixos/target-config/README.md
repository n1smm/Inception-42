# NixOS Custom Installation ISO

This repository contains the configuration files and scripts needed to build a custom NixOS installation ISO.

## Building the ISO

To build the ISO, run the following command:

```bash
./build-iso.sh
```

This will create an ISO file in the `result/iso/` directory.

```
user = nixos
password = password123
```

## running inception directly from installer image

1. cd into inception directory and run `make` to see the options.
2. rename env_example.txt into .env (it needs to be here: `./srcs/.env`)
3. `make up` to run the build/run containers

## Installing NixOS

1. Boot from the ISO in your virtual machine
2. Log in with username `nixos` and password `nixos`
3. Open a terminal and run:

```bash
sudo /etc/nixos/target/install.sh
```

4. Follow the prompts to install NixOS on your virtual machine
5. After installation, reboot and log in with username `nismm` and password `changeme`
6. Change your password immediately with `passwd`

## Customizing the Installation

You can customize the installation by editing the following files:

- `target-config/configuration.nix`: Main system configuration
- `target-config/home.nix`: Home Manager configuration
- `target-config/packages.nix`: Package definitions

## Troubleshooting

If you encounter issues during installation:

1. Check the installation logs in `/tmp/nixos-install.log`
2. Make sure your virtual machine has enough disk space (at least 20GB recommended)
3. Ensure your virtual machine has at least 2GB of RAM
