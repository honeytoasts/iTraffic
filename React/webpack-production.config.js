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
    app: ['babel-polyfill', indexPath]
  },
  // output config
  output: {
    filename: '[name]-[chunkhash].js' // note *chunkhash* used here
  },
  // cheap-module-eval-source-map
  devtool: 'source-map',
  plugins: [
    // 消除重复的模块
    new webpack.optimize.DedupePlugin(),
    // Define production build to allow React to strip out unnecessary checks
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': JSON.stringify('production')
      }
    }),
    // Minify the bundle
    new webpack.optimize.UglifyJsPlugin({
      parallel: 4, // 使用多進程並行運行來提高構建速度
      beautify: false, // 最紧凑的输出
      comments: false, // 删除所有的注释
      sourceMap: true, // 是否使用 sourceMap 來追蹤錯誤發生
      compress: {
        // 在 UglifyJs 删除没有用到的代码时不输出警告
        warnings: false,
        // 删除所有的 `console` 语句, 还可以兼容ie浏览器
        drop_console: true,
        // 内嵌定义了但是只用到一次的变量
        collapse_vars: true
        // 提取出出现多次但是没有定义成变量去引用的静态值
        // reduce_vars: true
      }
    }),
    // 依赖次数更高的模块靠前分到更小的 id 来达到输出更少的代码
    new webpack.optimize.OccurrenceOrderPlugin(),
    // chunks 的优化, 合并细小的模块
    new webpack.optimize.LimitChunkCountPlugin({maxChunks: 15}),
    new webpack.optimize.MinChunkSizePlugin({minChunkSize: 10000}),
    // 將 css 提取成一個檔案
    new ExtractTextPlugin('styles-[contenthash].css'),
    // 自動生成 .html 檔案
    new HtmlWebpackPlugin({
      title: 'iTraffic 交通服務平台',
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
    })
  ],
  module: {
    loaders: [
      {
        test: /\.jsx?$/, // All .js files
        loaders: ['babel-loader'], // react-hot is like browser sync and babel loads jsx and es6-7
        include: [srcPath],
        exclude: [nodeModulesPath]
      }
    ]
  }
}

module.exports = merge(common, config)
