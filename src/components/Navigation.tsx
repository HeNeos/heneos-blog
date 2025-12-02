"use client";

import Link from "next/link";
import { useRouter, usePathname } from "next/navigation";
import { useEffect, useState, useRef } from "react";


const NAV_ITEMS = [
  { href: "/", label: "Home", shortcut: "ha", keyChar: "a" },
  { href: "/blog", label: "Blog", shortcut: "hb", keyChar: "b" },
  { href: "/about", label: "About", shortcut: "hc", keyChar: "c" },
  { href: "/devlog", label: "Dev Log", shortcut: "hd", keyChar: "d" },
];

export default function Navigation() {
  const router = useRouter();
  const pathname = usePathname();
  
  
  const [activeShortcut, setActiveShortcut] = useState<string | null>(null);

  
  const lastKeyTime = useRef<number>(0);
  const lastKey = useRef<string>("");

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      
      const target = e.target as HTMLElement;
      if (
        target.tagName === "INPUT" ||
        target.tagName === "TEXTAREA" ||
        target.isContentEditable
      ) {
        return;
      }

      const currentTime = Date.now();
      const char = e.key.toLowerCase();
      const isSequenceActive = currentTime - lastKeyTime.current < 1000;

      
      if (lastKey.current === "h" && isSequenceActive) {
        
        const targetItem = NAV_ITEMS.find((item) => item.keyChar === char);

        if (targetItem) {
          
          setActiveShortcut(targetItem.shortcut);
          
          
          router.push(targetItem.href);
          
          
          lastKey.current = ""; 
          return;
        }
      }

      
      if (char === "h") {
        lastKey.current = "h";
        lastKeyTime.current = currentTime;
      } else {
        lastKey.current = "";
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [router]);

  
  useEffect(() => {
    setActiveShortcut(null);
  }, [pathname]);

  return (
    <div className="text-xl font-raleway flex flex-col sm:flex-row justify-center gap-4 border-t border-zinc-800 pt-4">
      {NAV_ITEMS.map((item) => {
        
        const isUrlActive = pathname === item.href;
        const isShortcutActive = activeShortcut === item.shortcut;
        const isActive = isUrlActive || isShortcutActive;

        return (
          <Link key={item.shortcut} href={item.href} className="block">
            <div
              className={`
                cursor-pointer px-4 py-2 rounded-md flex items-center justify-between transition-all duration-200
                ${
                  isActive
                    ? "bg-zinc-100 text-zinc-900 scale-105 font-medium shadow-[0_0_15px_rgba(255,255,255,0.3)]" 
                    : "hover:bg-zinc-800 text-zinc-400 hover:text-zinc-100" 
                }
              `}
            >
              <span>{item.label}</span>
              <span
                className={`ml-6 text-sm font-mono ${
                  isActive ? "text-zinc-600 font-bold" : "text-zinc-600"
                }`}
              >
                {item.shortcut}
              </span>
            </div>
          </Link>
        );
      })}
    </div>
  );
}
