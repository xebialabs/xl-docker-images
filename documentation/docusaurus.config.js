const {themes} = require('prism-react-renderer');

module.exports = {
  title: 'DevOps Platform Docker Images',
  tagline: '',
  url: 'https://xebialabs.github.io',
  baseUrl: '/xl-docker-images/',
  onBrokenLinks: 'throw',
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },
  favicon: 'img/digital_ai_deploy.svg',
  organizationName: 'Digital.ai',
  projectName: 'xl-docker-images',
  themeConfig: {
    navbar: {
      title: 'DevOps Platform Docker Images',
      logo: {
        alt: 'DevOps Platform Docker Images Digital.ai',
        src: 'img/digital_ai_deploy.svg',
      },
      items: [
        {
          type: 'doc',
          docId: 'intro',
          position: 'left',
          label: 'Tutorial',
        },

        {
          href: 'https://github.com/xebialabs/xl-docker-images',
          label: 'GitHub',
          position: 'right',
        }
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Tutorial',
              to: '/docs/intro',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/xebialabs/xl-docker-images',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} DevOps Platform Docker Images Digital.ai`,
    },
    prism: {
      theme: themes.github,
      darkTheme: themes.dracula,
      additionalLanguages: ['bash', 'yaml'],
    },
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js')
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
