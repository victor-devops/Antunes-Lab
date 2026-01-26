"use client";

import { useState } from "react";

const KEYS = [
  "+",
  "7",
  "8",
  "9",
  "-",
  "4",
  "5",
  "6",
  "*",
  "1",
  "2",
  "3",
  "/",
  "0",
  ".",
  "=",
  "C",
] as const;

export default function CalculatorPage() {
  const [display, setDisplay] = useState("");

  const handleKey = (key: string) => {
    if (key === "C") {
      setDisplay("");
      return;
    }
    if (key === "=") {
      try {
        const result = Function(`"use strict"; return (${display})`)();
        setDisplay(String(result));
      } catch {
        setDisplay("Error");
      }
      return;
    }
    setDisplay((prev) => prev + key);
  };

  return (
    <main className="min-h-[100svh] w-full px-6 pb-16 pt-[120px] sm:pt-[140px]">
      <div className="mx-auto w-full max-w-[480px]">
        <div className="rounded-3xl border border-purple-300/20 bg-gradient-to-br from-[#22112f]/95 to-[#2b1640]/95 shadow-[0_24px_60px_rgba(38,17,63,0.35)]">
          <div className="border-b border-purple-300/10 bg-gradient-to-br from-purple-500/20 to-purple-400/10 px-6 py-6 text-right text-4xl font-semibold text-white">
            {display || "0"}
          </div>
          <div className="grid grid-cols-4 gap-3 p-6">
            {KEYS.map((key) => {
              const isOperator =
                key === "+" ||
                key === "-" ||
                key === "*" ||
                key === "/" ||
                key === "C";
              return (
                <button
                  key={key}
                  type="button"
                  onClick={() => handleKey(key)}
                  className={`aspect-square rounded-2xl border text-2xl font-semibold text-white shadow-[0_8px_16px_rgba(28,12,45,0.35)] transition-transform duration-150 hover:-translate-y-0.5 active:translate-y-0.5 ${isOperator
                      ? "border-purple-300/30 bg-gradient-to-br from-purple-500/80 to-purple-700/80"
                      : "border-purple-300/15 bg-gradient-to-br from-[#562d82]/70 to-[#2d1647]/90"
                    }`}
                >
                  {key}
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </main>
  );
}
