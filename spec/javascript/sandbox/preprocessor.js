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

  t.sandbox.spade.register('commenter', {
    'name': 'commenter',
    'plugin:preprocessors': ['commenter/preprocessor']
  });
  t.sandbox.spade.register('commenter/preprocessor',
    "exports.compilePreprocessor = function(code, _, filename){ "+
      "return '// From '+filename+'\\n'+code; "+
    "};");
});

Ct.teardown(function(t) { 
  delete t.sandbox;
});

Ct.test('normal', function(t){
  var pkg = t.sandbox.spade.package('commenter');

  t.equal(t.sandbox.compilePreprocessors('var hello = "hi";', 'test_file.js', pkg), '// From test_file.js\nvar hello = "hi";');
});

Ct.test('multiple', function(t){
  t.sandbox.spade.register('functionizer', {
    'name': 'functionizer',
    'dependencies': { 'commenter': '1.0' },
    'plugin:preprocessors': ['functionizer/preprocessor', 'commenter/preprocessor']
  });
  t.sandbox.spade.register('functionizer/preprocessor',
    "exports.compilePreprocessor = function(code){ "+
      "return 'function(){ '+code+' };'; "+
    "};");

  var pkg = t.sandbox.spade.package('functionizer');

  t.equal(t.sandbox.compilePreprocessors('var hello = "hi";', 'test_file.js', pkg), '// From test_file.js\nfunction(){ var hello = "hi"; };');
});

Ct.test("don't preprocess self", pending);

Ct.test("checks dependencies", pending);

Ct.test("only checks immediate dependencies", pending);

Ct.test("proper order?", pending);

