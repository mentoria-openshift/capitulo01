<p align="center"><a href="../aula03">Aula 3</a> | <a href="../aula04">Aula 4</a></p>
<br/>

# Exercício prático - Aulas 3 e 4

Com o conteúdo que aprendemos nas aulas 3 e 4, podemos criar imagens de forma mais flexível e subi-la para um repositório usando o Buildah e o Skopeo, além de comandos mais avançados do Docker. Ao final deste exercício, você terá compilado sua imagem com o Buildah e a subido para sua conta do Quay.io. 

**NOTA:** este exercício usa Buildah e Skopeo, que estão disponíveis apenas para Linux. Se você usa Windows ou mac, precisará de uma máquina virtual com Linux para fazê-lo.

## Requerimentos
- Use a imagem gerada no exercício prático anterior.
- Os comandos deverão ser adicionados num arquivo chamado `simplecrud-imagem.sh`.
- O arquivo `simplecrud-imagem.sh` deverá estar na mesma pasta do Dockerfile do exercício anterior.
- Sua imagem de container deve se chamar `simplecrud`, e deverá ter a tag `2.0`.
- Sua imagem deverá ser copiada para sua conta do Quay.io com o Skopeo, usando o nome `simplecrud-skopeo:1.0`.

## Passo-a-passo
Este passo a passo indica como chegar ao resultado final do exercício. Clique na seta ao lado do enunciado para exibir a resposta. Note que o exercício todo será feito na linha de comando.

<details> 
  <summary>1. Em um script chamado `simplecrud-imagem.sh`, traduza o `FROM` do seu Dockerfile do exercício anterior para um comando Buildah.</summary>
   
```bash
# SEMPRE INICIE UM SCRIPT BASH COM A LINHA ABAIXO. ELA NÃO É UM COMENTÁRIO.
#!/bin/bash

# Salvando a imagem na variável
simplecrud=$(buildah from maven:3.6.3-adoptopenjdk-11)
```

</details>

<details> 
  <summary>2. Defina variável de ambiente conforme Dockerfile e copie o arquivo de entrypoint.</summary>
   
```bash
# Definindo a variável de ambiente
buildah config --env APP_PROFILE="default" $simplecrud

# Copiando o arquivo local
buildah copy $simplecrud ./scripts/entrypoint.sh /entrypoint.sh
```

</details>

<details> 
  <summary>3. Traduza os comandos contidos nos `RUN` e troque o diretório de trabalho.</summary>
   
```bash
# Executando comandos
buildah config --cmd "apt update -y && \
    apt install -y git && \
    git clone https://github.com/mentoria-openshift/simplecrud-spring /opt/simplecrud" \
    $simplecrud

# Trocando o diretório
buildah config --workingdir /opt/simplecrud $simplecrud

# Compile a aplicação
buildah config --cmd "mvn clean install" $simplecrud
```

</details>

<details> 
  <summary>4. Exponha as portas, defina o entrypoint e salve sua imagem</summary>
   
```bash
# Expondo a porta
buildah config --port 8080 $simplecrud

# Definindo o entrypoint
buildah config --entrypoint "sh /entrypoint.sh" $simplecrud

# Salvando a imagem
buildah commit $simplecrud simplecrud:2.0
```

</details>

<details> 
  <summary>5. Execute o script, copie a imagem para o Quay.io com o Skopeo</summary>
   
```bash
# Executando o script
sh simplecrud-imagem.sh

# Fazendo login no repositório
skopeo login -u seu_usuario docker.io

# Copiando a imagem
skopeo copy containers-storage:localhost/simplecrud:2.0 docker://quay.io/seu_usuario/simplecrud-skopeo:1.0
```

</details>

---
<p align="center"><a href="../aula03">Aula 3</a> | <a href="../aula04">Aula 4</a></p>