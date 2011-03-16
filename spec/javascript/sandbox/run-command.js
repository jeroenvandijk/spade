// ==========================================================================
// Project:   Spade - CommonJS Runtime
// Copyright: ©2011 Strobe Inc. All rights reserved.
// License:   Licened under MIT license (see __preamble__.js)
// ==========================================================================

var Ct = require('core-test/sync'),
    Spade = require('spade').Spade,
    Sandbox = require('spade').Sandbox,
    pending = function(t){ console.log("PENDING: "+t.toString()); };

Ct.module('spade: Sandbox runCommand');

Ct.test('success', pending);

Ct.test('failure', pending);

Ct.test('not supported', pending);

Ct.test('browser', pending);
