<p align="center"><a href="../aula05">❮ Aula anterior</a> | <a href="https://github.com/mentoria-openshift/capitulo02">Próximo capítulo ❯</a></p>
<br/>

# Aula 6 - Aplicações multi-container com Docker
Nesta aula, vamos aprender mais sobre aplicações multi-container. Vamos entrar mais profundamente no conceito de redes Docker e comunicação entre vários containers. O exercício prático desta aula englobará todo o conteúdo aprendido nas últimas aulas, e, após aprender sobre como aplicações funcionam em diversos containers, iniciaremos o capítulo 2 com uma introdução ao OpenShift. 

## Containers em rede
Assim como aplicações em ambientes reais, com um datacenter com diversos servidores que se comunicam entre si, podemos usar containers em rede. Existem diversos tipos de rede diferentes suportados, e podemos usá-los tanto com containers iniciados por linha de comando quanto por Compose.

Como mencionando anteriormente, a ideia de usar containers é quebrar aplições em módulos. Por exemplo: seu sistema teria um microsserviço responsável por fazer autenticação, outro para fazer as operações comuns, um de front-end e um container de banco de dados. Nesse esquema, temos um total de quatro containers, que precisam estar constantemente em contato um com o outro.

## Tipos de rede
Redes no Docker são separadas por tipos, cada um com um driver. Diferentes drivers usam diferentes topologias de rede, que geram diferentes comportamentos nas interações entre containers.

* **bridge:** Este é o driver padrão. Caso não seja especificado driver ao criar uma rede, ela será definida como bridge. Redes bridge permitem que containers inclusos nelas se comuniquem entre si, isolando de outras redes bridge. Também fecha a comunicação entre containers que estão rodando no mesmo daemon. 
* **host:** Redes host removem o isolamento dos containers, e o inserem na mesma rede onde o computador hospedeiro está, e permite acesso entre todos os containers rodando na rede do hospedeiro, além do hospedeiro em si e outros computadores inseridos naquela rede.
* **overlay:** O tipo overlay conecta diversos daemons Docker na mesma rede, permitindo que eles se comuniquem entre si. 
* **macvlan:** Uma rede LAN virtual que fornece endereços MAC para os containers, fazendo com que apareçam como dispositivos físicos reais nos gerenciadores de rede. É ideal para quando existe um DHCP a nível global, ou quando comunicação com sistemas legados que não podem ser inseridos em redes de containers é necessária.
* **none:** Uma rede nula. Containers inseridos numa rede de tipo none não terão acesso a outros containers, e executarão de forma standalone, completamente isolados.

## Criando containers em rede
Para comandos da linha de comando comuns, usa-se o flag `--network` ao criar o container para se especificar a rede da qual ele fará parte. Mas, antes disso, a rede precisa existir. Usa-se o comando `docker network` para gerenciar redes, o que inclui criá-las, removê-las e alterá-las. 

```bash
# Criando uma rede (tipo bridge, por padrão)
podman network create minha_rede
```

Mas, como vimos acima, temos vários tipos de rede que podem ser utilizados. Usa-se o flag `-d` (ou `--driver`) para fornecer o driver desejado.

```bash
podman network create -d host minha_rede
```

Outros comandos simples, e bem parecidos com os demais comandos Docker, permitem que você liste as redes existentes ou delete-as.

```bash
# Listando redes existentes
podman network ls

# Removendo uma rede
podman network rm minha_rede
```

Também é possível adicionar containers existentes a uma rede diferente usando o comando `connect`.

```bash
# Adicionando um container à rede
podman network connect minha_rede meu_container

# Adicionando à rede com IP específico (também pode ser ipv6)
podman network connect --ipv4 192.168.1.100 minha_rede meu_container
```

Usa-se a mesma lógica para desconectar um container de uma rede. É possível forçar a remoção do container caso ele esteja em execução usando o flag `-f` (ou `--force`).

```bash
podman network disconnect minha_rede meu_container
```

Podemos também inspecionar uma rede para saber mais detalhes sobre ela, usando o comando `inspect`. E, também, remover todas as redes não utilizadas com o comando `prune`.

```bash
# Removendo redes não usadas
podman network prune

# Inspecionando uma rede
podman network inspect minha_rede
```

Para criar um container e imediatamente adicioná-lo à rede, usamos o flag `--network` no comando `run`.

```bash
# Adicionando um container à rede ao criá-lo
podman run -d --name meu_container --network minha_rede imagem:tag
```

## Redes e Docker Compose
Além de fazermos tudo isso através da linha de comando, podemos também criar redes através de um template do Compose, e imediatamente incluir os containers nelas. O Compose permite que diversas redes sejam criadas, e que os containers recebam IPs ao serem adicionados a uma delas.

Por padrão, quando executamos um template do Compose, uma rede chamada `myapp_default` é criada, e os containers sem rede definida são inseridos nela. Mas podemos especificar nossas próprias redes e drivers. 

```yaml
networks:
    # Sem driver especificado, é criada uma rede bridge
    minha_rede:
        name: rede_app

    # Criando uma rede macvlan
    frontend:
        name: rede_frontend
        driver: macvlan

    # Criando uma rede host
    backend:
        name: rede_backend
        driver: host
```

Podemos também declarar uma rede única sem declarar tipo de driver usando um mapa da sintaxe do YAML.

```yaml
networks:
    ? minha_rede
```

Também é possível alterar caractéristicas da rede padrão, e até mesmo usar redes já existentes e não gerenciadas pelo Compose. Para alterar a rede padrão, basta especificar o nome da rede como `default`, e a rede padrão acatará as definições fornecidas.

```yaml
networks:
    # Usando uma rede já existente
    minha_rede:
        external:
        name: minha_rede

    # Alterando o driver da rede padrão
    default:
        driver: host
```

Após definir uma rede no nosso template, precisamos especifica-la nos dados dos containers que serão criados.

```yaml
services:
    simplecrud:
        container_name: simplecrud
        image: simplecrud:latest
        hostname: simplecrud
        networks:
            - minha_rede
        ports:
            - '8080:8080'
```

Um exemplo de `docker-compose.yaml` completo com uma rede definida, com uma aplicação que se comunica com um banco de dados MySQL. Note que a aplicação tem o banco de dados como dependência. Isso serve para que a aplicação não suba sem o banco, o que pode ocasionar em erros.

```yaml
version: '3'
networks:
  minha_rede:
    name: rede_app

services:
  mysql:
    container_name: mysql
    image: docker.io/mysql:8
    hostname: mysql
    ports:
     - '3306:3306'
    environment:
     - MYSQL_USER=usuario
     - MYSQL_PASSWORD=senha
     - MYSQL_DATABASE=banco
    networks:
     - rede_app

  meu_app:
    container_name: meu_app
    image: imagem:tag
    hostname: meu_app
    ports:
     - '8080:8080'
     - '9090:9090'
    networks:
     - rede_app
    depends_on:
      - mysql
```

Isso conclui o capítulo 1 do curso com introdução a containers. No próximo capítulo, teremos uma introdução ao OpenShift e suas funcionalidades. Para praticar os assuntos estudados, faça o questionário e o exercício prático.

## Exercícios
Isso conclui nosso material sobre Docker Compose e aplicações multi-container das aulas 3 e 4. Para praticar o conteúdo aprendido, vamos fazer alguns exercícios, tanto conceituais quanto práticos. 

* [Questionário](questionario.md)
* [Exercício prático](exercicio-pratico.md)

## Referências
* [Documentação do comando network](https://docs.docker.com/engine/reference/commandline/network/)
* [Documentação do comando network connect](https://docs.docker.com/engine/reference/commandline/network_connect/)
* [Documentação do comando network disconnect](https://docs.docker.com/engine/reference/commandline/network_disconnect/)
* [Documentação do comando network inspect](https://docs.docker.com/engine/reference/commandline/network_inspect/)
* [Documentação do comando network prune](https://docs.docker.com/engine/reference/commandline/network_prune/)
* [Documentação do comando network create](https://docs.docker.com/engine/reference/commandline/network_create/)
* [Documentação do comando network rm](https://docs.docker.com/engine/reference/commandline/network_rm/)
* [Documentação do comando network ls](https://docs.docker.com/engine/reference/commandline/network_ls/)
* [Redes Docker](https://docs.docker.com/network/)
* [Redes no Docker Compose](https://docs.docker.com/compose/networking/)
* [Redes bridge](https://docs.docker.com/network/bridge/)
* [Redes host](https://docs.docker.com/network/host/)
* [Redes overlay](https://docs.docker.com/network/overlay/)
* [Redes macvlan](https://docs.docker.com/network/macvlan/)
* [Redes desativadas](https://docs.docker.com/network/none/)
* [Plugins de rede](https://docs.docker.com/engine/extend/plugins_services)

---
<p align="center"><a href="../aula05">❮ Aula anterior</a> | <a href="https://github.com/mentoria-openshift/capitulo02">Próximo capítulo ❯</a></p>