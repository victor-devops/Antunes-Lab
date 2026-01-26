import { ProjectCard } from "@/components/ui/project-card";
import { PROJECTS } from "@/data";

export const Projects = () => {
  return (
    <section
      id="projects"
      className="relative flex flex-col items-center justify-center py-24"
    >
      <h1 className="text-[40px] font-semibold text-transparent bg-clip-text bg-gradient-to-r from-purple-500 to-cyan-500 py-20">
        My Projects
      </h1>

      <div className="w-full max-w-5xl px-6">
        <div className="grid grid-cols-1 gap-8 md:grid-cols-2">
          {PROJECTS.map((project) => (
            <ProjectCard
              key={project.title}
              title={project.title}
              description={project.description}
              link={project.link}
              ctaLabel={"ctaLabel" in project ? project.ctaLabel : undefined}
              secondaryLabel={
                "secondaryLabel" in project ? project.secondaryLabel : undefined
              }
              secondaryLink={
                "secondaryLink" in project ? project.secondaryLink : undefined
              }
              hidePrimaryCta={
                "hidePrimaryCta" in project ? project.hidePrimaryCta : undefined
              }
            />
          ))}
        </div>
      </div>
    </section>
  );
};
