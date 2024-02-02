#!/bin/bash

project_directories=("Nova-server-eureka" "Nova-auth" "Nova-core" "Nova-mail" "Nova-cloud-gateway")
project_docker="docker-dev"

cleanup() {
    echo "Recebido sinal de interrupção. Desligando serviços..."
    stop_docker
    stop_services
    exit 1
}

check_process_running() {
    local process_name=$1
    pgrep -f "$process_name" > /dev/null
}

stop_docker() {
    if [ "$project_docker" == "docker-dev" ]; then
        if [ -d "$project_docker" ]; then
            echo "Desligando Docker em $project_docker..."
            (cd "$project_docker" && docker-compose down)
            echo "Docker em $project_docker desligado."
        fi
    fi
}

stop_services() {
    for dir in "${project_directories[@]}"; do
        if [ -d "$dir" ]; then
            echo "Desligando serviço em $dir..."
            pkill -f "mvn spring-boot:run"
            echo "Serviço em $dir desligado."
        fi
    done
}

start_repository() {
    local repo_dir=$1
    if [ -d "$repo_dir" ]; then
        echo "Iniciando repositório em $repo_dir..."
        if [ -x "$repo_dir/mvnw" ]; then
            (cd "$repo_dir" && ./mvnw spring-boot:run &) || { echo "Erro ao iniciar repositório em $repo_dir."; exit 1; }
            wait_for_process "mvn spring-boot:run" 6
            echo "Repositório em $repo_dir iniciado."
        else
            echo "Erro: Permissão de execução negada para $repo_dir/mvnw."
            exit 1
        fi
    else
        echo "Erro: O diretório $repo_dir não existe."
        exit 1
    fi
}

trap 'cleanup' INT

wait_for_process() {
    local process_name=$1
    local max_attempts=$2
    local current_attempt=0

    if check_process_running "$process_name"; then
        echo "Processo $process_name já está em execução."
        return
    fi

    echo "Processo $process_name iniciado."
}

initialize_docker() {
    echo "Iniciando Docker em $project_docker..."
    (docker-compose up -d) || { echo "Erro ao iniciar Docker em $project_docker."; exit 1; }
    wait_for_process "docker-compose" 6
    echo "Docker em $project_docker iniciado."
}

initialize_services() {
    for dir in "${project_directories[@]}"; do
        if [ -d "$dir" ]; then
            echo "Iniciando serviço em $dir..."

            if [ -x "$dir/mvnw" ]; then
                (cd "$dir" && ./mvnw spring-boot:run &) || { echo "Erro ao iniciar serviço em $dir."; exit 1; }
                wait_for_process "mvn spring-boot:run" 6
                echo "Serviço em $dir iniciado."
            else
                echo "Erro: Permissão de execução negada para $dir/mvnw."
                exit 1
            fi
        else
            echo "Erro: O diretório $dir não existe."
            exit 1
        fi
    done
}

initialize_repositories() {
    read -p "Digite os diretórios dos repositórios que deseja iniciar (separados por espaço): " repositories
    for repo in $repositories; do
        start_repository "$repo"
    done
}

echo "Bem vindo a Nova-software!"
echo "Selecione a opção de inicialização:"
echo "1. Inicializar Docker"
echo "2. Inicializar Serviços em Diretórios"
echo "3. Inicializar Repositórios Específicos"
echo "4. Inicializar Ambos"
read -p "Digite o número da opção desejada: " choice

case $choice in
    1)
        initialize_docker
        ;;
    2)
        initialize_services
        ;;
    3)
        initialize_repositories
        ;;
    4)
        initialize_docker
        initialize_services
        ;;
    *)
        echo "Opção inválida. Saindo."
        exit 1
        ;;
esac

wait
