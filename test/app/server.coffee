# Essentially, the example given in the README.

require '../../'
subapp = require './' # index.coffee -- app factory
express = require 'express'

app = module.exports = express()

app.use(express.logger('dev'))
# Mounting as "main app".
app.addSubapp(subapp)
# Statics are handled *after* the rest of the... stuff.
app.mainApp()
app.use(express.errorHandler())

unless module.parent
  app.listen(3000)

