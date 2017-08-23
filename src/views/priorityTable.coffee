$ = require 'jquery'
_ = require 'underscore'
stringify = require 'json-stable-stringify'

rx = require 'bobtail'
{rxt, bind} = rx
R = rxt.tags

util = require '../util.coffee'
priority = require '../data/priority.js'
qualities = require '../data/qualities.js'
inputs = require '../inputs.coffee'


main = require './edit-character.coffee'

$priorityRadio = (initial, field, priorityVal, choice) ->
  value = stringify(_.extend {priorityVal}, choice)

  return R.input.checkbox {
    name: "priority[#{field}]:object"
    value: JSON.stringify(_.extend {priorityVal}, choice)
    field
    priorityVal
    checked: value == stringify initial?.priority?[field]
    change: (event) -> rx.transaction ->
      if event.target.checked
        $radios = $("input[type=checkbox][priorityVal=#{priorityVal}]").add $("input[field=#{field}]")
        $radios.each (i, $radio) ->
          if $radio != event.target
            $($radio).prop 'checked', false
            $($radio).change()
      true
  }



isSelected = (obj, field, priorityVal) -> obj.priority?[field]?.priorityVal == priorityVal

charPri = (field) ->
  base = main.getData("priority.#{field}")?.priorityVal
  if base then " (#{base})" else ""

exports.default = (initial) -> R.table {class: 'table priority-table'}, [
  R.thead R.tr bind -> [
    R.th {class: 'priority'}, "Priority"
    R.th {class: "metatype"}, bind -> ["Metatype", charPri "metatype"]
    R.th {class: "attributes"}, bind -> ["Attributes", charPri "attributes"]
    R.th {class: "magic"}, bind -> ["Magic/Resonance", charPri "magic"]
    R.th {class: 'skills'}, bind -> ["Skills", charPri 'skills']
    R.th {class: 'resources'}, bind -> ["Resources", charPri 'resources']
  ]
  R.tbody ["A", "B", "C", "D", "E"].map (priorityVal) ->
    tdFn = (field, fmtfn) ->
      choices = priority[field][priorityVal]
      R.td {class: bind -> if isSelected main.getData(), field, priorityVal then 'info'}, [
        choices.map (choice) -> R.div {class: 'checkbox'}, R.label [
          $priorityRadio initial, field, priorityVal, choice
          fmtfn choice
        ]
      ]
    R.tr [
      R.th {style: width: 1}, rx.flatten [
        R.strong priorityVal
        bind ->
          field = _.chain(main.getData().priority).pairs().findWhere({1: priorityVal}).value()?[0]
          if field then " (#{field})" else ""
      ]
      tdFn 'metatype', ({metatype, special}) -> "#{metatype} (#{special})"
      tdFn 'attributes', _.property 'points'
      tdFn 'magic', ({type, attribute, skills, spells}) ->
        if type then return [
          type
          if attribute then ": #{attribute.name} #{attribute.value}"
          if skills then ", #{skills.quantity} Rating #{skills.rating} #{skills.type} skill#{if not skills.group then 's' else ' group'}"
          if spells then ", #{spells} spells"
        ]
        else "(none)"
      tdFn 'skills', ({skills, groups}) -> "#{skills}/#{groups}"
      tdFn 'resources', ({nuyen}) -> "#{nuyen}¥"
    ]
  ]
