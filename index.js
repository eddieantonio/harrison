/**
 * Monkey-patches the Express application prototype with our new methods.
 */

var extendedPrototype = require('./lib/extended-prototype');
var express = require('express');
var extend = require('extend');

extend(express.application, extendedPrototype);

