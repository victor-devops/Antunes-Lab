import {
  RxDiscordLogo,
  RxGithubLogo,
  RxInstagramLogo,
  RxLinkedinLogo,
} from "react-icons/rx";

export const FOOTER_DATA = [
  {
    title: "Community",
    data: [
      {
        name: "GitHub",
        icon: RxGithubLogo,
        link: "https://github.com/victor-trapp/Antunes-Lab",
      },
      {
        name: "Discord",
        icon: RxDiscordLogo,
        link: "https://discord.com/users/trapp7778",
      },
    ],
  },
  {
    title: "Social Media",
    data: [
      {
        name: "Instagram",
        icon: RxInstagramLogo,
        link: "https://www.instagram.com/victorantuness_",
      },
      {
        name: "Linkedin",
        icon: RxLinkedinLogo,
        link: "https://www.linkedin.com/in/victor-antunes-3267a1241",
      },
    ],
  },
  {
    title: "About",
    data: [
      {
        name: "Learning about me",
        icon: null,
        link: "https://github.com/victor-trapp/Antunes-Lab",
      },
      {
        name: "Contact Me",
        icon: null,
        link: "mailto:victorsysadm@gmail.com",
      },
    ],
  },
] as const;
