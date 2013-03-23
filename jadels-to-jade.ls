entab = -> \\t * it
blame = -> console.log it; process.exit!
require! jade

export compile = (src, filename) ->
  src .= replace /@/g \locals.

  src = convert src
  src .= replace /#{/g \{{

  # sometimes we need jade interp
  # let's use %{} for that (only for the parser)
  src .= replace /%{/g \#{

  try
    fn = jade.compile src, {+pretty}
  catch
    say src
    blame "Jade Error compiling #filename : #e"

  fn = fn!
  
  # used for tag interpolation (`#{tag} text`)
  # WARNING : can not use ''
  fn .= replace /__INTER__/g \#{
  fn .= replace /__OUTER__/g \}

  # clean a bit. Sadly no way to disable escaping
  fn .= replace /&quot;/g \"

  wrap fn.replace /\{\{/g \#{

# prepares interpolations
interp = (line, extra) ->
  line .= slice extra
  trimmed = line.trim!

  if trimmed.0 is '-'
    ; # jade interpolation

  else if trimmed.slice(0 2) is \#{
    # tag interpolation => #{tag} becomes should be #{"tag"}
    line .= replace \#{ '%{"__INTER__'
    line .= replace \} '__OUTER__"}'

    # `== abc` is jade, `= abc` is coco
  else if trimmed.0 is '=' and trimmed.1 is not '='
    line = line.replace('=' '| #{(') + ') or ""}'

  else if ~line.indexOf '== '
    line .= replace '== ' '= '

  else if ~line.indexOf '= '
    # BAAH this is bad, it's gonna do bad things such as
    # a(foo= "bar")
    # but well...
    line = line.replace('= ' ' #{(') + ') or ""}'

  line


export convert = ->
  it -= /\r/g # fuck
  src = []

  # tags to parse
  tags = <[if unless join while for]>

  # tags that must take on another
  chained-tags = <[else]>

  # tags that must be joined
  joinable-tags = <[while for]>
  
  # keep tracks on indent needed for tags
  # so that we can 
  indent-levels = []

  # keep tracks of real indent to insert
  # (same as indent-levels minus extra-level)
  real-indents = []

  var prev-indent
  for line in (it + "\n") / '\n'
    if line.trim!0 is '-' or src[*-1]?[*-1] is ','
      # jade interpolation
      # | attributes continuation
      src.push interp line, extra-level
      continue

    extra-level = indent-levels.length

    indent = if line.match /^\t+/
      that.0.length
    else 0

    [tag] = line.trim!split ' '

    # auto-close
    while indent <= indent-levels[*-1]
      indent-levels.pop!
      #        INDENT            close the """ and nullcheck
      src.push entab(real-indents.pop!) + '| """) or ""}'
      --extra-level # decrease debt

    tabs = entab indent - extra-level
    
    if tag is '~'
      line = tabs + "| \#{((#{line.trim!slice 1}); '')}"
    else if tag in tags
      # insert the tag
      code = line.trim!

      filter = if tag in joinable-tags
        \join
      else ''

      line = tabs + '| #{' + filter + '(' + code + ' then """'

      # we're expecting an outdent
      indent-levels.push indent
      real-indents.push indent - extra-level
    else if tag in chained-tags
      # answer to another tag
      src.pop! # remove closing + nullcheck
      line = tabs + '| """ ' + line.trim! + ' then """'

      # we're expecting an outdent
      indent-levels.push indent
      real-indents.push indent - extra-level
    else
      line = interp line, extra-level

    src.push line
    prev-indent := indent - extra-level

  src *= \\n

  src

export wrap = ->
  """
    require! lang
    join = -> it?join '' or ''
    module.exports = (locals, wrap = true) ->
      html = \"""
       #it
      \"""
      return html unless wrap

      document.createElement 'div'
        ..innerHTML = html

        return ..firstElementChild
  """