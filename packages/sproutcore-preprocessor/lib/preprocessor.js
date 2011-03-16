var scStatic = require('./sc_static');

exports.compilePreprocessor = function(code, sandbox, filename, pkg){
  // Handle sc_super()
  code = code.replace(/sc_super\(\s*\)/g, 'arguments.callee.base.apply(this, arguments)');

  // Handle sc_static|static_url
  code = scStatic.replace(code, sandbox, pkg);

  return code;
};

