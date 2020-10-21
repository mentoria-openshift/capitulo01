<p align="center"><a href="../aula04">❮ Aula anterior</a> | <a href="../aula06">Próxima aula ❯</a></p>
<br/>

# Aula 5 - Templates com Docker Compose
Nesta aula, vamos aprender sobre o Docker Compose. Já vimos como containers funcionam e como criar imagens, mas sabemos fazer isso somente pela linha de comando. Vamos, nesta aula, aprender a criar containers usando um arquivo de template, que já tem as características de um template definidas.

## Docker Compose
O Docker Compose é uma ferramente que vem incluída no Docker, e serve para gerenciar containers de forma mais ágil, em grupo. É ideal para aplicações multicontainer, isto é, aplicações que são executadas em módulos. A sintaxe de escrita do template do Docker Compose é a linguagem YAML. Nesta aula, vamos criar um simples container usando o Docker Compose.

### Criando o template
Criar o template é simples. Você pode iniciar com um arquivo em branco chamado `docker-compose.yaml`. Vamos usar este arquivo para definir nosso template.

A primeira coisa a se fazer é definir a versão do template. Vamos usar a [versão 3](https://docs.docker.com/compose/compose-file/compose-versioning/#version-3) do template, que é a mais atualizada no momento. 

Após a definição da versão da API do Docker Compose, temos que definir nossos serviços. Vamos usar a mesma imagem que compilamos nas aulas anteriores: `simplecrud:1.0`.

```yaml
version: 3

services:
    simplecrud:
```

Definimos nosso serviço, que vai ser transformado num container. Nele, podemos definir diversos itens referentes ao container a ser criado, e as opções são semelhantes àquelas do comando `run` do Docker/Podman. 

Dentro do serviço, definimos a imagem a ser usada para o container (o último parâmetro do comando `run`), o nome do container (o valor do flag `--name` do comando `run`), o hostname do container (o valor do flag `--hostname` do comando `run`) e as portas a serem expostas (o valor do flag `--publish` do comando `run`). Outras opções, como volumes, redes e variáveis de ambiente também podem ser definidas aqui. Veremos mais sobre redes e variáveis de ambiente na próxima aula.

Vamos definir os dados do container. Deixe seu `docker-compose.yaml` como o a seguir.

```yaml
version: 3

services:
    simplecrud:
        container_name: simplecrud
        image: simplecrud:latest
        hostname: simplecrud
        ports:
        - '8080:8080'
```

Com isso, temos nosso primeiro template pronto. Agora precisamos processar o template para que o container seja criado.

### Usando o template
Para esta aula, vamos usar o Podman Compose ao invés do Docker Compose. Como você deve imaginar, os dois servem para a mesma coisa, e o Podman Compose é uma extensão do Podman assim como seu outro é uma extensão do Docker. A sintaxe dos comandos é exatamente a mesma, então basta trocar `podman-compose` por `docker-compose` ao executar os comandos. O nome do arquivo, entretanto, continua sendo `docker-compose.yaml` por padrão, independente de qual ferramenta seja usada.

#### Criando containers
O comando `up` serve para criar containers. O template é processado, as informações são absorvidas e usadas para subir containers conforme definido no template. É como executar o comando `docker run`, mas de forma padronizada.

```bash
podman-compose up
```

Todos os comandos do Compose seguem a mesma lógica: eles assumem que você está na pasta onde o arquivo a ser processado se encontra. O comando mostrado acima cria containers a partir do arquivo `docker-compose.yaml` existente na pasta onde o comando foi executado. Assim como o comando `build`, é possível fornecer um caminho diferente para o arquivo caso ele tenha outro nome ou esteja em outro lugar com o flag `-f`.

```bash
podman-compose -f /caminho/do/template/docker-compose.yaml up
```

### Removendo containers
Assim como o comando `up` cria containers, o comando `down` os remove. Ele segue o mesmo padrão do comando `up`, e inclusive tem o flag `-f`. Assim como todos os comandos de gerenciar containers do Compose, ele precisa de um template para se basear. É uma forma padronizada de executar o comando tradicional `podman rm -f <CONTAINER>`, excluindo em massa todos os containers do template.

```bash
podman-compose down
```

### Parando containers
O Compose fornece o comando `stop`, que faz uma função parecida com o `docker stop`, mas, assim como os demais comandos do Compose, usa um template como base. Ele para a execução de um container ativo mas não o remove.

```bash
podman-compose stop
```

### Iniciando containers
Quando você reinicia o computador hospedeiro ou para a execução de um container, ele não é removido. Ele fica disponível para reinício, e é possível vê-lo com o comando `docker ps -a`, que exibe todos os containers existentes. 

Semelhante ao comando `docker start`, o `docker-compose start` também inicia containers parados, mas serve somente para containers que foram criados usando templates do Compose.

```bash
podman-compose start
```

## Referências
* [Documentação do Docker Compose](https://docs.docker.com/compose)
* [Documentação do Podman](http://docs.podman.io/en/latest/)
* [API 3 do Docker Compose](https://docs.docker.com/compose/compose-file/compose-versioning/#version-3)
* [Código do Podman Compose](https://github.com/containers/podman-compose)

---
<p align="center"><a href="../aula04">❮ Aula anterior</a> | <a href="../aula06">Próxima aula ❯</a></p>