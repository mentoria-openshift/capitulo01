<p align="center"><a href="../aula03">Aula 3</a> | <a href="../aula04">Aula 4</a></p>
<br/>

# Questionário - Aulas 3 e 4

1. O que faz o Buildah?

    **a)** Compila imagens e gerencia containers.

    **b)** Copia imagens de um repositório para outro.

    **c)** Cria containers a partir de um template.

    **d)** Gera um Dockerfile para uso.
---

2. O que faz o Skopeo?

    **a)** Compila imagens e gerencia containers.

    **b)** Copia imagens de um repositório para outro.

    **c)** Cria containers a partir de um template.

    **d)** Gera um Dockerfile para uso.
---

3. Qual dos comandos a seguir remove todos os container existentes localmente?

    **a)** `docker rmi -f $(docker ps -aq)`

    **b)** `docker rm all`

    **c)** `docker rm -f $(docker ps -aq)`

    **d)** `docker remove-container -f $(docker ps -aq)`
---

4. Como baixar imagens de um repositório remoto para o repositório local com o Skopeo?

    **a)** `skopeo download imagem:tag`

    **b)** `skopeo copy --from docker://repo.com/imagem:tag --to docker://localhost/imagem:tag`

    **c)** `skopeo copy docker://repo.com/imagem:tag containers-storage:imagem:tag`

    **d)** `skopeo download --from docker://repo.com/imagem:tag`
---

5. Por que é importante diminuir o número de camadas de uma imagem?

    **a)** Para que o código do Dockerfile fique mais organizado

    **b)** Para que a imagem não fique tão pesada

    **c)** Para que o container fique mais rápido

    **d)** Não é necessário diminuir o número de camadas
---

<details> 
  <summary>Respostas</summary>

    1. Resposta: a
    2. Resposta: b
    3. Resposta: c
    4. Resposta: c
    5. Resposta: b
</details>

---
<p align="center"><a href="../aula03">Aula 3</a> | <a href="../aula04">Aula 4</a></p>