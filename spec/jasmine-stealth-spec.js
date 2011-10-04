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

    xcontext("the stubbing is unmet", function() {
      beforeEach(function() {
      });
    });

  });

});