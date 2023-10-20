const coffeeScriptPlugin = require('esbuild-coffeescript');

require('esbuild').build({
  entryPoints: ['app/javascript/*.*'],
  bundle: true,
  sourcemap: true,
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  plugins: [coffeeScriptPlugin()],
});
