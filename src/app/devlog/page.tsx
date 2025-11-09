import type { Metadata } from 'next';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'DevLog | HeNeos blog',
  description: 'My personal devlog',
};

export default function DevLogPage() {
  return (
    <div className="max-w-4xl mx-auto">
      <div className="border border-zinc-800 rounded-sm p-8 bg-zinc-900/30">
        <h1 className="text-4xl font-mono font-bold mb-6 border-b border-zinc-800 pb-2">Dev Log</h1>
        <div className="line-numbers font-mono text-sm">
          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://www.cs.hmc.edu/~oneill/papers/Sieve-JFP.pdf">Genuine Sieve</a>
              <br/>A raw implementation of Erastosthenes' Sieve in Functional Programming
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://chshersh.com/blog/2024-02-05-learn-lambda-calculus-in-10-minutes-with-ocaml.html">Learn Lambda Calculus in 10 minutes with OCaml</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://chshersh.com/blog/2024-07-30-pragmatic-category-theory-part-01.html">Pragmatic Category Theory</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://snyk.io/blog/introduction-to-rego/">Rego 101: Introduction to Rego</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://codeforces.com/blog/entry/98663">[Tutorial] Knapsack, Subset Sum and the (max,+) Convolution</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://writings.stephenwolfram.com/2025/09/the-ruliology-of-lambdas/">The ruliology of lambdas</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://github.com/sharkdp/numbat">Numbat</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://www.modular.com/mojo">Mojo</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://toolz.readthedocs.io/en/latest/">Pytoolz</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://maddie.wtf/posts/2025-07-21-jujutsu-for-busy-devs">Jujutsu for busy devs</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html">The confused deputy problem</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://github.com/njbmartin/diggydb-nodejs">DiggyDB</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://anubis.techaro.lol/">Anubis</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://en.wikipedia.org/wiki/K-d_tree">k-d tree</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://notashelf.dev/posts/curse-of-knowing">The Curse of Knowing How, or; Fixing Everything</a>
            </p>
          </div>

          <div className="flex items-start my-2">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              <a className="text-blue-300" href="https://mathstodon.xyz/@grhkm">grhkm mastodon<br/></a>
              <a className="text-blue-300" href="infosec.exchange/@grhkm">grhkm old mastodon<br/></a>
              <a className="text-blue-300" href="https://connor-mccartney.github.io/cryptography/small-roots/babyRSA-Bauhinia-CTF-2023">grhkm baby rsa<br/></a>
              <a className="text-blue-300" href="https://www.youtube.com/watch?v=OC5D6DD1-_w">breaking perfect security with timming attacks<br/></a>
              <a className="text-blue-300" href="https://codeforces.com/blog/grhkm">grhkm codeforces<br/></a>
              <a className="text-blue-300" href=" https://cryptohack.org/user/grhkm/">grhkm cryptohack</a>
            </p>
          </div>

        </div>
      </div>
    </div>
  );
}
