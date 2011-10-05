# jasmine-stealth

jasmine-stealth is a [Jasmine](https://github.com/pivotal/jasmine) helper that adds a little sugar to Jasmine's spies.

**[Download the latest version here](https://github.com/searls/jasmine-stealth/archives/master)**.

## "when" + "thenReturn"

One annoyance with Jasmine spies is the default semantics of `Spy#andReturn` limits you to a single return value, regardless of which arguments a spy is invoked with. However, the arguments a spy is called with *usually matter* to the spec. None of your out-of-the-box options are great:

1. You could instead use `Spy#andCallFake` to return conditionally. But this isn't very expressive, and may grow fatter if more conditions are added.

2. You could write an additional `it` that uses `toHaveBeenCalledWith`, but then we're verifying the same call that we're stubbing, which requires the spec to be redundant in order to be complete.

3. You could just leave the arguments unspecified and leave the spec as incomplete.

Enter jasmine-stealth, which adds a `#when` method to Jasmine's spies. It lets you specify a conditional stubbing by chaining `thenReturn`. Example:

    describe("multiple stubbings", function() {
      beforeEach(function() {
        spy.when("pirate", { booty: ["jewels",jasmine.any(String)]}).thenReturn("argh!");
        spy.when("panda",1).thenReturn("sad");
      });

      it("stubs the first accurately", function() {
        expect(spy("pirate",{ booty: ["jewels","coins"]})).toBe("argh!");
      });

      it("stubs the second too", function() {
        expect(spy("panda",1)).toBe("sad");
      });
    });

It's worth noting that Jasmine's matchers will work with when-thenReturn (see the usage of `jasmine#any` above).

## Stub aliases

I can [often](http://searls.heroku.com/2011/06/03/whats-wrong-with-rubys-test-doubles/) [be](https://github.com/pivotal/jasmine/issues/88#issuecomment-2132975) [found](http://stackoverflow.com/questions/5208089/are-there-any-test-spy-libraries-available-for-objective-c) [complaining](https://github.com/searls/gimme) about the nomenclature of test doubles. One reason: when test double libraries conflate stubbing and verifying, developers not versed in Test Double Science™ get confused more frequently.

I love spies (over mocks) for verification. But most of the time I don't need verification; I only want to stub behavior.

So in jasmine-stealth, I've added a couple aliases to Jasmine's spy creation to allow spec authors to discriminate their intent. They are:

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

## Future plans

I'm interested in adding additional Matchers and coming up with a creative way to eliminate the some keystrokes (say, with `any` instead of `jasmine.any`).