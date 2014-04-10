/*
 * Methods to add to the Express application prototype.
 */

var connect = require('connect');

module.exports = Harrison;

/**
 * Helper object for managing subapps.
 ()*/
function Harrison(app, options) {
  options = options || {};
  /* I've only thougt of one option so far... */
  this.staticPrefix = options.staticPrefix || '/static';

  this.parent = app;
  this.apps = {};

  /* A queue of all pairs to be mounted during middleware creation. */
  this.mountPairs = [];
}


/**
 * Adds a subapp to the main application.
 */
Harrison.prototype.addApp = function addSubapp(mount, appFactory, config) {
  var app;
  var parent = this.parent;

  switch (arguments.length) {
    /* Unary. Mount is '/'. */
    case 1:
      app = mount;
      mount = '/';
      break;
    /* Binary methods -- assume appFactory is actually just an app. */
    case 2:
      app = appFactory;
      break;
    /* Ternary method (rest of the arugments ignored). */
    default:
      /* Add the parent. */
      config.parent = parent;
      app = appFactory(config);
      break;
  }

  /* Delegate to subapp manager. */
  return addApp.call(this, mount, app);
};


/**
 * Sets this application as a sub app.
 *
 * Conditionally adds routers, helpers, and all kinds of goods.
 */
Harrison.prototype.create = function createConnectMiddleware(options) {
  var middleware, self = this;
  var staticPrefix = self.staticPrefix;

  if (!this.mountPairs.length) {
    throw new Error('Must add at least one subapp before calling create()');
  }

  middleware = connect();

  /* ADD ALL THE MIDDLEWARE. MUWHAHAHHAHAHAHAHHAHAH! */
  this.mountPairs.forEach(function (pair) {
    var mount = pair.mount;
    var app = pair.app;

    addAppAsMiddleware(middleware, mount, app);
    addStaticMiddleware(middleware, staticPrefix, mount, app);

    // TODO: move this to #addApp()?
    self._addLocals(mount, app);
  });
  
  return middleware;
};


/**
 * [Assumes `this` is a Harrison object!]
 *
 * Does the actual work of adding an app.
 */
function addApp(mount, app) {
  app.set('parent', this.parent);

  if (this.apps[mount]) {
    throw new Error('An existing subapp is already mounted at ' + mount);
  }

  /* Keep track of the app. */
  this.apps[mount] = app;

  /* Wait for #create() to be called to add this to the connect middleware. */
  this.mountPairs.push({
    mount: mount,
    app: app,
  });
  
  return this;
}


function addAppAsMiddleware(middleware, mount, app) {

  /* Install the app. */
  if (mount === '/') {
    middleware.use(app);
  } else {
    middleware.use(mount, app);
  }

  return this;
}

function addStaticMiddleware(middlware, basePath, mount, app) {
  var mountPath, staticPath;

  /* For now, these are one and the same thing. */
  mountPath = basePath + mount;

  staticPath = app.get('harrison static');
  /* No use installing a static middlware for this. */
  if (!staticPath) {
    return;
  }

  /* ADD THAT DANG MIDDLEWARE. */
  app.use(mountPath, createStaticMiddleware(staticPath));
}


Harrison.prototype._addLocals = function (name, app) {
  // Add the static helper!
  app.locals.static = this.makeStaticHelper(name);

  // Additional routers.
  /* TODO: completely reconsider this API. */
  app.locals.global = function (url) {
    return url; // Yes. It is literally an identity function.
  };

};

Harrison.prototype.makeStaticHelper = function (name) {
  var self = this;
  var prefix = self.staticPrefix;
  var middle = name.replace(/^\//, '');

  return function static(url) {
    /* TODO: Normalize this all nice and pretty. */
    return  prefix + middle + url;
  };
};



function createStaticMiddleware(path)  {
  var express = require('express');
  return express.static(path);
}


/*
 * Facilitates conditional assignment.
 */
function $default(value, otherwise) {
  if (typeof value === 'undefined' || value === null) {
    return otherwise;
  }
  return value;
}

