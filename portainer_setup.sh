# Setup Portainer on Docker Swarm

# Add Portainer
ssh -tt $user@$manager1 -i ~/.ssh/$certName sudo su <<EOF
mkdir /mnt/Portainer
curl -L https://raw.githubusercontent.com/JamesTurland/JimsGarage/main/Docker-Swarm/portainer-agent-stack.yml -o portainer-agent-stack.yml
docker stack deploy -c portainer-agent-stack.yml portainer

docker service ls
exit
EOF
echo -e " \033[32;5mPortainer deployed\033[0m"
