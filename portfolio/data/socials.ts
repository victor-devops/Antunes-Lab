import { RxGithubLogo, RxInstagramLogo, RxLinkedinLogo } from "react-icons/rx";

export const SOCIALS = [
  {
    name: "Instagram",
    icon: RxInstagramLogo,
    link: "https://www.instagram.com/victorantuness_/?hl=en-gb",
  },
  {
    name: "GitHub",
    icon: RxGithubLogo,
    link: "https://github.com/victor-trapp/Antunes-Lab",
  },
  {
    name: "LinkedIn",
    icon: RxLinkedinLogo,
    link: "https://www.linkedin.com/in/victor-antunes-3267a1241",
  },
] as const;
