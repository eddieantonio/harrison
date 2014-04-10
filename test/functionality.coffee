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
  it 'must be constructed with an Express app', ->
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

      expect(initial).itself.to.respondTo('addApp')
        # Should look like Connect middleware.
        .and.to.be.a('function')
        .and.to.have.property('length', 3)

      afterAdd = initial.addApp(appFactory())

      expect(afterAdd).itself.to.respondTo('addApp')
        .and.to.respondTo('create')
        .and.to.be.a('function')
      expect(afterAdd.length).to.equal(3)

      # create() should be a no-op.
      expect(afterAdd.create()).to.equal(afterAdd)


    it '[unary] should mount a main app', (done) ->
      app = express()
      subapps = harrison(app)
        .addApp(appFactory())

      app.use(subapps)

      request(app)
        .get('/')
        .expect(200, done)


    it '[binary] should mount an app at the specified mount point', (done) ->
      app = express()
      subapps = harrison(app)
        .addApp('/saboo', appFactory())
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

      expect(subapp.get('parent')).to.equal(app)



  describe 'view locals:', ->
    # This is before support for named routes.

    describe 'local()', ->
      it 'should return an absolute path for the current sub app', (done) ->
        subapp = express()
        subapp.get '/', (req, res) ->
          { local } = subapp.locals
          res.redirect(local('/nifty-goods'))
        subapp.get '/nifty-goods', (req, res) ->
          res.send(200, "It's nifty.")

        app = express()
        app.use(harrison(app).addApp('/nested/path/subapp', subapp))

        request(app)
          .get('/nested/path/subapp')
          .expect('Location', '/nested/path/subapp/nifty-goods')
          .expect(302, done)


    describe 'global()', ->
      it 'should return absolute paths to other named apps'

    describe 'static()', ->
      it 'should return absolute path for statics for this named app', ->
        app = express()
        subapp = express()
        harrison(app).addApp(subapp)

        subapp.get 'name'


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

