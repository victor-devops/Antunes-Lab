export const PROJECTS = [
  {
    title: "Calculator App",
    description:
      "This project was built as a focused learning exercise to strengthen my JavaScript fundamentals and problem-solving skills. Rather than just creating a working calculator, the focus was on understanding state management, event handling, conditional logic, and edge-case handling such as chained operations, resets, and invalid input. Through this process, I explored how UI interactions translate into application logic and how to iteratively refine clean, maintainable JavaScript.",
    link: "/calculator",
    ctaLabel: "View App",
    secondaryLabel: "Source Code",
    secondaryLink:
      "https://github.com/victor-trapp/Antunes-Lab/tree/main/portfolio/public/calculator",
  },
  {
    title: "Ansible for AWS Infrastructure",
    description:
      'Implemented Ansible to manage and automate AWS infrastructure for a scientific research business across multiple EC2 instances. Developed reusable playbooks and roles to provision new instances, configure users and access controls, apply baseline security hardening, install required packages, and deploy monitoring agents. Added availability and readiness checks (connectivity validation, service status verification, and post-deploy smoke tests) to confirm systems were reachable and correctly configured after changes. This improved environment consistency, reduced manual effort, and enabled scalable, version-controlled infrastructure updates.',
    link: "https://example.com",
    hidePrimaryCta: true,
  },
] as const;
