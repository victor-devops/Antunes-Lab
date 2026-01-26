import { SkillDataProvider } from "@/components/ui/skill-data-provider";
import { SkillText } from "@/components/ui/skill-text";

import { OTHER_SKILL, SKILL_DATA } from "@/data";

export const Skills = () => {
  return (
    <section
      id="skills"
      className="
    relative overflow-visible
    flex flex-col items-center
    pt-10 md:pt-14 lg:pt-16
    pb-16">

      <SkillText />

      <div className="flex flex-row justify-around flex-wrap mt-4 gap-5 items-center">
        {SKILL_DATA.map((skill, i) => (
          <SkillDataProvider
            key={skill.skill_name}
            src={skill.image}
            name={skill.skill_name}
            width={skill.width}
            height={skill.height}
            index={i}
          />
        ))}
      </div>
      <div className="flex flex-row justify-around flex-wrap mt-4 gap-5 items-center">
        {OTHER_SKILL.map((skill, i) => (
          <SkillDataProvider
            key={skill.skill_name}
            src={skill.image}
            name={skill.skill_name}
            width={skill.width}
            height={skill.height}
            index={i}
          />
        ))}
      </div>

      <div className="w-full h-full absolute">
        <div className="w-full h-full z-[-40] opacity-20 absolute flex items-center justify-center bg-cover">

        </div>
      </div>
    </section>
  );
};
