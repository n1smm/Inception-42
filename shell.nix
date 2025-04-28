#shell.nix for inception project

{pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
	name = "docker_tut";

	buildInputs = [
		pkgs.cmake
			pkgs.zsh
			pkgs.php
			pkgs.curl
			pkgs.procps
			pkgs.sudo
			pkgs.systemd
			pkgs.gcc
			pkgs.git
			pkgs.docker
			pkgs.docker-compose
			pkgs.nginx
			pkgs.openssl
			pkgs.neovim
			pkgs.filezilla
	];

	shellHook = ''
		echo "welcome to Inception only shell"
		# export SHELL=$(which zsh)
		export PS1="❄ inception-shell $PS1"
	'';
	
}

