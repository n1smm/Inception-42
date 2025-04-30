# Inception Project


---

## Prerequisites

- **Docker** (>= 20.10)
- **Docker Compose** (>= v2)
- **Make**
- **Git**

Ensure Docker and Docker Compose are installed and that your user has permission to run Docker commands (or use `sudo`).

---

## Setup

1. **Clone the repository**:

   ```bash
   git clone <repo-url>
   cd inception2
   ```

2. **Environment variables**:
   - Copy the example file and rename it to `.env` in the `srcs/` directory:

     ```bash
     cp srcs/env_example.txt srcs/.env
     ```

   - Open `srcs/.env` and review or update credentials and site-specific settings.

3. **Directory for persistent data**:
   - The Makefile will create host directories under `${HOME}/data` for MariaDB, WordPress, Redis, and Portainer. Ensure you have write permissions.

---

## Makefile Targets

Run `make help` to list all available commands:

```bash
make help
```

### build

Builds all Docker images without starting containers. Also creates data directories:

```bash
make build
```

### up

Builds (if needed) and starts all containers in detached mode:

```bash
make up
```

### down

Stops and removes all containers:

```bash
make down
```

### clean

Stops containers and removes images and orphaned resources:

```bash
make clean
```

### fclean

Removes containers, images, volumes, and network caches:

```bash
make fclean
```

### clean_host_data

Destroys all host data under `${HOME}/data` (requires `sudo` if permissions restrict you):

```bash
make clean_host_data
```

### status

Displays detailed info on running containers:

```bash
make status
```

### logs

Tails logs of all containers:

```bash
make logs
```

### check

Performs health and connectivity checks against the MariaDB service and lists databases:

```bash
make check
```

### re

Shortcut to rebuild and restart:

```bash
make re
```

---

## Docker Compose

All services are orchestrated by Docker Compose using the file `srcs/inception.yaml`. Key services and their ports:

| Service   | Container Name | Ports                             | Notes                                           |
|-----------|----------------|-----------------------------------|-------------------------------------------------|
| MariaDB   | mariadb        | (internal)                        | Health‑checked by WordPress and Adminer          |
| WordPress | wordpress      | (internal)                        | Depends on mariadb & redis                      |
| Nginx     | nginx          | 443:443                           | Hosts WordPress with SSL certs                  |
| Redis     | redis          | (internal)                        | Caching layer, health‑checked                   |
| FTP       | ftp            | 21,20,40000-40005                 | Exposes WordPress files; see FTP section below  |
| Adminer   | adminer        | 7070:7070                         | Database manager for MariaDB                    |
| Portainer | portainer      | 9443:9443                         | Docker UI; mounts Docker socket & SSL certs     |
| Website   | website        | 3000:3000                         | Custom frontend application                     |

Persistent data for MariaDB, WordPress, Redis, and Portainer is stored on the host in `${HOME}/data/<service>` via bind mounts.

---

## Accessing Services

### WordPress

- **URL:** `https://tjuvan.42.fr`
- **Admin Login:**
  - **User:** `bossman`
  - **Password:** (from `WORDPRESS_ADMIN_PASSWORD` in `.env`)

Incoming requests are routed through the Nginx container.

### Adminer

- **URL:** `http://localhost:7070`
- **Login credentials:**
  - **Server:** `mariadb`
  - **Username/Password:** from `.env`

### Portainer

- **URL:** `https://localhost:9443`
- **Login credentials:** Set up via Portainer's first-time web UI.

### Custom Website

- **URL:** `http://localhost:3000`

### FTP (FileZilla)

Use your favorite FTP client (e.g., FileZilla) to connect:

- **Host:** `localhost`
- **Port:** `21`
- **Protocol:** FTP (plain)
- **User:** value of `FTP_USER` in `.env`
- **Password:** value of `FTP_PASSWORD` in `.env`
- **Remote directory:** `/home/${FTP_USER}/ftp/files`

### Redis

Redis is used internally by WordPress; no direct public endpoint is exposed.

---

