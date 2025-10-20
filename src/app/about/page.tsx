import type { Metadata } from 'next';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'About | HeNeos blog',
  description: 'Learn more about the author of this blog',
};

export default function AboutPage() {
  return (
    <div className="max-w-4xl mx-auto">
      <div className="border border-zinc-800 rounded-sm p-8 bg-zinc-900/30">
        <h1 className="text-4xl font-bold mb-6 border-b border-zinc-800 pb-4">About Me</h1>
        <div className="line-numbers">
          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              Welcome to my blog! I'm an engineer with interests in distributed systems,
              cloud security, algorithms & data structures, and technology in general.
            </p>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              I used to be a competitive programmer in my college days and still have fun doing that in my barely free time.
            </p>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              I'm currently the top 2 solver of my country in Project Euler.
            </p>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <div>
              <h2 className="text-2xl font-bold mb-3 text-zinc-100">My Tech Stack</h2>
              <p className="text-zinc-300 mb-2">
                I work with a variety of technologies including:
              </p>
              <ul className="text-zinc-300 list-none">
                <li className="flex items-center">
                  <span className="text-blue-400 mr-2">▪</span>
                  Python
                </li>
                <li className="flex items-center">
                  <span className="text-blue-400 mr-2">▪</span>
                  JavaScript/TypeScript
                </li>
                <li className="flex items-center">
                  <span className="text-blue-400 mr-2">▪</span>
                  AWS
                </li>
                <li className="flex items-center">
                  <span className="text-blue-400 mr-2">▪</span>
                  Kubernetes
                </li>
                <li className="flex items-center">
                  <span className="text-blue-400 mr-2">▪</span>
                  And more!
                </li>
              </ul>
            </div>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <div>
              <h2 className="text-2xl font-bold mb-3 text-zinc-100">Connect with Me</h2>
              <p className="text-zinc-300 mb-2">
                Feel free to reach out to me on social media or check out my work:
              </p>
              <ul className="text-zinc-300 list-none">
                <li className="flex items-center">
                  <span className="text-blue-400 mr-2">▪</span>
                  <a
                    href="https://github.com/HeNeos"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-400 hover:underline"
                  >
                    GitHub
                  </a>
                </li>
                <li className="flex items-center">
                  <span className="text-blue-400 mr-2">▪</span>
                  <a
                    href="https://x.com/_HeNeos"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-400 hover:underline"
                  >
                    Twitter
                  </a>
                </li>
                <li className="flex items-center">
                  <span className="text-blue-400 mr-2">▪</span>
                  <a
                    href="https://www.linkedin.com/in/heneos"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-400 hover:underline"
                  >
                    LinkedIn
                  </a>
                </li>
              </ul>
            </div>
          </div>

          <div className="flex items-start my-8">
            <Link
              href="/blog"
              className="bg-zinc-800 hover:bg-blue-400 hover:text-zinc-900 text-zinc-100 px-4 py-2 rounded-sm transition-colors"
            >
              Check out my blog
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
