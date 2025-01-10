# True Tor Stack

*Shæreded Tor gateway for increasing darkweb speed*

## Introduction

True Tor Stack is a tool for running Tor under an invisible webtunnel obfuscation solution along with rotation every week onto a new tunnel endpoint set.
<br/>
Utilizes `torbridge-cli` to automatically obtain webtunnel bridges and establish a connection to the darkweb.

## Used submodules

All used submodules can be found in [.gitmodules](.gitmodules) file.

## Ethical concerns

**I'M NOT LIABLE FOR ANY DAMAGE OR ILLEGAL USE OF THE TOOL, IT WAS MADE FOR EDUCATIONAL AND RESEARCH PURPOSES.**
**BY USING SAID SOFTWARE YOU AGREE TO TAKE THE FULL RESPONSIBILITY OF YOUR ACTIONS.**

External `torbridge-cli` tool uses Tor Bridges website, which might rise doubts about being anonymous.
Try to fork it and develop alternative way to automatically obtain bridges through i.e. Telegram or email (GMail?).

Or provide alternative database store medium (Sharing between friends? Scrapping database onto another storage medium?).

## License

The tool is using the [MIT](LICENSE.md) License.
<br/>
Why? Spread the knowledge and how to load balance resources in every way.

# Installation

There are 2 ways to install this project: through Git repository or docker-compose.yml standalone.

## Method 1.

1. Fetch the git repository: `git clone --recursive --depth 1 -b main https://git.chimmie.k.vu/GamePlayer-8/true-tor-stack`
2. Install Docker or Podman for container management. (For Kubernetes, please refer to Method 1.2.)
3. Check if Docker or Podman is running through `docker ps -a` or `podman ps -a`. For Docker or Podman rootless please refer to external wikis.
4. Enter the directory and execute `docker compose up -d` or `podman-compose up -d`.

## Method 1.1

 * Using ghcr as container source storage

1. Follow the Method 1 till point 4th.
2. Modify `docker-compose.yml` file and comment `build:` directives, uncomment `image:` directives.
3. Execute `docker compose up -d` or `podman-compose up -d`.

## Method 1.2

 * Using Kubernetes

1. Follow the Method 1 till point 4th.
2. Follow the Method 1.1 till point 3rd.
3. Use Kubernetes tools to convert `docker-compose.yml` to Kubernetes-compatible Yaml formats (search the web).

## Method 2

1. Download `docker-compose.yml` from the source directory (go [here](docker-compose.yml)).
2. Install Docker or Podman for container management. (For Kubernetes, please refer to Method 2.2.)
3. Check if Docker or Podman is running through `docker ps -a` or `podman ps -a`. For Docker or Podman rootless please refer to external wikis.
4. Enter the directory and execute `docker compose up -d` or `podman-compose up -d`.

## Method 2.1

 * Using ghcr as container source storage

1. Follow the Method 2 till point 4th.
2. Modify `docker-compose.yml` file and comment `build:` directives, uncomment `image:` directives.
3. Execute `docker compose up -d` or `podman-compose up -d`.

## Method 2.2

 * Using Kubernetes

1. Follow the Method 2 till point 4th.
2. Follow the Method 2.1 till point 3rd.
3. Use Kubernetes tools to convert `docker-compose.yml` to Kubernetes-compatible Yaml formats (search the web).

# Usage

After successful start, you should be able to see exposed port `9050/tcp` and `9040/tcp`.
 * `9050/tcp` is a SOCKS5 proxy
 * `9040/tcp` is a TRANS proxy

SOCKS5 can be used by web browsers while TRANS proxy for transparent communication, along with using `iptables` to redirect ports.

## Limitations

UDP protocol haven't yet been implemented by the Tor Team. Make sure they will do implement to fully proxy your home network over it.
