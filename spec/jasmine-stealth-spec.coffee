( ->
  root = this

  root.context = root.describe
  root.xcontext = root.xdescribe

  describe "jasmine-stealth", ->
    describe "aliases", ->
      Then -> jasmine.createStub == jasmine.createSpy

      describe ".stubFor", ->
        context "existing method", ->
          Given -> root.lolol = -> "roflcopter"
          When -> stubFor(root, "lolol").andReturn("lol")
          Then -> root.lolol() == "lol"

        context "non-existing method", ->
          Given -> @obj = { woot: null }
          When -> spyOn(@obj, "woot").andReturn("troll")
          Then -> @obj.woot() == "troll"

    describe "#when", ->
      Given -> @spy = jasmine.createSpy("my spy")

      context "a spy is returned by then*()", ->
        Then -> expect(@spy.when("a").thenReturn("")).toBe(@spy)
        Then -> expect(@spy.when("a").thenCallFake((->))).toBe(@spy)

      describe "#thenReturn", ->
        context "the stubbing is unmet", ->
          Given -> @spy.when("53").thenReturn("yay!")
          Then -> expect(@spy("not 53")).not.toBeDefined()

        context "the stubbing is met", ->
          Given -> @spy.when("53").thenReturn("winning")
          Then -> @spy("53") == "winning"

        context "multiple stubbings exist", ->
          Given -> @spy.when("pirate", booty: ["jewels", jasmine.any(String)]).thenReturn("argh!")
          Given -> @spy.when("panda", 1).thenReturn("sad")

          Then -> @spy("pirate", booty: ["jewels", "coins"]) ==  "argh!"
          Then -> @spy("panda", 1) == "sad"

        context "complex types", ->
          Given -> @complexType =
            fruits: [ "apple", "berry" ]
            yogurts:
              greek: ->
                "expensive"

          context "complex return types", ->
            Given -> @spy.when("breakfast").thenReturn(@complexType)
            Then -> @spy("breakfast") == @complexType

          context "complex argument types", ->
            Given -> @spy.when(@complexType).thenReturn("breakfast")
            Then -> @spy(@complexType) == "breakfast"

        context "stubbing with multiple arguments", ->
          Given -> @spy.when(1, 1, 2, 3, 5).thenReturn("fib")
          Then -> @spy(1, 1, 2, 3, 5) == "fib"

        context "returns a function", ->
          Given -> @func = -> throw "WTF DUDE"
          Given -> @spy.when(1).thenReturn(@func)
          Then -> @spy(1) == @func

        context "a stubbing is later overridden", ->
          Given -> @spy.when("foo").thenReturn(1)
          context "here's that override I talked about", ->
            Given -> @spy.when("foo").thenReturn(2)
            Then -> @spy("foo") == 2

      describe "#thenCallFake", ->
        context "stubbing a conditional call fake", ->
          Given -> @fake = jasmine.createSpy("fake")
          Given -> @spy.when("panda", "baby").thenCallFake(@fake)
          When -> @spy("panda", "baby")
          Then -> expect(@fake).toHaveBeenCalledWith("panda", "baby")

      context "default andReturn plus some conditional stubbing", ->
        Given -> @spy.andReturn "football"
        Given -> @spy.when("bored").thenReturn "baseball"

        describe "it doesn't appear to invoke the spy", ->
          Then -> expect(@spy).not.toHaveBeenCalled()
          Then -> @spy.callCount == 0
          Then -> @spy.calls.length == 0
          Then -> @spy.argsForCall.length == 0
          Then -> expect(@spy.mostRecentCall).toEqual({})

        context "stubbing is not satisfied", ->
          Then -> @spy("anything at all") == "football"

        context "stubbing is satisfied", ->
          Then -> @spy("bored") == "baseball"

      context "default andCallFake plus some conditional stubbing", ->
        Given -> @spy.andCallFake (s1,s2) -> s2
        Given -> @spy.when("function").thenCallFake -> "football"
        Given -> @spy.when("value").thenReturn "baseball"

        describe "it doesn't appear to invoke the spy", ->
          Then -> expect(@spy).not.toHaveBeenCalled()
          Then -> @spy.callCount == 0
          Then -> @spy.calls.length == 0
          Then -> @spy.argsForCall.length == 0
          Then -> expect(@spy.mostRecentCall).toEqual({})

        context "default stubbing is satisfied", ->
          Then -> @spy("cricket", "tennis") == "tennis"

        context "conditional function stubbing is satisfied", ->
          Then -> @spy("function") == "football"

        context "conditional value stubbing is satisfied", ->
          Then -> @spy("value") == "baseball"

    describe "#whenContext", ->
      Given -> @ctx = "A"
      Given -> @spy = jasmine.createSpy().whenContext(@ctx).thenReturn("foo")

      context "when satisfied", ->
        When -> @result = @spy.call(@ctx)
        Then -> @result == "foo"

      context "when not satisfied", ->
        When -> @result = @spy.call("B")
        Then -> @result == undefined

    describe "#mostRecentCallThat", ->
      Given -> @spy = jasmine.createSpy()
      Given -> @spy("foo")
      Given -> @spy("bar")
      Given -> @spy("baz")

      context "when given a truth test", ->
        When -> @result = @spy.mostRecentCallThat (call) ->
          call.args[0] is "bar"
        Then -> @result == @spy.calls[1]

      context "when the context matters", ->
        Given -> @panda = "baz"
        When -> @result = @spy.mostRecentCallThat((call) ->
          call.args[0] is @panda
        , this)
        Then -> @result == @spy.calls[2]

    describe "jasmine.createStubObj", ->
      context "used just like createSpyObj", ->
        Given -> @subject = jasmine.createStubObj('foo',['a','b'])
        Given -> @subject.a()
        Given -> @subject.b()
        Then -> expect(@subject.a).toHaveBeenCalled()
        Then -> expect(@subject.b).toHaveBeenCalled()

      context "passed an obj literal", ->
        Given -> @subject = jasmine.createStubObj 'foo',
          a: 5
          b: -> 8
        Then -> @subject.a() == 5
        Then -> @subject.b() == 8

    describe "jasmine.argThat (jasmine.Matchers.ArgThat)", ->
      context "with when()", ->
        Given -> @spy = jasmine.createSpy()
        Given -> @spy.when(jasmine.argThat (arg) -> arg > 5).thenReturn("YAY")
        Given -> @spy.when(jasmine.argThat (arg) -> arg < 3).thenReturn("BOO")

        Then -> @spy(1) == "BOO"
        Then -> @spy(4) == undefined
        Then -> @spy(8) == "YAY"


      context "with a spy arg, using toHaveBeenCalledWith", ->
        Given -> @spy = jasmine.createSpy()
        When -> @spy(5)
        Then -> expect(@spy).toHaveBeenCalledWith(jasmine.argThat (arg) -> arg < 6)
        Then -> expect(@spy).not.toHaveBeenCalledWith(jasmine.argThat (arg) -> arg > 5)

      context "passes the equals contract", ->
        Then -> true == jasmine.getEnv().equals_(5, jasmine.argThat (arg) -> arg == 5)
        Then -> false == jasmine.getEnv().equals_(5, jasmine.argThat (arg) -> arg == 4)
        Then -> false == jasmine.getEnv().equals_(5, jasmine.argThat (arg) -> arg != 5)

    describe "jasmine.captor, #capture() & .value", ->
      Given -> @captor = jasmine.captor()
      Given -> @spy = jasmine.createSpy()
      When -> @spy("foo!")
      Then -> expect(@spy).toHaveBeenCalledWith(@captor.capture())
      And -> @captor.value == "foo!"

      it "readme example", ->
        captor = jasmine.captor()
        save = jasmine.createSpy()

        save({ name: "foo", phone: "123"});

        expect(save).toHaveBeenCalledWith(captor.capture())
        expect(captor.value.name).toBe("foo")

    describe "root.spyOnConstructor", ->
      describe "a simple class", ->
        class root.Pizza
          makeSlice: -> "nah"

        context "spying on the constructor - string method arg", ->
          Given -> @pizzaSpies = spyOnConstructor(root, "Pizza", "makeSlice")
          When -> new Pizza("banz").makeSlice("lol")
          Then -> expect(@pizzaSpies.constructor).toHaveBeenCalledWith("banz")
          Then -> expect(@pizzaSpies.makeSlice).toHaveBeenCalledWith("lol")

        context "spying on the constructor - array method arg", ->
          Given -> @pizzaSpies = spyOnConstructor(root, "Pizza", ["makeSlice"])
          When -> new Pizza("banz").makeSlice("lol")
          Then -> expect(@pizzaSpies.constructor).toHaveBeenCalledWith("banz")
          Then -> expect(@pizzaSpies.makeSlice).toHaveBeenCalledWith("lol")

        context "normal operation", ->
          Given -> @pizza = new Pizza
          Then -> @pizza.makeSlice() == "nah"

      describe "a collaboration", ->
        class root.View
          serialize: ->
            model: new Model().toJSON()
        class root.Model

        context "stubbing the model's method", ->
          Given -> @modelSpies = spyOnConstructor(root, "Model", "toJSON")
          Given -> @subject = new root.View()
          Given -> @modelSpies.toJSON.andReturn("some json")
          When -> @result = @subject.serialize()
          Then -> expect(@result).toEqual
            model: "some json"
)()
