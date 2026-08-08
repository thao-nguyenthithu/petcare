import animate from 'tailwindcss-animate';

const rgb = (name) => `rgb(var(${name}) / <alpha-value>)`;

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: rgb('--color-primary'),
        surface: rgb('--color-surface'),
        background: rgb('--color-background'),
        canvas: rgb('--color-canvas'),
        'card-mint': rgb('--color-card-mint'),
        accent: rgb('--color-accent'),
        honey: rgb('--color-honey'),
        error: rgb('--color-error'),
        neutral: rgb('--color-neutral'),
        'neutral-light': rgb('--color-neutral-light'),
        'text-white': rgb('--color-text-white'),
        'text-primary': rgb('--color-text-primary'),
        'text-secondary': rgb('--color-text-secondary'),
      },
      borderRadius: {
        card: 'var(--radius-14)',
        lg: 'var(--radius-20)',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        h1: ['24px', { lineHeight: '30px', fontWeight: '700' }],
        h2: ['20px', { lineHeight: '26px', fontWeight: '700' }],
        h3: ['18px', { lineHeight: '24px', fontWeight: '700' }],
        button: ['15px', { lineHeight: '24px', fontWeight: '700' }],
        label: ['14px', { lineHeight: '20px', fontWeight: '600' }],
        'label-sm': ['12px', { lineHeight: '16px', fontWeight: '600' }],
        body: ['15px', { lineHeight: '24px', fontWeight: '400' }],
        'caption-sm': ['12px', { lineHeight: '16px', fontWeight: '400' }],
      },
      spacing: {
        text: 'var(--space-text)',
        label: 'var(--space-label)',
        item: 'var(--space-item)',
        title: 'var(--space-title)',
        screen: 'var(--space-screen)',
        card: 'var(--space-card)',
        stack: 'var(--space-stack)',
        block: 'var(--space-block)',
        'screen-wide': 'var(--space-screen-wide)',
        group: 'var(--space-group)',
        section: 'var(--space-section)',
        edge: 'var(--space-edge)',
        sidebar: 'var(--size-sidebar)',
        topbar: 'var(--size-topbar)',
        content: 'var(--size-content)',
      },
      boxShadow: {
        card: '0 2px 12px rgb(var(--color-shadow) / 0.14)',
        pop: '0 8px 24px rgb(var(--color-shadow) / 0.22)',
      },
    },
  },
  plugins: [animate],
};
