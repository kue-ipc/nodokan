const { generateWebpackConfig } = require('shakapacker')
const customConfig = {
  module: {
    rules: [
      {
        test: /\.s[ac]ss$/i,
        use: [
          // Creates `style` nodes from JS strings
          // "style-loader",
          // Translates CSS into CommonJS
          "css-loader",
          // Compiles Sass to CSS
          "sass-loader"
        ]
      }
    ]
  },
  resolve: {
    extensions: ['.css']
  }
}
const webpackConfig = generateWebpackConfig(customConfig)

module.exports = webpackConfig
