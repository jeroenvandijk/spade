require('sproutcore-corefoundation');

// Remove loading text
jQuery(document).ready(function() {
  $(document.body).html('');
});

require('./todos');
require('./~resources/templates/todos');
require('./~resources/stylesheets/todos');
