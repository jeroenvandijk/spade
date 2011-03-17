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

// TODO: Add the next 3 tests when adding Ruby and node.js support
Ct.test('success', pending);

Ct.test('failure', pending);

Ct.test('not supported', pending);

// Not really sure how to test this, other than a bunch of stubbing
Ct.test('browser', pending);
