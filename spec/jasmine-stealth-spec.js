window.context = window.describe;
window.xcontext = window.xdescribe;

describe("jasmine-stealth", function() {

  describe("aliases", function() {
    it("creates createStub as an alias of createSpy", function() {
      expect(jasmine.createStub).toBe(jasmine.createSpy);
    });

    it("creates stubFor as an alias of spyOn", function() {
      expect(this.stubFor).toBe(this.spyOn);
    });
  });

  describe("#when", function() {
    var spy,result;
    beforeEach(function() {
      spy = jasmine.createSpy("my spy")

      result = spy.when("53").thenReturn("winning");
    });

    it("thenReturn returns the spy", function() {
      expect(result).toBe(spy);
    });

    context("the stubbing is unmet", function() {
      beforeEach(function() {
        result = spy("not 53");
      });
      it("returns undefined", function() {
        expect(result).not.toBeDefined();
      });
    });

    context("the stubbing is met", function() {
      beforeEach(function() {
        result = spy("53");
      });
      it("returns the stubbed value", function() {
        expect(result).toEqual("winning");
      });
    });

    context("multiple stubbings exist", function() {
      beforeEach(function() {
        spy.when("pirate").thenReturn("argh");
        spy.when("panda").thenReturn("sad");
      });

      it("stubs the first accurately", function() {
        expect(spy("pirate")).toBe("argh");
      });

      it("stubs the second too", function() {
        expect(spy("panda")).toBe("sad");
      });
    });

    context("complex return types are stubbed", function() {
      var complexType;
      beforeEach(function() {
        complexType = {
          fruits: ['apple','berry'],
          yogurts: {
            greek: function() { return "expensive"; }
          }
        }

        spy.when("breakfast").thenReturn(complexType);
      });

      it("stubs precisely the same object", function() {
        expect(spy("breakfast")).toBe(complexType);
      });
    });

    context("complex argument types are stubbed", function() {
      var complexType;
      beforeEach(function() {
        complexType = {
          fruits: ['apple','berry'],
          yogurts: {
            greek: function() { return "expensive"; }
          }
        }

        spy.when(complexType).thenReturn("breakfast");
      });

      it("satisfies the stubbing", function() {
        expect(spy(complexType)).toBe("breakfast");
      });
    });

    context("stubbing with multiple arguments", function() {
      beforeEach(function() {
        spy.when(1,1,2,3,5).thenReturn("fib")
      });

      it("satisfies that stubbing too", function() {
        expect(spy(1,1,2,3,5)).toBe("fib");
      });
    });

  });

});