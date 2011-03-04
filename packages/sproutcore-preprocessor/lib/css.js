exports.compileFormat = function(code, sandbox, filename, format, pkg){
  // Handle sc_static|static_url
  code = require('./sc_static').replace(code, sandbox, pkg, "url('{url}')");

  // escape
  code = code.replace(/"/g,'\\"').replace(/\n/g, '\\n');

  var ret =
    "if (window.document && window.document.head) {\n"+
    "  var el = document.createElement('style');\n"+
    "  el.type = \"text/css\";\n"+
    "  el.innerHTML = \""+code+"\";\n"+
    "  document.head.appendChild(el);\n"+
    "} else {\n"+
    "  console.error(\"Can't handle css outside of browser!\");\n"+
    "}\n";

  return ret;
};
