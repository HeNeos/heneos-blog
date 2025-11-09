import type { Metadata } from "next";
import "./globals.css";
import Link from "next/link";
import 'katex/dist/katex.min.css';

export const metadata: Metadata = {
  title: "HeNeos blog",
  description: "A programming blog with Markdown, LaTeX, and code snippets",
};

const NavLink = ({ href, children, shortcut }: { href: string; children: React.ReactNode; shortcut: string }) => (
  <div className="cursor-pointer hover:bg-gray-200 hover:text-zinc-900 transition-colors px-4 py-2 rounded-md flex items-center justify-between">
    <span>{children}</span>
    <span className="text-zinc-500 ml-6">{shortcut}</span>
  </div>
);

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="bg-zinc-950 text-zinc-100 min-h-screen">
        <header className="p-6 border-b border-zinc-800">
          <div className="max-w-6xl mx-auto">
            <div className="mb-10">
              <h1 className="text-6xl font-raleway tracking-tighter mb-2 text-center">
                HeNeos blog
              </h1>
              <p className="text-xl font-mono text-center text-zinc-500 mb-1">
                Josue H. @ JP Morgan Chase
              </p>
              <p className="text-xl font-raleway text-center text-zinc-600">
                HeNeos
              </p>
            </div>

            <div className="flex justify-center space-x-20 mb-4">
              <Link href="https://github.com/HeNeos" target="_blank" className="text-base font-raleway text-zinc-500 hover:text-accent animated-underline">
                GitHub
              </Link>
              <Link href="https://www.linkedin.com/in/heneos" target="_blank" className="text-base font-raleway text-zinc-500 hover:text-accent animated-underline">
                LinkedIn
              </Link>
              <Link href="mailto:he.neos@outlook.com" className="text-base font-raleway text-zinc-500 hover:text-accent animated-underline">
                Email
              </Link>
            </div>

            <div className="text-xl font-raleway flex flex-col sm:flex-row justify-center gap-4 border-t border-zinc-800 pt-4">
              <Link href="/">
                <NavLink href="/" shortcut="ha">Home</NavLink>
              </Link>
              <Link href="/blog">
                <NavLink href="/blog" shortcut="hb">Blog</NavLink>
              </Link>
              <Link href="/about">
                <NavLink href="/about" shortcut="hc">About</NavLink>
              </Link>
              <Link href="/devlog">
                <NavLink href="/devlog" shortcut="hd">Dev Log</NavLink>
              </Link>
            </div>
          </div>
        </header>

        <main className="mx-auto px-4 py-6 max-w-5xl">
          {children}
        </main>

          <footer className="border-t border-zinc-800 py-6 mt-2">
            <div className="container mx-auto px-4 relative h-full">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div>
                  <h3 className="text-lg font-semibold text-white mb-4">Connect</h3>
                  <div className="flex space-x-4">
                    <a
                      href="https://github.com/HeNeos"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-slate-400 hover:text-white transition-colors"
                    >
                      GitHub
                    </a>
                    <a
                      href="https://x.com/_HeNeos"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-slate-400 hover:text-white transition-colors"
                    >
                      X
                    </a>
                    <a
                      href="https://codeforces.com/profile/HeNeos"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-slate-400 hover:text-white transition-colors"
                    >
                      Codeforces
                    </a>
                    <a
                      href="https://codeforces.com/profile/Ptolemy_314"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-slate-400 hover:text-white transition-colors"
                    >
                      Codeforces old
                    </a>
                  </div>
                </div>

                <div>
                  <h4 className="text-lg font-semibold text-white mb-4">Project Euler</h4>
                  <a href="https://projecteuler.net/profile/HeNeos.png" target="_blank" rel="noopener noreferrer">
                    <img
                      src="https://projecteuler.net/profile/HeNeos.png"
                      alt="Project Euler Profile"
                      className=" h-auto max-h-10 rounded-sm object-contain"
                    />
                  </a>
                </div>
              </div>
            </div>
          </footer>
      </body>
    </html>
  );
}
