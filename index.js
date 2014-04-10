/**
 * Creates a new fluent Harrison object.
 */

var Harrison = require('./lib/harrison');

module.exports = makeHarrison;

function makeHarrison(app, options) {
  if (!app) {
    throw new Error('Must take Express app as first argument.');
  }

  return new Harrison(app, options);
}

