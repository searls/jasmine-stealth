//https://github.com/searls/jasmine-stealth
(function(jasmine) {
  beforeEach(function() {
    this.stubFor = this.spyOn;
  });

  jasmine.createStub = jasmine.createSpy;
  jasmine.Spy.prototype.when = function() {
    var spy = this,
        ifThis = jasmine.util.argsToArray(arguments);
    spy._stealth_stubbings = spy._stealth_stubbings || [];

    var priorStubbing = spy.plan();

    spy.andCallFake(function() {
      for(var i=0;i<spy._stealth_stubbings.length;i++) {
        var stubbing = spy._stealth_stubbings[i];
        if(jasmine.getEnv().equals_(stubbing.ifThis,jasmine.util.argsToArray(arguments))) {
          return stubbing.thenThat;
        }
      }
      return priorStubbing;
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