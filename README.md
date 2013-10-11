 [![Build Status](https://secure.travis-ci.org/Nami-Doc/nephrite.png)](http://travis-ci.org/Nami-Doc/nephrite)

Nephrite
==============

Pre-compiles [Jade](https://github.com/visionmedia/jade) to Coffee/Coco/LiveScript, allowing you to have the syntax of Jade with the best perfs (only interpolation is used). It also avoids you the pain of undefined and null by auto-soaking.

To make you understand this a bit better, let's say that your code :

```jade
ul#pages
  for page in @pages
    li: a(href="page/#{page}")= page
```

will get compiled to

```js
'<ul id="pages">' + join((function () {
  var ref$, results$ = [];
  for (key in ref$ = locals.pages) {
    val = ref$[key];
    results$.push('<li><a href="page/' + page + '">' + page + '</a></li>');
  }
  return results$;
}()) || '') + '</ul>'
```

**IMPORTANT NOTE** : nephrite does **NOT** do interpolation. This is because its main use-case (FULL SPEED) (also the fact that it was hard hard to do considering the code). Use at your own risk ;).

Jade itself can be slow due to several factors (`with`, `attrs`, `escape`) and this project allows you to avoid that!

(the code is highly unstable and total crap)
Tho, it's used in [c4](http://github.com/qqueue/c4) and [wowboardhelpers](http://github.com/Nami-Doc/wowboardhelpers).


## Extension

Files are valid jade files per se, minus the `@` part.
Nephrite's default extension is `.ne` - `.jade` being valid too.

## Usage

Compile it and use it client-side (this acts like jade's `client: true`).
Attributes are passed as `locals`, aliased to `@`. You can pass an extra attributes object as `@@`.
The code returned is a module export (`module.exports = -> ...`).

```coffee
# compile it
nephrite = require 'nephrite'

src = nephrite 'a(b="#{@c}")', 'index.jade', options
js = Coco.compile src, {bare: true, filename}

# use it client-side
fn obj, extra
```

The options object is passed to jade, without :

  - the `safe` option, for `@` and `@@` replacement (see below).


## Syntax

The syntax is the same as Jade, with a few gotchas :
  - Don't prefix your tags with `-`, it's jade interpolation, to allow for even better perfs on static content :

```jade
ul#pages
 - for (var i = 0; i <= 10; ++i)
    li: a(data-page=i, href="/page/%{i}")== i
```

  for tags, see just below.

  - Jade output is `==` (as seen just before). This is executed compile-time (by jade).

  - Jade interpolation is `%{}`

  - Tags are automatically recognized.
    Currently supported tags are : `if`, `unless`, `while`, `for`, `else`.
    Loops are automatically joined.

  - To avoid complexity in the converter, for attribute interpolation you have to explicitely interpolate them :
  `a(href=foo) Foo!` will use jade's `foo` local (compile time) whereas
  `a(href="#{@foo}") Foo!` will use your `@foo` (`locals.foo`, runtime).

  - Filter content is not modified in any way.

  - The "silent code interpolation" (and prelude) is `~`.
    (take note that any code interpolation appearing BEFORE content will be moved in the prelude, out of the closure, for better perfs.)
    For example :

```jade
~ template = require 'user-template'
~ /*^ this will be moved out of the closure function*/
#users
  ~ /*this will not*/
  ~ "this won't be outputted anyway"
```

  - For bigger blocks, use `:prelude` filter.

```coffee
:prelude
  gen-classes = ->
    classes = "post "
    classes += "abc " if it.abc
    classes

blah= gen-classes {}
```
  Remember, of course, that you should avoid having too much logic in your templates

  - Do note one thing : replacement of `@` is `@@` is made globally, even in your text.
    For example, `div @hey` will give `<div>locals.hey</div>`.

    In order to avoid that, you can enable the "safe mode" through two ways :

      - Passing the option `{+safe}` to the compiling (3rd parameter).

      - Using the directive in prelude :
      ```jade
        ~ "use safe"
        div @hey
        div= @this-is-interpolated
      ```

      Be warned that this comes with a performance loss (the function is wrapped with an IIFE for the transpiler to recognize `@` as `this`), which is why it's not active by default.