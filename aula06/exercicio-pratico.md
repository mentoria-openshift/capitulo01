<p align="center"><a href="../aula05">Aula 5</a> | <a href="../aula06">Aula 6</a></p>
<br/>

# Exercício prático - Aulas 5 e 6

Com o conteúdo que aprendemos nas aulas 5 e 6, podemos criar redes Docker e fazer nossos containers as utilizarem. Aprendemos sobre os diferentes tipos de rede e como aplica-los. Ao final deste exercício, você terá criado uma aplicação que funciona com multicontainer.

## Requerimentos
- Você deverá usar a imagem que criamos no exercício 2, de nome `simplecrud:1.0`.
- Você deverá fazer uma ligação com um banco de dados PostgreSQL usando a imagem `docker.io/postgres:10`.
- Nome do banco de dados, senha e usuário do PostgreSQL é a string `simplecrud`.
- Os dados acima são definidos nas variáveis de ambiente `POSTGRES_USER`, `POSTGRES_PASSWORD` e `POSTGRES_DATABASE`.
- O hostname do banco de dados deve ser `postgresql`.
- Os containers deverão ser inseridos numa rede chamada `simplecrud_net`, do tipo `bridge`.
- O container do PostgreSQL deverá ter a porta `5432` exposta.
- A aplicação deverá ser iniciada com um dos três perfis `pt`, `en` ou `fr`.
- O perfil da aplicação é definido na variável de ambiente `APP_PROFILE`, especificada no container da aplicação.
- As demais especificações da aplicação, como porta e imagem deverão ser iguais à do exercício da aula 2.
- O nome do hostname da aplicação deverá ser `simplecrud`.
- Teste seu resultado exibindo a lista de livros contida no banco de dados, através do endpoint `localhost:8080/api/get`.

## Passo-a-passo
<details> 
  <summary>1. Declare sua rede no seu `docker-compose.yaml`</summary>
   
```yaml
version: '3'
networks:
    ? simplecrud_net
```

</details>

<details> 
  <summary>2. Declare o template do seu container do PostgreSQL</summary>
   
```yaml
services:
  postgresql:
    container_name: postgresql
    image: docker.io/postgres:10
    hostname: postgresql
    ports:
     - '5432:5432'
    environment:
     - POSTGRES_USER=simplecrud
     - POSTGRES_PASSWORD=simplecrud
     - POSTGRES_DATABASE=simplecrud
    networks:
     - simplecrud_net
```

</details>

<details> 
  <summary>3. Declare o template da aplicação</summary>
   
```yaml
  simplecrud:
    container_name: simplecrud
    image: simplecrud:1.0
    hostname: simplecrud
    environment:
      - APP_PROFILE=fr
    ports:
     - '8080:8080'
    networks:
     - simplecrud_net
```

</details>

<details> 
  <summary>4. Inicie a aplicação</summary>
   
```bash
podman-compose up
```

</details>

<details> 
  <summary>5. Teste o endpoint exposto</summary>
   
```bash
curl localhost:8080/api/get
```

</details>

---
<p align="center"><a href="../aula05">Aula 5</a> | <a href="../aula06">Aula 6</a></p>