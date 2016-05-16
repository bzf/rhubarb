var webpack = require('webpack');

module.exports = {
  entry: {
    app: ['webpack/hot/dev-server', './src/index.js'],
  },

  output: {
    path: './public/built',
    filename: 'bundle.js',
    publicPath: 'http://localhost:8080/built/'
  },

  devServer: {
    contentBase: './public',
    publicPath: 'http://localhost:8080/built/'
  },

  module: {
    loaders: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'elm-webpack'
    },
    {
      test: /\.(png|jpg|gif)$/,
      loader: "file-loader"
    },
    {
      test: /\.scss$/,
      loaders: ["style", "css", "sass"]
    }]
  },

  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.IgnorePlugin(new RegExp("^(fs|ipc)$"))
  ],

  node: {
    "fs": "remote"
  },

  target: "atom"
};
