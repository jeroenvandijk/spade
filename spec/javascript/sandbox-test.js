// ==========================================================================
// Project:   Spade - CommonJS Runtime
// Copyright: ©2011 Strobe Inc. All rights reserved.
// License:   Licened under MIT license (see __preamble__.js)
// ==========================================================================

var Ct = require('core-test/sync'),
    Spade = require('spade').Spade,
    Sandbox = require('spade').Sandbox,
    pending = function(t){ console.log("PENDING: "+t.toString()); };

// ..........................................................
// BASIC REQUIRE
// 

Ct.module('spade: Sandbox Creation');

Ct.setup(function(t) {
  t.spade = new Spade(); 
});

Ct.teardown(function(t) { 
  delete t.spade;
});

Ct.test('basic sandbox', function(t) {
  var spade = t.spade,
      sandbox = new Sandbox(spade);

  t.equal(sandbox.spade, spade);
  t.equal(sandbox.name, '(anonymous)');
  t.equal(sandbox.isIsolated, false);
});

Ct.test('named sandbox', function(t) {
  var sandbox = new Sandbox(t.spade, 'Test Sandbox');

  t.equal(sandbox.name, 'Test Sandbox');
});

Ct.test('isolated sandbox', function(t) {
  var sandbox = new Sandbox(t.spade, 'Test Sandbox', true),
      sandbox2 = new Sandbox(t.spade, true);

  t.equal(sandbox.isIsolated, true);
  t.equal(sandbox2.isIsolated, true);
});


Ct.module('spade: Sandbox Miscellaneous');

Ct.test('toString', function(t){
  var sandbox = new Sandbox(new Spade(), 'Test Sandbox');

  t.equal(sandbox.toString(), '[Sandbox Test Sandbox]');
});


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

Ct.module('spade: Sandbox format compilation');

Ct.setup(function(t) {
  t.sandbox = new Sandbox(new Spade()); 
});

Ct.teardown(function(t) { 
  delete t.sandbox;
});

Ct.test('normal', function(t){
  var sandbox = t.sandbox, pkg;
  sandbox.spade.register('text', {
    'name': 'text',
    'plugin:formats': {
      'txt': 'text/format'
    }
  });
  sandbox.spade.register('text/format',
    "exports.compileFormat = function(code, _, filename){ "+
      "return '// From '+filename+'\\nreturn \"'+code+'\";'; "+
    "};");
  pkg = sandbox.spade.package('text');

  t.equal(sandbox.compileFormat('Testing', 'test_file.txt', 'txt', pkg), '// From test_file.txt\nreturn "Testing";');
});

Ct.test("checks dependencies", pending);

Ct.test("only checks immediate dependencies", pending);

Ct.test("self takes priority", pending);


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
