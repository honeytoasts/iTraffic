const merge = require('webpack-merge')
const common = require('./webpack-common.config.js')
const webpack = require('webpack')
const path = require('path')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const WebpackIsomorphicToolsPlugin = require('webpack-isomorphic-tools/plugin')

const srcPath = path.resolve(__dirname, 'src')
const nodeModulesPath = path.resolve(__dirname, 'node_modules')
const indexPath = path.join(__dirname, '/src/app/index.js')

const webpackIsomorphicToolsPlugin =
  new WebpackIsomorphicToolsPlugin(require('./server/webpack-isomorphic-tools-configuration.js'))
    .development()

const config = {
  // Entry points to the project
  entry: {
    app: [
      'webpack/hot/dev-server',
      'webpack/hot/only-dev-server',
      'babel-polyfill',
      indexPath
    ]
  },
  // output config
  output: {
    filename: '[name].js'
  },
  // Server Configuration options
  devServer: {
    historyApiFallback: true,
    contentBase: 'src/www', // Relative directory for base of server
    hot: true, // Live-reload
    inline: true,
    port: 5000, // Port Number
    host: 'localhost', // Change to '0.0.0.0' for external facing server
    compress: true, // 启用 gzip 压缩
    open: true, // 打包後自動開啟瀏覽器
    noInfo: true,
    watchOptions: {
      ignored: nodeModulesPath
      // aggregateTimeout: 300,
      // poll: 1000,
    }
  },
  devtool: 'eval',
  // devtool: 'inline-source-map',
  plugins: [
    // Enables Hot Modules Replacement
    new webpack.HotModuleReplacementPlugin(),
    // 將 css 提取成一個檔案
    new ExtractTextPlugin('styles.css'),
    webpackIsomorphicToolsPlugin,
    // Define production build to allow React to strip out unnecessary checks
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': JSON.stringify('server')
      }
    })
  ],
  module: {
    loaders: [
      {
        // React-hot loader and
        test: /\.jsx?$/, // All .js files
        loaders: ['react-hot', 'babel-loader?cacheDirectory'], // react-hot is like browser sync and babel loads jsx and es6-7
        include: [srcPath],
        exclude: [nodeModulesPath]
      }, {
        test: webpackIsomorphicToolsPlugin.regular_expression('images'),
        loader: 'url-loader?limit=10240' // any image below or equal to 10K will be converted to inline base64 instead
      }
    ]
  }
}

module.exports = merge(common, config)
