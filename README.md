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

Jade itself can be slow due to several factors (`with`, `attrs`, `escape`) and this project allows you to avoid that!

(the code is highly unstable and total crap)
Tho, it's used in [html5chan](http://github.com/qqueue/html5chan) and [wowboardhelpers](http://github.com/Nami-Doc/wowboardhelpers).


## Usage

Compile it and use it later.
Attributes are passed as `locals`, aliased to `@`. You can pass an extra attributes object as `@@`

```coffee
# compile it
nephrite = require 'nephrite'

src = nephrite 'a(b="#{@c}")', 'index.jade'
js = Coco.compile src, {bare: true, filename}

# use it
fn obj, extra
```

## Syntax

The syntax is the same as Jade, with a few gotchas :
  - Don't prefix your tags with `-`, it's jade interpolation, to allow for even better perfs on static content :

```jade
ul#pages
 - for (var i = 0; i <= 10; ++i)
    li: a(data-page=i, href="/page/%{i}")== i
```

  for tags, see just below.

  - The jade content is `==` (as seen just before). This is executed compile-time (by jade).

  - Jade interpolation is `%{}`

  - Tags are automatically recognized.
    Currently supported tags are : `if`, `unless`, `while`, `for`, `else`.
    Loops are automatically joined.

  - To avoid complexity in the converter, for attribute interpolation you have to explicitely interpolate them :
  `a(href=foo) Foo!` will use jade's `foo` local (compile time),
  `a(href="#{@foo}") Foo!` will use your `locals.foo` (runtime).

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