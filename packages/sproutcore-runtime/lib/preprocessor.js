// Handle sc_super()
exports.compilePreprocessor = function(code){
 return code.replace(/sc_super\(\s*\)/g, 'arguments.callee.base.apply(this, arguments)');
};
