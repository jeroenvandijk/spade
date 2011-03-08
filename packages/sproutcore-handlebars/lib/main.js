sc_require = function(path){
  require('sproutcore-handlebars/~framework/'+path);
};

window.SC = window.SC || {};

window.Handlebars = require('sproutcore-handlebars/~framework/handlebars');

sc_require('extensions');

return SC;
