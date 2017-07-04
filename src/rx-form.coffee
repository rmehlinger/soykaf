window.jQuery = require 'jquery'
require 'jquery-serializejson'
$ = window.jQuery
_ = require 'underscore'
rx = require 'bobtail'
MutationSummary = require 'mutation-summary'

tagCheck = (tag) ->
  tag?.tagName?.toLowerCase() of {"input", "select", "textarea"}

module.exports = ($form, map=undefined, serializeOpts={}, lag=100) ->
  map ?= rx.map {}
  $target = $($form[0])
  s = _.debounce (-> map.update $target.serializeJSON serializeOpts), lag

  s()
  new MutationSummary {
    callback: s
    rootNode: $form[0]
    queries: [
      {element: 'input, select, textarea'}
      {attribute: 'value'}
      {attribute: 'selected'}
      {attribute: 'checked'}
      {attribute: 'name'}
    ]
  }

  $target.on 'change', 'input, select, textarea', s
  return map.readonly()
