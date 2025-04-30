{ pkgs, lib, config, ... }:

let
  cfg = config.xdg.configHome;
  hd = config.home.homeDirectory;
  
  # Fetch repositories once
  kittyRepo = builtins.fetchGit {
    url = "https://github.com/n1smm/kitty.git";
    ref = "master";
  };
  
  inceptionRepo = builtins.fetchGit {
  	url = "https://github.com/n1smm/Inception-42.git";
	ref = "main";
  };

in {
  home.stateVersion = "24.11";
  xdg.enable = true;

  home.packages = [ pkgs.git pkgs.openssh ];

  # ===== Kitty Config (Writable) =====
  home.activation.setupKitty = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Copy files from Nix store to config directory
    mkdir -p "${cfg}/kitty"
    cp -rT "${kittyRepo}" "${cfg}/kitty"
    
    # Make all files writable
    chmod -R u+w "${cfg}/kitty"
  '';

  # ===== Home Directory Repo =====
  home.activation.setupInception = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${hd}/inception"
    cp -rT "${inceptionRepo}" "${hd}/inception"
    chmod -R u+w "${hd}/inception"
  '';
  # home.file."inception" = {
  #   source = builtins.fetchGit {
  #     url = "https://github.com/n1smm/Inception-42.git";
  #     ref = "main";
  #   };
  #   recursive = true;
  #   force = true;
  # };
}
