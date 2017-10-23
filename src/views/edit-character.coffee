$ = window.$ = window.jQuery = require 'jquery'
window._ = require 'underscore'
window.rx = require 'bobtail'
require 'jquery-serializejson'
bobtailForm = require('bobtail-form').default

{rxt, bind} = rx
R = rxt.tags
{groups, active} = require '../data/skills.js'
util = require '../util.coffee'

{attributeNames, metatypeStats} = require '../data/character.js'
qualities = require '../data/qualities.js'
window.deepGet = require 'lodash.get'

$priorityTable = require('./priorityTable.coffee').default
$qualityPicker = require('./qualityPicker.coffee').default
$personalData = require('./personalData.coffee').default
{$attrInput, $magicAttrInput} = require './attrInputs.coffee'
{$freeSkill, $skillGroup, $skillsByType, $mkKnowledgeGrp} = require './skills.coffee'


exports.editCharacter = (initial, submitFn) ->
  {$form} = bobtailForm (cell) ->
    cell.getData = (nonReact) ->
      if nonReact
        val = this.snapGet(nonReact)
        if not val?
          return deepGet this.data, nonReact
        else val
      else rx.snap => this.data
    contactSpent = bind -> util.sum(_.pluck cell.data.contacts, 'loyalty') + util.sum(_.pluck cell.data.contacts, 'connection')
    contactPoints = bind -> 3 * cell.getData('attributes')?.charisma ? 0
    freeSkills = bind -> cell.getData('priority.magic.skills')?.quantity ? 0
    freeSkillsCount = rx.array.from bind -> [0...freeSkills.get()]
    magicType = bind -> cell.getData('priority.magic.attribute')?.name
    incompetentGroup = bind ->
      index = _.findIndex(cell.getData('qualities.negative')?.qualia, {name: 'Incompetent'})
      if index != -1 then cell.getData('qualities.negative')?.choice?[index]
      else null
    rx.autoSub incompetentGroup.onSet, ([o, n]) ->
      $("input[group='#{o}']").val(0).change()
      $("input[group='#{n}']").val(null).change()

    aptitude = bind ->
      index = _.findIndex cell.getData('qualities.positive')?.qualia ? [], (qual) -> qual?.name == 'Aptitude'
      if index != -1
        return util.logReturn cell.getData('qualities.positive.choice')?[index]
      return null

    return R.form {
      class: 'form'
      submit: (event) ->
        event.preventDefault()
        event.stopPropagation()
        formData = $(@).serializeJSON()
        submitFn formData
        false
    }, rx.flatten bind -> [
      $personalData initial, bind -> cell.getData('priority.metatype')?.metatype
      R.h2 "Priority Table"
      R.div {class: 'row'}, R.div {class: 'col-xs-12'}, $priorityTable cell, initial
      R.div {class: 'row'}, [
        R.div {class: 'col-md-6'}, [
          R.h2 rx.flatten [
            "Attributes "
            R.strong bind ->
              base = util.sum attributeNames?.map (attr) -> metatypeStats[cell.getData('priority.metatype')?.metatype]?.attributes?[attr]?.base ? 1
              spent = util.sum(_.values cell.data.attributes) - base
              allowed = cell.getData('priority.attributes')?.points
              R.span {class: bind -> if spent > allowed then "red" else ""}, [
                "("
                spent
                "/"
                allowed ? '??'
                ")"
              ]
          ]
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
          R.h2 rx.flatten [
            "Special Attributes "
            R.strong bind ->
              base = 1 + (cell.getData('priority.magic.attribute')?.value ? 0)
              if cell.getData('priority.metatype')?.metatype == 'human' then base += 1
              spent = -base + util.sum _.values cell.data.specialAttributes
              allowed = cell.getData('priority.metatype')?.special
              R.span {class: bind -> if spent > allowed then "red" else ""}, [
                "("
                spent
                "/"
                allowed ? '??'
                ")"
              ]
          ]
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
                  .chain cell.getData()?.skills
                  .pairs()
                  .filter ([name, skill]) -> not cell.getData(['skillGroups', skill])?.group
                  .pluck 1
                  .value()
                points = util.sum(_.pluck skills, 'rating')
                specialties = skills.filter(({specialties}) -> specialties?[0]?.length).length
                free = (cell.getData()?.freeSkills?.filter(_.identity).length ? 0) *
                  (cell.getData('priority.magic.skills')?.rating ? 0)

                spent = points + specialties - free

                "#{spent} / #{cell.getData('priority.skills')?.skills ?  '??'})"
            ]
            R.h4 rx.flatten [
              "groups: "
              "("
              bind -> util.sum _.values cell.getData()?.skillGroups
              bind -> " / #{cell.getData('priority.skills')?.groups ? '??'})"
            ]
          ]
          R.div {class: 'col-sm-6'}, bind -> freeSkillsCount.map (i) -> $freeSkill cell, i, initial, magicType
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
          skills = _.chain(cell.getData()?.knowledge).values().flatten().value()
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
        R.div {class: 'row'}, rx.flatten [
          R.div {class: 'col-md-6'}, $mkKnowledgeGrp 'language', initial
          R.div {class: 'col-md-6'}, rx.flatten [
            R.h3 "native language(s)"
            bind -> [0..if _.findWhere(cell.getData('qualities.positive')?.qualia, {name: 'Bilingual'}) then 1 else 0].map -> R.div {class: 'form-group'}, [
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
        pos = bind -> util.sum _.pluck cell.getData('qualities.positive')?.qualia, 'karma'
        neg = bind -> util.sum _.pluck cell.getData('qualities.negative')?.qualia, 'karma'
        contactsOver = bind -> Math.max 0, contactSpent.get() - contactPoints.get()
        R.p "Spend Karma: (#{contactsOver.get()} / #{25 + neg.get() - pos.get()})"

      R.div {class: 'row'}, do ->
        contacts = rx.array initial?.contacts ? []
        R.div {class: 'col-md-6'}, rx.flatten [
          R.h3 bind -> "Contacts: (#{contactSpent.get()} / #{contactPoints.get()} free)"
          R.small "Max 7 karma per contact"
          R.div {class: 'row'}, [
            R.div {class: 'col-sm-8'}, R.label {class: 'control-label'}, "Name"
            R.div {class: 'col-sm-2'}, R.label {class: 'control-label'}, "Connection"
            R.div {class: 'col-sm-2'}, R.label {class: 'control-label'}, "Loyalty"
          ]

          R.div {class: 'form-horizontal'}, contacts.indexed().map (contact, iCell) ->
            $name = R.input.text {
              value: contact?.name
              name: 'contacts[][name]:string',
              class: 'form-control input-sm'
            }
            $connection = R.input.number {
              value: contact?.connection ? 1
              min: 1
              max: bind -> 7 - cell.data.contacts?[iCell.get()]?.loyalty ? 1
              name: 'contacts[][connection]:number'
              class: 'form-control input-sm'
            }
            $loyalty = R.input.number {
              value: contact?.loyalty ? 1
              min: 1
              max: bind -> 7 - cell.data.contacts?[iCell.get()]?.connection ? 1
              name: 'contacts[][loyalty]:number'
              class: 'form-control input-sm'
            }
            R.div {class: 'form-group'}, [
              R.div {class: 'col-sm-7'}, R.span {class: 'input-group'}, [
                R.span {class: 'input-group-btn'}, R.button {
                  type: 'button', class: 'btn btn-danger btn-sm'
                  click: -> contacts.removeAt iCell.raw()
                }, R.span {class: 'glyphicon glyphicon-remove'}
                $name
              ]
              R.div {class: 'col-sm-3 text-right'}, $connection
              R.div {class: 'col-sm-2 text-right'}, $loyalty
            ]
          R.button {type: 'button', class: 'btn btn-primary btn-sm pull-right', click: -> contacts.push {}}, "Add Contact"
        ]

      R.div {class: 'form-group save-row'},
        R.div {class: 'col-xs-12 col-md-offset-3 col-md-6'}, R.p R.button {type: 'Submit', class: 'btn btn-success btn-block'}, R.h5 "Save Character"
    ]
  return $form
