import Link from 'next/link';
import { getAllPosts } from '@/lib/api';

export default function HomePage() {
  const posts = getAllPosts().slice(0, 3); // Get the 3 most recent posts

  return (
    <div className="max-w-5xl mx-auto">
      <section className="mb-16 p-6 border border-zinc-800 rounded-sm bg-zinc-900/60">
        <div className="line-numbers">
          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <h1 className="text-3xl font-bold text-zinc-100">
              Hi, I'm HeNeos
            </h1>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              I'm a Cloud Solutions Architect.
            </p>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              I primarily use <span className="font-bold">Python</span>, <span className="font-bold">TypeScript</span>, <span className="font-bold">AWS</span>, and <span className="font-bold">Kubernetes</span>.
            </p>
          </div>

          <div className="flex items-start my-4">
            <span className="text-zinc-500 mr-2 select-none"></span>
            <p className="text-zinc-300">
              I'm interested on distributed systems, cloud, cyber security, algorithms and data structures.
            </p>
          </div>

          <div className="flex gap-4 mt-8">
            <Link
              href="/blog"
              className="bg-zinc-800 hover:bg-blue-400 hover:text-zinc-900 text-zinc-100 px-4 py-2 rounded-sm transition-colors"
            >
              Read Blog
            </Link>
            <Link
              href="/about"
              className="border border-zinc-700 hover:border-blue-400 text-zinc-300 hover:text-blue-400 px-4 py-2 rounded-sm transition-colors"
            >
              About Me
            </Link>
          </div>
        </div>
      </section>

      <section>
        <div className="flex justify-between items-center mb-8 border-b border-zinc-800 pb-4">
          <h2 className="text-2xl font-bold">Recent Posts</h2>
          <Link href="/blog" className="text-zinc-500 hover:text-blue-400">
            View all →
          </Link>
        </div>

        <div className="space-y-6">
          {posts.map((post, index) => (
            <article key={post.slug} className="border border-zinc-800 rounded-sm p-6 hover:bg-zinc-900/50 transition-colors">
              <div className="flex items-start">
                <div className="text-zinc-500 font-mono mr-4 pt-1 select-none">
                  {String(index + 1).padStart(2, '0')}
                </div>
                <div className="flex-1">
                  <Link href={`/blog/${post.slug}`}>
                    <h3 className="text-xl font-bold mb-2 hover:text-blue-400 transition-colors">{post.title}</h3>
                  </Link>
                  <p className="text-zinc-500 mb-3 text-sm font-mono">{new Date(post.date).toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                  })}</p>
                  <p className="text-zinc-400 mb-4">{post.description}</p>

                  <div className="flex gap-2 flex-wrap">
                    {post.tags.map((tag) => (
                      <span
                        key={tag}
                        className="inline-block bg-zinc-800 text-zinc-300 px-2 py-1 text-xs rounded-sm"
                      >
                        #{tag}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            </article>
          ))}
        </div>
      </section>
    </div>
  );
}
