// Create the application namespace.
Todos = SC.Application.create();

//
// MODELS
//

Todos.Todo = SC.Object.extend({
  init: function() {
    if (!this.get('title')) { this.set('title', "empty todo..."); }

    return sc_super();
  },

  title: null,
  isDone: false
});

//
// CONTROLLERS
//

Todos.todoListController = SC.ArrayController.create({
  content: [],

  // Creates a new todo with the passed title, then adds it
  // to the array.
  createTodo: function(title) {
    var todo = Todos.Todo.create({ title: title });
    this.pushObject(todo);
  }
});

//
// VIEWS
//

Todos.CreateTodoView = SC.TemplateView.create(SC.TextFieldSupport, {

  insertNewline: function() {
    Todos.todoListController.createTodo(this.get('value'));

    this.set('value', '');
    return true;
  }
});

Todos.todoListView = SC.TemplateCollectionView.create({
  contentBinding: 'Todos.todoListController',

  itemView: SC.TemplateView.extend({
    // Add the 'done' class to this view
    // if the Todo object is marked isDone
    isDoneDidChange: function() {
      var isDone = this.getPath('content.isDone');

      this.$().toggleClass('done', isDone);
    }.observes('.content.isDone')
  })
});

Todos.CheckboxView = SC.TemplateView.extend(SC.CheckboxSupport, {

  // Observe the value property
  valueDidChange: function() {
    // Get the Todo object and change its isDone property
    this.setPath('parentView.content.isDone', this.get('value'));
  }.observes('value')
});

jQuery(document).ready(function() {
  $(document.body).html(''); // Clear loading message
  Todos.mainPane = SC.TemplatePane.append({
    layerId: "todoapp",
    templateName: "app"
  });
});

