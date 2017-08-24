$ = require 'jquery'
_ = require 'underscore'
stringify = require 'json-stable-stringify'
_str = require 'underscore.string'

rx = require 'bobtail'
{rxt, bind} = rx
R = rxt.tags

{attributeNames} = require '../data/character.js'
{groups, active} = require '../data/skills.js'

util = require '../util.coffee'
priority = require '../data/priority.js'
qualities = require '../data/qualities.js'
inputs = require '../inputs.coffee'

main = require './edit-character.coffee'

exports.default = $qualityPicker = (initial, qualType) ->
  initQuals = initial?.qualities?[qualType]
  rows = rx.array _.map initQuals?.qualia, (skill, i) -> _.extend {choice: initQuals?.choice?[i]}, skill
  selected = rx.array.from bind -> Array.from main.getData("qualities.#{qualType}")?.qualia ? []
  selectedNames = bind -> _.pluck selected.all(), 'name'

  nameStem = "qualities[#{qualType}]"

  return [
    R.h3 rx.flatten [
      _str.capitalize qualType
      R.strong [
        "("
        bind -> util.sum _.pluck selected.all(), 'karma'
        "/25)"
      ]
    ]
    rows.indexed().map (val, iCell) ->
      otherNames = bind -> selectedNames.get().filter (e, i) -> i != iCell.get()
      $select = inputs.select {class: 'form-control input-sm', name: "#{nameStem}[qualia][]:object"},
        rx.flatten bind -> [
          qualities[qualType].map (qual) -> bind ->
            disable = bind -> qual.name in otherNames.get()
            return [
              if qual.multiple then [1..qual.multiple].map (mult) ->
                inputs.option {
                  value: JSON.stringify {karma: qual.karma * mult, name: qual.name, multiple: qual.multiple}
                  selected: val?.name == qual.name and val.multiple == qual.multiple
                  title: qual.description
                  disabled: bind -> disable.get()
                }, "#{qual.name} x #{mult} (#{qual.karma * mult})"
              else
                inputs.option {
                  value: JSON.stringify qual
                  selected: val?.name == qual.name
                  title: qual.description
                  disabled: bind -> disable.get()
                }, "#{qual.name} (#{qual.karma})"
            ]
      ]

      subchoices = bind ->
        qual = JSON.parse($select.rx('val').get())
        sub = qual?.select
        if sub == 'skill' then active.map ({name, group}) -> {
          value: name, description: _str.capitalize(name) + if group then " (#{group})" else ""
        }
        else if sub == 'skill group' then groups.map (group) -> {
          value: group.name
          description: _str.capitalize group.name
        }
        else if qual.name == 'Exceptional Attribute'
          attributeNames.concat(['magic', 'resonance']).map (attr) -> {
            value: attr
            description: _str.capitalize attr
          }
        else if _.isArray sub then sub.map (value) -> {value, description: _str.capitalize value}
        else if sub == 'playerDescribed' then 'text'
        else return null

      R.p {class: 'row'}, [
        R.div {class: 'col-xs-7'}, R.div {class: 'input-group input-group-sm'}, [
          R.span {class: 'input-group-btn'}, R.button {
            type: 'button', class: 'btn btn-danger'
            click: -> rows.removeAt iCell.raw()
          }, R.span {class: 'glyphicon glyphicon-remove'}
          $select
        ]
        R.div {class: 'col-xs-5'}, bind ->
          opts = {
            name: "#{nameStem}[choice][#{iCell.get()}]:string"
            class: 'form-control input-sm'
          }
          $text = R.input.text _.extend {value: val?.choice}, opts
          $subSelect = inputs.select opts, rx.flatten [
            inputs.option {}
            subchoices.get()?.map? ({value, description}) -> inputs.option {
              value
              selected: value == val?.choice
            }, description
          ]
          bind ->
            if subchoices.get() == 'text' then $text
            else if _.isArray subchoices.get() then $subSelect
            else ''
      ]
    R.button {class: 'btn btn-primary pull-right', type: 'button', click: -> rows.push null}, "Add Quality"
  ]
