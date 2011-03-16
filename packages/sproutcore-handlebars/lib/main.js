sc_require = function(path){
  require('sproutcore-handlebars/~framework/'+path);
};

window.SC = window.SC || {};

window.Handlebars = require('sproutcore-handlebars/~framework/handlebars');

sc_require('extensions');
sc_require('extensions/bind');
sc_require('extensions/collection');
sc_require('extensions/localization');
sc_require('extensions/view');

return SC;
