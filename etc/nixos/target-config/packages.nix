# THIS IS THE PACKAGES FILE IF IT WAS NOT OBVIOUS FROM THE NAME OF THE FILE

{ config, pkgs, ...}:

{
  # user packages
  users.users.nismm = {
    packages = with pkgs; [
      neovim
      kitty
    ];
  };

  # global packages
  environment.systemPackages = with pkgs; [
    #basic utilities
    zsh
    vim
    wget
    curl
    # Version control
    git
    # Build tools and compilers for C/C++
    gcc
    # Programming languages
    clang  # For C/C++ development
    python3
    nodejs
    # Useful development utilities
    docker
    nixos-generators # generator of nix isos
  ];
}
