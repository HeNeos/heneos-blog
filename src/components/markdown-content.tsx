import React from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import rehypeRaw from 'rehype-raw';
import rehypeHighlight from 'rehype-highlight';
import 'highlight.js/styles/github-dark.css';

interface MarkdownContentProps {
  content: string;
}

export default function MarkdownContent({ content }: MarkdownContentProps) {
  return (
    <div className="prose prose-invert prose-zinc max-w-none">
      <ReactMarkdown
        remarkPlugins={[remarkGfm, remarkMath]}
        rehypePlugins={[rehypeKatex, rehypeRaw, [rehypeHighlight, { detect: true }]]}
        components={{
          img: ({ node, ...props }) => {
            // Check if the src is a URL or a local path
            const {src, alt, width, height, ...rest} = props;

            // For all images, use an img tag for static export
            return (
              <div className="image-container my-8">
                <img
                  src={src || ''}
                  alt={alt || ''}
                  width={width || '100%'}
                  height={height || 'auto'}
                  className="object-contain mx-auto"
                />
              </div>
            );
          },
          pre: ({ node, ...props }) => (
            <pre className="rounded-sm p-4 overflow-auto bg-zinc-900 text-zinc-100 my-4 border border-zinc-800 font-mono text-sm">
              {props.children}
            </pre>
          ),
          code: ({ node, inline, className, children, ...props }) => {
            if (inline) {
              return (
                <code className="bg-zinc-800 text-blue-400 px-1 py-0.5 rounded-sm font-mono text-sm" {...props}>
                  {children}
                </code>
              );
            }
            return (
              <code className={`${className} font-mono`} {...props}>
                {children}
              </code>
            );
          },
          p: ({ node, ...props }) => (
            <p className="text-zinc-300 my-4 leading-relaxed">
              {props.children}
            </p>
          ),
          h1: ({ node, ...props }) => (
            <h1 className="text-3xl font-bold my-6 text-zinc-100 border-b border-zinc-800 pb-2">
              {props.children}
            </h1>
          ),
          h2: ({ node, ...props }) => (
            <h2 className="text-2xl font-bold mt-8 mb-4 text-zinc-100 border-b border-zinc-800 pb-2">
              {props.children}
            </h2>
          ),
          h3: ({ node, ...props }) => (
            <h3 className="text-xl font-bold mt-6 mb-3 text-zinc-100">
              {props.children}
            </h3>
          ),
          ul: ({ node, ...props }) => (
            <ul className="list-disc pl-6 my-4 text-zinc-300 space-y-2">
              {props.children}
            </ul>
          ),
          ol: ({ node, ...props }) => (
            <ol className="list-decimal pl-6 my-4 text-zinc-300 space-y-2">
              {props.children}
            </ol>
          ),
          li: ({ node, ...props }) => (
            <li className="text-zinc-300">
              {props.children}
            </li>
          ),
          blockquote: ({ node, ...props }) => (
            <blockquote className="border-l-4 border-blue-400 pl-4 italic text-zinc-400 my-4">
              {props.children}
            </blockquote>
          ),
          a: ({ node, ...props }) => (
            <a
              href={props.href}
              className="text-blue-400 hover:underline"
              target={props.href?.startsWith('http') ? '_blank' : undefined}
              rel={props.href?.startsWith('http') ? 'noopener noreferrer' : undefined}
            >
              {props.children}
            </a>
          ),
          table: ({ node, ...props }) => (
            <div
              className="overflow-x-auto my-6"
              style={{ WebkitOverflowScrolling: "touch" }}
            >
              <table className="min-w-max divide-y divide-zinc-800 border border-zinc-800 rounded-sm">
                {props.children}
              </table>
            </div>
          ),
          th: ({ node, ...props }) => (
            <th className="px-4 py-3 text-left text-xs font-medium text-zinc-400 uppercase tracking-wider bg-zinc-900 border-b border-zinc-800">
              {props.children}
            </th>
          ),
          td: ({ node, ...props }) => (
            <td className="px-4 py-3 whitespace-nowrap text-zinc-300 border-b border-zinc-800">
              {props.children}
            </td>
          ),
          hr: ({ node, ...props }) => (
            <hr className="my-6 border-zinc-800" />
          ),
        }}
      >
        {content}
      </ReactMarkdown>
    </div>
  );
}
