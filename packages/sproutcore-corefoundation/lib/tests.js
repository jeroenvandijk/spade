require('sproutcore-corefoundation');

/* BEGIN HACKS */
require('sproutcore-runtime/~framework/debug/test_suites/array/base');

htmlbody = function(html){
  $(document.body).html(html);
};

Q$ = jQuery;
/* END HACKS */

var Ct = require('core-test');

require('core-test/qunit');

var pkg = spade.package('sproutcore-corefoundation');

var params = {}, match, parts, kv;
if (match = window.location.href.match(/\?(.+)$/)) {
  parts = match[1].split('&');
  for (var i=0, len=parts.length; i < len; i++) {
    kv = parts[i].split('=');
    if (kv.length != 2) {
      console.error("Expected format of key=value!");
      continue;
    }
    params[kv[0]] = kv[1];
  }
}

var len = pkg.files.length, i, file;
for (i=0; i<len; i++) {
  file = pkg.files[i];
  if (file.substring(0,16) === 'framework/tests/' && (!params.file || file.indexOf(params.file) === 16)) {
    file = file.replace(/\.[^\.]+$/,''); // Remove ext
    require('sproutcore-corefoundation/~'+file);
  }
}

$().ready(function(){ Ct.run(); });
