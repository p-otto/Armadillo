const path = require('path')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const VueLoaderPlugin = require('vue-loader/lib/plugin')

module.exports = {
  entry: './src/main.js',
  output: {
    path: path.resolve(__dirname, './build'),
    filename: 'bundle.js'
  },
  devtool: 'source-map',
  plugins: [
    // Copy our app's index.html to the build folder.
    new CopyWebpackPlugin([{ from: './index.html', to: 'index.html' }]),
    // Enable loading of .vue files
    new VueLoaderPlugin()
  ],
  module: {
    rules: [
      {
        test: /\.bpmn$/,
        use: 'raw-loader'
      },
      {
        test: /\.sol$/,
        use: 'raw-loader'
      },
      {
        test: /\.vue$/,
        loader: 'vue-loader'
      },
      {
        test: /\.css$/,
        use: [{ loader: 'vue-style-loader' }, { loader: 'css-loader' }]
      },
      {
        test: /\.json$/,
        use: 'json-loader'
      },
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015'],
          plugins: ['transform-runtime']
        }
      }
    ]
  },
  resolve: {
    alias: {
      vue: 'vue/dist/vue.js'
    }
  }
}
