# Aula 3 - Linha de Comando Docker
<p align="center"><a href="../aula02">❮ Aula anterior</a> | <a href="../aula04">Próxima aula ❯</a></p>
<br/>

Nesta aula, aprenderemos alguns comandos para gerenciamento de imagens e containers com Docker e Podman. Ao completar esta aula, você saberá alterar tags, listar, remover, baixar e subir imagens usando o Docker ou o Podman. Você saberá também como executar, parar e remover containers existentes.

**Nota:** a partir de agora será usado somente o Podman para containers locais. Lembre-se que a sintaxe do Podman e do Docker é a mesma. Basta trocar `podman` por `docker` caso você esteja rodando Docker. Podman, Skopeo e Buildah estão disponíveis apenas para Linux.

## Gerenciando imagens
Além de criar e compilar imagens e executar containers a partir delas, temos outras operacções para executar também. Enquanto containers rodam localmente em uma máquina hospedeira, imagens podem ser compartilhadas entre diferentes pessoas. Pense num repositório git, como esse onde estamos fazendo o curso. Você cria uma pasta local onde vai hospedar seu código, a transforma num repositório git e adiciona um repositório remoto. Ao commitar e "pushar" alterações, você estará sincronizando seu repositório local com o remoto. Repositórios Docker funcionam de forma semelhante, com comandos semelhantes: pull, push e commit. 

Você pode também alterar o nome e a tag de imagens localmente para subi-las para um repositório, e manter a mesma imagem em diferentes repositórios. E existem formas diferentes de fazer isso, usando o Docker, o Podman ou o Skopeo. 

### Gerenciando Imagens
Além de compilar imagens e executar containers, podemos fazer outras coisas com os comandos padrão do Docker, que o Podman herdou. Vamos explorar alguns comandos.

#### Listando imagens
Podemos listar as imagens que temos atualmente no nosso repositório local. 
Nota: o Podman adiciona `localhost/` ao início das imagens locais, enquanto o Docker não. Não se preocupe, os comandos dos dois ainda são os mesmos.

```bash
# Listando as imagens que temos
podman images
REPOSITORY                           TAG     IMAGE ID      CREATED        SIZE
localhost/front-end                  latest  2f960356f800  26 hours ago   480 MB
localhost/s2i-do288-go               latest  3b35081d8245  29 hours ago   706 MB
localhost/s2i-go-app                 latest  e3456b270cd5  29 hours ago   714 MB
registry.access.redhat.com/ubi8      8.0     11f9dba4d1bc  13 months ago  216 MB
registry.access.redhat.com/ubi8/ubi  8.0     11f9dba4d1bc  13 months ago  216 MB
```

Este comando mostra nossas imagens, com o repositório completo, a tag, o ID da tag, a criação e o tamanho da imagem. Mas note que aqui temos apenas as imagens "tagueadas" listadas. Lembra-se sobre como comandos de Dockerfile geram camadas diferentes? Estas camadas também são suas próprias imagens, e ficam nesta lista também. Mas precisamos de um flag específico para mostra-las: `-a`. Essas imagens de camada, no entanto, não têm nome nem tag.

```bash
# Listando **todas** as imagens que temos
podman images -a
REPOSITORY                           TAG     IMAGE ID      CREATED        SIZE
localhost/front-end                  latest  2f960356f800  26 hours ago   480 MB
<none>                               <none>  343e7beee255  26 hours ago   480 MB
<none>                               <none>  70e9bf6a6725  26 hours ago   480 MB
<none>                               <none>  deee3d7c7967  26 hours ago   480 MB
<none>                               <none>  045ee6e00590  26 hours ago   479 MB
<none>                               <none>  caab27efddba  26 hours ago   479 MB
<none>                               <none>  48ee93cf6541  26 hours ago   479 MB
<none>                               <none>  b48985363ca6  26 hours ago   216 MB
<none>                               <none>  3678534ce48b  26 hours ago   216 MB
localhost/s2i-do288-go               latest  3b35081d8245  29 hours ago   706 MB
<none>                               <none>  7d828ca7c62c  29 hours ago   706 MB
<none>                               <none>  1d02b2e6a69c  29 hours ago   706 MB
<none>                               <none>  5df0dd16c76e  29 hours ago   706 MB
<none>                               <none>  8cc5524b50be  29 hours ago   706 MB
<none>                               <none>  e5417a8042a6  29 hours ago   706 MB
localhost/s2i-go-app                 latest  e3456b270cd5  30 hours ago   714 MB
<none>                               <none>  10c59e86472e  30 hours ago   714 MB
<none>                               <none>  6535d056a149  30 hours ago   706 MB
<none>                               <none>  b034a69e57f4  30 hours ago   706 MB
<none>                               <none>  50ca870ad49a  30 hours ago   706 MB
<none>                               <none>  0e4bcd17d447  30 hours ago   706 MB
<none>                               <none>  45116b10d4ce  30 hours ago   706 MB
<none>                               <none>  18cb522dc06a  30 hours ago   706 MB
<none>                               <none>  e27e49afd02f  30 hours ago   706 MB
<none>                               <none>  1c0228ac0eab  30 hours ago   706 MB
<none>                               <none>  0ca88c23fb28  30 hours ago   706 MB
<none>                               <none>  a7eaa94392a2  30 hours ago   706 MB
<none>                               <none>  dd04037d5641  30 hours ago   706 MB
<none>                               <none>  0045b7dd8cd5  30 hours ago   706 MB
<none>                               <none>  8b4db4abfb23  30 hours ago   216 MB
<none>                               <none>  b46b029c6cb8  30 hours ago   216 MB
<none>                               <none>  8cb3a5ed9cec  30 hours ago   216 MB
<none>                               <none>  4677fe4f0d63  30 hours ago   216 MB
registry.access.redhat.com/ubi8/ubi  8.0     11f9dba4d1bc  13 months ago  216 MB
registry.access.redhat.com/ubi8      8.0     11f9dba4d1bc  13 months ago  216 MB
```

Use o switch `-q` para omitir detalhes da imagem e mostrar apenas seu ID. Isso facilita quando o objetivo é remover imagens.

```bash
# Listando apenas os IDs
podman images -q
3b35081d8245
0d120b6ccaa8
11f9dba4d1bc
```

#### Renomeando e alterando tags
Podemos renomear imagens e alterar tags localmente também. Para isso, usamos o comando `tag`. Ao executar este comando, uma nova imagem, idêntica à imagem fonte, é criada com uma tag nova, especificada pelo usuário.

```bash
# Renomeando uma imagem
podman tag registry.access.redhat.com/ubi8:8.0 ubi:8

podman images
REPOSITORY                           TAG     IMAGE ID      CREATED        SIZE
localhost/front-end                  latest  2f960356f800  26 hours ago   480 MB
localhost/s2i-do288-go               latest  3b35081d8245  29 hours ago   706 MB
localhost/s2i-go-app                 latest  e3456b270cd5  30 hours ago   714 MB
registry.access.redhat.com/ubi8      8.0     11f9dba4d1bc  13 months ago  216 MB
registry.access.redhat.com/ubi8/ubi  8.0     11f9dba4d1bc  13 months ago  216 MB
localhost/ubi                        8       11f9dba4d1bc  13 months ago  216 MB
```

Note que a imagem `localhost/ubi:8` foi criada a partir da `registry.access.redhat.com/ubi8:8.0`. Estas duas imagens são idênticas, mas com nomes diferentes. 

#### Subindo e baixando imagens de um repositório
Assim como no git, nosso repositório local pode ser usado como base para subir e baixar imagens. Por exemplo, podemos baixar a imagem `centos:8` do Dockerhub sem usar um Dockerfile. Podemos, inclusive, mudar a sua tag e em seguida subi-la para nosso próprio repositório. Mas, para isso, precisamos estar autenticados. Repositórios públicos permitem que qualquer um baixe imagens dele, mas precisamos de um usuário autenticado para subir imagens.

```bash
# Baixando a imagem
podman pull docker.io/centos:8
Trying to pull docker.io/centos:8...
Getting image source signatures
Copying blob 3c72a8ed6814 done  
Copying config 0d120b6cca done  
Writing manifest to image destination
Storing signatures
0d120b6ccaa8c5e149176798b3501d4dd1885f961922497cd0abef155c869566

# Alterando a tag (repositório)
podman tag docker.io/centos:8 quay.io/seuusuario/centos:8

# Fazendo login no repositório destino
podman login -u seuusuario quay.io
Password: 
Login Succeeded!

# Subindo a imagem
podman push quay.io/seuusuario/centos:8
Getting image source signatures
Copying blob 291f6e44771a [--------------------------------------] 0.0b / 0.0b
Copying config 0d120b6cca done  
Writing manifest to image destination
Storing signatures
```

Esta sequência de comandos baixa uma imagem do Dockerhub, altera a tag para que ela seja aceita em outro repositório no Quay, e em seguida sobe a imagem para o Quay. Ela poderá, a partir de agora, ser baixada da mesma forma que no primeiro comando, somente ajustando o repositório da imagem.

### Removendo imagens
Para remover imagens, podemos usar o comando `rmi` do Docker ou do Podman. Este comando segue uma lógica parecida com o `rm` do Linux, usando o flag `-f` para excluir uma imagem forçadamente. Ele recebe como parâmetro o nome ou o ID da imagem, e, ao ser executado, remove uma imagem do seu repositório local. Ao remover uma imagem com nome e tag, todas as suas camadas criadas durante a build (caso existam) são removidas. 

```bash
# Removendo uma imagem
podman rmi localhost/front-end
343e7beee255192f41acf764cc2b21264835c69640ace64ed3f9dac34bca5d53
70e9bf6a672501d7236f1739bbc1279229b474b291eeb5038d080aedadebf92f
deee3d7c796709a4a4d066f6354f6f3363af54dc02da1ce3d6159be1cccea149
045ee6e0059063d5af2773793c030d5dc19b94084c25022a5bf1cfbd376c65b6
caab27efddba42c9fb11425a75da19033c20ecab64f2c706e7cd237000e12e7c
48ee93cf6541ff7b82710cdf4cb882b234bbf79b591dfb780a004a389effa9df
b48985363ca619bc51a31cf14d76459fbe9472d94f5690e585416cb052269f44
3678534ce48b8276e0c13c797e6e7d68ced5a8f990fd7264a90ed0abd6f188b3
Untagged: localhost/front-end:latest
Deleted: 2f960356f80096ec8287f95c78d4df01c57da6ae5e5caab2b4f065241926729b
``` 

O flag `-f`, que força a remoção de uma imagem, é usado quando a imagem está presa: existem containers em execução vinculados àquela imagem. Claro, você pode parar o container antes de remover a imagem (vide próxima seção), mas existe a opção de forçar a remoção da imagem. Isso para a execução do container e o deleta antes que a imagem seja removida permanentemente. 

```bash
# Tentando remover uma imagem vinculada a um container em execução
podman rmi localhost/s2i-go-app:latest
Error: 1 error occurred:
	* could not remove image e3456b270cd598c6fca211ef40c05256373678847d4eaef7624990779041ede1 as it is being used by 1 containers: image is being used

# Forçando a remoção da imagem
podman rmi -f localhost/s2i-go-app:latest
10c59e86472e348a6fbb70ec8d9cb615d9abf07762115baa9f0fb34cfb50fcdb
6535d056a149fc2c37d6ae277675c21dc40038b1acbda3467b9a93ffe4b9afdb
b034a69e57f4e0176ac0c2bdeb07d1bdecbff1c693fbd64df40f3528153fcea9
50ca870ad49a8b3fb467729e0b979ad84bbeebda55153ccf9aecb5173ea9e860
0e4bcd17d4477952233411066fd295d83d2f11fe4cefb2bc4b2fdc4dafd94a26
45116b10d4ce9a0f43f0d6d97321d9e5e0766f505b23b7fe5a9a9c52a344ba5e
18cb522dc06affdca1754dc33197e20b985ddcf2a8ed0261267055e303e5a43f
e27e49afd02fd4bedead3bba268aa5c2513165673f74a78209074a4dc46a0953
1c0228ac0eab03dd19c94ca93b27af92b3f44a421b1e1e33445fb2eaa7bf85cf
0ca88c23fb289f60a56555bac740e8cb37132b1db8a1df5dc725d530738726fb
a7eaa94392a29eb9deabc1a57791567321677065191091f99e8d3d27f698a71f
dd04037d5641788998158f93f319f2c8104addd05930735a7bf4ceabe45d12b1
Untagged: localhost/s2i-go-app:latest
Deleted: e3456b270cd598c6fca211ef40c05256373678847d4eaef7624990779041ede1
```

Dica: use `podman rmi -f $(podman images -aq)` para remover todas as imagens (e containers vinculados) num comando só.

### Gerenciando containers
Semelhante a imagens, podemos gerenciar containers. Os comandos são, como anteriormente, baseados nos comandos Unix. Caso você seja familiarizado com o `bash`, não vai achar os comandos tão estranhos. Podemos listar, parar, iniciar e remover containers usando comandos locais. Os flags `-a` e `-q` seguem o mesmo padrão dos comandos de imagem, e servem para a mesma função ao gerenciar containers.

**Nota:** Assim como com as imagens, os comandos suportam o nome do container ou o seu ID. Troque `<CONTAINER>` por um deles. Para remover containers em execução sem para-los antes, use o flag `-f`.

```bash
# Listando os containers ativos
podman ps

# Listando todos os containers existentes
podman ps -a

# Listando IDs de containers ativos
podman ps -q

# Parando a execução de um container
podman stop <CONTAINER>

# Reiniciando um container parado
podman start <CONTAINER>

# Removendo um container
podman rm <CONTAINER>

# Removendo todos os containers em execução
podman rm $(podman ps -q)

# Removendo todos os containers existentes
podman rm $(podman ps -aq)
```

## Referências
* [Documentação do Docker](https://docs.docker.com/)
* [Documentação do Podman](http://docs.podman.io/en/latest/)
* [Documentação do comando rm](https://docs.docker.com/engine/reference/commandline/rm/)
* [Documentação do comando rmi](https://docs.docker.com/engine/reference/commandline/rmi/)
* [Documentação do comando ps](https://docs.docker.com/engine/reference/commandline/ps/)
* [Documentação do comando start](https://docs.docker.com/engine/reference/commandline/start/)
* [Documentação do comando stop](https://docs.docker.com/engine/reference/commandline/stop/)
* [Documentação do comando tag](https://docs.docker.com/engine/reference/commandline/tag/)
* [Documentação do comando pull](https://docs.docker.com/engine/reference/commandline/pull/)
* [Documentação do comando push](https://docs.docker.com/engine/reference/commandline/push/)
* [Documentação do comando images](https://docs.docker.com/engine/reference/commandline/images/)

---
<p align="center"><a href="../aula02">❮ Aula anterior</a> | <a href="../aula04">Próxima aula ❯</a></p>