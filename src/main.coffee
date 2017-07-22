$ = window.$ = window.jQuery = require 'jquery'
window._ = require 'underscore'
_str = require 'underscore.string'
window.rx = require 'bobtail'
require 'jquery-serializejson'
bobtailForm = require('bobtail-form').default
{rxt, bind} = rx
R = rxt.tags
priority = require './data/priority.js'
{groups, active, knowledge} = require './data/skills.js'
util = require './util.coffee'
window.rxStorage = require 'bobtail-storage'
stringify = require 'json-stable-stringify'

{attributeNames, metatypeStats} = require './data/character.js'
qualities = require './data/qualities.js'
deepGet = require 'lodash.get'
inputs = require './inputs.coffee'

curFormData = {}
getData = (nonReact) ->
  if nonReact
    val = rx.snap => deepGet curFormData, nonReact
    if not val?
      return deepGet curFormData, nonReact
    else val
  else rx.snap => curFormData


isSelected = (obj, field, priorityVal) -> obj.priority?[field]?.priorityVal == priorityVal

main = (initial) ->
  $priorityRadio = (field, priorityVal, choice) ->
    value = stringify(_.extend {priorityVal}, choice)

    return R.input.checkbox {
      name: "priority[#{field}]:object"
      value: JSON.stringify(_.extend {priorityVal}, choice)
      field
      priorityVal
      checked: do ->
        return value == stringify initial?.priority?[field]
      change: (event) -> rx.transaction ->
        if event.target.checked
          $radios = $("input[type=checkbox][priorityVal=#{priorityVal}]").add $("input[field=#{field}]")
          $radios.each (i, $radio) ->
            if $radio != event.target
              $($radio).prop 'checked', false
              $($radio).change()
        true
    }

  charPri = (field) ->
    base = getData("priority.#{field}")?.priorityVal
    if base then " (#{base})" else ""

  $priorityTable = () -> R.table {class: 'table priority-table'}, [
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
        R.td {class: bind -> if isSelected getData(), field, priorityVal then 'info'}, [
          choices.map (choice) -> R.div {class: 'checkbox'}, R.label [
            $priorityRadio field, priorityVal, choice
            fmtfn choice
          ]
        ]
      R.tr [
        R.th {style: width: 1}, rx.flatten [
          R.strong priorityVal
          bind ->
            field = _.chain(getData().priority).pairs().findWhere({1: priorityVal}).value()?[0]
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

  $qualityPicker = (qualType) ->
    initQuals = initial?.qualities?[qualType]
    rows = rx.array _.map initQuals?.qualia, (skill, i) -> _.extend {choice: initQuals?.choice?[i]}, skill
    selected = rx.array.from bind -> Array.from getData("qualities.#{qualType}")?.qualia ? []
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
              required: true
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

  $attrInput = (subfield, field="attributes") ->
    metatypeAttr = bind -> metatypeStats[getData('priority.metatype')?.metatype]?.attributes?[subfield]
    max = bind ->
      base = metatypeAttr.get()?.limit ? 6
      index = _.findIndex(getData('qualities.positive')?.qualia, {name: 'Exceptional Attribute'})
      if index != -1 and getData('qualities.positive')?.choice?[index] == subfield
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

  $magicAttrInput = (subfield) ->
    charMagic = bind -> getData('priority.magic')?.attribute
    max = bind ->
      index = _.findIndex(getData('qualities.positive')?.qualia, {name: 'Exceptional Attribute'})
      if index != -1 and getData('qualities.positive')?.choice?[index] == subfield then 7
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

  $skillWidget = ({name, group}, aptitude, incompetentGroup, groupScore=bind -> null) ->
    min = bind -> if name in (getData()?.freeSkills ? []) then getData('priority.magic.skills')?.rating else 0
    max = bind -> if aptitude.get() == name then 7 else 6
    $input = R.input.number {
      name: "skills[#{name}][rating]:number"
      value: initial?.skills?[name]?.rating ? 0
      class: 'form-control input-sm'
      min: bind -> min.get()
      max: bind -> max.get()
      readonly: bind -> not not groupScore.get() or (group and group == incompetentGroup.get())
      group
    }

    rx.autoSub min.onSet, rx.skipFirst ([o, n]) ->
      if n > parseInt $input.val()
        $input.val n
        $input.change()
    rx.autoSub max.onSet, rx.skipFirst ([o, n]) ->
      if n < parseInt $input.val()
        $input.val n
        $input.change()


    $specialty = R.input.text {
      name: "skills[#{name}][specialty][]:string"
      value: initial?.skills?[name]?.specialty?[0] ? ''
      class: 'form-control input-sm'
      disabled: bind -> not not groupScore.get() or (group and group == incompetentGroup.get())
      placeholder: 'specialty'
    }
    rx.autoSub groupScore.onSet, rx.skipFirst ([o, n]) ->
      if o? and n? then $input.val(n).change()
      if n then $specialty.val('').change()
    R.div {class: 'form-group'}, [
      R.div {class: 'col-xs-5 text-right'}, R.label {class: 'control-label'}, name
      R.div {class: 'col-xs-3'}, $input
      R.div {class: 'col-xs-4'}, $specialty
      R.input.hidden {name: "skills[#{name}][group]:string", value: group}
    ]

  $mkKnowledgeGrp = (category) ->
    rows = rx.array(initial?.knowledge?[category] ? [])
    R.div rx.flatten [
      R.h3 category
      rows.indexed().map (v, iCell) -> $knowlSkillRow category, iCell.raw(), (i) -> rows.removeAt i
      R.button {
        class: 'btn btn-primary btn-sm pull-right'
        type: 'button'
        click: -> rows.push {}
      }, "Add Skill"
    ]

  $knowlSkillRow = (category, i, rmFn) ->
    initRoot = initial?.knowledge?[category]?[i] ? {}
    return R.div {class: 'form-group'}, [
      R.div {class: 'col-xs-6'}, R.div {class: 'input-group input-group-sm'}, [
        R.span {class: 'input-group-btn'}, R.button {
          class: 'btn btn-danger btn-sm'
          type: 'button'
          click: -> rmFn i
        }, R.span {class: 'glyphicon glyphicon-remove'}
        R.input.text {
          name: "knowledge[#{category}][][name]:string"
          value: initRoot?.name ? ''
          class: 'form-control input-sm'
          placeholder: "subject"
          required: true
        }
      ]
      R.div {class: 'col-xs-2'}, R.input.number {
        name: "knowledge[#{category}][][rating]:number",
        value: initRoot?.rating ? 0
        class: 'form-control input-sm'
        min: 1  # a knowledge skill at rank 0 is one you don't have
        max: 6
      }
      R.div {class: 'col-xs-4'}, R.input.text {
        name: "knowledge[#{category}][][specialty][]:string"
        value: initRoot?.specialty?[0] ? ''
        class: 'form-control input-sm'
        placeholder: 'specialization'
      }
    ]

  {$form} = bobtailForm (cell) ->
    curFormData = rx.snap -> cell.data
    freeSkills = bind -> getData('priority.magic.skills')?.quantity ? 0
    freeSkillsCount = rx.array.from bind -> [0...freeSkills.get()]
    magicType = bind -> getData('priority.magic.attribute')?.name
    incompetentGroup = bind ->
      index = _.findIndex(getData('qualities.negative')?.qualia, {name: 'Incompetent'})
      if index != -1 then getData('qualities.negative')?.choice?[index]
      else null
    rx.autoSub incompetentGroup.onSet, ([o, n]) ->
      $("input[group='#{o}']").val(0).change()
      $("input[group='#{n}']").val('X').change()

    aptitude = bind ->
      index = _.findIndex getData('qualities.positive')?.qualia ? [], ({name}) -> name == 'Aptitude'
      return getData('qualities.positive')?.choice[index]
    return R.form {
      class: 'form'
      submit: ->
        rxStorage.local.setItem 'character', $(@).serializeJSON()
        return false
    }, rx.flatten bind -> [
      R.h2 "Personal Data"
      R.div {class: 'row'}, [
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Primary Name/Alias"
          R.input.text {
            class: 'form-control input-sm'
            name: 'personalData[primaryName]:string'
            value: initial?.personalData?.primaryName
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Other Name/Alias"
          R.input.text {
            class: 'form-control input-sm'
            name: 'personalData[secondaryName]:string'
            value: initial?.personalData?.secondaryName
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Metatype"
          R.input.text {
            class: 'form-control input-sm'
            disabled: true
            value: bind -> _str.capitalize getData('priority.metatype')?.metatype
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Ethnicity"
          R.input.text {
            class: 'form-control input-sm'
            name: 'personalData[ethnicity]:string'
            value: initial?.personalData?.ethnicity
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Gender"
          R.input.number {
            class: 'form-control input-sm'
            name: 'personalData[gender]:string'
            value: initial?.personalData?.gender
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Age"
          R.input.number {
            class: 'form-control input-sm'
            name: 'personalData[age]:string'
            value: initial?.personalData?.age
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Height"
          R.input.number {
            class: 'form-control input-sm'
            name: 'personalData[height]:string'
            value: initial?.personalData?.height
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Weight"
          R.input.number {
            class: 'form-control input-sm'
            name: 'personalData[weight]:string'
            value: initial?.personalData?.weight
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Hair"
          R.input.number {
            class: 'form-control input-sm'
            name: 'personalData[hair]:string'
            value: initial?.personalData?.hair
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Eyes"
          R.input.number {
            class: 'form-control input-sm'
            name: 'personalData[eyes]:string'
            value: initial?.personalData?.eyes
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Skin"
          R.input.number {
            class: 'form-control input-sm'
            name: 'personalData[skin]:string'
            value: initial?.personalData?.skin
          }
        ]
        R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
          R.label {class: 'control-label'}, "Build"
          R.input.number {
            class: 'form-control input-sm'
            name: 'personalData[build]:string'
            value: initial?.personalData?.height
          }
        ]
      ]
      R.div {class: 'row'}, [
        R.div {class: 'form-group col-md-6'}, [
          R.label {class: 'control-label'}, "Distinguishing Marks/Tattoos"
          R.textarea {
            rows: 4
            class: 'form-control input-sm'
            name: 'personalData[distinguishing]:string'
            value: initial?.personalData?.distinguishing
          }
        ]
        R.div {class: 'form-group col-md-6'}, [
          R.label {class: 'control-label'}, "Description"
          R.textarea {
            rows: 4
            class: 'form-control input-sm'
            name: 'personalData[description]:string'
            value: initial?.personalData?.description
          }
        ]
        R.div {class: 'form-group col-md-6'}, [
          R.label {class: 'control-label'}, "Backstory"
          R.textarea {
            rows: 4
            class: 'form-control input-sm'
            name: 'personalData[backstory]:string'
            value: initial?.personalData?.description
          }
        ]
        R.div {class: 'form-group col-md-6'}, [
          R.label {class: 'control-label'}, "Relationships"
          R.textarea {
            rows: 4
            class: 'form-control input-sm'
            name: 'personalData[backstory]:string'
            value: initial?.personalData?.relationships
          }
        ]
      ]
      R.h2 "Priority Table"
      R.div {class: 'row'}, R.div {class: 'col-xs-12'}, $priorityTable()
      R.h2 rx.flatten [
        "Attributes "
        R.strong bind ->
          base = util.sum attributeNames.map (attr) -> metatypeStats[getData('priority.metatype')?.metatype]?.attributes?[attr]?.base ? 1
          spent = util.sum(_.values curFormData.attributes) - base
          allowed = getData()?.priority?.attributes?.points
          R.span {class: bind -> if spent > allowed then "red" else ""}, [
            "("
            spent
            "/"
            allowed ? '??'
            ")"
          ]
      ]
      R.p {class: 'row'}, [
        $attrInput "body"
        $attrInput "agility"
        $attrInput "reaction"
        $attrInput "strength"
      ]
      R.p {class: 'row'}, [
        $attrInput "willpower"
        $attrInput "logic"
        $attrInput "intuition"
        $attrInput "charisma"
      ]
      R.h2 rx.flatten [
        "Special Attributes "
        R.strong bind ->
          base = 1 + (getData('priority.magic.attribute')?.value ? 0)
          if getData('priority.metatype')?.metatype == 'human' then base += 1
          spent = -base + util.sum _.values getData().specialAttributes
          allowed = getData('priority.metatype')?.special
          R.span {class: bind -> if spent > allowed then "red" else ""}, [
            "("
            spent
            "/"
            allowed ? '??'
            ")"
          ]
      ]
      R.div {class: 'row'}, [
        $attrInput "edge", "specialAttributes"
        $magicAttrInput "magic"
        $magicAttrInput "resonance"
      ]
      R.h2 "Qualities"
      R.div {class: 'row'}, [
        R.div {class: 'col-xs-6'}, $qualityPicker 'positive'
        R.div {class: 'col-xs-6'}, $qualityPicker 'negative'
      ]
      R.div {class: 'form-horizontal'}, rx.flatten [
        R.h2 "Active Skills"
        R.div {class: 'row'}, [
          R.div {class: 'col-sm-6'}, [
            R.h4 rx.flatten [
              "skills: "
              "("
              bind ->
                skills = _
                  .chain curFormData.skills
                  .pairs()
                  .filter ([name, skill]) -> not curFormData?.skillGroups?[skill?.group]
                  .pluck 1
                  .value()

                util.sum(_.pluck skills, 'rating') +
                  skills.filter(({specialty}) -> specialty?[0]?.length).length -
                  freeSkills.get() * getData('priority.magic.skills')?.rating ? 0
              bind -> " / #{getData('priority.skills')?.skills ?  '??'})"
            ]
            R.h4 rx.flatten [
              "groups: "
              "("
              bind -> util.sum _.values curFormData.skillGroups
              bind -> " / #{getData('priority.skills')?.groups ? '??'})"
            ]
          ]
          R.div {class: 'col-sm-6'}, bind -> freeSkillsCount.map (i) ->
            R.p {class: 'input-group input-group-sm'}, [
              R.span {class: 'input-group-addon'}, 'Free Skill'
              inputs.select {
                class: 'form-control input-sm'
                name: 'freeSkills[]:string'
              }, rx.flatten [
                inputs.option {}
                bind -> _.where(active, {type: if magicType.get() == 'magic' then 'magical' else 'resonance'}).map (skill) ->
                  inputs.option {value: skill.name, selected: initial?.freeSkills[i] == skill.name}, skill.name
              ]
              R.span {class: 'input-group-addon'}, bind -> getData('priority.magic.skills')?.rating
            ]
        ]
        R.div {class: 'row', style: {display: 'flex', 'flex-wrap': 'wrap'}}, do ->
          rx.flatten groups.map (group) ->
            skills = _.where(active, {group: group.name})
            mkgrp = -> R.div {class: 'col-lg-6 col-xs-12', style: {clear: 'right'}}, _.flatten [
              R.h4 {class: 'form-group'}, [
                R.div {class: 'col-xs-5'}, R.label {class: 'control-label'}, "#{group.name} (#{group.type[...3]})"
                R.div {class: 'col-xs-2'}, R.input.number {
                  name: "skillGroups[#{group.name}]:number"
                  min: 0
                  max: 6
                  value: initial?.skillGroups?[group.name] ? 0
                  class: 'form-control input-sm'
                  group: group.name
                  readonly: bind -> incompetentGroup.get() == group.name
                }
              ]
              skills.map (skill) -> $skillWidget skill, aptitude, incompetentGroup, bind -> curFormData?.skillGroups?[skill.group]
            ]
            bind ->
              if group.type not in ['magical', 'resonance'] or (
                group.type == 'magical' and magicType.get() == 'magic'
              ) or (
                group.type == 'resonance' and magicType.get() == 'resonance'
              )
                mkgrp()
              else null
        R.h4 "Others"
        R.div {class: 'row'}, rx.flatten (_
          .chain(active)
          .groupBy('type')
          .pairs()
          .sortBy(([type, skills]) -> -skills.length)
          .value()
        ).map ([type, skills]) -> bind ->
          R.div {class: 'col-lg-6 col-xs-12'}, bind ->
            if type != 'resonance' and (type != 'magical' or magicType.get() == 'magic') then [
              R.h4 "(#{type})"
              rx.flatten(skills).map (skill) ->
                bind ->
                  if not skill.group?
                    $skillWidget skill, aptitude
                  else null
            ]
            else null
      ]
      R.h2 rx.flatten [
        "Knowledge Skills"
        bind ->
          cap = ((getData('attributes')?.logic ? 0) + (getData('attributes')?.intuition ? 0)) * 2
          skills = _.chain(getData().knowledge).values().flatten().value()
          total = util.sum(_.pluck skills, 'rating') + skills.filter(({specialty}) -> specialty?[0]?.length).length
          return " (#{total} / #{cap})"
      ]
      R.div {class: 'form-horizontal'}, [
        R.div {class: 'row'}, [
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp "academic"
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp "interests"
        ]
        R.div {class: 'row'}, [
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp "professional"
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp "street"
        ]
        R.div {class: 'row'}, rx.flatten [
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp 'language'
          R.div {class: 'col-md-6'}, rx.flatten [
            R.h3 "native language(s)"
            bind -> [0..if _.findWhere(getData()?.qualities, {name: 'Bilingual'}) then 1 else 0].map -> R.div {class: 'form-group'}, [
              R.div {class: 'col-xs-4'}, R.input.text {
                placeholder: "native language"
                name: "nativeLang[][name]:string"
                class: 'form-control input-sm'
              }
              R.div {class: 'col-xs-2'}, R.input.text {
                class: 'form-control input-sm'
                value: 'N'
                readonly: true
              }
            ]
          ]
        ]
      ]
      R.h2 bind ->
        pos = bind -> util.sum _.pluck getData('qualities.positive')?.qualia, 'karma'
        neg = bind -> util.sum _.pluck getData('qualities.negative')?.qualia, 'karma'

        R.p "Spend Karma: (0/#{25 + neg.get() - pos.get()})"
      R.div {class: 'form-group'}, R.div {class: 'col-xs-12 col-md-offset-3 col-md-6'}, R.p R.button {type: 'Submit', class: 'btn btn-success btn-block'}, R.h4 "Save Character"
    ]
  return $form

$('body').append R.div {class: 'container'}, R.div {class: "row"}, R.div {class: 'col-xs-12'}, main rxStorage.local.getItem 'character'
