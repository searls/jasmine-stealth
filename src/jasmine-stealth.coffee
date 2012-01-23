###
jasmine-stealth Makes Jasmine spies a bit more robust
site: https://github.com/searls/jasmine-stealth
###
isFunction = (thing) ->
  Object::toString.call(thing) is "[object Function]"

beforeEach ->
  @stubFor = @spyOn

jasmine.createStub = jasmine.createSpy
jasmine.createStubObj = (baseName, stubbings) ->
  if stubbings.constructor is Array
    jasmine.createSpyObj baseName, stubbings
  else
    obj = {}
    for name of stubbings
      stubbing = stubbings[name]
      obj[name] = jasmine.createSpy(baseName + "." + name)
      if isFunction(stubbing)
        obj[name].andCallFake stubbing
      else
        obj[name].andReturn stubbing
    obj

jasmine.Spy::when = ->
  spy = this
  ifThis = jasmine.util.argsToArray(arguments)
  spy._stealth_stubbings = spy._stealth_stubbings or []
  priorStubbing = spy.plan()
  spy.andCallFake ->
    i = 0

    while i < spy._stealth_stubbings.length
      stubbing = spy._stealth_stubbings[i]
      if jasmine.getEnv().equals_(stubbing.ifThis, jasmine.util.argsToArray(arguments))
        if Object::toString.call(stubbing.thenThat) is "[object Function]"
          return stubbing.thenThat()
        else
          return stubbing.thenThat
      i++
    priorStubbing

  addStubbing = (thenThat) ->
    spy._stealth_stubbings.push
      ifThis: ifThis
      thenThat: thenThat

    spy

  thenReturn: addStubbing
  thenCallFake: addStubbing

jasmine.Spy::mostRecentCallThat = (callThat, context) ->
  i = @calls.length - 1

  while i >= 0
    return @calls[i]  if callThat.call(context or this, @calls[i]) is true
    i--

class jasmine.Matchers.ArgThat extends jasmine.Matchers.Any
  constructor: (matcher) ->
    @matcher = matcher

  matches: (actual) ->
    @matcher(actual)

jasmine.argThat = (expected) -> new jasmine.Matchers.ArgThat(expected)
