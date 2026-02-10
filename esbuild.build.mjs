import process from 'node:process';
import * as esbuild from 'esbuild';
import civetPlugin from '@danielx/civet/esbuild-plugin';

const esbuildOptions = {
  entryPoints: ['app/javascript/*.*'],
  bundle: true,
  sourcemap: true,
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  plugins: [civetPlugin()],
  define: {RAILS_ENV: `"${process.env.RAILS_ENV ?? "development"}"`}
}

if (process.argv.includes('--watch')) {
  const ctx = await esbuild.context(esbuildOptions);
  await ctx.watch();
  console.log('watching...');
} else {
  await esbuild.build(esbuildOptions);
}
