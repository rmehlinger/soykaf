window._ = require 'underscore'
window.$ = window.jQuery = require 'jquery'
window.rx = require 'bobtail'
firebase = require 'firebase'
firetail = require 'firetail'
{DepSyncArray, DepFireTailCell} = firetail
cherrytree = require 'cherrytree'
{rxt, bind} = rx
R = rxt.tags
util = require './util.coffee'

{editCharacter} = require './views/edit-character.coffee'

firebase.initializeApp {
  apiKey: "AIzaSyBESCY7XqXljS0Kggi3hGYx0AZZDdTZOUI",
  authDomain: "soykaf-44394.firebaseapp.com",
  databaseURL: "https://soykaf-44394.firebaseio.com",
  projectId: "soykaf-44394",
  storageBucket: "soykaf-44394.appspot.com",
  messagingSenderId: "1020089486763"
}
googleProvider = new firebase.auth.GoogleAuthProvider()
window.db = firebase.database()

window.curUser = rx.cell -1
firebase.auth().onAuthStateChanged (user) -> curUser.set user

window.router = cherrytree {
  pushState: true
}

window.curRoutes = rx.set []
window.curRoutesList = rx.array.from curRoutes
window.curParams = rx.map {}

curCharacter = bind ->
  if not curRoutes.has 'character'
    return null
  else

router.map (route) =>
  route 'home', {path: '/'}
  route 'profile'
  route 'character', {path: '/characters/:charId'}
  route 'new-character'

router.use (transition) => rx.transaction =>
  transition.prev.routes.forEach (route) -> curRoutes.delete(route)
  transition.routes.forEach (route) -> curRoutes.add(route)
  curParams.update transition.params

router.listen()

$('body').append R.div {class: 'container'}, rx.flatten [
  bind ->
    if curUser.get() == -1 then ''
    else if curUser.get()
      user = curUser.get()
      uid = user.uid
      depCharsShort = new DepSyncArray db.ref "characters-short/#{uid}"
      curCharacter = new DepFireTailCell -> db.ref "characters/#{uid}/#{curParams.get 'charId'}"
      return [
        switch curRoutesList.at(0)?.name
          when 'home' then bind ->
            _.defer -> router.replaceWith 'profile'
            "redirecting..."
          when 'profile' then R.div bind -> [
            R.div {class: 'row'}, [
              R.div {class: 'col-md-offset-2 col-md-8'}, R.h1 {class: 'text-center'}, "Welcome, #{user.displayName}!"
              R.div {class: 'col-md-2'}, signOutButton()
            ]
            R.div {class: 'row'}, R.div {class: 'col-lg-6 col-md-12'}, [
              R.h2 "Characters"
              R.ul {class: 'list-group'}, bind -> _.zip(rx.snap(-> depCharsShort.keys()), depCharsShort.data).map ([charId, char]) ->
                if charId and char then R.a {href: router.generate 'character', {charId}}, R.li {class: 'list-group-item'}, [
                  char.primaryName
                  R.button {
                    type: 'button',
                    class: 'btn btn-xs btn-danger pull-right'
                    click: ->
                      if confirm "Are you sure you would like to delete #{char.primaryName}?"
                        db.ref("characters/#{curUser.raw().uid}/#{charId}").remove => db.ref("characters-short/#{curUser.raw().uid}/#{charId}").remove()
                      return false
                  }, R.small {class: 'glyphicon glyphicon-remove', style: marginTop: 3}
                ]
                else ''
            ]
            R.a {
              type: 'button'
              class: "btn btn-success"
              href: "/new-character"
            }, "New Character"
          ]
          when 'new-character' then R.div {class: "row"}, R.div {class: 'col-xs-12'}, editCharacter {}, (data) ->
            ref = db.ref("characters/#{uid}").push()
            ref.set data
            db.ref("characters-short/#{uid}/#{ref.key}").set {primaryName: data.personalData.primaryName}
          when 'character'
            if curCharacter.data then R.div {class: "row"}, R.div {class: 'col-xs-12'},
              editCharacter curCharacter.data, (data) ->
                curCharacter.refCell.raw().set(data)
                db.ref("characters-short/#{uid}/#{curParams.get 'charId'}").set {primaryName: data.personalData.primaryName}
            else 'loading...'
          else R.h1 "WHAT"
      ]
    else R.div [
      R.h1 "Welcome to Soykaf!"
      R.p "A Shadowrun Character Creation Assistant"
      R.button {
        type: 'button'
        class: "btn btn-primary"
        click: -> firebase.auth().signInWithPopup(googleProvider).then (result) ->
      }, "Sign in with Google!"
    ]
  R.footer {class: 'row'}, R.p {
    class: "copyright-disclaimer col-xs-offset-3 col-xs-6"
  }, R.small [
    R.p "Shadowrun © 2001-2017. The Topps Company, Inc."
    R.p [
      "Shadowrun is a trademark of The Topps Company, Inc."
    ]
    R.p """
    The Topps Company, Inc. has sole ownership of the names, logo, artwork, marks, photographs, sounds, audio, video
    and/or any proprietary material used in connection with the game Shadowrun. The Topps Company, Inc. has granted
    permission to < fill in the name of your site > to use such names, logos, artwork, marks and/or any proprietary
    materials for promotional and informational purposes on its website but does not endorse, and is not affiliated
    with < fill in the name of your site > in any official capacity whatsoever.
    """
    R.p [
      "Soykaf is open source software, published under the "
      R.a {href: "http://opensource.org/licenses/MIT"}, "MIT License"
      ". Find and contribute to "
      R.a {href: "https://github.com/rmehlinger/Bonisagus"}, "our source code"
      " on GitHub."
    ]
  ]
]


signOutButton = -> R.button {
  type: 'button',
  class: 'btn btn-link pull-right text-muted',
  click: -> firebase.auth().signOut()
}, "Sign Out"