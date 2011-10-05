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
      it("returns undefined", function() {
        expect(spy("not 53")).not.toBeDefined();
      });
    });

    context("the stubbing is met", function() {
      it("returns the stubbed value", function() {
        expect(spy("53")).toEqual("winning");
      });
    });

    context("multiple stubbings exist", function() {
      beforeEach(function() {
        spy.when("pirate", { booty: ["jewels","coins"]}).thenReturn("argh!");
        spy.when("panda",1).thenReturn("sad");
      });

      it("stubs the first accurately", function() {
        expect(spy("pirate",{ booty: ["jewels","coins"]})).toBe("argh!");
      });

      it("stubs the second too", function() {
        expect(spy("panda",1)).toBe("sad");
      });
    });

    var complexType;
    beforeEach(function() {
      complexType = {
        fruits: ['apple','berry'],
        yogurts: {
          greek: function() { return "expensive"; }
        }
      }
    });

    context("complex return types are stubbed", function() {
      beforeEach(function() {
        spy.when("breakfast").thenReturn(complexType);
      });

      it("stubs precisely the same object", function() {
        expect(spy("breakfast")).toBe(complexType);
      });
    });

    context("complex argument types are stubbed", function() {
      beforeEach(function() {
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

    context("default andReturn plus some conditional stubbing", function() {
      beforeEach(function() {
        spy.andReturn("football");
        spy.when("bored").thenReturn("baseball");
      });

      describe("it doesn't leave appear to invoke the spy", function() {
        it("hasn't been called yet", function() {
          expect(spy).not.toHaveBeenCalled();
        });

        it("has a callCount of zero", function() {
          expect(spy.callCount).toBe(0);
        });

        it("has nothing in the calls array", function() {
          expect(spy.calls.length).toBe(0);
        });

        it("has no argsForCall entries", function() {
          expect(spy.argsForCall.length).toBe(0);
        });

        it("has no mostRecentCall", function() {
          expect(spy.mostRecentCall).toEqual({});
        });
      });

      context("stubbing is not satisfied", function() {
        it("returns the default stubbed value", function() {
          expect(spy("anything at all")).toBe("football");
        });
      });

      context("stubbing is satisfied", function() {
        it("returns the specific stubbed value", function() {
          expect(spy("bored")).toBe("baseball");
        });
      });

    });

  });
});