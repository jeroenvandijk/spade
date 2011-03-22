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

$('h1').remove();

var len = pkg.files.length, i, file, tests = [];
for (i=0; i<len; i++) {
  file = pkg.files[i];
  if (file.substring(0,16) === 'framework/tests/' && (!params.file || file.indexOf(params.file) === 16)) {
    file = file.replace(/\.[^\.]+$/,''); // Remove ext
    tests.push('sproutcore-corefoundation/~'+file);
  }
}

// Using this setup with setTimeout allows for rending to happen on WebKit
var curTestIndex = -1, test;
function runNextTest(){
  curTestIndex++;
  if (test = tests[curTestIndex]) {
    require(test);
    Ct.run();
    setTimeout(runNextTest, 100);
  }
}

SC.ready(runNextTest);
