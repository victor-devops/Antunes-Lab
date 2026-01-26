import { HeroContent } from "@/components/ui/hero-content";

export const Hero = () => {
  return (
    <section className="relative w-full min-h-[100svh] overflow-hidden">
      <div className="relative z-10 h-full w-full">
        <HeroContent />
      </div>
    </section>
  );
};
