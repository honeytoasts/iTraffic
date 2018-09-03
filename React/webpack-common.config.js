const webpack = require('webpack')
const path = require('path')
const TransferWebpackPlugin = require('transfer-webpack-plugin')
const CleanWebpackPlugin = require('clean-webpack-plugin')
const ExtractTextPlugin = require('extract-text-webpack-plugin')

const srcPath = path.resolve(__dirname, 'src')
const buildPath = path.resolve(__dirname, 'build')
const nodeModulesPath = path.resolve(__dirname, 'node_modules')
const reactPath = path.resolve(nodeModulesPath, 'react/dist/react.min.js')
const reactdomPath = path.resolve(nodeModulesPath, 'react-dom/dist/react-dom.min.js')
// const clipboardPath = path.resolve(nodeModulesPath, 'clipboard/dist/clipboard.min.js')

const config = {
  resolve: {
    modules: [nodeModulesPath],
    alias: {
      // clipboard: clipboardPath
    }
  },
  // output config
  output: {
    path: buildPath, // Path of output file
    chunkFilename: '[name]-[chunkhash].js',
    publicPath: '/' // CSS 打包時修改的引用檔案路徑
  },
  plugins: [
    new CleanWebpackPlugin(['build']),
    // Extract all 3rd party modules into a separate 'vendor' chunk
    new webpack.optimize.CommonsChunkPlugin({
      name: 'vendor',
      // 把有使用到的第三方套件都打包進 vender 之內
      minChunks: ({ resource }) => /node_modules/.test(resource)
    }),
    // Allows error warnings but does not stop compiling.
    new webpack.NoErrorsPlugin(),
    // Moves files
    new TransferWebpackPlugin([
      {from: 'www'}
    ], srcPath)
  ],
  module: {
    noParse: [reactPath, reactdomPath],
    // noParse: [reactPath, reactdomPath, clipboardPath],
    loaders: [
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract('style-loader', 'css-loader')
        // loaders: ['style-loader', 'css-loader']
      }, {
        test: /\.(jpe?g|png|gif|svg|bmp|ico)$/,
        loader: 'url?limit=8192&name=img/[hash].[ext]'
        // loaders: [
        //   'file?hash=sha512&digest=hex&name=[hash].[ext]',
        //   'image-webpack?bypassOnDebug&optimizationLevel=7&interlaced=false'
        // ]
      }, {
        test: /\.(woff|woff2|eot|ttf|otf)$/,
        loader: 'file&name=font/[hash].[ext]'
      }, {
        test: /\.json$/,
        loader: 'json-loader'
      }
    ]
  },
  node: {
    fs: 'empty'
  }
}

module.exports = config
