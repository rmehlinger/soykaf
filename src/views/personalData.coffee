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


exports.default = (initial, metatype) -> R.div [
  R.h2 "Personal Data"
  R.div {class: 'row'}, [
    R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
      R.label {class: 'control-label'}, "Primary Name/Alias"
      R.input.text {
        class: 'form-control input-sm'
        name: 'personalData[primaryName]:string'
        value: initial?.personalData?.primaryName
        required: true
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
        value: bind -> _str.capitalize metatype.get()
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
      R.input.text {
        class: 'form-control input-sm'
        name: 'personalData[gender]:string'
        value: initial?.personalData?.gender
      }
    ]
    R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
      R.label {class: 'control-label'}, "Age"
      R.input.text {
        class: 'form-control input-sm'
        name: 'personalData[age]:string'
        value: initial?.personalData?.age
      }
    ]
    R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
      R.label {class: 'control-label'}, "Height"
      R.input.text {
        class: 'form-control input-sm'
        name: 'personalData[height]:string'
        value: initial?.personalData?.height
      }
    ]
    R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
      R.label {class: 'control-label'}, "Weight"
      R.input.text {
        class: 'form-control input-sm'
        name: 'personalData[weight]:string'
        value: initial?.personalData?.weight
      }
    ]
    R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
      R.label {class: 'control-label'}, "Hair"
      R.input.text {
        class: 'form-control input-sm'
        name: 'personalData[hair]:string'
        value: initial?.personalData?.hair
      }
    ]
    R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
      R.label {class: 'control-label'}, "Eyes"
      R.input.text {
        class: 'form-control input-sm'
        name: 'personalData[eyes]:string'
        value: initial?.personalData?.eyes
      }
    ]
    R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
      R.label {class: 'control-label'}, "Skin"
      R.input.text {
        class: 'form-control input-sm'
        name: 'personalData[skin]:string'
        value: initial?.personalData?.skin
      }
    ]
    R.div {class: 'col-md-3 col-lg-2 col-xs-6'}, R.div {class: 'form-group'}, [
      R.label {class: 'control-label'}, "Build"
      R.input.text {
        class: 'form-control input-sm'
        name: 'personalData[build]:string'
        value: initial?.personalData?.build
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
]