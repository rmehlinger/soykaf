exports = module.exports = {}

exports.logReturn = logReturn = (arg) ->
  console.log arg
  arg

exports.sum = sum = (list) -> list.reduce ((memo, sum) -> memo + sum), 0
exports.geoSum = geoSum = (n) -> (n) * (n + 1) / 2
exports.triangleRoot = triangleRoot = (num) ->
  Math.floor (Math.sqrt(8 * num + 1) - 1) / 2

exports.modal = ({fade, header, body, footer, closeButton, size, modalOpts}) ->
  modalOpts ?= {}
  modalOpts.class = _.compact _.flatten [
    'modal'
    if fade then 'fade'
    modalOpts.class
  ]
  modalOpts.tabindex ?= -1
  modalOpts.role ?= 'dialog'

  R.div modalOpts, R.div {
    class: ['modal-dialog', if size then "modal-#{size}"]
  }, R.div {class: 'modal-content'}, rx.flatten [
    R.div {class: 'modal-header'}, rx.flatten [
      if closeButton ? true then R.button {
        type: 'button'
        class: 'close'
        'data-dismiss': 'modal'
        'aria-label': 'Close'
      }, R.span {'aria-hidden': true}, rxt.RawHtml '&times;'
      header
    ]
    if body then R.div {class: 'modal-body'}, rx.flatten [body]
    if footer then R.div {class: 'modal-footer'}, rx.flatten [footer]
  ]

exports.showModal = ($modal, opts) -> $modal.modal opts
exports.hideModal = -> $('.modal').modal 'hide'
