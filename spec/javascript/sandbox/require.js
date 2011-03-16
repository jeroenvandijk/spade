// ==========================================================================
// Project:   Spade - CommonJS Runtime
// Copyright: ©2011 Strobe Inc. All rights reserved.
// License:   Licened under MIT license (see __preamble__.js)
// ==========================================================================

var Ct = require('core-test/sync'),
    Spade = require('spade').Spade,
    Sandbox = require('spade').Sandbox,
    pending = function(t){ console.log("PENDING: "+t.toString()); };


Ct.module('spade: Sandbox require');

Ct.setup(function(t) {
  t.sandbox = new Sandbox(new Spade()); 
});

Ct.teardown(function(t) { 
  delete t.sandbox;
});

Ct.test("require new", function(t){
  t.sandbox.spade.register('testing', { name: 'testing' });
  t.sandbox.spade.register('testing/main', "exports.hello = 'hi';");
  t.equal(t.sandbox.require('testing').hello, 'hi');
});

Ct.test("require existing", pending);

Ct.test("require circular", pending);

Ct.test("throw if doesn't exist", function(t){
  t.throws(function(){ t.sandbox.require('missing'); }, "Module missing not found");
});

