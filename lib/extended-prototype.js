/*
 * Methods to add to the Express application prototype.
 */

var exports = module.exports = {};

/**
 * Adds a subapp to the main application.
 */
exports.addSubapp = function addSubapp(mount, app, config) {
  var parent = this;
  var subapps = parent._subapps = parent._subapps || new SubappManager();

  /* If only 'mount' is given, assume it is the main app, mounted at '/'. */
  if (arguments.length === 1) {
    app = mount;
    mount = '/';
  }

  /* Assume it's an app factory. */
  // TODO: reconsider if app factories are a necessary concept in Tony Harrison.
  if (app.length && app.length == 1) {
    app = app(config || {});
  }

  /* Delegate to subapp manager. */
  subapps.add(parent, mount, app);
};

/**
 * Sets this application as a sub app.
 *
 * Conditionally adds routers, helpers, and all kinds of goods.
 */
exports.mainApp = function mainApp(options) {
  if (!this._subapps) {
    throw new Error('Must add at least one subapp before calling mainApp()');
  }
};

/**
 * Sets a setting in all apps.
 */
exports.setAll = function (setting, value) {
  var subapps = this._subapps;

  if (!subapps) {
    return;
  }

  for (var app in subapps) {
    app.set(setting, value);
  }
};



/**
 * Helper object for managing subapps.
 */
function SubappManager(options) {
  options = options || {};
  this.staticPrefix = options.staticPrefix || '/static';

  this.apps = {};

  return this;
}

SubappManager.prototype.add = function (parent, mount, app) {
  app.set('parent', parent);

  if (this.apps[mount]) {
    throw new Error('An existing subapp is already mounted ' + mount);
  }

  /* Keep track of the app. */
  this.apps[mount] = app;

  /* Install the app. */
  if (mount === '/') {
    parent.use(app);
  } else {
    parent.use(mount, app);
  }

  this.addLocals(mount, app);
};

SubappManager.prototype.addLocals = function (name, app) {

  // Add the static helper!
  app.locals.static = this.makeStaticHelper(name);

  // Additional routers.
  app.locals.urlFor = dummy;
  app.locals.global = dummy;

  function dummy() {
    var msg = '#not-implemented';
    return msg;
  }

};

SubappManager.prototype.makeStaticHelper = function (name) {
  var self = this;
  var prefix = self.staticPrefix;
  var middle = name.replace(/^\//, '');

  return function static(url) {
    /* TODO: Normalize this all nice and pretty. */
    return  prefix + middle + url;
  };
};

