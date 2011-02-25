require('sproutcore-runtime');
require('sproutcore-bootstrap');
require('sproutcore-handlebars');
require('jquery');

sc_require = function(path){
  require('sproutcore-corefoundation/~framework/'+path);
};

sc_require('core');
sc_require('controllers/controller');
sc_require('controllers/object');
sc_require('controllers/array');
sc_require('ext/object');
sc_require('ext/run_loop');
sc_require('mixins/delegate_support');
sc_require('mixins/responder_context');
sc_require('mixins/selection_support');
sc_require('mixins/string');
sc_require('panes/pane');
sc_require('panes/keyboard');
sc_require('panes/layout');
sc_require('panes/manipulation');
sc_require('panes/visibility');
sc_require('panes/main');
sc_require('panes/template');
sc_require('system/application');
sc_require('system/browser');
sc_require('system/builder');
sc_require('system/core_query');
sc_require('system/cursor');
sc_require('system/device');
sc_require('system/event');
sc_require('system/json');
sc_require('system/locale');
sc_require('system/page');
sc_require('system/platform');
sc_require('system/ready');
sc_require('system/render_context');
sc_require('system/responder');
sc_require('system/root_responder');
sc_require('system/selection_set');
sc_require('system/sparse_array');
sc_require('system/theme');
sc_require('system/timer');
sc_require('system/utils');
sc_require('system/utils/rect');
sc_require('views/view/base');
sc_require('views/template');
sc_require('views/template/checkbox_support');
sc_require('views/template/collection');
sc_require('views/template/text_field_support');
sc_require('views/view');
sc_require('views/view/animation');
sc_require('views/view/cursor');
sc_require('views/view/enabled');
sc_require('views/view/keyboard');
sc_require('views/view/layout');
sc_require('views/view/layout_style');
sc_require('views/view/manipulation');
sc_require('views/view/theming');
sc_require('views/view/touch');
sc_require('views/view/visibility');
