import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import remarkMath from "remark-math";
import rehypeKatex from "rehype-katex";
import rehypeRaw from "rehype-raw";
import rehypeHighlight from "rehype-highlight";

const components = {
  source: ({ src, type, node, ...rest }) =>
    React.createElement("source", {
      src: src || "",
      type,
      className: "object-contain mx-auto",
      ...rest,
    }),

  video: ({ controls, width, height, children, node, ...rest }) =>
    React.createElement(
      "div",
      { className: "video-container my-8 flex justify-center" },
      React.createElement(
        "video",
        {
          controls: controls ?? true,
          width: width || "100%",
          height: height || "auto",
          className: "object-contain mx-auto shadow-lg",
          ...rest,
        },
        children,
      ),
    ),

  img: ({ src, alt, width, height, node, ...rest }) =>
    React.createElement(
      "div",
      { className: "image-container my-8" },
      React.createElement("img", {
        src: src || "",
        alt: alt || "",
        width: width || "100%",
        height: height || "auto",
        className: "object-contain mx-auto",
      }),
    ),

  pre: ({ node, ...props }) =>
    React.createElement(
      "pre",
      {
        className:
          "rounded-sm p-4 overflow-auto bg-zinc-900 text-zinc-100 my-4 border border-zinc-800",
      },
      props.children,
    ),

  code: ({ node, inline, className, children, ...props }) => {
    if (className === undefined) {
      return React.createElement(
        "code",
        {
          className:
            "bg-zinc-900 text-blue-600 px-1 py-0.5 rounded-sm text-xs",
          ...props,
        },
        children,
      );
    }

    return React.createElement(
      "code",
      { className: `${className} text-xs`, ...props },
      children,
    );
  },

  p: ({ node, ...props }) =>
    React.createElement(
      "p",
      { className: "text-base text-zinc-300 my-4 leading-relaxed" },
      props.children,
    ),

  h1: ({ node, ...props }) =>
    React.createElement(
      "h1",
      {
        className:
          "text-2xl font-bold my-6 text-zinc-100 border-b border-zinc-800 pb-2",
      },
      props.children,
    ),

  h2: ({ node, ...props }) =>
    React.createElement(
      "h2",
      {
        className:
          "text-xl font-bold mt-8 mb-4 text-zinc-100 border-b border-zinc-800 pb-2",
      },
      props.children,
    ),

  h3: ({ node, ...props }) =>
    React.createElement(
      "h3",
      { className: "text-lg font-bold mt-6 mb-3 text-zinc-100" },
      props.children,
    ),

  ul: ({ node, ...props }) =>
    React.createElement(
      "ul",
      { className: "list-disc pl-6 my-4 text-zinc-300 space-y-2" },
      props.children,
    ),

  ol: ({ node, ...props }) =>
    React.createElement(
      "ol",
      {
        className:
          "text-sm list-decimal pl-6 my-4 text-zinc-300 space-y-2",
      },
      props.children,
    ),

  li: ({ node, ...props }) =>
    React.createElement("li", { className: "text-zinc-300" }, props.children),

  blockquote: ({ node, ...props }) =>
    React.createElement(
      "blockquote",
      {
        className:
          "border-l-4 border-blue-400 pl-4 italic text-zinc-400 my-4",
      },
      props.children,
    ),

  a: ({ node, ...props }) =>
    React.createElement(
      "a",
      {
        href: props.href,
        className: "text-blue-400 hover:underline",
        target: props.href?.startsWith("http") ? "_blank" : undefined,
        rel: props.href?.startsWith("http")
          ? "noopener noreferrer"
          : undefined,
      },
      props.children,
    ),

  table: ({ node, ...props }) =>
    React.createElement(
      "div",
      {
        className: "overflow-x-auto",
        style: { WebkitOverflowScrolling: "touch" },
      },
      React.createElement(
        "table",
        {
          className:
            "min-w-max divide-y divide-zinc-800 border border-zinc-800 rounded-sm",
        },
        props.children,
      ),
    ),

  th: ({ node, ...props }) =>
    React.createElement(
      "th",
      {
        className:
          "text-sm px-4 py-3 text-left font-medium text-zinc-400 uppercase tracking-wider bg-zinc-900 border-b border-zinc-800",
      },
      props.children,
    ),

  td: ({ node, ...props }) =>
    React.createElement(
      "td",
      {
        className:
          "text-sm px-4 py-3 whitespace-nowrap text-zinc-300 border-b border-zinc-800",
      },
      props.children,
    ),

  hr: () => React.createElement("hr", { className: "my-6 border-zinc-800" }),
};

export function render_markdown(content) {
  const element = React.createElement(
    "div",
    { className: "prose prose-invert prose-zinc max-w-none" },
    React.createElement(
      ReactMarkdown,
      {
        remarkPlugins: [remarkGfm, remarkMath],
        rehypePlugins: [
          rehypeKatex,
          rehypeRaw,
          [rehypeHighlight, { detect: true }],
        ],
        components,
      },
      content,
    ),
  );

  return renderToStaticMarkup(element);
}
