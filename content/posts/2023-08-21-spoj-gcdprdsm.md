---
title: "SPOJ: GCDPRDSM"
description: "Solving GCDPRDSM | GCD Product Sum"
tags: ["spoj", "algorithms", "number-theory"]
date: "2023-08-21"
---

## Statement

In this problem, you will be given $q$ queries (1 $\leq$ $q$ $\leq$ $1000000$). Each query will contain a single integer $n$ ($1$ $\leq$ $n$ $\leq$ $1000000$).

For each query you have to output the following:

$$
    \sum_{i=1}^{n} i \gcd(i, n)
$$

## Solution

$$
    S = \sum_{i=1}^{n} i \gcd(i, n)\\
    S = \sum_{i=1}^{n} i \sum_{k\vert n} k \Big\vert \gcd(i/k, n/k) = 1 \Big\vert
$$

Where $k$ is the $\gcd(i, n)$. It means that $k\vert n$ and $k\vert i$.

$$
    S = \sum_{i=1}^{n} i \sum_{k\vert n} k \sum_{d\vert n} \mu(d) \Big\vert d\vert \gcd(i/k, n/k) \Big\vert\\
    S = \sum_{i=1}^{n} i \sum_{k\vert n} k \sum_{d\vert n} \mu(d) \Big\vert d\vert i/k \Big\vert \Big\vert d\vert n/k \Big\vert\\
    S = \sum_{d\vert n} \mu(d) \sum_{k\vert n} k \Big\vert d\vert n/k \Big\vert \sum_{i=1}^{n} i \Big\vert d\vert i/k \Big\vert\\
    S = \sum_{d\vert n} \mu(d) \sum_{k\vert n} k \Big\vert d\vert n/k \Big\vert \sum_{j=1}^{n/k} jk \Big\vert d\vert j \Big\vert
$$

The last sum is easy to calculate because it's just the sum of multiples of $d$ up to $n/k$.

$$
    S = \sum_{d\vert n} \mu(d) \sum_{k\vert n} k^{2} \Big\vert d\vert n/k \Big\vert d \frac{\frac{n/k}{d}(\frac{n/k}{d}+1)}{2}\\
    S = \sum_{d\vert n} \mu(d) d \sum_{k\vert n} (n/k)^{2} \Big\vert d\vert k \Big\vert  \frac{k/d(k/d+1)}{2}\\
    S = \sum_{d\vert n} \mu(d) d \sum_{k\in d\,\mathrm{div}(n/d)} (n/k)^{2} \frac{k/d(k/d+1)}{2}\\
    S = \sum_{d\vert n} \mu(d)/d \sum_{k\vert n/d} (n/k)^{2} \frac{k(k+1)}{2}\\
    S = \frac{n}{2}\sum_{d\vert n} \mu(d) \sum_{k \vert n/d} (k+1)\frac{n/d}{k}\\
    S = \frac{n}{2}\sum_{d\vert n} \mu(d) \Big(\frac{n}{d} \sigma_{0}(n/d) + \sigma_{1}(n/d)\Big)\\
    S = \frac{n}{2} \Big(n +\sum_{d\vert n} \mu(n/d) d \sigma_{0}(d)\Big)
$$
