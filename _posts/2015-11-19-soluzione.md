---
title: Soluzione Autovalutazione
layout: post
---

(*in Italian*) Qui sotto è riportata una possibile soluzione alla autovalutazione. Si ricorda che *esistono molteplici soluzioni* possibili. 

```python
# Apri il file
f = open("m.txt", "r")

# Media
m = [0.0, 0.0, 0.0]

# Numero di righe
n = 0

# Per ogni riga
for i in f:
    # Ottieni il punto trasformando in float tutti i numeri (split con la virgola)
    p = map(float, i.split(","))
    # Aggiorna la somma parziale
    m[0] = m[0] + p[0]
    m[1] = m[1] + p[1]
    m[2] = m[2] + p[2]
    # Aggiorna il numero di righe
    n = n + 1

# Calcola la media
m[0] = m[0] / n
m[1] = m[1] / n
m[2] = m[2] / n

# Stampa il risultato
print m
```

# File di Input

```
1.1,1.1,1.1
2.2,2.2,2.2
3.3,3.3,3.3
```

# Output

```
[2.1999999999999997, 2.1999999999999997, 2.1999999999999997]
```