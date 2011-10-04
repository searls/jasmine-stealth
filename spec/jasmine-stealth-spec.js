window.context = window.describe;
window.xcontext = window.xdescribe;

describe("jasmine-stealth", function() {

  describe("a stub for spies", function() {
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
        result = spy("not 54");
      });
      it("returns undefined", function() {
        expect(result).not.toBeDefined();
      });
    });

    context("the stubbing is met", function() {
      beforeEach(function() {
        result = spy("54");
      });
      it("returns the stubbed value", function() {
        expect(result).toEqual("winning");
      });
    });

  });

});