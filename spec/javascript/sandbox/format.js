// ==========================================================================
// Project:   Spade - CommonJS Runtime
// Copyright: ©2011 Strobe Inc. All rights reserved.
// License:   Licened under MIT license (see __preamble__.js)
// ==========================================================================

var Ct = require('core-test/sync'),
    Spade = require('spade').Spade,
    Sandbox = require('spade').Sandbox,
    pending = function(t){ console.log("PENDING: "+t.toString()); };

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
