exports.replace = function(code, sandbox, pkg, format) {
  var match, url, replacement;
  while (match = code.match(/(sc_static|static_url)\(['"]([^'"\(\)]+)['"]\)/)) {
    url = sandbox.spade.loader.resolveUrl(pkg.name+"/~resources/"+match[2], pkg);
    replacement = format ? format.replace('{url}', url) : '"'+url+'"';
    code = code.replace(match[0], replacement);
  }
  return code;
};
