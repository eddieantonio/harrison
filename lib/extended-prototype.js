/*
 * Methods to add to the Express application prototype.
 */

var exports = module.exports = {};

/**
 * Adds a subapp to the main application.
 */
exports.addSubapp = function addSubapp(mount, config) {
  var app = this;
  var subapps = this._subapps || {};

  subapps[mount] = config;

  console.warn('not implemented');
  console.log({ settings: {
    staticDirectory: app.get('harrison static'),
  }});

};

/**
 * Sets this application as a sub app.
 *
 * Conditionally adds routers, helpers, and all kinds of goods.
 */
exports.mainApp = function mainApp(options) {
  options = options || {};

  console.warn('not implemented');
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

