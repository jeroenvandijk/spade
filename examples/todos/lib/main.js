require('sproutcore-corefoundation');

// Remove loading text
$(document.body).html('');

// Trigger onReady handler
SC.onReady.done();

require('./todos');
require('./~resources/templates/todos');
require('./~resources/stylesheets/todos');
