# Docker on Photon Setup Scripts
Deployment scripts for photon

host_setup.sh:
- Configures static ip
- Enables ping
- Updates packages and installs nano and less
- Adds user
- Starts docker and enables start on boot

swarm_setup.sh:
- Creates docker swarm and adds nodes

portainer_setup.sh:
- Installs portainer service on docker swarm
