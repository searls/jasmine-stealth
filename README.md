# jasmine-stealth

jasmine-stealth is a [Jasmine](https://github.com/pivotal/jasmine) helper that adds a little sugar to Jasmine's spies.

**[Download the latest version here](https://github.com/searls/jasmine-stealth/archives/master)**.

## "when" + "thenReturn"

One annoyance with Jasmine spies is the default semantics of `Spy#andReturn` limits you to a single return value, regardless of which arguments a spy is invoked with. However, the arguments a spy is called with *usually matter* to the spec. None of your out-of-the-box options are great:

1. You could instead use `Spy#andCallFake` to return conditionally. But this isn't very expressive, and may grow fatter if more conditions are added.

2. You could write an additional `it` that uses `toHaveBeenCalledWith`, but then we're verifying the same call that we're stubbing, which requires the spec to be redundant in order to be complete.

3. You could just leave the arguments unspecified and leave the spec as incomplete.

Enter jasmine-stealth, which adds a `#when` method to Jasmine's spies. It lets you specify a conditional stubbing by chaining `thenReturn`. Example:

``` javascript
describe("multiple stubbings", function() {
  var someSpy;
  beforeEach(function() {
    someSpy = jasmine.createSpy();
    someSpy.when("pirate", { booty: ["jewels",jasmine.any(String)]}).thenReturn("argh!");
    someSpy.when("panda",1).thenReturn("sad");
  });

  it("stubs the first accurately", function() {
    expect(someSpy("pirate",{ booty: ["jewels","coins"]})).toBe("argh!");
  });

  it("stubs the second too", function() {
    expect(someSpy("panda",1)).toBe("sad");
  });

  it("doesn't return anything when a stubbing isn't satisfied",function(){
    expect(someSpy("anything else at all")).not.toBeDefined();
  });
});
```

It's worth noting that Jasmine's matchers will work with when-thenReturn (see the usage of `jasmine#any` above).

## mostRecentCallThat

Sometimes it's helpful to look for a certain call based on some arbitrary criteria (usually the arguments it was passed with).

jasmine-stealth adds the method `mostRecentCallThat(truthTest,context)` to each spy, and it can be used to nab the call you want by passing in a truth test.

See this example:

``` javascript

spy = jasmine.createSpy();
spy('foo',function(){});
spy('bar',function(){});
spy('baz',function(){});

var barCall = spy.mostRecentCallThat(function(call) {
  return call.args[0] === 'bar';
}); //returns the invocation passing 'bar'

barCall.args[1]() //invoke the function argument on that call (presumably to test its behavior)

```

You can also pass mostRecentCallThat a context (a value for `this` if the truth test needs access to a `this` object.)

## #createStubObj

Sometimes you want a fake object that stubs multiple functions. Jasmine provides `jasmine.createSpyObj`, which takes a name and an array of function names as parameters, but it doesn't make it any easier to set up stubbings for each of those passed functions.

Here's an example:

``` javascript

var person = jasmine.createStubObj('person',{
  name: "Steve",
  salary: 1.00,
  stealAnIdea: function(){ throw "I'm going to sue you!"; }
});

```

Following the above, `person.name()` is a normal jasmine spy configured to return steve (with `andReturn`). Likewise, invoking `person.salary()` will return `1.00`. You can also pass in functions as stubs, which will be passed to `andCallFake`; therefore, invoking `person.stealAnIdea()` will throw an exception.

*Disclaimer: If you find yourself setting up many functions on a stub, beware: complex stubs are smell that there's excessive coupling between the code under test and the dependency being faked.*

## Other stub aliases

I can [often](http://searls.heroku.com/2011/06/03/whats-wrong-with-rubys-test-doubles/) [be](https://github.com/pivotal/jasmine/issues/88#issuecomment-2132975) [found](http://stackoverflow.com/questions/5208089/are-there-any-test-spy-libraries-available-for-objective-c) [complaining](https://github.com/searls/gimme) about the nomenclature of test doubles. One reason: when test double libraries conflate stubbing and verifying, developers not versed in Test Double Science™ get confused more frequently.

I love spies (over mocks) for verification. But most of the time I don't need verification; I only want to stub behavior.

So in jasmine-stealth, I've added a couple aliases to Jasmine's spy creation to allow spec authors to discriminate their intent. They are:

    jasmine.createStub("a stub for #myMethod");

And

    stubFor(myObject,"bestMethodEver");

Both will create spies, but now the spec's intent will be a tad more clear. Especially when building a heavy-weight dependency in a `beforeEach` like this one:

``` javascript
var subject,dependency;
beforeEach(function(){
  dependency = {
    query: jasmine.createStub("#query"),
    count: jasmine.createStub("#count"),
    save: jasmine.createSpy("#save")
  }
  subject = Subject(dependency);
});
```

That might help the reader figure out your intent, but obviously you're free to take it or leave it.



## Future plans

I'm interested in adding additional Matchers and coming up with a creative way to eliminate the some keystrokes (say, with `any` instead of `jasmine.any`).