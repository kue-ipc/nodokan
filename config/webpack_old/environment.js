const { environment } = require('@rails/webpacker')
const coffee =  require('./loaders/coffee')

environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

environment.loaders.prepend('coffee', coffee)
module.exports = environment
