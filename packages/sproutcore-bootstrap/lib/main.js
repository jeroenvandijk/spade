require('sproutcore-runtime');

sc_require = function(path){
  require('sproutcore-bootstrap/~framework/'+path);
};

sc_require('core');
sc_require('system/bench');
sc_require('system/browser');
sc_require('system/loader');
sc_require('setup_body_class_names');
