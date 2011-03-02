require('sproutcore-corefoundation');

// Remove loading text
jQuery(document).ready(function() {
  $(document.body).html('');
});

require('./app');
require('./~resources/templates/app');
require('./~resources/stylesheets/todos');
