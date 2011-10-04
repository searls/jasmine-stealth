(function(jasmine) {
  var argsToArray = function(args) {
    return Array.prototype.slice.call(args, 0);
  };

  beforeEach(function() {
    this.stubFor = this.spyOn;
  });

  jasmine.createStub = jasmine.createSpy;
  jasmine.Spy.prototype.when = function() {
    var spy = this,
        ifThis = argsToArray(arguments);
    spy._stealth_stubbings = spy._stealth_stubbings || [];

    spy.andCallFake(function() {
      for(var i=0;i<spy._stealth_stubbings.length;i++) {
        var stubbing = spy._stealth_stubbings[i];
        if(jasmine.getEnv().equals_(stubbing.ifThis,argsToArray(arguments))) {
          return stubbing.thenThat;
        }
      }
    });

    return {
      thenReturn: function(thenThat) {
        spy._stealth_stubbings.push({
          ifThis: ifThis,
          thenThat: thenThat
        });
        return spy;
      }
    };
  };
})(jasmine);