// ==========================================================================
// Project:   Spade - CommonJS Runtime
// Copyright: ©2011 Strobe Inc. All rights reserved.
// License:   Licened under MIT license (see __preamble__.js)
// ==========================================================================

var Ct = require('core-test/sync'),
    Spade = require('spade').Spade,
    Sandbox = require('spade').Sandbox,
    pending = function(t){ console.log("PENDING: "+t.toString()); };


Ct.module('spade: Sandbox preprocessor compilation');

Ct.setup(function(t) {
  t.sandbox = new Sandbox(new Spade()); 
});

Ct.teardown(function(t) { 
  delete t.sandbox;
});

Ct.test('normal', function(t){
  var sandbox = t.sandbox, pkg;
  sandbox.spade.register('sc-super', {
    'name': 'sc-super',
    'plugin:preprocessors': ['sc-super/preprocessor']
  });
  sandbox.spade.register('sc-super/preprocessor',
    "exports.compilePreprocessor = function(code, _, filename){ "+
      "return '// From '+filename+'\\n'+code.replace(/sc_super\\(\\s*\\)/g, 'arguments.callee.base.apply(this, arguments)')+';'; "+
    "};");
  pkg = sandbox.spade.package('sc-super');

  t.equal(sandbox.compilePreprocessors('function(){ return sc_super()*2; }', 'test_file.js', pkg), '// From test_file.js\nfunction(){ return arguments.callee.base.apply(this, arguments)*2; };');
});

Ct.test('multiple', pending);

Ct.test("don't preprocess self", pending);

Ct.test("checks dependencies", pending);

Ct.test("only checks immediate dependencies", pending);

Ct.test("proper order?", pending);

