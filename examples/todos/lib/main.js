require('sproutcore-corefoundation');

require('./resources/todos');
require('./app');

var appTemplate =
  "<h1>Todos</h1>\n" +
  "{{#view \"Todos.CreateTodoView\"}}\n" +
  "<input id=\"new-todo\" type=\"text\"\n" +
  "       placeholder=\"What needs to be done?\" />\n" +
  "{{/view}}\n" +
  "\n" +
  "{{#collection \"Todos.todoListView\"}}\n" +
  "  {{#view \"Todos.CheckboxView\"}}\n" +
  "    <input class=\"check\" type=\"checkbox\" />\n" +
  "  {{/view}}\n" +
  "  <div class='todo-content'>{{title}}</div>\n" +
  "{{/collection}}";

SC.TEMPLATES.set("app", SC.Handlebars.compile(appTemplate));
