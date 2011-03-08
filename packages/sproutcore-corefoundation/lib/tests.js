require('sproutcore-corefoundation');

/* BEGIN HACKS */
Q$ = jQuery;

clearHtmlbody = function(){
  var body = Q$('body')[0];
  
  // first, find the first element with id 'htmlbody-begin'  if exists,
  // remove everything after that to reset...
  var begin = Q$('body #htmlbody-begin')[0];
  if (!begin) {
    begin = Q$('<div id="htmlbody-begin"></div>')[0];
    body.appendChild(begin);
  } else {
    while(begin.nextSibling) body.removeChild(begin.nextSibling);
  }
  begin = null; 
};

htmlbody = function(string) {
  var html = Q$(string) ;
  var body = Q$('body')[0];

  clearHtmlbody();

  // now append new content
  html.each(function() { body.appendChild(this); });
};

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

$().ready(function(){
  $('h1').remove();
  Ct.run();
});
