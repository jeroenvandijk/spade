exports.compileFormat = function(code, spade, filename){
  var name = filename.replace(/^[^\/]+\/~?/, '').replace(/\.handlebars$/, '');
  var escaped = code.replace(/"/g,'\\"').replace(/\n/g, '\\n');
  return "SC.TEMPLATES[\""+name+"\"] = SC.Handlebars.compile(\""+escaped+"\")";
};
