import type { Metadata } from 'next';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'About | Developer Blog',
  description: 'Learn more about the author of this blog',
};

export default function AboutPage() {
  return (
    <div className="max-w-3xl mx-auto">
      <div className="border border-zinc-800 rounded-sm p-8 bg-zinc-900/30">
        <h1 className="text-4xl font-bold mb-6 border-b border-zinc-800 pb-4">About Me</h1>

        <div className="line-numbers">
          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none">1</span>
            <p className="text-zinc-300">
              Welcome to my blog! I'm a passionate developer with interests in web development,
              programming languages, and technology in general.
            </p>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none">2</span>
            <p className="text-zinc-300">
              This blog is built with Next.js and features:
            </p>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none">3</span>
            <ul className="text-zinc-300 list-none">
              <li className="flex items-center">
                <span className="text-yellow-400 mr-2">▪</span>
                Markdown support for content
              </li>
              <li className="flex items-center">
                <span className="text-yellow-400 mr-2">▪</span>
                LaTeX for mathematical expressions
              </li>
              <li className="flex items-center">
                <span className="text-yellow-400 mr-2">▪</span>
                Syntax highlighting for code snippets
              </li>
              <li className="flex items-center">
                <span className="text-yellow-400 mr-2">▪</span>
                Responsive design
              </li>
              <li className="flex items-center">
                <span className="text-yellow-400 mr-2">▪</span>
                Dark mode by default
              </li>
            </ul>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none">4</span>
            <div>
              <h2 className="text-2xl font-bold mb-3 text-zinc-100">My Tech Stack</h2>
              <p className="text-zinc-300 mb-2">
                I work with a variety of technologies including:
              </p>
              <ul className="text-zinc-300 list-none">
                <li className="flex items-center">
                  <span className="text-yellow-400 mr-2">▪</span>
                  JavaScript/TypeScript
                </li>
                <li className="flex items-center">
                  <span className="text-yellow-400 mr-2">▪</span>
                  React and Next.js
                </li>
                <li className="flex items-center">
                  <span className="text-yellow-400 mr-2">▪</span>
                  Node.js
                </li>
                <li className="flex items-center">
                  <span className="text-yellow-400 mr-2">▪</span>
                  Python
                </li>
                <li className="flex items-center">
                  <span className="text-yellow-400 mr-2">▪</span>
                  And more!
                </li>
              </ul>
            </div>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none">5</span>
            <div>
              <h2 className="text-2xl font-bold mb-3 text-zinc-100">Connect with Me</h2>
              <p className="text-zinc-300 mb-2">
                Feel free to reach out to me on social media or check out my work:
              </p>
              <ul className="text-zinc-300 list-none">
                <li className="flex items-center">
                  <span className="text-yellow-400 mr-2">▪</span>
                  <a
                    href="https://github.com/"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-yellow-400 hover:underline"
                  >
                    GitHub
                  </a>
                </li>
                <li className="flex items-center">
                  <span className="text-yellow-400 mr-2">▪</span>
                  <a
                    href="https://twitter.com/"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-yellow-400 hover:underline"
                  >
                    Twitter
                  </a>
                </li>
                <li className="flex items-center">
                  <span className="text-yellow-400 mr-2">▪</span>
                  <a
                    href="https://linkedin.com/"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-yellow-400 hover:underline"
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
              className="bg-zinc-800 hover:bg-yellow-400 hover:text-zinc-900 text-zinc-100 px-4 py-2 rounded-sm transition-colors"
            >
              Check out my blog
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
