#!/bin/bash

# Detener el script si ocurre un error
set -e

echo "--- 1. Actualizando el sistema ---"
sudo dnf update -y

echo "--- 2. Instalando dependencias y repositorio de Docker ---"
sudo dnf install -y dnf-plugins-core git net-tools
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "--- 3. Instalando Docker y Docker Compose ---"
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- 4. Configurando el Firewall para Koha (Puertos 8080 y 8081) ---"
# Abrimos los puertos 8080 (OPAC) y 8081 (Intranet)
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
echo "Puertos 8080 y 8081 abiertos correctamente."

echo "--- 5. Iniciando y habilitando Docker ---"
sudo systemctl enable --now docker

echo "--- 6. Configurando permisos de usuario ---"
sudo usermod -aG docker $USER

echo "--- 7. Clonando el repositorio de Koha ---"
if [ -d "koha-docker-elasticsearch-main" ]; then
    echo "El directorio ya existe, saltando clonación..."
else
    git clone https://github.com/anthonyEdgeworth-bash/koha-docker-elasticsearch-main.git
fi

cd koha-docker-elasticsearch-main/examples

echo "--- 8. Desplegando contenedores ---"
# Levantamos el stack. Usamos sudo porque el cambio de grupo (usermod) 
# no surte efecto en la sesión actual de la terminal.
sudo docker compose up -d

echo "--- ¡Todo listo! ---"
echo "Koha debería estar disponible en:"
echo "- Intranet (Staff): http://tu-ip:8081"
echo "- OPAC (Público): http://tu-ip:8080"
echo ""
ip addr show | grep 'inet ' | grep -v '127.0.0.1'
