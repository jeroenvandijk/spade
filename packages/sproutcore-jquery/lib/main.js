sc_require = function(path){
  require('sproutcore-jquery/~framework/'+path);
};

sc_require('jquery');
sc_require('jquery-buffer');
sc_require('jquery-buffered');
sc_require('jquery-sc');

jQuery.extend(exports, jQuery);
