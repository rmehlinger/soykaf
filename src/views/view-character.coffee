window._ = require 'underscore'
_str = require 'underscore.string'
window.rx = require 'bobtail'
require 'jquery-serializejson'

{rxt, bind} = rx
R = rxt.tags
util = require '../util.coffee'
stringify = require 'json-stable-stringify'

qualities = require '../data/qualities.js'
inputs = require '../inputs.coffee'

exports.viewCharacter = (character) ->
  {personalData, attributes, specialAttributes, priority, skills, qualities} = character
  window.contacts = character.contacts
  condPhys = Math.ceil (attributes?.body ? 0) / 2 + 8
  condStun = Math.ceil (attributes?.willpower ? 0) / 2 + 8
  condOverflow = attributes?.body ? 0
  essence = 6
  return R.div [
    R.h3  {class: 'row'}, [
      R.div {class: 'col-xs-6 col-md-3'}, "Personal Information"
      R.div {class: 'col-xs-6 col-md-3'}, R.a {
        href: router.generate "edit"
        class: 'btn btn-success btn-block btn-sm hidden-print'
        title: 'Edit Character'
      }, [
        R.span {class: 'glyphicon glyphicon-pencil'}
        ' Edit Character'
      ]
    ]
    R.div {class: 'row'}, [
      personalDataField "Primary Name/Alias", personalData?.primaryName
      personalDataField "Other Name/Alias", personalData?.secondaryName
      personalDataField "Metatype", _str.capitalize priority?.metatype?.metatype
      personalDataField "Ethnicity", personalData?.ethnicity
      personalDataField "Gender", personalData?.gender
      personalDataField "Age", personalData?.age
      personalDataField "Height", personalData?.height
      personalDataField "Weight", personalData?.weight
      personalDataField "Hair", personalData?.hair
      personalDataField "Eyes", personalData?.eyes
      personalDataField "Skin", personalData?.skin
      personalDataField "Build", personalData?.build
    ]
    R.div {class: 'row'}, [
      R.div {class: 'form-group col-md-6'}, [
        R.div R.small {class: 'text-muted'}, "Distinguishing Marks/Tattoos"
        R.p personalData?.distinguishing
      ]
      R.div {class: 'form-group col-md-6'}, [
        R.div R.small {class: 'text-muted'}, "Description"
        R.p personalData?.description
      ]
      R.div {class: 'form-group col-md-6'}, [
        R.div R.small {class: 'text-muted'}, "Backstory"
        R.p personalData?.description
      ]
      R.div {class: 'form-group col-md-6'}, [
        R.div R.small {class: 'text-muted'}, "Relationships"
        R.p personalData?.relationships
      ]
    ]
    R.div {class: 'row'}, [
      R.div {class: 'col-md-6'}, [
        R.div {class: 'row'}, [
          R.div {class: 'col-md-6'}, [
            R.h3 "Priorities"
            R.table {class: 'table text-right'}, R.tbody [
              R.tr [
                R.td "Metatype"
                R.td priority?.metatype?.metatype
                R.td priority?.metatype?.priorityVal
              ]
              R.tr [
                R.td "Attributes"
                R.td priority?.attributes?.points
                R.td priority?.attributes?.priorityVal
              ]
              R.tr do -> [
                R.td "Magic"
                R.td priority?.magic?.type
                R.td priority?.magic?.priorityVal
              ]
              R.tr [
                R.td "Skills"
                R.td "#{priority?.skills?.skills}/#{priority?.skills?.groups}"
                R.td priority?.skills?.priorityVal
              ]
              R.tr [
                R.td "Resources"
                R.td [
                  priority?.resources?.nuyen
                  '¥'
                ]
                R.td priority?.resources?.priorityVal
              ]
            ]
          ]
          R.div {class: 'col-md-6'}, [
            R.h3 "Attributes"
            R.table {class: 'table text-right'}, R.tbody [
              R.tr [
                R.td "Body"
                R.td R.strong attributes?.body
                R.td "Willpower"
                R.td R.strong attributes?.willpower
              ]
              R.tr [
                R.td "Agility"
                R.td R.strong attributes?.agility
                R.td "Logic"
                R.td R.strong attributes?.logic
              ]
              R.tr [
                R.td "Reaction"
                R.td R.strong attributes?.reaction
                R.td "Intuition"
                R.td R.strong attributes?.intuition
              ]
              R.tr [
                R.td "Strength"
                R.td R.strong attributes?.strength
                R.td "Charisma"
                R.td R.strong attributes?.charisma
              ]
              R.tr _.flatten [
                R.td "Edge"
                R.td R.strong specialAttributes?.edge
                do ->
                  if priority?.magic?.type == 'technomancer' then [
                    R.td "Resonance"
                    R.td R.strong specialAttributes?.resonance
                  ]
                  else if priority?.magic?.priorityVal == 'E' then [R.td(), R.td()]
                  else [
                    R.td "Magic"
                    R.td R.strong specialAttributes?.magic
                  ]
              ]
            ]
          ]
        ]
        R.div {class: 'row'}, R.div {class: 'col-md-12'}, [
          R.h3 "Derived Stats"
          R.table {class: 'table text-right'}, R.tbody [
            R.tr [
              R.td "Essence"
              R.td {class: 'text-left'}, R.strong essence
              R.td "Composure"
              R.td R.strong (attributes?.charisma ? 0) + attributes?.willpower ? 0
            ]
            R.tr [
              R.td "Init."
              R.td {class: 'text-left'}, R.strong [
                attributes?.intuition ? 0 + attributes?.reaction ? 0
                " + 1d6"
              ]
              R.td "Judge Intentions"
              R.td R.strong (attributes?.charisma ? 0) * 2 + attributes?.intuition ? 0
            ]
            R.tr [
              R.td "Astral Init."
              R.td {class: 'text-left'}, R.strong [
                2 * (attributes?.intuition ? 0)
                " + 2d6"
              ]
              R.td "Memory"
              R.td R.strong (attributes?.logic ? 0) * 2 + attributes?.willpower ? 0
            ]
            R.tr [
              R.td "Physical Limit"
              R.td {class: 'text-left'}, R.strong (attributes?.strength ? 0) * 2 + attributes?.body ? 0 + attributes?.reaction ? 0
              R.td "Condition: Physical"
              R.td R.strong condPhys
            ]
            R.tr [
              R.td "Mental Limit"
              R.td {class: 'text-left'}, R.strong (attributes?.logic ? 0) * 2 + attributes?.intuition ? 0 + attributes?.willpower ? 0
              R.td "Condition: Stun"
              R.td R.strong condStun
            ]
            R.tr [
              R.td "Social Limit"
              R.td {class: 'text-left'}, R.strong (attributes?.charisma ? 0) * 2 + attributes?.willpower + essence
              R.td "Condition: Overflow"
              R.td R.strong condOverflow
            ]
          ]
        ]
        R.h3 "Qualities"
        R.div {class: 'row'}, R.div {class: "col-md-12"}, R.table {class: 'table '}, R.tbody do ->
          pos = _.map qualities?.positive?.qualia, (q, i) -> _.extend {}, q, {choice: qualities?.positive?.choice?[i]}
          neg = _.map qualities?.negative?.qualia, (q, i) -> _.extend {}, q, {choice: qualities?.negative?.choice?[i]}
          _.zip(pos, neg).map ([p, n]) -> R.tr [
            R.td {style: width: '50%'}, [
              p?.name
              if p?.choice then " (#{p?.choice})"
            ]
            R.td {style: width: '50%'}, [
              n?.name
              if n?.choice then " (#{n?.choice})"
            ]
          ]
        R.h3 "Contacts"
        R.table {class: 'table'}, do ->
          console.info contacts
          [
            R.thead R.tr [
              R.th "Name"
              R.th "Loyalty"
              R.th "Connection"
            ]
            R.tbody contacts?.map ({name, loyalty, connection}) -> R.tr [
              R.td name
              R.td loyalty
              R.td connection
            ]
          ]
      ]
      R.div {class: 'col-md-6'}, [
        R.div {class: 'row'}, [
          R.div {class: 'col-md-6'}, [
            R.h3 "Physical Damage"
            R.table {class: 'table table-bordered'}, R.tbody [0...Math.ceil condPhys / 3].map (r) -> R.tr [
              R.td {style: {width: "33%"}, class: if r * 3 + 1> condPhys then "crossed"}
              R.td {style: {width: "33%"}, class: if r * 3 + 2 > condPhys then "crossed"}
              R.td {style: {width: "33%"}, class: if r * 3 + 3 > condPhys then "crossed"}, R.div {class: 'text-bottom text-right text-muted'}, "-#{r}"
            ]
          ]
          R.div {class: 'col-md-6'}, [
            R.h3 "Stun Damage"
            R.table {class: 'table table-bordered'}, R.tbody [0...Math.ceil condStun / 3].map (r) -> R.tr [
              R.td {style: {width: "33%"}, class: if r * 3 + 1 > condStun then "crossed"}
              R.td {style: {width: "33%"}, class: if r * 3 + 2 > condStun then "crossed"}
              R.td {style: {width: "33%"}, class: if r * 3 + 3 > condStun then "crossed"}, R.div {class: 'text-bottom text-right text-muted'}, "-#{r}"
            ]
          ]
        ]
        R.h4 "Overflow Damage"
        R.table {class: 'table table-bordered'}, R.tbody R.tr [0...condOverflow].map ->
          R.td {style: width: "#{100/condOverflow}%"}, rxt.specialChar "nbsp"
        R.h3 "Skills"
        R.table {class: 'table'}, [
          R.thead R.tr [
            R.th "Skill"
            R.th "Group"
            R.th {colspan: 2}, "Total"
            R.th "Specializations"
          ]
          R.tbody do ->
            _.chain skills
              .pairs()
              .filter ([name, skill]) -> skill?.rating
              .sortBy ([name, skill]) -> skill.group
              .value()
              .map ([name, skill]) ->
                attr = attributes[skill.attribute] ? specialAttributes[skill.attribute] ? 0
                R.tr [
                  R.td {style: width: 1}, name
                  R.td {style: width: 1}, skill.group
                  R.td {class: 'text-right', style: {width: 1, whiteSpace: 'nowrap'}}, [
                    skill.rating
                    " + "
                    attr
                    " "
                    skill.attribute.slice(0, 3).toUpperCase()
                  ]
                  R.td {style: width: 1, whiteSpace: 'nowrap'}, [
                    "= "
                    R.strong "#{attr + skill.rating}"
                  ]
                  R.td skill.specialties?.join ', '
                ]
        ]
      ]
    ]
  ]

personalDataField = (label, value) -> R.p {class: "col-md-3 col-xs-6"}, [
  R.div R.small {class: 'text-muted'}, label
  R.div value or rxt.specialChar 'nbsp'
]
