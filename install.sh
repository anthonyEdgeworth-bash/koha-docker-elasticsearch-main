#!/bin/bash

# Evitar que git pida usuario y detener si hay errores
export GIT_TERMINAL_PROMPT=0
set -e

echo "--- 1. Actualizando el sistema ---"
sudo dnf update -y

echo "--- 2. Instalando dependencias (incluyendo unzip y curl) ---"
sudo dnf install -y dnf-plugins-core git net-tools curl unzip
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "--- 3. Instalando Docker y Docker Compose ---"
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- 4. Configurando el Firewall (8080 y 8081) ---"
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload

echo "--- 5. Configurando SELinux para Docker (AlmaLinux) ---"
# Esto evita el Error 500 por bloqueos de red o permisos
sudo setenforce 0 || true
sudo setsebool -P container_manage_cgroup on || true

echo "--- 6. Iniciando Docker ---"
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

echo "--- 7. Obteniendo repositorio ---"
REPO_DIR="koha-docker-elasticsearch-main"
if [ -d "$REPO_DIR" ]; then
    echo "Limpiando instalación anterior para asegurar limpieza..."
    rm -rf "$REPO_DIR"
fi
git clone https://github.com/anthonyEdgeworth-bash/koha-docker-elasticsearch-main.git

cd "$REPO_DIR/examples"

echo "--- 8. Desplegando contenedores ---"
sudo docker compose up -d

echo "--- 9. Esperando estabilidad del sistema (60 seg) ---"
# Damos tiempo a MariaDB para inicializar las tablas
sleep 60
sudo docker compose restart koha

echo "--- --- --- --- --- --- --- --- ---"
echo "--- ¡PROCESO COMPLETADO! ---"
MI_IP=$(hostname -I | awk '{print $1}')
echo "Koha está listo en:"
echo "- Intranet (Configuración): http://$MI_IP:8081"
echo "- OPAC (Público): http://$MI_IP:8080"
echo "--- --- --- --- --- --- --- --- ---"
