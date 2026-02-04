#!/bin/bash

# Configuración inicial para evitar errores interactivos
export GIT_TERMINAL_PROMPT=0
set -e

echo "--- 1. Actualizando el sistema ---"
sudo dnf update -y

echo "--- 2. Instalando dependencias necesarias ---"
sudo dnf install -y dnf-plugins-core git net-tools curl unzip
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "--- 3. Instalando Docker y Docker Compose ---"
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- 4. Configurando Firewall (Puertos 8080 y 8081) ---"
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload

echo "--- 5. Ajustando SELinux para contenedores (AlmaLinux) ---"
# Esto es CRÍTICO para evitar el error 500 y problemas de permisos
sudo setenforce 0 || true
sudo setsebool -P container_manage_cgroup on || true

echo "--- 6. Iniciando servicio Docker ---"
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

echo "--- 7. Clonando repositorio ---"
REPO_DIR="koha-docker-elasticsearch-main"

# Limpieza preventiva por si re-ejecutas el script
if [ -d "$REPO_DIR" ]; then
    echo "Eliminando versión anterior del repo..."
    rm -rf "$REPO_DIR"
fi

git clone https://github.com/anthonyEdgeworth-bash/koha-docker-elasticsearch-main.git

cd "$REPO_DIR/examples"

echo "--- 8. Desplegando contenedores ---"
# Ya no necesitamos sleep. Docker coordinará el inicio gracias a tu YAML mejorado.
sudo docker compose up -d

echo "--- --- --- --- --- --- --- --- ---"
echo "--- ¡INSTALACIÓN COMPLETADA! ---"
echo "Nota: Koha tardará unos segundos en arrancar mientras espera a la base de datos."
echo ""
MI_IP=$(hostname -I | awk '{print $1}')
echo "Intranet (Staff): http://$MI_IP:8081"
echo "OPAC (Público):   http://$MI_IP:8080"
echo "--- --- --- --- --- --- --- --- ---"
