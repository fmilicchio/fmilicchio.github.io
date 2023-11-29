---
title: Esercizio 30/11/2015
layout: post
---

(*in Italian*) 

# Esercizio 1

Si scriva una funzione `normCSV` che, date in input due stringhe `fin` e `fout`, legga dal file `fin` una serie di vettori $$ v_i \in \mathbb{R}^{n_i} $$, *i.e.*, di dimensione variabile, e scriva sul file `fout` i valori (con un valore per riga) $$ l_i \in \mathbb{R} $$ delle norme euclidee, *i.e.*, $$ l_i = \| v_i \| $$. 

# Esercizio 2

Data una lista $$ l = (l_i) $$ di vettori $$ l_i \in \mathbb{R}^{n_i} $$, scrivere una funzione "averages" che restituisca la lista delle coppie $$ (h_i, g_i) $$ delle medie armoniche e geometriche, con

\\[
h_i = \frac{n_i}{\sum_j (l_i)_j^{-1}} \,,
\\]

\\[
g_i = \sqrt[{\scriptstyle n_i}]{\Pi_j (l_i)_j} \,,
\\]