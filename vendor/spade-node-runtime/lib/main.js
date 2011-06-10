var SPADE = require('./core/spade');

SPADE.Spade.prototype.Sandbox = require('./node/sandbox').Sandbox;
SPADE.Spade.prototype.Loader  = require('./node/loader').Loader;

module.exports = new SPADE.Spade;
