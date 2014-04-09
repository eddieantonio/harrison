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

  describe 'as a main app', ->
    app = appFactory()

    it 'should have a #mainApp() method', ->
      expect(app.mainApp).to.exist
      app.mainApp()

    it 'should serve a generated page', (done) ->
      request(app)
        .get('/')
        .expect('Content-Type', /html/)
        .expect(200, done)

        # TODO: Make sure static links are all here.

    it 'should probably do some other stuff as well :/'

describe 'A parent app', ->

  app = express()
  
  describe '#addSubapp()', ->
    it 'should exist!', ->
      expect(app.addSubapp).to.exist

    it 'should mount an app as main if not given an explict mount'
    it 'should add a subapp'
    it 'should notify its child that it exists'
    it 'should provide global routing'


describe 'A subapp', ->
  it 'should declare statics'
  it 'should be mountable on another app'
  it 'should respond to any sort of mount path'
  it 'should still serve statics'

describe 'The README example', ->

  # This is the readme example.
  readmeExample = require './app/server'

  it 'should serve a static file from the normal app', (done) ->
    request(readmeExample)
      .get('/public/css/styles.css')
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

