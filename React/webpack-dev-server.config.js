const merge = require('webpack-merge')
const common = require('./webpack-common.config.js')
const webpack = require('webpack')
const path = require('path')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const ScriptExtHtmlWebpackPlugin = require('script-ext-html-webpack-plugin')

const srcPath = path.resolve(__dirname, 'src')
const nodeModulesPath = path.resolve(__dirname, 'node_modules')
const indexPath = path.join(__dirname, '/src/app/index.js')

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
    port: 8000, // Port Number
    host: '0.0.0.0', // Change to '0.0.0.0' for external facing server
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
    // 自動生成 .html 檔案
    new HtmlWebpackPlugin({
      title: 'iTraffic',
      template: 'src/app/template/index.html', // Load a custom template
      inject: true
      // hash: true, // 是否给页面的资源文件后面增加hash,防止读取缓存
      // minify: { // 精简优化功能 去掉换行之类的
      //   removeComments: true,
      //   collapseWhitespace: true,
      //   removeAttributeQuotes: true
      // },
      // filename: 'index.html'
    }),
    // HtmlWebpackPlugin 擴充套件
    new ScriptExtHtmlWebpackPlugin({
      defer: ['app', 'vendor']
    }),
    // Define production build to allow React to strip out unnecessary checks
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': JSON.stringify('development')
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
      }
    ]
  }
}

module.exports = merge(common, config)
