express = require('express')
less = require('less-middleware')
browserify = require('browserify-middleware')

module.exports = (opts = {}) ->
  app = express()

  app.on 'mount', (parent) ->
    apps = parent.get('apps')
    regex = '^\\/('
    regex += apps.join('|')
    regex += ')\\/client\\/[a-z0-9]+\.(?:coffee)$'

    ###
    Initialize the less middleware to compile our css assets on the
    fly.
    ###
    for path in [process.cwd(), 'node_modules']
      app.use '/assets', less(path,
        dest: 'public'
        parser:
          paths: [
            'styles'
            '.'
            'public/components'
          ]
      )

      app.use '/assets', browserify(path,
        transform: ['coffeeify']
        extensions: ['.coffee']
        grep: new RegExp(regex)
      )

    app.use '/assets', express.static("#{process.cwd()}/public")

  app
