// ==========================================================================
// Project:   Spade - CommonJS Runtime
// Copyright: ©2011 Strobe Inc. All rights reserved.
// License:   Licened under MIT license (see __preamble__.js)
// ==========================================================================

var Ct = require('core-test/sync'),
    Spade = require('spade').Spade,
    Sandbox = require('spade').Sandbox,
    pending = function(t){ console.log("PENDING: "+t.toString()); };

Ct.module('spade: Sandbox compilation');

Ct.setup(function(t) {
  t.sandbox = new Sandbox(new Spade()); 
});

Ct.teardown(function(t) { 
  delete t.sandbox;
});

Ct.test('normal', function(t){
  t.equal(t.sandbox._compilerInited, undefined);
  t.equal(t.sandbox.compile('2 * 2'), 4);
  t.equal(t.sandbox._compilerInited, true);
});

Ct.test('already initialized', function(t){
  // Initialize
  t.sandbox.compile('');
  // Test
  t.equal(t.sandbox.compile('3 * 3'), 9);
});

Ct.test('destroyed', function(t){
  t.sandbox.destroy();
  t.throws(function(){ t.sandbox.compile('4 * 4'); }, Error, "Sandbox destroyed");
});
