window._ = require 'underscore'
window.$ = window.jQuery = require 'jquery'
window.rx = require 'bobtail'
cherrytree = require 'cherrytree'
{rxt, bind} = rx
R = rxt.tags
window.rxStorage = require 'bobtail-storage'

{editCharacter} = require './views/edit-character.coffee'

window.router = cherrytree {
  pushState: true
}

curRoutes = rx.set []
curRoutesList = rx.array.from curRoutes
curParams = rx.map {}

router.map (route) =>
  route 'home', {path: '/'}
  route 'character-list', {path: '/characters'}

router.use (transition) => rx.transaction =>
  transition.prev.routes.forEach (route) -> curRoutes.delete(route)
  transition.routes.forEach (route) -> curRoutes.add(route)
  curParams.update transition.params

router.listen()

$('body').append R.div {class: 'container'}, bind ->
  switch curRoutesList.at(0)?.name
    when 'home'
      _.defer -> router.replaceWith 'character-list'
      "redirecting..."
    when 'character-list' then R.div {class: "row"}, R.div {class: 'col-xs-12'}, editCharacter rxStorage.local.getItem 'character'
    else R.h1 "WHAT"