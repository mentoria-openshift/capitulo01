# Aula 2 - Entendendo o Dockerfile
<p align="center"><a href="../aula01">❮ Aula anterior</a> | <a href="../aula03">Próxima aula ❯</a></p>
<br/>

Esta aula terá conteúdo prático, aplicando o que foi aprendido na anterior. Ao final desta aula, você saberá criar um Dockerfile para compilar uma imagem de container, executar o container e acessar seu shell.

## Docker x Podman
Existem diferentes formas de criar, executar e gerenciar templates, sendo o Docker a forma mais famosa nos últimos anos. Mais recentemente, foi lançado o Podman, que executa imagens 100% compatíveis com Docker, além de dar suporte também para imagens [OCI](https://opencontainers.org/). A sintaxe de comandos de ambos é idêntica, mas o Podman vai além dos containers: ele também dá suporte a pods. Ambos são ferramentas poderosas, e, apesar de serem parecidas e até mesmo compatíveis, tem diferenças substanciais na forma que funcionam. 

Os containers Docker são executados a partir do seu daemon, que deve ser executado como root. Já no Podman, os containers são executados usando a estratégia de fork, que faz com que cada container subido seja um processo "filho" do Podman, o que garante mais segurança pois não depende de acesso root para executar containers. Mas executar os containers como root tem suas vantagens: não é possível acessar portas privilegiadas, isto é, portas abaixo da 1024 quando não se acessa como root. Com o Docker, isso sempre é possível. Com o Podman, apenas caso o usuário criador dos containers tenha acesso `sudo`. O Podman dá suporte a pods também, o que torna possível gerenciar vários containers como se fossem uma única entidade. Isso o torna mais próximo do Kubernetes e do OpenShift, que seguem o conceito de pods. 

Infelizmente o Podman está disponível somente para Linux. 

## A anatomia do Dockerfile
Dockerfiles são centrais ao criar imagens Docker, e tudo começa nele. O Dockerfile é uma lista estruturada de comandos que serão executados para que a imagem seja criada. Veja um exemplo de um Dockerfile

```Dockerfile
FROM docker.io/debian:buster

LABEL maintainer="Seu Nome <vc@email.com>" 
LABEL outra_label="valor"

ENV PATH="$PATH:/home/user/.bin"
ENV VARIAVEL="VALOR"

RUN apt update -y
RUN apt install -y apache2 php7.0
RUN useradd usuario

EXPOSE 80 443

WORKDIR /var/www

VOLUME ["/var/www", "/var/log/apache2", "/etc/apache2"]

USER usuario

ENTRYPOINT [ "sh", "/entrypoint.sh" ]
```

Este Dockerfile compila uma imagem com o webserver Apache e com o PHP 7.0 instalados, para que você possa hospedar seus sites. Mas vamos dissecar os comandos usados (e alguns outros) para entendermos melhor o que está acontecendo.

* `FROM`: como imagens Docker são feitas por camadas, cada comando cria uma nova. Ao declarar o `FROM`, você define qual a imagem base usada para gerar as demais camadas.
* `COPY`: este comando copia arquivos de uma fonte local a um destino na imagem durante a compilação da imagem
* `ADD`: semelhante ao `COPY`, copia arquivos de uma fonte a um destino. Mas suporta mais de uma fonte, URLs da internet, e também extrai arquivos `tar` ao serem copiados.
* `RUN`: executa um comando do sistema operação em tempo de compilação
* `CMD`: semelhante ao `RUN`, mas não é executado durante tempo de compilação. O `CMD` executa quando o container é criado. Recebe um array de comandos, entre aspas e separados por vírgula (ou um único comando, sem array nem aspas).
* `LABEL`: metadados em formato de string inseridos no container, sendo o mais comum `maintainer`, o criador da imagem.
* `ENV`: define variáveis de ambiente (chave=valor) usadas no container.
* `EXPOSE`: expõe portas do container para fora, para que o container possa ouvi-las
* `WORKDIR`: define o diretório de trabalho deste comando para baixo, semelhante ao comando `cd` do shell.
* `VOLUME`: caminhos persistentes de pastas ou arquivos, que normalmente são compartilhados com o sistema hospedeiro.
* `ENTRYPOINT`: semelhante ao `CMD`, é um comando executado na criação do container. A diferença é que o entrypoint é a primeira coisa executada após a criação do container. Recebe um array de comandos, entre aspas e separados por vírgula (ou um único comando, sem array nem aspas).

Cada comando adicionado em um Dockerfile cria uma camada nova, baseada na anterior. Isso é ponto importante ao otimizar imagens. O ideal ao criar um Dockerfile é ter o mínimo de comandos possível, usando o operador lógico `&&` ou a quebra de linha com `\` (contrabarra). O Dockerfile acima, ao ser otimizado, ficaria desta forma:

```Dockerfile
FROM docker.io/debian:buster

LABEL maintainer="Seu Nome <vc@email.com>" \
    outra_label="valor"

ENV PATH="$PATH:/home/user/.bin" \
    VARIAVEL="VALOR"

RUN apt update -y && \
    apt install -y apache2 php7.0 && \
    useradd usuario

EXPOSE 80 443

WORKDIR /var/www

VOLUME ["/var/www", "/var/log/apache2", "/etc/apache2"]

USER usuario

ENTRYPOINT [ "sh", "/entrypoint.sh" ]
```

## Criando imagens Docker
Uma vez que o Dockerfile está criado, podemos prosseguir para a compilação da imagem. Novamente, mencionando o Podman, os comandos dele e do Docker enquanto gerenciando containers são exatamente os mesmos. 

```bash
# Compilando uma imagem
docker build -t imagem:tag .

# Com o Podman
podman build -t imagem:tag .
```

Este comando compila uma imagem de container Docker, levando em consideração que você esteja atualmente no diretório onde o Dockerfile e os arquivos necessários se encontram. 

Note que foram fornecidos um nome da imagem e uma tag como parâmetro do flag `-t`. O nome da imagem normalmente é acompanhado do repositório onde ela será hospedada. Por padrão, imagens sem endereço de repositório são enviadas para o [Dockerhub](https://dockerhub.com), o serviço de hospedagem de imagens oficial do Docker. As tags são usadas para versionamento da imagem. Por exemplo, se você está compilando a imagem de uma aplicação chamada `simplecrud` na versão 2.3, o identificador da imagem será provavelmente `simplecrud:2.3`. A tag da imagem também pode ser omitida, e neste caso a engine assumirá que a tag é `latest`. 

O ponto no final do comando indica o caminho local da compilação da sua imagem, ou seja, onde estão os arquivos necessários para que a imagem seja compilada. Os comandos `ADD` e `COPY`, quando recebem caminhos locais como fonte, vão buscar os arquivos na pasta daquele ponto. Você pode, por exemplo, fornecer outro caminho para compilar a imagem, caso seus arquivos necessários estejam em outro caminho. 

Mas e o Dockerfile? O caminho do Dockerfile é omitido, pois por padrão o comando de compilação é executado onde o Dockerfile se encontra. Mas é possível fornecer outro caminho para o Dockerfile usando o flag `-f`.

```bash
# Compilando uma imagem - diretório de compilação e de Dockerfile diferentes
docker build -f /caminho/do/Dockerfile -t imagem:tag /caminho/de/compilacao
docker build -f /caminho/do/Dockerfile -t imagem:tag .

# Com Podman
podman build -f /caminho/do/Dockerfile -t imagem:tag /caminho/de/compilacao
podman build -f /caminho/do/Dockerfile -t imagem:tag .
```

## Executando um container
Uma vez que uma imagem foi compilada com sucesso, é possível criar containers a partir dela. O número de containers que você pode criar é baseado na quantidade de recursos disponíveis no seu computador local. O comando `run` é utilizado para criar um container a partir de uma imagem.

```bash
# Criando um container
docker run -d --name nome -p 8080:8080 -e CHAVE=VALOR simplecrud:2.3

# Com Podman
podman run -d --name nome -p 8080:8080 -e CHAVE=VALOR simplecrud:2.3
```

Este comando cria um container a partir da imagem `simplecrud:2.3`. Mas temos uma série de flags para fornecer para o comando. O flag `-d` (que pode ser trocado por `--detach`) inicia o container e libera a linha de comando logo em seguida. Omitir este flag também cria o comando com sucesso, mas a linha de comando fica presa no stdout do container até que ele termine sua execução. O flag `--name` é autoexplicativo, e fornece um nome para o container. Ao listar os processos de container sendo executados, um nome aleatório é criado por padrão caso o container não tenha sido criado com esta opção. O flag `-p` (pode ser trocado por `--publish`) fornece portas a serem expostas e tuneladas para portas locais do hospedeiro. A porta do hospedeiro estando à esquerda, e a do container à direita. 

Com o container de pé e com as portas mapeadas, podemos acessar a aplicação hospedada como se estivesse rodando na nossa máquina local. No exemplo fornecido nesta seção, sua aplicação estará rodando em `localhost:8080`.

## Executando comandos no container
Ao executar o comando, você terá como saída o ID do container criado. Este ID é usado para identificar o container, e é especialmente útil quando existirem diversos containers com nomes parecidos. Uma vez que o container é criado, sua linha de comando fica acessível para uso. Usamos o comando `exec` para isso. 

```bash
# Executando um comando no shell do container
docker exec -t nome-do-container comando-executavel

# Também é possível acessar a linha de comando do container diretamente
docker exec -it nome-do-container bash

# Com Podman
podman exec -t nome-do-container comando-executavel
podman exec -it nome-do-container bash
```

Note os flags `-it`. Isso é a abreviação de `--interactive` e `--tty`. Esses flags criam uma interface interativa com um pseudo-tty (tty significa tele-typewriter) para que os comandos sejam executados, isto é, com `-i` a linha de comando é mantida aberta mesmo que seja "destacada", e você poderá executar outros comandos depois do primeiro, e `-t` cria um terminal virtual para que o comando possa ser executado como numa máquina comum. 

## Exercícios
Isso conclui os assuntos básicos de Docker ensinados nas aulas 1 e 2. Para praticar o conteúdo aprendido, vamos fazer alguns exercícios, tanto conceituais quanto práticos. 

* [Questionário](questionario.md)
* [Exercício prático](exercicio-pratico.md)

## Referências
* [Documentação do Docker](https://docs.docker.com/)
* [Documentação do Podman](http://docs.podman.io/en/latest/)
* [Documentação do comando build](https://docs.docker.com/engine/reference/commandline/build/)
* [Documentação do comando run](https://docs.docker.com/engine/reference/commandline/run/)
* [Documentação do comando exec](https://docs.docker.com/engine/reference/commandline/exec/)

---
<p align="center"><a href="../aula01">❮ Aula anterior</a> | <a href="../aula03">Próxima aula ❯</a></p>
<br/>