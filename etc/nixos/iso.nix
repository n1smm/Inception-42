# iso.nix - Configuration for building a NixOS installation ISO
{ config, pkgs, lib, modulesPath, ... }:

let
  # Import Home Manager
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz;


  inceptionRepo = builtins.fetchGit {
  	url = "https://github.com/n1smm/Inception-42.git";
	ref = "main";
  };

in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    (import "${home-manager}/nixos")
  ];

  # ISO-specific settings
  isoImage = {
    edition = "custom";
    compressImage = true;
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  # Include Home Manager configuration for the live user
  home-manager.users.nixos = { pkgs, config, lib, ... }: {
    imports = [ ./home.nix ];  # Your existing home configuration


    # Override home directory settings for live environment
    home = {
      username = "nixos";
      homeDirectory = "/home/nixos";
      stateVersion = "24.11";
    };

    # Customize for live environment
    xdg.enable = true;
    
    # Add specific Inception setup for ISO
	 home.activation.setupInception = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.home.homeDirectory}/inception"
      cp -rT "${inceptionRepo}" "${config.home.homeDirectory}/inception"
      chmod -R u+w "${config.home.homeDirectory}/inception"
    '';
  };

  # Existing hardware/filesystem configuration
  boot.supportedFilesystems = [ "btrfs" "ext4" ];
  
  # Networking configuration
  networking = {
    networkmanager.enable = true;
    wireless.enable = lib.mkForce false;
    hostName = "nixos";
	extraHosts = ''
	  127.0.0.1 tjuvan.42.fr www.tjuvan.42.fr
  	'';
  };

  # Essential tools (add home-manager dependencies)
  environment.systemPackages = with pkgs; [
    vim git wget curl
    parted gparted htop
    nixos-install-tools nixos-generators
    docker
	gnumake
	gcc
	docker-compose
	php
	filezilla
	openssl
	procps
    bash coreutils
    home-manager  # Add home-manager CLI
  ];

  # Live environment user configuration
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
     initialHashedPassword = "";
     hashedPassword = null;
     password = null;
     hashedPasswordFile = null;
    initialPassword = "password123";
    shell = pkgs.bash;
  };

  # Rest of your existing ISO configuration
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  virtualisation.docker.enable = true;
  # networking.extraHosts = ''
	  # 127.0.0.1 tjuvan.42.fr www.tjuvan.42.fr
  # '';


  system.activationScripts.installerCustomization = ''
    mkdir -p /etc/nixos/target
    cp -r ${./target-config}/* /etc/nixos/target/
    chmod +x /etc/nixos/target/install.sh
  '';

  system.stateVersion = "24.11";


}
