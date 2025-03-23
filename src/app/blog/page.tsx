import Link from 'next/link';
import { getAllPosts } from '@/lib/api';

export default function BlogPage() {
  const posts = getAllPosts();

  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-10 text-center">Blog Posts</h1>

      <div className="space-y-6">
        {posts.map((post, index) => (
          <article
            key={post.slug}
            className="border border-zinc-800 rounded-lg p-6 hover:bg-zinc-900/50 transition-colors"
          >
            <div className="flex items-start">
              <div className="text-zinc-500 font-mono mr-4 pt-1 select-none">
                {String(index + 1).padStart(2, '0')}
              </div>
              <div className="flex-1">
                <Link href={`/blog/${post.slug}`}>
                  <h2 className="text-2xl font-bold mb-2 hover:text-yellow-400 transition-colors">
                    {post.title}
                  </h2>
                </Link>
                <p className="text-zinc-500 mb-3 text-sm">
                  {new Date(post.date).toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                  })}
                </p>
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
    </div>
  );
}
