# jasmine-stealth

jasmine-stealth is a Jasmine helper that adds a little sugar to Jasmine's spies.

## "when" + "thenReturn"

One annoyance with Jasmine spies is the default semantics of `Spy#andReturn` limits you to a single return value, regardless of which arguments a spy is invoked with. And the arguments a spy is called with usually *matter* to the spec. Your options are all poor:

1. You could use `Spy#andCallFake` to return conditionally. Except this isn't very expressive, and may grow fatter with time.

2. You could write an additional `it` that uses `toHaveBeenCalledWith`, but then we're verifying the same call that we're stubbing, which requires the spec to be redundant in order to be complete.

3. You could just leave the arguments unspecified and leave the spec as incomplete.

jasmine-stealth adds a `#when` method to Jasmine's spies. It lets you specify a conditional stubbing by chaining `thenReturn`. Example:

    describe("multiple stubbings", function() {
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

## Stub aliases

I can [often](http://searls.heroku.com/2011/06/03/whats-wrong-with-rubys-test-doubles/) [be](https://github.com/pivotal/jasmine/issues/88#issuecomment-2132975) [found](http://stackoverflow.com/questions/5208089/are-there-any-test-spy-libraries-available-for-objective-c) [complaining](https://github.com/searls/gimme) about the nomenclature of test doubles.

One thing I've noticed over time is that some developers new to stubbing and verifying behavior are done a disservice by test double libraries that conflate the two activities. I love spies for verification--but 70% of the time I only want to stub behavior.

So in jasmine-stealth, I've added a couple little aliases to spy creation to allow spec authors to discriminate their intent:

    jasmine.createStub("a stub for #myMethod");

And

    stubFor(myObject,"bestMethodEver");

Both will create spies, but now the spec's intent will be a tad more clear. Especially when building a heavy-weight dependency in a `beforeEach` like this one:

    var subject,dependency;
    beforeEach(function(){
      dependency = {
        query: jasmine.createStub("#query"),
        count: jasmine.createStub("#count"),
        save: jasmine.createSpy("#save")
      }
      subject = Subject(dependency);
    });

That might help the reader figure out your intent, but obviously you're free to take it or leave it.