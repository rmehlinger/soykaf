rx = require 'bobtail'
{rxt, bind} = rx
R = rxt.tags

exports.select = select = (opts, children) ->
  ###
  Like normal select element, but does some work to make sure $.rx("val") stays as
  consistent as possible.  Specifically, you can count on $.rx("val") to reflect the real
  $.val() as long as $.val() is changed by:

  * Human interacting with the select widget.
  * Programmatically calling $select.val(...)
  * If the children options are constructed using inputs.option, then additionally,
    - option's `selected` property is a reactive cell, and the value of this cell changes
    - Programmatically calling $option.prop("selected", ...)

  Note that for the "programmatically" mentions above, this only applies if those calls are made
  on the instances returned by these functions.  That is, it will not work if you make those calls
  on fresh new jquery-selected instances (as obtained via $("select.my-select"), for example.

  select also optionally takes in a `value` opt argument; if specified, the select will select
  the option of that value.  If the `value` argument is a reactive cell, then the selected option
  will also change when the reactive cell content changes.  This should be a more convenient way
  of specifying which option to specify than using a bind on the `selected` attribute of
  child options.
  ###
  return boundSelect(opts, children)

exports.option = option = (args...) ->
  ###
  Produces a version of option element that, when its `selected` attribute changes, will notify
  its parent select to update its $.rx("val").  If you are using a bind on the selected attribute
  of options to determine which option is selected in the select, and if you care about the parent
  select's $.rx("val") being correct, you should use this function to create your options, rather
  than using R.option.
  ###
  $option = R.option args...
  $option._oldProp = $option.prop
  $option.prop = (args...) ->
    res = $option._oldProp(args...)
    if args.length > 1 and args[0] == "selected"
      # If someone called .prop("selected", ...), then notify the parent to update its rx("val")!
      # This also takes care of the case where the option's selected attribute is a reactive
      # cell; when the cell content changes, reactive-coffee will call $.prop() to set the new value.
      $parent = $option.closest("select")
      if $parent
        $parent.rx("val").set $parent.val()
    return res
  return $option

exports.multiSelect = multiSelect = (args...) ->
  ###
  A select with {multiple: true}.  val() will accept and return an array of values.
  ###
  [widgetArgs, opts, children] = normalizeWidgetArgs(args)
  opts = mergeOpts({multiple: true}, opts)
  return boundSelect(opts, children)

boundSelect = (opts, children) ->
  ###
  Produces a select element that keeps $.rx("val") value in sync even if the list of children
  options is reactive and changes.
  ###
  if not children
    if _.isArray opts
      children = opts
      opts = {}
    else
      children = []
  {value} = opts
  childrenCell = rx.array.from children
  if value?
    valueCell = rx.cell.from value

  $select = swapVal(R.select opts, childrenCell)

  rx.autoSub childrenCell.onChange, ([i, a, r]) ->
    # If the children options change, the browser will by default select something from the new
    # children options, but no change event is fired, so the $select.rx("val") can be out of sync.
    # We forcibly update $select.rx("val") here.
    if valueCell?
      # If there's a valueCell, make sure that that value is selected when the children changes
      val = valueCell.raw()
      if val? and val != $select.val()
        $select.val val
    $select.rx("val").set $select.val()

  if valueCell?
    # If there's a valueCell specified, then whenever the value changes, update $select.val()
    # (which will update $select.rx("val") for us).
    rx.autoSub valueCell.onSet, ([o, n]) -> if n? then $select.val n

  return $select

swapVal = ($input) ->
  ###
  Swaps $input.val so that, whenever $input.val(...) is called to set the value of the $input,
  we also update the content of $input.rx("val") with the same.
  ###
  $input._oldVal = $input.val
  $input.val = (args...) ->
    res = $input._oldVal(args...)
    if args.length > 0
      $input.rx("val").set $input.val()
    return res
  return $input
