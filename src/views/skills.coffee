_ = require 'underscore'
stringify = require 'json-stable-stringify'

rx = require 'bobtail'
{rxt, bind} = rx
R = rxt.tags

{active, knowledge} = require '../data/skills.js'

util = require '../util.coffee'
priority = require '../data/priority.js'
qualities = require '../data/qualities.js'
inputs = require '../inputs.coffee'

main = require './edit-character.coffee'


$freeSkill = exports.$freeSkill = (i, initial, magicType) -> R.p {class: 'input-group input-group-sm'}, [
  R.span {class: 'input-group-addon'}, 'Free Skill'
  inputs.select {
    class: 'form-control input-sm'
    name: 'freeSkills[]:string'
  }, rx.flatten [
    inputs.option {}
    bind -> _.where(active, {type: if magicType.get() == 'magic' then 'magical' else 'resonance'}).map (skill) ->
      inputs.option {value: skill.name, selected: initial?.freeSkills[i] == skill.name}, skill.name
  ]
  R.span {class: 'input-group-addon'}, bind -> main.getData('priority.magic.skills')?.rating
]

$skillWidget = exports.$skillWidget = ({name, group, aptitude, incompetentGroup, initial, groupScore}) ->
  groupScore ?= bind -> null
  min = bind -> if name in (main.getData()?.freeSkills ? []) then main.getData('priority.magic.skills')?.rating else 0
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


$skillGroup = exports.$skillGroup = ({group, incompetentGroup, initial, aptitude, magicType}) ->
  skills = _.where(active, {group: group.name})
  mkgrp = -> R.div {class: 'col-lg-6 col-xs-12', style: {clear: 'right'}}, _.flatten [
    R.h4 {class: 'form-group'}, [
      R.div {class: 'col-xs-5'}, R.label {class: 'control-label'}, "#{group.name} (#{group.type[...3]})"
      R.div {class: 'col-xs-3'}, R.input.number {
        name: "skillGroups[#{group.name}]:number"
        min: 0
        max: 6
        value: initial?.skillGroups?[group.name] ? 0
        class: 'form-control input-sm'
        group: group.name
        readonly: bind -> incompetentGroup.get() == group.name
      }
    ]
    skills.map (skill) ->
      $skillWidget {name: skill.name, group: skill.group, initial, aptitude, incompetentGroup, groupScore: bind -> main.getData('skillGroups')?[skill.group]}
  ]
  bind ->
    if group.type not in ['magical', 'resonance'] or (
      group.type == 'magical' and magicType.get() == 'magic'
    ) or (
      group.type == 'resonance' and magicType.get() == 'resonance'
    )
      mkgrp()
    else null


$skillsByType = exports.$skillsByType = ({type, skills, magicType, aptitude, initial}) -> bind ->
  R.div {class: 'col-lg-6 col-xs-12'}, bind ->
    if type != 'resonance' and (type != 'magical' or magicType.get() == 'magic') then [
      R.h4 "(#{type})"
      rx.flatten(skills).map (skill) ->
        bind ->
          if not skill.group?
            $skillWidget {name: skill.name, aptitude, initial}
          else null
    ]
    else null


$mkKnowledgeGrp = exports.$mkKnowledgeGrp = (category, initial) ->
  rows = rx.array(initial?.knowledge?[category] ? [])
  R.div rx.flatten [
    R.h3 category
    rows.indexed().map (v, iCell) -> $knowlSkillRow category, iCell.raw(), initial, (i) -> rows.removeAt i
    R.button {
      class: 'btn btn-primary btn-sm pull-right'
      type: 'button'
      click: -> rows.push {}
    }, "Add Skill"
  ]

$knowlSkillRow = (category, i, initial, rmFn) ->
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
      }
    ]
    R.div {class: 'col-xs-2'}, R.input.number {
      name: "knowledge[#{category}][][rating]:number",
      value: initRoot?.rating ? 1
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
