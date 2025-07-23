const { environment } = require('@rails/webpacker')

// 1. Eliminar cualquier configuración conflictiva existente
environment.loaders.delete('file')

// 2. Configuración compatible con Webpack 5
const fontLoader = {
  test: /\.(woff|woff2|eot|ttf|svg)$/,
  use: {
    loader: 'file-loader',
    options: {
      name: '[name].[ext]',
      outputPath: 'fonts/',
      publicPath: '/packs/fonts/',
      esModule: false
    }
  }
}

environment.loaders.append('fonts', fontLoader)

module.exports = environment
