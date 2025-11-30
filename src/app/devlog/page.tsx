import type { Metadata } from "next";
import { useEffect, useState } from "react";
import { devlogEntries } from "@/data/devlog";

export const metadata: Metadata = {
  title: "DevLog | HeNeos blog",
  description: "My personal devlog",
};

type ReadState = Record<string, string | null>;

export default function DevLogPage() {
  return (
    <div className="max-w-4xl mx-auto">
      <div className="border border-zinc-800 rounded-sm p-8 bg-zinc-900/30">
        <h1 className="text-4xl font-mono font-bold mb-6 border-b border-zinc-800 pb-2">
          Dev Log
        </h1>

        <div className="font-mono text-sm space-y-5">
          {devlogEntries.map((entry) => {
            const isRead = Boolean(entry.readAt);
            return (
              <div
                key={entry.id}
                className="relative group flex items-center justify-between"
              >
                {/* Link + hover tooltip */}
                <div className="relative">
                  <a className="font-bold text-blue-300" href={entry.url}>
                    {entry.title}
                  </a>

                  {/* Floating tooltip */}
                  <div
                    className="
                      absolute left-0 top-full mt-1 w-80
                      rounded-md border border-zinc-700 bg-zinc-800 p-2
                      font-mono text-[11px] text-zinc-300 shadow-lg z-50
                      opacity-0 pointer-events-none
                      group-hover:opacity-100 group-hover:pointer-events-auto
                      transition-opacity duration-450
                    "
                  >
                    {entry.description}

                    <div className="text-[9px] text-zinc-500 mt-3 border-t border-zinc-700 pt-1">
                      Added: {entry.addedAt}
                      {entry.readAt && (
                        <>
                          <br />
                          Read: {new Date(entry.readAt).toLocaleDateString()}
                        </>
                      )}
                    </div>
                  </div>
                </div>

                {/* Status pill */}
                <span
                  className={`
                    text-xs px-2 py-1 rounded border ml-4
                    ${
                      isRead
                        ? "bg-green-700 border-green-600 text-green-200"
                        : "bg-zinc-700 border-zinc-600 text-zinc-300"
                    }
                  `}
                >
                  {isRead ? "Read ✓" : "Unread"}
                </span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
