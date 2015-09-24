module.exports = {
  entry: {
    application: './app/assets/javascripts/application.js'
  },
  output: {
    path: './public/javascripts',
    filename: '[name].bundle.js'
  },
  module: {
    loaders: [
      {
        test: /\.(css|scss)$/,
        loader: 'style!css!sass'
      },
      {
        test: /\.(woff|woff2|eot|svg|ttf|png|jpg)(\?v=\d+\.\d+\.\d+)?$/,
        loader: 'url?limit=30000&name=[name]-[hash].[ext]'
      },
      {
        test: /bootstrap\/js\//,
        loader: 'imports?jQuery=jquery'
      },
      {
        test: /application\.js/,
        loader: 'imports?$=jquery'
      }
    ]
  }
}
