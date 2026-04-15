export type Engagement = {
  company: string;
  url?: string;
  period: string;
  outcome: string;
};

export const engagements: Engagement[] = [
  {
    company: 'Withfriends',
    url: 'https://withfriends.co',
    period: '2026',
    outcome:
      'Consolidated eight legacy repos into one monorepo. Cut bookstore onboarding from 4 hours of back-office work to 1, fully automated.',
  },
  {
    company: 'Finny',
    url: 'https://finny.com',
    period: '2025–2026',
    outcome:
      'Tech lead on an AI prospecting platform (YC S24). Shipped a greenfield news aggregation service, led a multi-month editor migration, and stood up E2E testing and trunk-based deploys.',
  },
  {
    company: 'Cassi',
    url: 'https://cassihome.com',
    period: '2025',
    outcome:
      'Built the alpha and beta of an AI property manager from zero. Contributed to a $1M pre-seed raise and recruited the first five engineers.',
  },
  {
    company: 'Rooted Agriculture',
    url: 'https://rootedag.com',
    period: '2025',
    outcome:
      'Shipped the platform for a regenerative-agriculture AI copilot. Cut backend build times 100x with CI/CD work that unblocked demos and local dev.',
  },
];
