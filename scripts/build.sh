#!/bin/bash

build_image_docker() {
    echo "Iniciando build!"
    docker-compose build
}

echo "Deseja reconstruir a imagem do docker ?"
echo "Digite 1 para recriar"
echo "Digite 2 para sair"

read choice

if [ "$choice" == "1" ]; then
    build_image_docker
elif [ "$choice" == "2" ]; then
    echo "Saindo..."
else
    echo "Opção inválida. Saindo..."
fi
