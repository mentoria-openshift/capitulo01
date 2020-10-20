<p align="center"><a href="../aula01">Aula 1</a> | <a href="../aula02">Aula 2</a></p>
<br/>

# Exercício prático - Aulas 1 e 2

Com o conteúdo que aprendemos neste capítulo, podemos criar uma imagem de container simples para subi-la e executar sua aplicação. Ao final deste exercício, você saberá criar uma imagem de container e executa-la. A aplicação que usaremos é um simples hello-world escrito em Java que exibe uma mensagem quando o endpoint é acessado.

## Requerimentos
- Sua imagem de container deve se chamar `simplecrud`, e deverá ter a tag `1.0`.
- A porta `8080` deverá ser exposta e tunelada entre seu container e seu computador.
- A veriável de ambiente `APP_PROFILE` deverá ser declarada com o valor `default`.
- O sistema operacional base da imagem deverá ser o `maven:3.6.3-adoptopenjdk-11`
- O nome do container também deve ser `simplecrud`.
- A aplicação ficará disponível no endpoint `http://localhost:8080/api`.
- O código da aplicação está disponível em `https://github.com/thaalesalves/simplecrud-spring`.
- Para compilar o código da aplicação, use o comando `mvn clean install`
- Para executar a aplicação compilada, use `java -Dspring.profiles.active="$APP_PROFILE" -jar /opt/simplecrud-spring/target/simplecrud-0.0.1-SNAPSHOT.jar`

## Passo-a-passo
Este passo a passo indica como chegar ao resultado final do exercício. Clique na seta ao lado do enunciado para exibir a resposta. Note que o exercício todo será feito na linha de comando.

<details> 
  <summary>1. Crie o arquivo Dockerfile e declare a imagem base.</summary>
   
```bash
mkdir -p /pasta/de/trabalho/exercicio1/scripts
cd /pasta/de/trabalho/exercicio1
touch Dockerfile
```

Abra o Dockerfile com seu editor de texto favorito. O conteúdo do seu Dockerfile deverá ser o seguinte.

```Dockerfile
FROM docker.io/maven:3.6.3-adoptopenjdk-11
```

</details>

<details> 
  <summary>2. Declare as variáveis de ambiente e os comandos necessários para clonar e compilar a aplicação.</summary>
  
```Dockerfile
ENV APP_PROFILE="default"

COPY [ "scripts/entrypoint.sh", "/entrypoint.sh" ]

RUN apt update -y
RUN apt install -y git
RUN git clone https://github.com/thaalesalves/simplecrud-spring /opt/simplecrud

WORKDIR /opt/simplecrud

RUN mvn clean install
```

</details>

<details> 
  <summary>3. Exponha a porta necessária e declare a execução da aplicação no entrypoint.</summary>

```Dockerfile
EXPOSE 8080
ENTRYPOINT [ "sh", "/entrypoint.sh" ]
```

</details>

<details> 
  <summary>4. Crie um arquivo de entrypoint e copie-o para a imagem.</summary>
  
```bash
touch scripts/entrypoint.sh
```

Abra seu `entrypoint.sh` com seu editor de texto favorito.

```bash
#!/bin/bash

java -Dspring.profiles.active="$APP_PROFILE" -jar /opt/simplecrud/target/simplecrud-0.0.1-SNAPSHOT.jar 
```

</details>

<details> 
  <summary>5. Compile a imagem.</summary>
   
```bash
docker build -t simplecrud:1.0 .
```

</details>

<details> 
  <summary>6. Crie um container a partir da imagem e acesse o shell dele.</summary>
   
```bash
# Criando um container
docker run -d --name simplecrud -p 8080:8080 simplecrud:1.0

# Para acessar o bash do container
docker exec -it simplecrud bash
```

</details>

<details> 
  <summary>7. Acesse o endpoint da aplicação e veja o JSON exibido duas vezes, uma pelo bash do container e outra localmente na sua máquina.</summary>

```bash
# Execute o curl duas vezes:
curl localhost:8080/api
```

</details>

---
<p align="center"><a href="../aula01">Aula 1</a> | <a href="../aula02">Aula 2</a></p>