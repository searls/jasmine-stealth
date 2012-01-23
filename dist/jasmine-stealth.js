
/*
jasmine-stealth Makes Jasmine spies a bit more robust
site: https://github.com/searls/jasmine-stealth
*/

(function() {
  var isFunction,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  isFunction = function(thing) {
    return Object.prototype.toString.call(thing) === "[object Function]";
  };

  beforeEach(function() {
    return this.stubFor = this.spyOn;
  });

  jasmine.createStub = jasmine.createSpy;

  jasmine.createStubObj = function(baseName, stubbings) {
    var name, obj, stubbing;
    if (stubbings.constructor === Array) {
      return jasmine.createSpyObj(baseName, stubbings);
    } else {
      obj = {};
      for (name in stubbings) {
        stubbing = stubbings[name];
        obj[name] = jasmine.createSpy(baseName + "." + name);
        if (isFunction(stubbing)) {
          obj[name].andCallFake(stubbing);
        } else {
          obj[name].andReturn(stubbing);
        }
      }
      return obj;
    }
  };

  jasmine.Spy.prototype.when = function() {
    var addStubbing, ifThis, priorStubbing, spy;
    spy = this;
    ifThis = jasmine.util.argsToArray(arguments);
    spy._stealth_stubbings = spy._stealth_stubbings || [];
    priorStubbing = spy.plan();
    spy.andCallFake(function() {
      var i, stubbing;
      i = 0;
      while (i < spy._stealth_stubbings.length) {
        stubbing = spy._stealth_stubbings[i];
        if (jasmine.getEnv().equals_(stubbing.ifThis, jasmine.util.argsToArray(arguments))) {
          if (Object.prototype.toString.call(stubbing.thenThat) === "[object Function]") {
            return stubbing.thenThat();
          } else {
            return stubbing.thenThat;
          }
        }
        i++;
      }
      return priorStubbing;
    });
    addStubbing = function(thenThat) {
      spy._stealth_stubbings.push({
        ifThis: ifThis,
        thenThat: thenThat
      });
      return spy;
    };
    return {
      thenReturn: addStubbing,
      thenCallFake: addStubbing
    };
  };

  jasmine.Spy.prototype.mostRecentCallThat = function(callThat, context) {
    var i;
    i = this.calls.length - 1;
    while (i >= 0) {
      if (callThat.call(context || this, this.calls[i]) === true) {
        return this.calls[i];
      }
      i--;
    }
  };

  jasmine.Matchers.ArgThat = (function(_super) {

    __extends(ArgThat, _super);

    function ArgThat(matcher) {
      this.matcher = matcher;
    }

    ArgThat.prototype.matches = function(actual) {
      return this.matcher(actual);
    };

    return ArgThat;

  })(jasmine.Matchers.Any);

  jasmine.argThat = function(expected) {
    return new jasmine.Matchers.ArgThat(expected);
  };

}).call(this);
