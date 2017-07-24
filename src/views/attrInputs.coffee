$ = require 'jquery'
_ = require 'underscore'
stringify = require 'json-stable-stringify'
_str = require 'underscore.string'

rx = require 'bobtail'
{rxt, bind} = rx
R = rxt.tags

{metatypeStats} = require '../data/character.js'
main = require './edit-character.coffee'

exports.$attrInput = (initial, subfield, field="attributes") ->
  metatypeAttr = bind -> metatypeStats[main.getData('priority.metatype')?.metatype]?.attributes?[subfield]
  max = bind ->
    base = metatypeAttr.get()?.limit ? 6
    index = _.findIndex(main.getData('qualities.positive')?.qualia, {name: 'Exceptional Attribute'})
    if index != -1 and main.getData('qualities.positive')?.choice?[index] == subfield
      base += 1
    base
  min = bind -> metatypeAttr.get()?.base ? 1
  $input = R.input.number {
    class: 'form-control input-sm'
    name: "#{field}[#{subfield.toLowerCase()}]:number"
    value: initial?[field]?[subfield] ? 1
    min: bind -> min.get()
    max: bind -> max.get()
  }

  rx.autoSub min.onSet, ([o, n]) ->
    if n > parseInt $input.val()
      $input.val n
      $input.change()
  rx.autoSub max.onSet, ([o, n]) ->
    if n < parseInt $input.val()
      $input.val n
      $input.change()

  return R.div {class: 'form-group attr-input-group'}, [
    R.label subfield
    R.span {class: 'input-group-sm input-group'}, [
      $input
      R.span {class: 'input-group-addon'}, bind -> "/#{max.get()}"
    ]
  ]

exports.$magicAttrInput = (initial, subfield) ->
  charMagic = bind -> main.getData('priority.magic')?.attribute
  max = bind ->
    index = _.findIndex(main.getData('qualities.positive')?.qualia, {name: 'Exceptional Attribute'})
    if index != -1 and main.getData('qualities.positive')?.choice?[index] == subfield then 7
    else 6

  min = bind -> charMagic.get()?.value
  $disabled = R.input.number {
    class: 'form-control input-sm'
    name: "specialAttributes[#{subfield.toLowerCase()}]:number"
    value: 0
    readonly: true
  }
  $input = R.input.number {
    class: 'form-control'
    name: "specialAttributes[#{subfield}]:number"
    value: initial?.specialAttributes?[subfield] ? 1
    min: bind -> min.get()
    max: bind -> max.get()
  }

  return R.div {class: 'form-group attr-input-group'}, [
    R.label subfield
    R.span {class: 'input-group-sm input-group'}, bind -> [
      if subfield == charMagic.get()?.name
        $input
        rx.autoSub min.onSet, ([o, n]) ->
          if n > parseInt $input.val()
            $input.val n
            $input.change()
        rx.autoSub max.onSet, ([o, n]) ->
          if n < parseInt $input.val()
            $input.val n
            $input.change()
        $input

      else $disabled
      R.span {class: 'input-group-addon'}, bind -> "/#{max.get()}"
    ]
  ]
