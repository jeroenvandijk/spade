require('sproutcore-runtime');

sc_require = function(path){
  require('sproutcore-datastore/~framework/'+path);
};

sc_require('core');
sc_require('system/store');
sc_require('system/nested_store');
sc_require('system/query');
sc_require('models/record');
sc_require('models/record_attribute');
sc_require('models/single_attribute');
sc_require('models/many_attribute');
sc_require('models/child_attribute');
sc_require('models/children_attribute');
sc_require('system/record_array');
sc_require('data_sources/data_source');
sc_require('data_sources/cascade');
sc_require('data_sources/fixtures');
