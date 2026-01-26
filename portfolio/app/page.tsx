
import { Hero } from "@/components/sections/hero";
import { Projects } from "@/components/sections/projects";
import { Skills } from "@/components/sections/skills";

export default function Home() {
  return (
    <main className="h-full w-full">
      <div className="flex flex-col gap-16">
        <Hero />
        <Skills />
        <Projects />
      </div>
    </main>
  );
}
