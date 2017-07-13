$ = window.$ = window.jQuery = require 'jquery'
window._ = require 'underscore'
_str = require 'underscore.string'
rx = require 'bobtail'
require 'jquery-serializejson'
bobtailForm = require('bobtail-form').default
{deepBind, rxt, bind} = rx
R = rxt.tags
priority = require './data/priority.js'
{rxForm} = require './rx-form.js'
util = require './util.coffee'

{attributeNames, metatypeStats} = require './data/character.js'
qualities = require './data/qualities.js'

main = ->
  {$form} = bobtailForm (cell) ->
    curFormData = cell.data
    return R.form {
      class: 'form'
      submit: ->
    }, bind -> [
      R.h2 "Priority Table"
      R.div {class: 'row'}, R.div {class: 'col-sm-12'}, $priorityTable curFormData
      R.h2 rx.flatten [
        "Attributes "
        R.strong bind ->
          base = util.sum attributeNames.map (attr) -> metatypeStats[curFormData.metatype]?.attributes?[attr]?.base ? 1
          spent = util.sum(_.values curFormData.attributes) - base
          allowed = priority.attributes[curFormData.priority?.attributes]
          R.span {class: bind -> if spent > allowed then "red" else ""}, [
            "("
            spent
            "/"
            allowed ? '??'
            ")"
          ]
      ]
      R.p {class: 'row'}, [
        $attrInput "body", curFormData
        $attrInput "agility", curFormData
        $attrInput "reaction", curFormData
        $attrInput "strength", curFormData
      ]
      R.p {class: 'row'}, [
        $attrInput "willpower", curFormData
        $attrInput "logic", curFormData
        $attrInput "intuition", curFormData
        $attrInput "charisma", curFormData
      ]
      R.h2 rx.flatten [
        "Special Attributes "
        R.strong bind ->
          base = 1 + (curFormData.startingMagic?.attribute?.value ? 0)
          if curFormData.metatype == 'human' then base += 1
          spent = -base + util.sum _.values curFormData.specialAttributes
          allowed = curFormData.specialPoints
          R.span {class: bind -> if spent > allowed then "red" else ""}, [
            "("
            spent
            "/"
            allowed ? '??'
            ")"
          ]
      ]
      R.div {class: 'row'}, [
        $attrInput "edge", curFormData, "specialAttributes"
        $magicAttrInput "magic", curFormData
        $magicAttrInput "resonance", curFormData
      ]
      R.h2 "Qualities"
      R.div {class: 'row'}, [
        R.div {class: 'col-sm-6'}, $qualityPicker curFormData, 'positive'
        R.div {class: 'col-sm-6'}, $qualityPicker curFormData, 'negative'
      ]
      R.h2 "Skills"
      R.h2 bind ->
        pos = bind -> util.sum _.pluck curFormData.qualities?.positive, 'karma'
        neg = bind -> util.sum _.pluck curFormData.qualities?.negative, 'karma'

        "Spend Karma: (0/#{25 + neg.get() - pos.get()})"
    ]
  console.info($form)
  return $form

$priorityTable = (charMap) -> R.table {class: 'table priority-table'}, [
  R.thead R.tr [
    R.th "Priority"
    R.th bind -> ["Metatype", if charMap.priority?.metatype then " (#{charMap.priority?.metatype})" else ""]
    R.th bind -> ["Attributes", if charMap.priority?.attributes then " (#{charMap.priority?.attributes})" else ""]
    R.th bind -> ["Magic/Resonance", if charMap.priority?.magic then " (#{charMap.priority?.magic})" else ""]
    R.th bind -> ["Skills", if charMap.priority?.skills then " (#{charMap.priority?.skills})" else ""]
    R.th bind -> ["Resources", if charMap.priority?.resources then " (#{charMap.priority?.resources})" else ""]
  ]
  R.tbody ["A", "B", "C", "D", "E"].map (priorityVal) ->
    $priorityRadio = (field) -> R.input.checkbox {
      name: "priority[#{field}]:string"
      class: "priority"
      field
      value: priorityVal
      change: (event) -> rx.transaction ->
        if event.target.checked
          $radios = $("input.priority[type=checkbox][value=#{priorityVal}]").add $("input[type=checkbox][field=#{field}]")
          $radios.each (i, $radio) ->
            if $radio != event.target
              $($radio).prop 'checked', false
              $($radio).change()
        true

    }
    cellClass = (field) -> bind ->
      if charMap.priority?[field] == priorityVal
        return 'info'
      else ''
    R.tr [
      R.th rx.flatten [
        R.strong priorityVal
        bind ->
          field = _.chain(charMap.priority).pairs().findWhere({1: priorityVal}).value()?[0]
          if field then " (#{field})" else ""
      ]
      R.td {class: cellClass 'metatype'}, priority.metatype[priorityVal].map ({metatype, special}) -> R.div {class: 'checkbox'}, R.label do ->
        $metatype = $priorityRadio 'metatype'
        return rx.flatten [
          $metatype
          R.input.checkbox {
            name: "metatype:string"
            value: metatype
            checked: bind -> $metatype.rx('checked').get()
            class: 'hidden'
          }
          R.input.checkbox {
            name: "specialPoints:number"
            value: special
            checked: bind -> $metatype.rx('checked').get()
            class: 'hidden'
          }
          "#{metatype} (#{special})"
        ]
      R.td {class: cellClass 'attributes'}, R.div {class: 'checkbox'}, R.label [
        $priorityRadio 'attributes'
        priority.attributes[priorityVal]
      ]
      R.td {class: cellClass 'magic'}, priority.magic[priorityVal].map ({type, skills, spells, attribute}) ->
        $magic = $priorityRadio 'magic'
        R.div {class: 'checkbox'}, R.label rx.flatten [
          $magic
          bind -> if $magic.rx('checked').get() then [
            R.input.hidden {
              name: "startingMagic:object"
              value: JSON.stringify {type, skills, spells, attribute}
            }
          ]
          R.strong "#{type}: "
          if attribute then "#{attribute.name} #{attribute.value}"
          if skills then ", #{skills.quantity} Rating #{skills.rating} #{skills.type} skill#{if not skills.group then 's' else ' group'}"
          if spells then ", #{spells} spells"
        ]
      R.td {class: cellClass 'skills'}, R.div {class: 'checkbox'}, R.label [
        $priorityRadio 'skills'
        "#{priority.skills[priorityVal].skills}/#{priority.skills[priorityVal].groups}"
      ]
      R.td {class: cellClass 'resources'}, R.div {class: 'checkbox'}, R.label [
        $priorityRadio 'resources'
        "#{priority.resources[priorityVal]}¥"
      ]
    ]
  ]

$qualityPicker = (charMap, qualType) ->
  rows = rx.array [{}]
  selected = bind -> charMap.qualities?[qualType] ? []
  selectedNames = bind -> _.pluck selected.all(), 'name'


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
      selectedQuality = bind -> selected.get()?[iCell.get()]
      choices = rx.array.from bind -> selectedQuality.get()?.select ? []

      $select = R.select {class: 'form-control', name: "qualities[#{qualType}][]:object"},
        rx.flatten qualities[qualType].map (qual) ->
          if qual.multiple then [1..qual.multiple].map (mult) ->
            R.option {
              value: JSON.stringify {karma: qual.karma * mult, name: qual.name}
              title: qual.description
              disabled: bind -> qual.name in selectedNames.get() and qual.name != selectedQuality.get()?.name
            }, "#{qual.name} x #{mult} (#{qual.karma * mult})"
          else
            R.option {
              value: JSON.stringify qual
              title: qual.description
              disabled: bind -> qual.name in selectedNames.get() and qual.name != selectedQuality.get()?.name
            }, "#{qual.name} (#{qual.karma})"
      R.p {class: 'row'}, [
        R.div {class: 'col-sm-4'}, $select
        R.div {class: 'col-sm-4'}, bind ->
          if choices.length()
            R.select {
              name: "qualities[#{qualType}][][choice]:string"
              class: 'form-control'
            }, bind -> choices.get().map (choice) ->
              R.option {value: choice.name, title: choice.description}, choice.name
          else ""
        R.div {class: 'col-sm-2'}, R.button {
          type: 'button', class: 'btn btn-default'
          click: -> rows.removeAt iCell.raw()
        }, R.div {class: "glyphicon glyphicon-remove"}
      ]
    R.button {class: 'btn btn-primary', type: 'button', click: -> rows.push {}}, "Add Quality"
  ]


$attrInput = (subfield, character, field="attributes") ->
  max = bind -> metatypeStats[character.metatype]?.attributes?[subfield]?.limit ? 6
  min = bind -> metatypeStats[character.metatype]?.attributes?[subfield]?.base ? 1
  $input = R.input.number {
    class: 'form-control'
    name: "#{field}[#{subfield.toLowerCase()}]:number"
    value: 1
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

$magicAttrInput = (subfield, character) ->
  charMagic = bind -> character.startingMagic?.attribute?.name
  max = bind -> 6
  min = bind -> character.startingMagic?.attribute?.value
  return R.div {class: 'form-group attr-input-group'}, [
    R.label subfield
    R.span {class: 'input-group-sm input-group'}, rx.flatten [
      bind ->
        if subfield == charMagic.get()
          $input = R.input.number {
            class: 'form-control'
            name: "specialAttributes[#{subfield}]:number"
            value: 1
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
          $input

        else R.input.number {
          class: 'form-control'
          name: "specialAttributes[#{subfield.toLowerCase()}]:number"
          value: 0
          readonly: true
        }
      R.span {class: 'input-group-addon'}, bind -> "/#{max.get()}"
    ]
  ]

$('body').append R.div {class: 'container-fluid'}, R.div {class: "row"}, R.div {class: 'col-sm-12'}, main()

`$('body').append(
  bobtailForm(jsonCell => R.form([
    R.input.number({name: 'base:number', value: 3}),
    R.input.number({name: 'exponent:number', value: 2}),
    R.strong(bind(() => jsonCell.data.base ** jsonCell.data.exponent))
  ])).$form
)`