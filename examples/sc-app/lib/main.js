require('sproutcore-runtime');
require('jquery'); // Override SC's jquery-core

var testObj = SC.Object.create({

  random: null,

  value: function(){
    return "Random: "+this.get('random');
  }.property('random').cacheable(),

  randomize: function(){
    this.set('random', Math.random());
  },

  _valueDidChange: function(){
    $('h1').html(this.get('value'));
  }.observes('value')

});

$(document.body).click(function(){
  testObj.randomize();
});
