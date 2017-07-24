window._ = require 'underscore'
$ = window.$ = window.jQuery = require 'jquery'
window.rx = require 'bobtail'
{rxt, bind} = rx
R = rxt.tags
window.rxStorage = require 'bobtail-storage'

{editCharacter} = require './views/edit-character.coffee'

$('body').append R.div {class: 'container'},
  R.div {class: "row"}, R.div {class: 'col-xs-12'}, editCharacter rxStorage.local.getItem 'character'
