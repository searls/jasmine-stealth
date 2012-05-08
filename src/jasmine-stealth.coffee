###
jasmine-stealth @@VERSION@@
Makes Jasmine spies a bit more robust
site: https://github.com/searls/jasmine-stealth
###
root = this

isFunction = (thing) ->
  Object::toString.call(thing) is "[object Function]"


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
      if isFunction(stubbing)
        obj[name].andCallFake stubbing
      else
        obj[name].andReturn stubbing
    obj

whatToDoWhenTheSpyGetsCalled = (spy) ->
  matchesStub = (stubbing,args,context) ->
    switch stubbing.type
      when "args" then jasmine.getEnv().equals_(stubbing.ifThis, jasmine.util.argsToArray(args))
      when "context" then jasmine.getEnv().equals_(stubbing.ifThis,context)

  priorStubbing = spy.plan()
  spy.andCallFake ->
    i = 0
    while i < spy._stealth_stubbings.length
      stubbing = spy._stealth_stubbings[i]
      if matchesStub(stubbing,arguments,this)
        if Object::toString.call(stubbing.thenThat) is "[object Function]"
          return stubbing.thenThat()
        else
          return stubbing.thenThat
      i++
    priorStubbing


jasmine.Spy::whenContext = (context) ->
  spy = this
  spy._stealth_stubbings ||= []
  whatToDoWhenTheSpyGetsCalled(spy)

  addStubbing = (thenThat) ->
    spy._stealth_stubbings.push
      type: 'context'
      ifThis: context
      thenThat: thenThat
    spy

  thenReturn: addStubbing
  thenCallFake: addStubbing


jasmine.Spy::when = ->
  spy = this
  ifThis = jasmine.util.argsToArray(arguments)
  spy._stealth_stubbings ||= []
  whatToDoWhenTheSpyGetsCalled(spy)

  addStubbing = (thenThat) ->
    spy._stealth_stubbings.push
      type: 'args'
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

## Matchers

class jasmine.Matchers.ArgThat extends jasmine.Matchers.Any
  constructor: (matcher) ->
    @matcher = matcher

  matches: (actual) ->
    @matcher(actual)

jasmine.argThat = (expected) -> new jasmine.Matchers.ArgThat(expected)


class jasmine.Matchers.Capture extends jasmine.Matchers.Any
  constructor: (captor) ->
    @captor = captor

  matches: (actual) ->
    @captor.value = actual
    true

class Captor
  capture: ->
    new jasmine.Matchers.Capture(@)

jasmine.captor = () -> new Captor()
