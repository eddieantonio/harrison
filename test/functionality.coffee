# Basic functionality tests for Tony Harrison.

{ expect } = require 'chai'
request = require 'supertest'

# Monkey-patch the Express app.
# Note that this *MUST* be done before the app factory is require'd!
express = require 'express'
require '../'

# Get the initial app factory.
appFactory = require './app'

describe 'Patched Express application', ->
  app = appFactory()
  it 'should have a #mainApp() method', ->
    expect(app.mainApp).to.exist
  it 'should have a #addSubapp() method', ->
    expect(app.addSubapp).to.exist

describe 'In the parent app', ->

  app = express()
  
  describe '#addSubapp()', (done) ->
    it 'should mount an app as main if not given an explict mount', ->
      mainApp = appFactory()
      app.addSubapp(mainApp)

      expect(app._subapps).to.exist
      expect(app._subapps.apps).to.have.key('/')
      expect(app._subapps.apps['/']).to.equal(mainApp)

      request(mainApp)
        .get('/')
        .expect(200)

    it 'should add a subapp', (done) ->
      subapp = appFactory()
      app.addSubapp('/saboo', subapp)
      
      expect(app._subapps.apps).to.have.keys('/', '/saboo')

      request(app)
        .get('/saboo/')
        .expect(200, done)

    it 'should notify its child that it exists', ->
      subapp = appFactory()
      app.addSubapp('/hasParent', subapp)

      expect(subapp.get('parent')).to.equal(app)

    it 'should provide global routing', ->
      subapp = appFactory()
      app.addSubapp('/naboo', subapp)

      expect(subapp.locals.global).to.exist
        .and.to.be.a('function')

      # Should also, you know... test that it returns expected results..


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
    # Does this even make sense?
    hasHomepageLink = ///<a href=['"]?\/['"]?> Homepage///
    hasStylesheetLink = ///<link[^>]+href=['"]?/static/css/styles.css["']?///

    request(readmeExample)
      .get('/')
      .expect(hasHomepageLink)
      .expect(hasStylesheetLink)
      .expect(200, done)

