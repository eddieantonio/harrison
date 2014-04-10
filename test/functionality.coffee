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
    expect( do ->
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

      afterAdd = initial.addApp(appFactory)

      expect(afterAdd).to.respondTo('addApp')
        .and.to.respondTo('create')

      # #create is not expected to be fluent.

    it '[unary] should mount a main app', ->
      app = express()
      subapps = harrison(app)
        .addApp(appFactory())
        .create()

      app.use(subapps)

      # Weird old tests... might want to find a better way to test this.
      ->
        expect(app).to.exist
        expect(app._subapps.apps).to.have.key('/')
        expect(app._subapps.apps['/']).to.equal(mainApp)

      request(app)
        .get('/')
        .expect(200)

    it '[binary] should mount an app at the specified mount point', ->
      app = express()
      subapps = harrison(app)
        .addApp('/saboo', appFactory())
        .create()
      app.use(subapps)

      # Once again... weird old tests.
      ->
        expect(app._subapps.apps).to.have.key('/saboo')

      request(app)
        .get('/saboo/')
        .expect(200, done)

    it '[ternary] should accept an app factory, and configure it'

    it 'should notify its child that it exists', ->
      app = express()
      subapp = appFactory()
      subapps = harrison(app)
        .addApp('/hasParent', subapp)
        .create()

      expect(subapp.get('parent')).to.equal(app)

    it 'should provide global routing...?'

describe 'A subapp', ->
  it 'should declare statics'
  it 'should be mountable on another app'
  it 'should respond to any sort of mount path'
  it 'should still serve statics'

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

