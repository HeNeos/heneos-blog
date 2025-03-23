import type { Metadata } from "next";
import "./globals.css";
import Link from "next/link";
import 'katex/dist/katex.min.css';

export const metadata: Metadata = {
  title: "HeNeos blog",
  description: "A programming blog with Markdown, LaTeX, and code snippets",
};

const NavLink = ({ href, children, shortcut }: { href: string; children: React.ReactNode; shortcut: string }) => (
  <div className="cursor-pointer hover:bg-blue-400 hover:text-zinc-900 transition-colors px-4 py-2 rounded-md flex items-center justify-between">
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
              <h1 className="text-4xl font-bold tracking-tighter mb-4 text-center">
                HeNeos blog
              </h1>
              <p className="text-center text-zinc-500 mb-2">
                Josue H. @ JP Morgan Chase
              </p>
              <p className="text-center text-zinc-600">
                HeNeos
              </p>
            </div>

            <div className="flex justify-center space-x-10 mb-4">
              <Link href="https://github.com/HeNeos" target="_blank" className="text-zinc-500 hover:text-zinc-300">
                GH
              </Link>
              <Link href="https://x.com/_HeNeos" target="_blank" className="text-zinc-500 hover:text-zinc-300">
                TW
              </Link>
              <Link href="https://www.linkedin.com/in/heneos" target="_blank" className="text-zinc-500 hover:text-zinc-300">
                LI
              </Link>
              <Link href="https://codeforces.com/profile/HeNeos" className="text-zinc-500 hover:text-zinc-300">
                CF
              </Link>
              <Link href="https://codeforces.com/profile/Ptolemy_314" className="text-zinc-500 hover:text-zinc-300">
                CF old
              </Link>
              <Link href="mailto:he.neos@outlook.com" className="text-zinc-500 hover:text-zinc-300">
                EM
              </Link>
            </div>

            <div className="flex flex-col sm:flex-row justify-center gap-4 border-t border-zinc-800 pt-4">
              <Link href="/">
                <NavLink href="/" shortcut="ha">Home</NavLink>
              </Link>
              <Link href="/blog">
                <NavLink href="/blog" shortcut="hb">Blog</NavLink>
              </Link>
              <Link href="/about">
                <NavLink href="/about" shortcut="hc">About</NavLink>
              </Link>
            </div>
          </div>
        </header>

        <main className="container mx-auto px-4 py-8 max-w-6xl">
          {children}
        </main>

        <footer className="border-t border-zinc-800 py-6 mt-12">
          <div className="container mx-auto px-4 relative h-full">
            <div className="flex items-center justify-between">
              <div className="flex-shrink-0" style={{ maxWidth: '20%' }}>
                <a href="https://projecteuler.net/profile/HeNeos.png" target="_blank" rel="noopener noreferrer">
                  <img
                    src="https://projecteuler.net/profile/HeNeos.png"
                    alt="Project Euler Profile"
                    className="w-full h-auto max-h-12 border border-zinc-700 rounded-sm object-contain"
                  />
                </a>
              </div>

              <div className="absolute left-1/2 -translate-x-1/2">
                <p className="text-zinc-500 text-sm sm:text-base">
                  © {new Date().getFullYear()} HeNeos Blog. Built with Next.js, Markdown, and KaTeX.
                </p>
              </div>
            </div>
          </div>
        </footer>
      </body>
    </html>
  );
}
