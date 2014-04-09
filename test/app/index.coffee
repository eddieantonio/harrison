# Example Harrison app.

express = require 'express'

module.exports = (options={}) ->

  app = express()

  app.engine('jade', require('jade').__express)
  app.set 'view engine', 'jade'
  app.set 'views', __dirname + '/views'

  # Harrison settings:
  app.set 'harrison static', __dirname + '/public'


  # Middleware.
  # Note the absence of logging, statics, and catch-all error handling.
  app.use app.router

  # The route(s).
  app.get '/', (req, res) ->
    res.render 'home'

  return app

