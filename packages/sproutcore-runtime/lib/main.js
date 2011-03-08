sc_require = function(path){
  require('sproutcore-runtime/~framework/'+path);
};

require('jquery-core');

sc_require('core');
sc_require('mixins/array');
sc_require('mixins/comparable');
sc_require('mixins/copyable');
sc_require('mixins/enumerable');
sc_require('mixins/freezable');
sc_require('mixins/observable');

sc_require('system/binding');
sc_require('system/enumerator');
sc_require('system/error');
sc_require('system/index_set');
sc_require('system/logger');
sc_require('system/object');
sc_require('system/range_observer');
sc_require('system/run_loop');
sc_require('system/set');

// Hack to allow tests to run
CoreTest = window.CoreTest || {};
CoreTest.Suite = SC.Object.extend({
  define: function(){},
  generate: function(){
    if (window.test) { test("CoreTest.Suite.generate is not implemented"); }
  }
});

// Normally we wouldn't want to do this globally
sc_require('debug/test_suites/array');

return SC;
