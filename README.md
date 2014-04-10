# Harrison

AKA, Express 3.0 subapps done... in a rather ad hoc manner, to be honest.

# Converting a normal app to a "Harrison-enabled" app.

You can convert any old Express app into a Harrison app in three easy (read: somewhat annoying) steps!

## Step One

Export your app! Wrapping it in a customizable fucntion is recommended, but
not required!

Turn this:


```js
// index.js
var express = require('express');
var app = express();

app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.static(__dirname + '/public'));
app.use(app.router);
app.use(express.errorHandler());

app.get('/', function (req, res) {
    res.send('Hello, world!');
});

app.listen(3000);
```

Into this:

```js
// index.js
var express = require('express');

// This module's main export is the app factory.
module.exports = appFactory;

function appFactory(options) {
  var app = express();

  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.static(__dirname + '/public'));
  app.use(app.router);
  app.use(express.errorHandler());

  app.get('/', function (req, res) {
  res.send('Hello, world!');
  });

  return app;
};


/* If running as main... */
if (!module.parent) {
  var app = appFactory();
  app.listen(3000);
}
```

# Step two

Remove statics, and "common" middleware.

```js
// index.js
var express = require('express');

module.exports = appFactory;

function appFactory(options) {
  var app = express();

  /*
   * This line:
   *
   *   app.use(express.static(__dirname + '/public'));
   *
   * Turns into this:
   */
  app.set('harrison static', __dirname + '/public');

  app.use(app.router);

  app.get('/', function (req, res) {
    res.send('Hello, world!');
  });

  return app;
};

/* If running as main... */
if (!module.parent) {
  var app = appFactory();
  app.listen(3000);
}
```

# Step three

Use Harrison!

**Note**: now the main is in `server.js`.

```js
// index.js
var express = require('express');

module.exports = appFactory;

function appFactory(options) {
  var app = express();

  app.set('harrison static', __dirname + '/public');

  app.use(app.router);

  app.get('/', function (req, res) {
    res.send('Hello, world!');
  });

  return app;
};
```


And in the newly created `server.js`:

```js
// server.js

var harrison = require('harrison');
var appFactory = require('./index');
var express = require('express');

var app = express();

var subapps = harrison(app)
  // Provide the Express app to #addApp() to make it the "main" app.
  .addApp(appFactory());
  .create();

/*
 * Can also use these forms:
 *
 * Explicitly specify the mount:
 *
 *    subapps.addApp('/mount', appFactory());
 *
 * Give the app factory and some additional configuration. The benefit
 * is that Harrison will add the property { parent: app } to the options
 * object, allowing the subapp to configure itself differently knowing it's
 * a subapp.
 *
 *    subapps.addApp('/', appFactory, { withBodyParser: true })
 *
 */

app.use(express.logger('dev'));
/* Note: Order matters since subapps includes statics. */
app.use(subapps);
app.use(express.errorHandler());

app.listen(3000);
```

