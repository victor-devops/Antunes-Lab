"use client";

import { motion } from "framer-motion";
import Image from "next/image";
import { useInView } from "react-intersection-observer";

type SkillDataProviderProps = {
  src: string;
  name: string;
  width: number;
  height: number;
  index: number;
};

export const SkillDataProvider = ({
  src,
  name,
  width,
  height,
  index,
}: SkillDataProviderProps) => {
  const { ref, inView } = useInView({
    triggerOnce: true,
  });

  const imageVariants = {
    hidden: { opacity: 0 },
    visible: { opacity: 1 },
  };

  const animationDelay = 0.1;

  return (
    <motion.div
      ref={ref}
      initial="hidden"
      variants={imageVariants}
      animate={inView ? "visible" : "hidden"}
      custom={index}
      transition={{ delay: index * animationDelay }}
      className="group relative z-10 inline-flex">

      <Image
        src={`/images/skills/${src}`}
        width={width}
        height={height}
        alt={name} />

      <div className="pointer-events-none absolute left-1/2 top-full z-50 mt-2 -translate-x-1/2 rounded-md border border-purple-400/30 bg-gradient-to-r from-purple-600/35 via-purple-500/25 to-fuchsia-500/20 px-2 py-1 text-xs text-white opacity-0 shadow-lg shadow-purple-500/20 backdrop-blur-md transition-opacity duration-150 group-hover:opacity-100">
        {name}
      </div>
    </motion.div>
  );
};
