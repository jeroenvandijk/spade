// ==========================================================================
// Project:   Spade - CommonJS Runtime
// Copyright: ©2011 Strobe Inc. All rights reserved.
// License:   Licened under MIT license (see __preamble__.js)
// ==========================================================================

var Ct = require('core-test/sync'),
    Spade = require('spade').Spade,
    Sandbox = require('spade').Sandbox,
    pending = function(t){ console.log("PENDING: "+t.toString()); };

Ct.module('spade: Sandbox Miscellaneous');

Ct.test('toString', function(t){
  var sandbox = new Sandbox(new Spade(), 'Test Sandbox');

  t.equal(sandbox.toString(), '[Sandbox Test Sandbox]');
});
