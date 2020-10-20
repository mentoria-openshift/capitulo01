<p align="center"><a href="../aula03">❮ Aula anterior</a> | <a href="../aula05">Próxima aula ❯</a></p>
<br/>

# Aula 4 - Skopeo e Buildah
Esta aula terá conteúdo prático, aplicando o que foi aprendido na anterior. Ao final desta aula, você saberá gerenciar suas imagens e containers usando o Buildah e o Skopeo.

### Compilando com o Buildah
O Buildah é uma ferramenta poderosa e flexível para compilação de imagens de container, e a grosso modo faz o mesmo que já aprendemos com o Docker e com o Podman: transformar um Dockerfile numa imagem completa. Mas o Buildah vai além: ele é capaz de executar comandos específicos de Dockerfile em linha de comando, inserir variáveis de ambiente em tempo de compilação.

Bom, o mais simples de todos: compilar um Dockerfile com o Buildah. Não existe muita diversão nisso, já que o processo é basicamente o mesmo usando Podman ou Docker.

```bash
buildah bud -t imagem:tag .
```

Vamos à parte interessante: criar imagens *sem* um Dockerfile, usando somente a linha de comando. Você pode baixar uma imagem com o Buildah usando o comando `from`.

```bash
# Baixando uma imagem
buildah from debian:stretch
```

Este comando baixa a imagem do Debian Stretch na sua máquina, bem como o comando `pull` faria, e retorna a imagem. Para usar a imagem baixada de fato, faremos o seguinte:

```bash
# Armazenando a imagem numa variável
container_openjdk8=$(buildah from centos:8)
```

Isso emula o passo `FROM` do Dockerfile, pois já temos uma imagem baixada e armazenada. Agora precisamos emular os passos de `RUN` para que os comandos necessários sejam executados e o Java e o Maven sejam instalado. E, além disso, precisamos emular o passo `ENV` e definir as variáveis de ambiente.

```bash
# Definindo as variáveis de ambiente da imagem
buildah config \
    --env MAVEN_HOME="/opt/apache-maven-3.6.3" \
    --env PATH="$PATH:$MAVEN_HOME/bin" \
    --env JAVA_HOME="/usr/lib/jvm/java-11-openjdk-11.0.8.10-0.el8_2.x86_64" \
    --env APP_PROFILE="default" \
    $container_openjdk8

# Definindo a pasta de trabalho
buildah config --workingdir /opt $container_openjdk8

# Instalando depências e executando comandos
buildah run $container_openjdk8 /bin/bash -c 'yum update -y && \
    yum install -y wget tar java-11-openjdk-devel java-11-openjdk git && \
    git clone https://github.com/thaalesalves/simplecrud-spring.git && \
    wget https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \
    tar xvzf apache-maven-3.6.3-bin.tar.gz && \
    chmod -R +x $MAVEN_HOME/bin && \
    $MAVEN_HOME/bin/mvn clean install -f /opt/simplecrud-spring/pom.xml'

# Expondo a porta de execução
buildah config --port 8080 $container_openjdk8
```

Com isto, instalamos as dependências necessárias, o Java, o Maven, o Git e clonamos o código da nossa aplicação, expomos a porta e definimos o comando de compilação dela. Bem como faríamos no Dockerfile. 

Mas ainda faltam alguns passos. Precisamos fornecer um comando a ser executado na criação do container, e, claro, salvar a imagem.

```bash
# Definindo o script de execução (entrypoint)
buildah config --cmd "java -Dspring.profiles.active=$APP_PROFILE -jar /opt/simplecrud-spring/target/simplecrud-0.0.1-SNAPSHOT.jar" $container_openjdk8

# Salvando a imagem
buildah commit $container_openjdk8 simplecrud:1.0
```

Agora sim vimos o poder do Buildah. Leia a documentação no site oficial para saber mais sobre ele. Ao invés de usar um Dockerfile, você pode criar sua imagem com comandos executados diretamente no shell, e salvar esses comandos num script `.sh`. Quando este script for executado, o resultado será o mesmo de compilar um Dockerfile.

### Gerenciando com o Skopeo
O Skopeo é uma ferramenta adicional ao Podman, e serve para copiar imagens de um lugar a outro, inspecionar imagens, de forma altamente compatível. É possível usá-lo num repositório local, em repositórios externos, públicos, privados, com imagens OCI, imagens tar, Docker daemon... enfim, o Skopeo é poderosíssimo. 

Podemos usá-lo para copiar uma imagem de um repositório para outro, subir imagens locais para um repositório remoto ou buscar informações sobre uma imagem. A vantagem de usar o Skopeo para isso é que não é necessário alterar a tag da imagem localmente para subi-la para um repositório. Para isso, usamos o comando `skopeo copy`.

```bash
# Fazendo login no repositório remoto
skopeo login -u seuusuario quay.io
Password: 
Login Succeeded!

# Copiando uma imagem local para o quay
skopeo copy containers-storage:docker.io/centos:8 docker://quay.io/thaalesalves/centos-novo:8
Getting image source signatures
Copying blob 291f6e44771a [--------------------------------------] 0.0b / 0.0b
Copying config 0d120b6cca done  
Writing manifest to image destination
Storing signatures
```

Podemos também inspecionar uma imagem de container com o Skopeo, e retornar os metadados dela caso precisemos de informações.

```bash
# Inspecionando uma imagem local
skopeo inspect containers-storage:docker.io/centos:8
{
    "Name": "docker.io/library/centos",
    "Digest": "sha256:fc4a234b91cc4b542bac8a6ad23b2ddcee60ae68fc4dbd4a52efb5f1b0baad71",
    "RepoTags": [],
    "Created": "2020-08-10T18:19:49.837885498Z",
    "DockerVersion": "18.09.7",
    "Labels": {
        "org.label-schema.build-date": "20200809",
        "org.label-schema.license": "GPLv2",
        "org.label-schema.name": "CentOS Base Image",
        "org.label-schema.schema-version": "1.0",
        "org.label-schema.vendor": "CentOS"
    },
    "Architecture": "amd64",
    "Os": "linux",
    "Layers": [
        "sha256:3c72a8ed68140139e483fe7368ae4d9651422749e91483557cbd5ecf99a96110"
    ],
    "Env": [
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ]
}
```

Note os protocolos `containers-storage:` e `docker://`. Eles são importantes para que o Skopeo saiba onde a imagem está. Ao usar `containers-storage:`, você indica ao Skopeo que a imagem existe localmente, na sua máquina. Ao usar `docker://`, estamos indicando que se trata de um repositório Docker remoto. É possível baixar imagens usando esta lógica ao invés do comando `pull` clássico também, e assim podemos especificar a tag que queremos usar localmente logo ao baixar a imagem.

Existem outros protocolos compatíveis com o Skopeo, e você pode inclusive enviar uma imagem do Quay para o Dockerhub usando esta sintaxe, prestando atenção aos protocolos usados. Refira à documentação do Skopeo para mais informações. 

## Exercícios
Isso conclui nosso material sobre comandos de Docker, Podman, Skopeo e Buildah, vistos nas aulas 3 e 4. Para praticar o conteúdo aprendido, vamos fazer alguns exercícios, tanto conceituais quanto práticos. 

* [Questionário](questionario.md)
* [Exercício prático](exercicio-pratico.md)

## Referências
* [Podman](https://podman.io/)
* [Buildah](https://buildah.io/)
* [Documentação do Podman](http://docs.podman.io/en/latest/)
* [Usando o Buildah](https://www.redhat.com/sysadmin/building-buildah)
* [Usando o Skopeo](https://www.redhat.com/pt-br/blog/skopeo-copy-rescue)

---
<p align="center"><a href="../aula03">❮ Aula anterior</a> | <a href="../aula05">Próxima aula ❯</a></p>