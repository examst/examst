// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'examst',
			customCss: ['./src/styles/custom.css'],
			social: [{ icon: 'codeberg', label: 'Codeberg', href: 'https://codeberg.org/landrew/examst' }],
			sidebar: [
				{
					label: 'Getting Started',
					items: [
						{ label: 'Introduction', slug: 'getting-started/introduction' },
						{ label: 'Installation', slug: 'getting-started/installation' },
					],
				},
				{
					label: 'Components',
					items: [
						{ label: 'Questions', slug: 'components/questions' },
						{ label: 'Multi-Choice', slug: 'components/multi-choice' },
						{ label: 'Fill-in', slug: 'components/fill-in' },
						{ label: 'Solutions', slug: 'components/solutions' },
						{ label: 'Points Table', slug: 'components/points-table' },
					],
				},
				{
					label: 'Configuration',
					items: [
						{ label: 'Exam Setup', slug: 'configuration/exam-setup' },
						{ label: 'All Options', slug: 'configuration/all-options' },
					],
				},
			],
		}),
	],
});
