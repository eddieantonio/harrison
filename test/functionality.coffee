# Basic functionality tests for Tony Harrison.

{ expect } = require 'chai'
request = require 'supertest'

# Monkey-patch the Express app.
# Note that this *MUST* be done before the app factory is require'd!
express = require 'express'
harrison = require '../'

# Get the initial app factory.
appFactory = require './app'

describe 'Harrison', ->
  it 'should be constructed with an Express app', ->
    expect(->
      subapps = harrison(null)
    ).to.throw(Error)

    mainApp = express()
    expect(harrison(mainApp)).to.exist

  describe '#addApp()', ->

    it 'should implement a fluent interface', ->
      app = express()
      # So... we can't be sure that the *exact* same object will be returned
      # but we can expect that they respond to the same methods.
      initial = harrison(app)

      expect(initial).to.respondTo('addApp')
        .and.to.respondTo('create')

      afterAdd = initial.addApp(appFactory())

      expect(afterAdd).to.respondTo('addApp')
        .and.to.respondTo('create')

      # #create is not expected to be fluent.

    it '[unary] should mount a main app', (done) ->
      app = express()
      subapps = harrison(app)
        .addApp(appFactory())
        .create()

      app.use(subapps)

      request(app)
        .get('/')
        .expect(200, done)

    it '[binary] should mount an app at the specified mount point', (done) ->
      app = express()
      subapps = harrison(app)
        .addApp('/saboo', appFactory())
        .create()
      app.use(subapps)

      request(app)
        .get('/saboo/')
        .expect(200, done)


    it '[ternary] should accept an app factory, and configure it', (done) ->
      customAppFactory = (options) ->
        app = express()
        # Based on configuration.
        name = options.name ? 'Naboo'
        identity = if options.parent? then "child" else "root"
        app.get '/who-are-you', (req, res) ->
          res.send(200, "#{identity}:#{name}")

      mainApp = express()
      subapps = harrison(mainApp)
        # Third argument is required for second to be interpreted as
        # appFactory!
        .addApp('/', customAppFactory, {})
        .addApp('/saboo', customAppFactory, name: 'Saboo')
        .create()
      mainApp.use(subapps)

      # This is the callback to the first request...
      testSaboo = (err)->
        return done(err) if err?
        request(mainApp)
          .get('/saboo/who-are-you')
          .expect('child:Saboo', done)

      # *This* is the first request.
      request(mainApp)
        .get('/who-are-you')
        .expect('child:Naboo', testSaboo)


    it 'should notify its child that it exists', ->
      app = express()
      subapp = appFactory()
      subapps = harrison(app)
        .addApp('/hasParent', subapp)
        .create()

      expect(subapp.get('parent')).to.equal(app)



describe 'The README example', ->

  readmeExample = require './app/server'

  it 'should serve a static file from the normal app', (done) ->
    request(readmeExample)
      .get('/static/css/styles.css')
      .expect(200, /Comic Sans MS/, done)

  it 'should serve the home page', (done) ->
    # These are pretty brittle regexes, to be honest.
    hasHomepageLink = ///<a[^>]+href=['"]?/['"]?> Homepage///
    hasStylesheetLink = ///<link[^>]+href=['"]?/static/css/styles.css["']?///

    request(readmeExample)
      .get('/')
      .expect(hasHomepageLink)
      .expect(hasStylesheetLink)
      .expect(200, done)

