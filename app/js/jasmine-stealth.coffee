( ->
  root = `(1, eval)('this')`

  #private helpers

  _ = (obj) ->
    each: (iterator) ->
      iterator(item) for item in obj
    isFunction: ->
      Object::toString.call(obj) is "[object Function]"
    isString: ->
      Object::toString.call(obj) is "[object String]"

  #spyOnConstructor

  root.spyOnConstructor = (owner, classToFake, methodsToSpy = []) ->
    methodsToSpy = [methodsToSpy] if _(methodsToSpy).isString()

    spies = constructor: jasmine.createSpy("#{classToFake}'s constructor")
    fakeClass = class
      constructor: -> spies.constructor.apply(@, arguments)

    _(methodsToSpy).each (methodName) ->
      spies[methodName] = jasmine.createSpy("#{classToFake}##{methodName}")
      fakeClass.prototype[methodName] = -> spies[methodName].apply(@,arguments)

    fake(owner, classToFake, fakeClass)
    spies

  unfakes = []
  afterEach ->
    _(unfakes).each (u) -> u()
    unfakes = []

  fake = (owner, thingToFake, newThing) ->
    originalThing = owner[thingToFake]
    owner[thingToFake] = newThing
    unfakes.push ->
      owner[thingToFake] = originalThing

  #stub nomenclature

  root.stubFor = root.spyOn
  jasmine.createStub = jasmine.createSpy
  jasmine.createStubObj = (baseName, stubbings) ->
    if stubbings.constructor is Array
      jasmine.createSpyObj baseName, stubbings
    else
      obj = {}
      for name of stubbings
        stubbing = stubbings[name]
        obj[name] = jasmine.createSpy(baseName + "." + name)
        if _(stubbing).isFunction()
          obj[name].andCallFake stubbing
        else
          obj[name].andReturn stubbing
      obj

  whatToDoWhenTheSpyGetsCalled = (spy) ->
    matchesStub = (stubbing,args,context) ->
      switch stubbing.type
        when "args" then jasmine.getEnv().equals_(stubbing.ifThis, jasmine.util.argsToArray(args))
        when "context" then jasmine.getEnv().equals_(stubbing.ifThis,context)

    priorPlan = spy.plan

    spy.andCallFake ->
      i = 0
      while i < spy._stealth_stubbings.length
        stubbing = spy._stealth_stubbings[i]
        if matchesStub(stubbing,arguments,this)
          if stubbing.satisfaction == "callFake"
            return stubbing.thenThat(arguments...)
          else
            return stubbing.thenThat
        i++
      priorPlan.apply(spy, arguments)

  jasmine.Spy::whenContext = (context) ->
    spy = this
    spy._stealth_stubbings ||= []
    whatToDoWhenTheSpyGetsCalled(spy)
    stubChainer(spy, "context", context)

  jasmine.Spy::when = ->
    spy = this
    ifThis = jasmine.util.argsToArray(arguments)
    spy._stealth_stubbings ||= []
    whatToDoWhenTheSpyGetsCalled(spy)
    stubChainer(spy, "args", ifThis)

  stubChainer = (spy, type, ifThis) ->
    addStubbing = (satisfaction) ->
      (thenThat) ->
        spy._stealth_stubbings.unshift({type, ifThis, satisfaction, thenThat})
        spy

    thenReturn: addStubbing("return")
    thenCallFake: addStubbing("callFake")

  jasmine.Spy::mostRecentCallThat = (callThat, context) ->
    i = @calls.length - 1

    while i >= 0
      return @calls[i]  if callThat.call(context or this, @calls[i]) is true
      i--

  ## Matchers

  class jasmine.Matchers.ArgThat extends jasmine.Matchers.Any
    constructor: (matcher) ->
      @matcher = matcher

    jasmineMatches: (actual) ->
      @matcher(actual)

  jasmine.Matchers.ArgThat::matches = jasmine.Matchers.ArgThat::jasmineMatches #backwards compatibility for jasmine 1.1
  jasmine.argThat = (expected) -> new jasmine.Matchers.ArgThat(expected)

  class jasmine.Matchers.Capture extends jasmine.Matchers.Any
    constructor: (captor) ->
      @captor = captor

    jasmineMatches: (actual) ->
      @captor.value = actual
      true

  jasmine.Matchers.Capture::matches = jasmine.Matchers.Capture::jasmineMatches #backwards compatibility for jasmine 1.1

  class Captor
    capture: ->
      new jasmine.Matchers.Capture(@)

  jasmine.captor = () -> new Captor()
)()
