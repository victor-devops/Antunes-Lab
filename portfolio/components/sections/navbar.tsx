'use client';
import { useState } from "react";
import Image from "next/image";
import Link from "next/link";

import { NAV_LINKS, SOCIALS } from "@/data";

export const Navbar = () => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  return (
    <div className="w-full h-[65px] fixed top-0 shadow-lg shadow-[#2A0E61]/50 bg-[#0000001a] backdrop-blur-md z-50 px-10">
      {/* Navbar Container */}
      <div className="w-full h-full flex items-center justify-between m-auto px-[10px]">
        {/* Logo + Name */}
        <Link href="/" className="flex items-center">
          <Image
            src="/images/branding/logo.png"
            alt="Logo"
            width={70}
            height={70}
            draggable={false}
            className="cursor-pointer"
          />
          <div className="hidden md:flex md:selffont-bold ml-[10px] text-gray-300">Victor Antunes</div>
        </Link>

        {/* Web Navbar */}
        <div className="hidden md:flex w-[500px] h-full flex-row items-center justify-between md:mr-20">
          <div className="flex items-center justify-between w-full h-auto border-[rgba(112,66,248,0.38)] bg-[rgba(0,0,0,0.08)] mr-[15px] px-[20px] py-[10px] rounded-full text-gray-200">
            {NAV_LINKS.map((link) => {
              const isExternal = link.link.startsWith("http");
              return (
              <Link
                key={link.title}
                href={link.link}
                target={isExternal ? "_blank" : undefined}
                rel={isExternal ? "noreferrer noopener" : undefined}
                className="cursor-pointer hover:text-[rgb(112,66,248)] transition"
              >
                {link.title}
              </Link>
            );
            })}

          </div>
        </div>

        {/* Social Icons (Web) */}
        <div className="hidden md:flex flex-row gap-5">
          {SOCIALS.map(({ link, name, icon: Icon }) => (
            <Link
              href={link}
              target="_blank"
              rel="noreferrer noopener"
              key={name}
            >
              <Icon className="h-6 w-6 text-white" />
            </Link>
          ))}
        </div>

        {/* Hamburger Menu */}
        <button
          className="md:hidden inline-flex h-10 w-10 flex-col items-center justify-center gap-1 rounded-full border border-white/10 bg-white/5 text-white shadow-sm shadow-black/30 transition hover:bg-white/10"
          aria-label="Toggle menu"
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
        >
          <span className="block h-[2px] w-5 bg-white" />
          <span className="block h-[2px] w-5 bg-white" />
          <span className="block h-[2px] w-5 bg-white" />
        </button>
      </div>

      {/* Mobile Menu */}
      {isMobileMenuOpen && (
        <div className="absolute top-[65px] left-0 w-full bg-[#0b0616] p-6 flex flex-col items-center text-gray-200 shadow-[0_18px_40px_rgba(0,0,0,0.45)] md:hidden overflow-hidden">
          <div className="pointer-events-none absolute inset-0">
            <div className="absolute -top-24 right-0 h-48 w-48 rounded-full bg-purple-500/30 blur-3xl" />
            <div className="absolute -bottom-24 left-0 h-48 w-48 rounded-full bg-fuchsia-500/20 blur-3xl" />
          </div>
          {/* Links */}
          <div className="relative flex w-full flex-col items-center gap-4">
            {NAV_LINKS.map((link) => {
              const isExternal = link.link.startsWith("http");
              return (
                <Link
                  key={link.title}
                  href={link.link}
                  target={isExternal ? "_blank" : undefined}
                  rel={isExternal ? "noreferrer noopener" : undefined}
                  className="w-full rounded-xl border border-white/5 bg-white/5 px-6 py-3 text-center text-base font-medium transition hover:border-purple-400/40 hover:text-purple-200"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  {link.title}
                </Link>
              );
            })}
          </div>

          {/* Social Icons */}
          <div className="relative mt-6 flex justify-center gap-5 rounded-full border border-white/5 bg-white/5 px-6 py-3">
            {SOCIALS.map(({ link, name, icon: Icon }) => (
              <Link
                href={link}
                target="_blank"
                rel="noreferrer noopener"
                key={name}
              >
                <Icon className="h-6 w-6 text-white/90" />
              </Link>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
