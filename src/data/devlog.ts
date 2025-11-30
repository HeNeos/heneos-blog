export type DevlogEntry = {
  id: string;
  title: string;
  url: string;
  description: string;
  addedAt: string;
  readAt?: string;
};

export const devlogEntries: DevlogEntry[] = [
  {
    id: "genuine-sieve",
    title: "Genuine Sieve",
    url: "https://www.cs.hmc.edu/~oneill/papers/Sieve-JFP.pdf",
    description:
      "A raw implementation of Eratosthenes' Sieve in functional programming.",
    addedAt: "2025-10-29",
  },
  {
    id: "lambda-calculus-ocaml",
    title: "Learn Lambda Calculus in 10 minutes with OCaml",
    url: "https://chshersh.com/blog/2024-02-05-learn-lambda-calculus-in-10-minutes-with-ocaml.html",
    description: "A fast introduction to lambda calculus using OCaml.",
    addedAt: "2025-10-29",
  },
  {
    id: "pragmatic-category-theory",
    title: "Pragmatic Category Theory",
    url: "https://chshersh.com/blog/2024-07-30-pragmatic-category-theory-part-01.html",
    description: "A practical introduction to category theory concepts.",
    addedAt: "2025-10-29",
  },
  {
    id: "rego-101",
    title: "Rego 101: Introduction to Rego",
    url: "https://snyk.io/blog/introduction-to-rego/",
    description: "Learn the basics of Rego and policy-based authorization.",
    addedAt: "2025-10-29",
  },
  {
    id: "knapsack-convolution",
    title: "[Tutorial] Knapsack, Subset Sum and the (max,+) Convolution",
    url: "https://codeforces.com/blog/entry/98663",
    description:
      "Understanding DP optimizations and (max,+) convolution in competitive programming.",
    addedAt: "2025-10-29",
  },
  {
    id: "ruliology-lambdas",
    title: "The ruliology of lambdas",
    url: "https://writings.stephenwolfram.com/2025/09/the-ruliology-of-lambdas/",
    description:
      "Stephen Wolfram explores lambda calculus through the lens of ruliology.",
    addedAt: "2025-10-29",
  },
  {
    id: "numbat",
    title: "Numbat",
    url: "https://github.com/sharkdp/numbat",
    description: "Numbat is a statically typed programming language for scientific computations with first class support for physical dimensions and units.",
    addedAt: "2025-10-29",
  },
  {
    id: "mojo",
    title: "Mojo",
    url: "https://www.modular.com/mojo",
    description: "Mojo is a programming language that unifies high-level AI development with low-level systems programming. Write once, deploy everywhere - from CPUs to GPUs",
    addedAt: "2025-10-29",
  },
  {
    id: "pytoolz",
    title: "Pytoolz",
    url: "https://toolz.readthedocs.io/en/latest/",
    description: "A set of utility functions for iterators, functions, and dictionaries.",
    addedAt: "2025-10-29",
  },
  {
    id: "jujutsu-for-busy-devs",
    title: "Jujutsu for busy devs",
    url: "https://maddie.wtf/posts/2025-07-21-jujutsu-for-busy-devs",
    description: "Jujutsu (jj) is a version control system with a significantly simplified mental model and command-line interface compared to Git, without sacrificing expressibility or power",
    addedAt: "2025-10-29",
  },
  {
    id: "confused-deputy",
    title: "The confused deputy problem",
    url: "docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html",
    description: "The confused deputy problem is a security issue where an entity that doesn't have permission to perform an action can coerce a more-privileged entity",
    addedAt: "2025-10-29",
  },
  {
    id: "diggydb",
    title: "DiggyDB",
    url: "https://github.com/njbmartin/diggydb-nodejs",
    description:
      "A lightweight Node.js key-value store with a simple file-based storage engine.",
    addedAt: "2025-11-01",
  },
  {
    id: "anubis",
    title: "Anubis",
    url: "https://anubis.techaro.lol/",
    description:
      "A small and elegant static site generator focused on simplicity and clean design.",
    addedAt: "2025-11-01",
  },
  {
    id: "kd-tree",
    title: "k-d tree",
    url: "https://en.wikipedia.org/wiki/K-d_tree",
    description:
      "A multidimensional binary search tree used for nearest-neighbor search and spatial indexing.",
    addedAt: "2025-11-01",
  },
  {
    id: "curse-of-knowing",
    title: "The Curse of Knowing How, or; Fixing Everything",
    url: "https://notashelf.dev/posts/curse-of-knowing",
    description:
      "A reflection on the cognitive trap of always wanting to fix systems once you understand them deeply.",
    addedAt: "2025-11-01",
  },
  {
    id: "grhkm-mastodon",
    title: "grhkm — Mastodon",
    url: "https://mathstodon.xyz/@grhkm",
    description: "grhkm's primary Mastodon profile, focused on math and cryptography insights.",
    addedAt: "2025-11-01",
  },
  {
    id: "grhkm-old-mastodon",
    title: "grhkm — Old Mastodon",
    url: "https://infosec.exchange/@grhkm",
    description: "grhkm's older Mastodon profile with infosec-related posts and discussions.",
    addedAt: "2025-11-01",
  },
  {
    id: "grhkm-baby-rsa",
    title: "BabyRSA — Bauhinia CTF 2023 analysis",
    url: "https://connor-mccartney.github.io/cryptography/small-roots/babyRSA-Bauhinia-CTF-2023",
    description:
      "A detailed walk-through of solving the BabyRSA challenge using small-roots techniques.",
    addedAt: "2025-11-01",
  },
  {
    id: "grhkm-timing-attacks",
    title: "Breaking perfect security with timing attacks",
    url: "https://www.youtube.com/watch?v=OC5D6DD1-_w",
    description:
      "A great video illustrating how subtle timing differences can completely break cryptographic systems.",
    addedAt: "2025-11-01",
  },
  {
    id: "grhkm-codeforces",
    title: "grhkm — Codeforces blog",
    url: "https://codeforces.com/blog/grhkm",
    description:
      "Competitive programming posts, problem breakdowns, and math-heavy algorithm insights by grhkm.",
    addedAt: "2025-11-01",
  },
  {
    id: "grhkm-cryptohack",
    title: "grhkm — CryptoHack",
    url: "https://cryptohack.org/user/grhkm/",
    description:
      "grhkm's CryptoHack profile with their progress on modern cryptography challenges.",
    addedAt: "2025-11-01",
  },
];

