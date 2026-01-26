import { HiArrowUpRight } from "react-icons/hi2";
import Link from "next/link";

type ProjectCardProps = {
  title: string;
  description: string;
  link: string;
  ctaLabel?: string;
  secondaryLabel?: string;
  secondaryLink?: string;
  hidePrimaryCta?: boolean;
};

export const ProjectCard = ({
  title,
  description,
  link,
  ctaLabel = "View Project",
  secondaryLabel,
  secondaryLink,
  hidePrimaryCta = false,
}: ProjectCardProps) => {
  const isPrimaryExternal = link.startsWith("http");
  const isSecondaryExternal = secondaryLink?.startsWith("http");

  return (
    <div className="group relative flex h-full min-h-[290px] w-full flex-col overflow-hidden rounded-2xl border border-white/10 bg-[#0b0616]/70 p-6 shadow-[0_18px_50px_rgba(6,2,18,0.45)] backdrop-blur-md transition-transform duration-200 hover:-translate-y-1">
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute -top-20 right-4 h-40 w-40 rounded-full bg-purple-500/15 blur-3xl opacity-0 transition-opacity duration-200 group-hover:opacity-100" />
        <div className="absolute -bottom-20 left-4 h-40 w-40 rounded-full bg-cyan-500/10 blur-3xl opacity-0 transition-opacity duration-200 group-hover:opacity-100" />
        <div className="absolute inset-x-0 top-0 h-24 bg-gradient-to-b from-purple-500/10 to-transparent" />
      </div>
      <div className="relative flex h-full flex-col">
        <div className="mb-4 h-[2px] w-12 bg-gradient-to-r from-purple-400/80 to-cyan-400/70" />
        <h1 className="text-2xl font-semibold text-white">{title}</h1>
        <p className="mt-3 text-sm leading-relaxed text-gray-300">{description}</p>
        {!hidePrimaryCta || secondaryLink ? (
          <div className="mt-auto flex flex-wrap items-center gap-4 pt-6 text-sm font-medium text-purple-200">
            {!hidePrimaryCta ? (
              <Link
                href={link}
                target={isPrimaryExternal ? "_blank" : undefined}
                rel={isPrimaryExternal ? "noreferrer noopener" : undefined}
                className="hover:text-purple-100 transition-colors">
                {ctaLabel}
                <HiArrowUpRight className="ml-1 inline-block h-4 w-4 translate-y-[1px] text-purple-200 transition-transform duration-200 group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
              </Link>
            ) : null}
            {secondaryLink ? (
              <Link
                href={secondaryLink}
                target={isSecondaryExternal ? "_blank" : undefined}
                rel={isSecondaryExternal ? "noreferrer noopener" : undefined}
                className="text-purple-300 hover:text-purple-200 transition-colors">
                {secondaryLabel ?? "Source Code"}
                <HiArrowUpRight className="ml-1 inline-block h-4 w-4 translate-y-[1px]" />
              </Link>
            ) : null}
          </div>
        ) : null}
      </div>
    </div>
  );
};
