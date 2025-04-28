#!/usr/bin/env bash
set -e
set -x

# Create FTP user if missing
if ! id "$FTP_USER" &>/dev/null; then

	echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

	mkdir -p "/home/$FTP_USER/ftp/files"
	chown -R "$FTP_USER":"$FTP_USER" "/home/$FTP_USER"
fi

mkdir -p /home/$FTP_USER/ftp/files
chown root:root /home/$FTP_USER/ftp
chmod 755 /home/$FTP_USER/ftp
chown $FTP_USER:$FTP_USER /home/$FTP_USER/ftp/files

# Run vsftpd in foreground
exec "$@"
