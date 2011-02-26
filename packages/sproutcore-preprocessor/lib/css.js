exports.compileFormat = function(code){
  var escaped = code.replace(/"/g,'\\"').replace(/\n/g, '\\n');

  var ret =
    "if (window.document && window.document.head) {\n"+
    "  var el = document.createElement('style');\n"+
    "  el.type = \"text/css\";\n"+
    "  el.innerHTML = \""+escaped+"\";\n"+
    "  document.head.appendChild(el);\n"+
    "} else {\n"+
    "  console.error(\"Can't handle css outside of browser!\");\n"+
    "}\n";

  return ret;
};
