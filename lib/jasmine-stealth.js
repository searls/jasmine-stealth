//https://github.com/searls/jasmine-stealth
(function(jasmine) {
  var isFunction = function(thing) {
    return Object.prototype.toString.call(thing) === '[object Function]';
  };

  beforeEach(function() {
    this.stubFor = this.spyOn;
  });
  jasmine.createStub = jasmine.createSpy;
  jasmine.createStubObj = function(baseName,stubbings) {
    if(stubbings.constructor === Array) {
      return jasmine.createSpyObj(baseName,stubbings);
    } else {
      var obj = {};
      for(var name in stubbings) {
        var stubbing = stubbings[name];
        obj[name] = jasmine.createSpy(baseName + '.' + name);
        if(isFunction(stubbing)) {
          obj[name].andCallFake(stubbing);
        } else {
          obj[name].andReturn(stubbing);
        }
      }
      return obj;
    }
  };




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

  jasmine.Spy.prototype.mostRecentCallThat = function(callThat,context) {
    for (var i=this.calls.length-1; i >= 0; i--) {
      if(callThat.call(context || this,this.calls[i]) === true) {
        return this.calls[i];
      }
    }
  };
})(jasmine);