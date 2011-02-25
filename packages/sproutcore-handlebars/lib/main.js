sc_require = function(path){
  require('sproutcore-handlebars/~framework/'+path);
};

window.SC = window.SC || {};

sc_require('handlebars');
sc_require('extensions');

return SC;
