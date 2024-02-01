#!/bin/bash

project_directories=("Nova-server-eureka" "Nova-auth" "Nova-core" "Nova-mail" "Nova-cloud-gateway")
project_docker="docker-dev"

if [ "$project_docker" == "docker-dev" ]; then
    if [ -d "$project_docker" ]; then
        echo "Desligando Docker em $project_docker..."
        (cd "$project_docker" && docker-compose down)
        echo "Docker em $project_docker desligado."
    fi
fi

for dir in "${project_directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "Desligando serviço em $dir..."
        pkill -f "mvn spring-boot:run"
        echo "Serviço em $dir desligado."
    fi
done
