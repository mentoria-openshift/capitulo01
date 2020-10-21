#!/bin/bash

# Salvando a imagem na variável
simplecrud=$(buildah from maven:3.6.3-adoptopenjdk-11)

# Definindo a variável de ambiente
buildah config --env APP_PROFILE="default" $simplecrud

# Copiando o arquivo local
buildah copy $simplecrud ./scripts/entrypoint.sh /entrypoint.sh

# Executando comandos
buildah config --cmd "apt update -y && \
    apt install -y git && \
    git clone https://github.com/mentoria-openshift/simplecrud-spring /opt/simplecrud" \
    $simplecrud

# Trocando o diretório
buildah config --workingdir /opt/simplecrud $simplecrud

# Compile a aplicação
buildah config --cmd "mvn clean install" $simplecrud

# Expondo a porta
buildah config --port 8080 $simplecrud

# Definindo o entrypoint
buildah config --entrypoint "sh /entrypoint.sh" $simplecrud

# Salvando a imagem
buildah commit $simplecrud simplecrud:2.0