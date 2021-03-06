{noop,isString,clone} = require("./_helpers")
overlay = document.createElement "div"
s = overlay.style
s.position = "fixed"
s.top = "-10px"
s.left = 0
s.right = 0
s.height = "120vh"
s.willChange = "opacity"
stack = []
close = (e) ->
  if not e.defaultPrevented and (e.type == "click" or e.which == 27)
    if (li = getLastItem())? and not li.keepOpen
      li.close()
      e.preventDefault()
overlay.addEventListener "click", close
getLastItem = (steps = 1) -> stack[stack.length-steps]
attach = ->
  document.body.appendChild overlay
  document.addEventListener "keyup", close
detach = ->
  document.body.removeChild overlay
  document.removeEventListener "keyup", close
dEl = document.documentElement
getAnimateObj = (o, li, getViewportSize) ->
  if li?
    li.animation?.stop?()
  else
    li = opacity: 0, done: detach, allowScroll: true
    attach() if o.open
  if o.open
    duration = o.durationIn || 300
    source = li
    target = o
  else
    duration = o.durationOut || 200
    source = o
    target = li
  s = dEl.style
  if target.allowScroll
    s.overflow = null
    s.marginRight = null
  else
    s.marginRight = getViewportSize().width - dEl.clientWidth + "px"
    s.overflow = "hidden"
    
  target.animation =
    animate: o.animate
    el: overlay
    style:
      opacity: [source.opacity, target.opacity]
    init:
      backgroundColor: target.color || "black"
      zIndex: target.zIndex
    duration: duration
    done: target.done
  return target.animation
  
  
module.exports =

  mixins:[
    require("./animate")
    require("./getViewportSize")
    require("./path")
    require("./parseActive")
  ]

  methods:
    $overlay: (o) ->
      o ?= clone(@overlay) || {}
      o.activate = ->
        for k,v of {zIndex: 995, opacity: 0.5, keepOpen: false, animate: true}
          if (val = o[k])?
            o[k] = @$path.resolveValue(val)
          else
            o[k] = v
        o.open = true
        li = getLastItem()
        stack.push o
        o.close = =>
          o.close = noop
          return unless o.open
          o.open = false
          @$path.resolveValue(o.onClose)?.call(@)
          i = stack.indexOf o
          if i == stack.length - 1
            @$animate getAnimateObj(stack.pop(), getLastItem(),  @getViewportSize)
          else
            stack.splice i,1
        o.cancel = ->
          o.animation?.toEnd?()
        o.zIndex = Math.max o.zIndex, li.zIndex+5 if li?
        @$path.resolveValue(o.onOpen)?.call(@,o.zIndex)
        @$animate getAnimateObj(o, li, @getViewportSize)
        return o.close
      return @$parseActive(o)


  connectedCallback: ->
    if @_isFirstConnect and @overlay
      @$overlay(clone(@overlay))
    