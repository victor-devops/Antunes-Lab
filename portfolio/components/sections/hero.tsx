import { HeroContent } from "@/components/ui/hero-content";

export const Hero = () => {
  return (
    <section className="relative w-full min-h-[100svh] overflow-hidden">

      {/* Background video layer */}
      {/* Background video is now full-page in layout */}

      {/* Foreground content */}
      <div className="relative z-10 h-full w-full">
        <HeroContent />
      </div>
    </section>
  );
};
