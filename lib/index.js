// ==========================================================================
// Project:   Spade - CommonJS Runtime
// Copyright: ©2010 Strobe Inc. All rights reserved.
// License:   Licened under MIT license (see __preamble__.js)
// ==========================================================================
/*globals process __dirname */

var SPADE = require('./spade'), spade;

SPADE.Spade.prototype.Sandbox = require('./node/sandbox').Sandbox;
SPADE.Spade.prototype.Loader  = require('./node/loader').Loader;

module.exports = new SPADE.Spade()

