(function(jasmine) {
  jasmine.Spy.prototype.when = function() {
    var spy = this;
    return {
      thenReturn: function() {
        return spy;
      }
    };
  };
})(jasmine);