<p align="center"><a href="../aula03">Aula 3</a> | <a href="../aula04">Aula 4</a></p>
<br/>

# Questionário - Aulas 3 e 4

1. Qual tipo de rede Docker permite que containers se comunique com computadores da rede física real?

    **a)** host

    **b)** macvlan

    **c)** bridge

    **d)** overlay
---

2. Qual o comando usado para adicionar um container a uma rede?

    **a)** `docker network <REDE> add-contanainer <CONTAINER>`

    **b)** `docker network connect <REDE> <CONTAINER>`

    **c)** `docker network connect-to-network <CONTAINER> <NETWORK>`
---

3. Como declarar uma rede no Compose usando mapa que seja criada como bridge?

    **a)** 
    ```yaml
    networks:
        ? minha_rede
    ```

    **b)** 
    ```yaml
    networks:
        - minha_rede
    ```

    **c)**
    ```yaml
    networks:
        minha_rede:
            driver: bridge
    ```
---

4. Qual comando cria uma rede Docker do tipo macvlan?

    **a)** `docker network create minha_rede --type macvlan`

    **b)** `docker new-network minha_rede --type macvlan`

    **c)** `docker network create minha_rede --driver macvlan`

    **c)** `docker network add minha_rede --driver macvlan`

---

<details> 
  <summary>Respostas</summary>

    1. Resposta: a
    2. Resposta: b
    3. Resposta: a
    4. Resposta: c
</details>

---
<p align="center"><a href="../aula03">Aula 3</a> | <a href="../aula04">Aula 4</a></p>