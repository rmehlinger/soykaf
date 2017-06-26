window.jQuery = require 'jquery'
rx = require 'bobtail'
{rxt} = rx
R = rxt.tags
$ = window.jQuery

main = -> R.div {class: 'container'}, R.div {class: 'row'}, R.div {class: 'col-md-12'}, [
  R.h1 "Hello, Chummers!"
  R.button {type: 'button', class: 'btn btn-primary'}, "CREATE"
]

$('body').append main()