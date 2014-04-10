# Essentially, the example given in the README.

express = require 'express'
harrison = require '../../'

subapp = require './index' # an app factory

app = module.exports = express()

app.use(express.logger('dev'))

# Mounting as "main app".
app.use(harrison(app)
  .addApp(subapp)
  .create())

# Statics are handled *after* the rest of the... stuff.
app.use(express.errorHandler())

unless module.parent
  app.listen(3000)

