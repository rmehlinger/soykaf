$ = window.$ = window.jQuery = require 'jquery'
window._ = require 'underscore'
window.rx = require 'bobtail'
require 'jquery-serializejson'
bobtailForm = require('bobtail-form').default

{rxt, bind} = rx
R = rxt.tags
{groups, active} = require '../data/skills.js'
util = require '../util.coffee'

qualities = require '../data/qualities.js'
$qualityPicker = require('./qualityPicker.coffee').default
$personalData = require('./personalData.coffee').default
{$attrInput, $magicAttrInput} = require './attrInputs.coffee'
{$skillGroup, $skillsByType, $mkKnowledgeGrp} = require './skills.coffee'


exports.editNPC = (initial, submitFn) ->
  {$form} = bobtailForm (cell) ->
    cell.getData = (nonReact) ->
      if nonReact
        val = this.snapGet(nonReact)
        if not val?
          return deepGet this.data, nonReact
        else val
      else rx.snap => this.data
    magicType = bind -> cell.getData('priority.magic.attribute')?.name
    incompetentGroup = bind ->
      index = _.findIndex(cell.getData('qualities.negative')?.qualia, {name: 'Incompetent'})
      if index != -1 then cell.getData('qualities.negative')?.choice?[index]
      else null
    rx.autoSub incompetentGroup.onSet, ([o, n]) ->
      $("input[group='#{o}']").val(0).change()
      $("input[group='#{n}']").val(null).change()

    aptitude = bind ->
      index = _.findIndex cell.getData('qualities.positive')?.qualia ? [], ({name}) -> name == 'Aptitude'
      if index != -1
        return cell.getData('qualities.positive')?[index]?.choice
      return null
    return R.form {
      class: 'form'
      submit: ->
        try
          data = $(@).serializeJSON()
          submitFn data
        finally
          false
    }, rx.flatten bind -> [
      $personalData initial, bind -> cell.getData('priority.metatype')?.metatype
      R.div {class: 'row'}, [
        R.div {class: 'col-md-6'}, [
          R.h2 "Attributes "
          R.p {class: 'row'}, [
            $attrInput cell, initial, "body"
            $attrInput cell, initial, "agility"
            $attrInput cell, initial, "reaction"
            $attrInput cell, initial, "strength"
          ]
          R.p {class: 'row'}, [
            $attrInput cell, initial, "willpower"
            $attrInput cell, initial, "logic"
            $attrInput cell, initial, "intuition"
            $attrInput cell, initial, "charisma"
          ]
        ]
        R.div {class: 'col-md-6'}, [
          R.h2 "Special Attributes "
          R.div {class: 'row'}, [
            $attrInput cell, initial, "edge", "specialAttributes"
            $magicAttrInput cell, initial, "magic"
            $magicAttrInput cell, initial, "resonance"
          ]
        ]
      ]
      R.h2 "Qualities"
      R.div {class: 'row'}, [
        R.div {class: 'col-xs-6'}, $qualityPicker cell, initial, 'positive'
        R.div {class: 'col-xs-6'}, $qualityPicker cell, initial, 'negative'
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
                  .chain cell?.skills
                  .pairs()
                  .filter ([name, skill]) -> not cell.getData('skillGroups')?[skill?.group]
                  .pluck 1
                  .value()
                points = util.sum(_.pluck skills, 'rating')
                specialties = skills.filter(({specialties}) -> specialties?[0]?.length).length
                spent = points + specialties

                "(#{spent})"
            ]
            R.h4 rx.flatten [
              "groups: "
              "("
              bind -> util.sum _.values cell.data.skillGroups
              bind -> " / #{cell.getData('priority.skills')?.groups ? '??'})"
            ]
          ]
        ]
        R.div {class: 'row', style: {display: 'flex', 'flex-wrap': 'wrap'}}, do ->
          rx.flatten groups?.map (group) -> $skillGroup {cell, group, incompetentGroup, initial, aptitude, magicType}
        R.h4 "Others"
        R.div {class: 'row'}, rx.flatten (_
          .chain(active)
          .groupBy('type')
          .pairs()
          .sortBy(([type, skills]) -> -skills.length)
          .value()
        ).map ([type, skills]) -> bind -> $skillsByType {cell, type, skills, magicType, aptitude, initial}
      ]
      R.h2 rx.flatten [
        "Knowledge Skills"
        bind ->
          cap = ((cell.getData('attributes')?.logic ? 0) + (cell.getData('attributes')?.intuition ? 0)) * 2
          skills = _.chain(cell?.knowledge).values().flatten().value()
          total = util.sum(_.pluck skills, 'rating') + skills.filter(({specialties}) -> specialties?[0]?.length).length
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
      ]

      R.div {class: 'form-group save-row'},
        R.div {class: 'col-xs-12 col-md-offset-3 col-md-6'}, R.p R.button {type: 'Submit', class: 'btn btn-success btn-block'}, R.h5 "Save Character"
    ]
  return $form
