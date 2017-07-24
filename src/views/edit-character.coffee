$ = window.$ = window.jQuery = require 'jquery'
window._ = require 'underscore'
_str = require 'underscore.string'
window.rx = require 'bobtail'
require 'jquery-serializejson'
bobtailForm = require('bobtail-form').default
{rxt, bind} = rx
R = rxt.tags
priority = require '../data/priority.js'
{groups, active, knowledge} = require '../data/skills.js'
util = require '../util.coffee'
window.rxStorage = require 'bobtail-storage'
stringify = require 'json-stable-stringify'

{attributeNames, metatypeStats} = require '../data/character.js'
qualities = require '../data/qualities.js'
deepGet = require 'lodash.get'
inputs = require '../inputs.coffee'

$priorityTable = require('./priorityTable.coffee').default
$qualityPicker = require('./qualityPicker.coffee').default
$personalData = require('./personalData.coffee').default
{$attrInput, $magicAttrInput} = require './attrInputs.coffee'
{$freeSkill, $skillGroup, $skillsByType, $mkKnowledgeGrp} = require './skills.coffee'

curFormData = {}
exports.getData = getData = (nonReact) ->
  if nonReact
    val = rx.snap => deepGet curFormData, nonReact
    if not val?
      return deepGet curFormData, nonReact
    else val
  else rx.snap => curFormData


exports.editCharacter = (initial) ->
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
      $personalData initial, bind -> getData('priority.metatype')?.metatype
      R.h2 "Priority Table"
      R.div {class: 'row'}, R.div {class: 'col-xs-12'}, $priorityTable initial
      R.div {class: 'row'}, [
        R.div {class: 'col-md-6'}, [
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
            $attrInput initial, "body"
            $attrInput initial, "agility"
            $attrInput initial, "reaction"
            $attrInput initial, "strength"
          ]
          R.p {class: 'row'}, [
            $attrInput initial, "willpower"
            $attrInput initial, "logic"
            $attrInput initial, "intuition"
            $attrInput initial, "charisma"
          ]
        ]
        R.div {class: 'col-md-6'}, [
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
            $attrInput initial, "edge", "specialAttributes"
            $magicAttrInput initial, "magic"
            $magicAttrInput initial, "resonance"
          ]
        ]
      ]
      R.h2 "Qualities"
      R.div {class: 'row'}, [
        R.div {class: 'col-xs-6'}, $qualityPicker initial, 'positive'
        R.div {class: 'col-xs-6'}, $qualityPicker initial, 'negative'
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
                  .chain getData()?.skills
                  .pairs()
                  .filter ([name, skill]) -> not getData('skillGroups')?[skill?.group]
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
          R.div {class: 'col-sm-6'}, bind -> freeSkillsCount.map (i) -> $freeSkill i, initial, magicType
        ]
        R.div {class: 'row', style: {display: 'flex', 'flex-wrap': 'wrap'}}, do ->
          rx.flatten groups.map (group) -> $skillGroup {group, incompetentGroup, initial, aptitude, magicType}
        R.h4 "Others"
        R.div {class: 'row'}, rx.flatten (_
          .chain(active)
          .groupBy('type')
          .pairs()
          .sortBy(([type, skills]) -> -skills.length)
          .value()
        ).map ([type, skills]) -> bind -> $skillsByType {type, skills, magicType, aptitude, initial}
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
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp "academic", initial
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp "interests", initial
        ]
        R.div {class: 'row'}, [
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp "professional", initial
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp "street", initial
        ]
        R.div {class: 'row'}, rx.flatten [
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp 'language', initial
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
      R.div {class: 'form-group save-row'},
        R.div {class: 'col-xs-12 col-md-offset-3 col-md-6'}, R.p R.button {type: 'Submit', class: 'btn btn-success btn-block'}, R.h5 "Save Character"
    ]
  return $form
