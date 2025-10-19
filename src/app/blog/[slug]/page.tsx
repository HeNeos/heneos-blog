import { getPostBySlug, getAllPosts } from '@/lib/api';
import MarkdownContent from '@/components/markdown-content';
import Link from 'next/link';
import { Metadata } from 'next';

// Generate static pages for all posts
export async function generateStaticParams() {
  const posts = getAllPosts();

  return posts.map((post) => ({
    slug: post.slug,
  }));
}

type Props = {
  params: { slug: string }
}

// Generate metadata for the page
export function generateMetadata({ params }: Props): Metadata {
  const post = getPostBySlug(params.slug);

  return {
    title: `${post.title} | HeNeos blog`,
    description: post.description,
  };
}

export default function BlogPostPage({ params }: Props) {
  const post = getPostBySlug(params.slug);

  return (
    <div className="max-w-5xl mx-auto">
      <Link href="/blog" className="text-zinc-500 hover:text-blue-400 mb-6 inline-block animated-underline">
        ← Back to all posts
      </Link>

      <article className="container p-1 bg-zinc-900/30">
        <header className="mb-8 border-b border-zinc-800 pb-6">
          <h1 className="text-3xl font-bold mb-4 gradient-text">{post.title}</h1>
          <p className="text-zinc-500 mb-4 font-mono">
            {new Date(post.date).toLocaleDateString('en-US', {
              year: 'numeric',
              month: 'long',
              day: 'numeric'
            })}
          </p>

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
        </header>

        <div className="gap-4 mt-8">
          <MarkdownContent content={post.content} />
        </div>
      </article>
    </div>
  );
}
