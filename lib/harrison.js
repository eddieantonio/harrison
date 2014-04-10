/*
 * Methods to add to the Express application prototype.
 */

var connect = require('connect');

var exports = module.exports = {};

/**
 * Helper object for managing subapps.
 */
exports.init = function init(app, options) {
  this.parent = app;

  /* I've only thougt of one option so far... */
  this.staticPrefix = options.staticPrefix || '/static';

  /* Maps canonical name to app. */
  this.apps = {};

  this.middleware = connect();
};


/**
 * Adds a subapp to the main application.
 */
exports.addApp = function addSubapp(mount, appFactory, config) {
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

exports.create = function () {
  return this;
};



/**
 * Does the actual work of adding an app.
 */
function addApp(mount, app) {
  var staticPrefix = this.staticPrefix;
  var middleware = this.middleware;

  app.set('parent', this.parent);

  if (this.apps[mount]) {
    throw new Error('An existing subapp is already mounted at ' + mount);
  }

  /* Keep track of the app. */
  this.apps[mount] = app;

  addAppAsMiddleware(middleware, mount, app);
  addStaticMiddleware(middleware, staticPrefix, mount, app);

  addLocals.call(this, mount, app);
  
  return this;
}


function addAppAsMiddleware(middleware, mount, app) {
  /* Install the app. */
  if (mount === '/') {
    middleware.use(app);
  } else {
    middleware.use(mount, app);
  }
}

function addStaticMiddleware(middleware, basePath, name, app) {
  var mountPath, staticPath;

  /* For now, these are one and the same thing. */
  mountPath = basePath + name;

  staticPath = app.get('harrison static');
  /* No use installing a static middlware for this. */
  if (!staticPath) {
    return;
  }

  /* ADD THAT DANG MIDDLEWARE. */
  middleware.use(mountPath, createStaticMiddleware(staticPath));
}


/**
 * [Must explicitly set `this`!]
 */
function addLocals(name, app) {
  // Add the static helper!
  app.locals.static = makeStaticHelper.call(this, name);

  app.locals.local = function local(id) {
    /* TODO: There must be a smarter way to do this... */
    return name.replace(/\/$/, '') + '/' + id.replace(/^\//, '');
  };

  app.locals.global = global;

  function global(app, id, options) {
    if (!id) {
      id = app;
    }
    return id;
  }
}

/**
 * [Must explicitly set `this`!]
 */
function makeStaticHelper(name) {
  var self = this;
  var prefix = self.staticPrefix;
  /* Strip leading and trailing slash .*/ 
  var middle = name.replace(/^\//, '').replace(/\/$/, '');

  return function static(url) {
    /* TODO: Normalize this all nice and pretty. */
    return  prefix + middle + url;
  };
}



function createStaticMiddleware(path)  {
  return connect.static(path);
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

