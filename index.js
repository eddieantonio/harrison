/**
 * Creates a new fluent Harrison object.
 */

var methods = require('./lib/harrison');

module.exports = makeHarrison;

function makeHarrison(app, options) {
  var subapp;

  if (!app) {
    throw new Error('Must take Express app as first argument.');
  }

  options = options || {};

  /* Looks and acts just like middleware! */
  subapp = function (req, res, next) {
    return subapp.middleware(req, res, next);
  };

  methods.init.call(subapp, app, options);

  /* Add just one method. */
  subapp.addApp = methods.addApp.bind(subapp);
  subapp.create = methods.create.bind(subapp);

  return subapp;
}
