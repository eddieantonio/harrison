# Harrison

AKA, Express 3.0 subapps done... in a rather ad hoc manner, to be honest.

# Converting a normal app to a "Harrison-enabled" app.

You can convert any old Express app into a Harrison app in three easy (read: somewhat annoying) steps!

## Step One

Wrap the app in a factory function and export it!

Turn this:

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

Into this:

    // index.js
    var express = require('express');

    var factory = module.exports = function (options) {
      var app = express();

      app.use(express.logger('dev'));
      app.use(express.bodyParser());
      app.use(express.static(__dirname + '/public'));
      app.use(app.router);
      app.use(express.errorHandler());

      app.get('/', function (req, res) {
        res.send('Hello, world!');
      });
    };

    /* If running as main... */
    if (!module.parent) {
      var app = appFactory();
      app.listen(3000);
    }

# Step two

Remove statics, and "common" middleware.

    // index.js
    var express = require('express');

    var factory = module.exports = function (options) {
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
    };

    /* If running as main... */
    if (!module.parent) {
      var app = appFactory();
      app.listen(3000);
    }

# Step three

Use Harrison `mainApp()`.

**Note**: now the main is in `server.js`.

    // index.js
    var express = require('express');

    var factory = module.exports = function (options) {
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
    };


And in the newly created `server.js`:

    // server.js

    /* Note: Must go before app require. */
    var harrison = require('harrison');
    var subapp = require('./'); // index.js -- app factory
    var express = require('express');
    var app = express();

    app.use(express.logger('dev'));
    // Mounting as "main app".
    app.addSubapp(subapp);
    /* Note: Call order matters since mainApp() calls app#use() for statics. */
    app.mainApp();
    app.use(express.errorHandler());

    app.listen(3000);

