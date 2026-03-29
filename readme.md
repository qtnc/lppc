# Lua Power Patch Collection
This repository contains several lua power patchs compatible with lua 5.4.8.
Each power patch is its own branch and independent from one another, making patch application as easy as it could be.

## What is a power patch ?
A [power patch](http://lua-users.org/wiki/LuaPowerPatches) as described on [lua-users.org](http://lua-users.org/) is a small modification of code made on the original distribution in order to add or modify some features to lua, such as new syntaxes, syntactic suggars, or additional options to standard library functions.
A power patch usually changes core language features otherwise impossible to do with a regular library. It has normally to stay small, because it isn't supported officially, and so need to be updated in order to follow the official lua distribution updates.

## How to apply a patch ?

1. Download lua from [lua.org](http://lua.org/) or just clone this repository which just holds a copy of the latest compatible version (to this date 5.4.8)
2. git merge the branch of the patch you want, or download the patch file and run `git apply file.patch`. Most of the patches can be combined with each other, but you will need to handle conflicts yourself.
3. Build lua as normal, by following [original build instructions](doc/readme.html).


## AVailable patchs in this collection

### Compound operators
Branch: compound-operators

Download [compound-operators.patch](compound-operators.patch) (3 files changed, 122 insertions(+), 7 deletions(-))

This patch adds the popular compound operators so well known and beloved in most other languages, that lua doesn't include by default.

- Add `+=, -=, *=, /=, //=, %=, ^=, |=, &=, <<=, >>=, ..=`
- Add `||` and `&&` as synonyms for `or` and `and`, which then allows the addition of the quite useful `||=` and `&&=` as well
- Add `!` and `!=` as synonyms for `not` and `~=`
- `~=` hasn't been changed to acts as a compound operator of `~`(binary xor), so to don't break existing lua codes
- Compound operators aren't allowed in multiple parralel assignments (this would lead to quite strange and hard to understand code)
- Only the lexer and the parser are modified, there's no change to the bytecode or the VM.

```
local a = 3
a += 4 -- equivalent to a = a + 4
print(a) -- 7

local t = { u = { v = 100 }}
t.u.v *= 5 -- equivalent to local temp = t.u; temp.v = temp.v * 5 (t.u is only evaluated once)
print(t.u.v) -- 500
```

### Lambdas
Branch: lambdas

Download [lambdas.patch](lambdas.patch) (3 files changed, 75 insertions(+), 12 deletions(-))

This patch adds the support for shorter function syntax as known as lambdas, as it exists in other languages such as JavaScript, Java and Python.
JavaScript's syntax with `=>` has been retained.

- Only the lexer and the parser are modified, there's no change to the bytecode or the VM.
- Single argument, single return syntax: `arg => expr`, equivalent to `function (arg) return expr end`
- multiple arguments, single return syntax: `(arg1, arg2, ...) => expr`, equivalent to `function (arg1, arg2, ...) return expr end`
- Multiple argument, multiple return syntax: `(arg1, arg2, ...) => (arg1, arg2, ...)`, equivalent to `function (arg1, arg2, ...) return arg1, arg2, ... end`. When there are multiple returns, parens are mandatory after `=>` to avoid ambiguity.
- Potential incompatibility: when using parens to restrict to a single return value, you need to add another pair of parens.


```lua
local t = { 2, 1, 4, 3, 5 }
table.sort(t, (a, b) => a>b)
print(table.concat(t, ', ')) -- 5, 4, 3, 2, 1

function cprintcall (f, ...)
  print(f(...))
end

printcall(a=>a+1, 15) -- 16
printcall( (a, b) => (b, a), 'one', 'two') -- two one
```

### Lambdas-ruby
Branch: lambdas-ruby

Download [lambdas-ruby.patch](lambdas-ruby.patch) (1 file changed, 30 insertions(+), 3 deletions(-))

This is another patch to add lambdas in the language, this time with ruby style syntax: 
`| args | ret` is translated to `function (args) return ret end `.

- Only the lexer and the parser are modified, there's no change to the bytecode or the VM.


```lua
local t = { 2, 1, 4, 3, 5 }
table.sort(t, | a, b | a>b)
print(table.concat(t, ', ')) -- 5, 4, 3, 2, 1
```

### Lambdas-ltgt
Branch: lambdas-ltgt

Download [lambdas-ltgt.patch](lambdas-ltgt.patch) (1 file changed, 30 insertions(+), 3 deletions(-))

This is another patch to add lambdas in the language, this time with another unique syntax:
`<args> ret` is translated to `function (args) return ret end `.

- Only the lexer and the parser are modified, there's no change to the bytecode or the VM.


```lua
local t = { 2, 1, 4, 3, 5 }
table.sort(t, <a,b> a>b)
print(table.concat(t, ', ')) -- 5, 4, 3, 2, 1
```

### Optional then/do after if/elseif/while/for
Branch: optional-then-do

Download [optional-then-do.patch](optional-then-do.patch) (1 file changed, 3 insertions(+), 3 deletions(-))

This little patch makes the keywords **then** and **do** optional after **if**, **elseif**, **while** and **for**.

```lua
for i = 1, 10
  print(i)
end 
```

As a statement almost never starts with `(`, `[` or `{`, it normally doesn't cause any problem. However, if it exceptionally does, then it can be misinterpreted as a function call, table access or call with single table argument. In case of doubt, you should use **then** and **do** keywords to make sure the code is interpreted as desired.

### Multiple local variables declaration
Branch: multilocal

Download [multilocal.patch](multilocal.patch) (1 file changed, 13 insertions(+), 8 deletions(-))

The lua syntax for declaring and initializing several local variables at once has always bugged me:

```lua
local a, b, c = 1, 2, 3
```

It is so by simplicity, and by analogy with multiple assignment syntax. However, it isn't very very readable. Of course you can always have separate local declarations:

```lua
local a = 1
local b = 2
local c = 3
```

However, it can be annoying to repeat multiple times the keyword **local**. 

This patch allows the following, arguably more conventional syntax, which is interpreted as it was separate statements.

```lua
local a = 1, b = 2, c = 3
```


## Table extraction in local variables
Branch: table-extract

Download [table-extract.patch](table-extract.patch) (2 files changed, 25 insertions(+), 1 deletion(-))

This patch brings a little syntax suggar to extract multiple table fields into local variables at once.

- Add the syntax `local a, b, ... in expr `
- Only works when declaring local variables, doesn't work with regular multiple assignments without local keyword

```lua
local floor, cos, log in math
print(log(64, 2), floor(17.25), cos(0)) -- 6.0 17 1.0
```

### Syntax suggar for defining methods in tables
Branch: methods-in-tables

Download [methods-in-tables.patch](methods-in-tables.patch) (1 file changed, 31 insertions(+), 3 deletions(-))

This patch brings a little syntax suggar to define methods in tables.

- Add method syntax in table (see below)
- Normal fields with usual syntax and new methods can be mixed in any order
- The comma is optional after a method definition

```lua
local account = {

  function new (a)
    a = setmetatable(a or {}, self)
    a.balance = 0
    return a
  end

  function deposit (sum)
    self.balance = self.balance + sum
  end
}
account.__index = account

local mybank = account:new()
print(mybank.balance) -- 0
mybank:deposit(1000)
print(mybank.balance) -- 1000
```

### Binary number literals and thousand separator 
Branch: better-numbers

Download [better-numbers.patch](better-numbers.patch) (2 files changed, 15 insertions(+), 4 deletions(-))

This simple patch allows binary literals with 0b and thousend separators in  literals for better readability.

- Add underscore `_` thousend separator syntax in the code, e.g. `1_234_567` inspired by Java and JavaScript
- Add binary literals with 0b or 0B prefix as it exists in several languages: Java, JavaScript, modern C/C++
- These new syntaxes are also supported in lua by the tonumber function

```lua
local a = 0b1000
local b = 1_234_567
print(a+b) 1234575
```

### A few string additions
Branch: better-strings

Download [better-strings.patch](better-strings.patch) (2 files changed, 10 insertions(+), 5 deletions(-))

This very small patch adds some string improvements:

- Added backtick `\``  as another possible string delimiter along with `'` and `"`
- Support for multiline short strings
- Added `\e` for escape, equivalent to `\x1b`
- Added `\\` followed by a newline to ignore it

### Default type metatable
Branch: default-type-mt

Download [default-type-mt.patch](default-type-mt.patch) (3 files changed, 52 insertions(+), 1 deletion(-))

You can call functions of the string table as methods without the need to do anything, because the type string has a shared metatable allowing it.
Why don't tables do the same and allow to call table.insert, table.remove, table.sort, etc. as methods as well ?

This patch brings exactly that. It allows to define a default metatable for tables and userdata.
When initializing lua, the default metatable is set to the global table object.

- Add two new C API functions:
  - `int lua_gettypemetatable (lua_State* L, int type)`:; 0|+1, pushes the default metatable of the type given (LUA_TXXX) on the stack and returns 1, or returns 0 and pushes nothing if the type has no default metatable
  - `int lua_settypemetatable (lua_State* L, int type)`; -1, sets the value on top of the stack as the default metatable of type (LUA_TXXX) given and pops that value from the stack. 
- Add two new lua functions in debug table:
  - debug.gettypemetatable(t); returns the default metatable of the type of t
  - debug.settypemetatable(t, mt); defines the default metatable of the type of t
- When changing the default metatable of tables and userdata, it doesn't change the metatable of objects already created before.

```lua
table.__index=table
debug.settypemetatable({}, table)
local t = { 1, 2, 3, 4, 5 }
print(t:concat(';')) -- 1;2;3;4;5
```

### Shorter table items
Branch: shorter-table-items

Download [shorter-table-items.patch](shorter-table-items.patch) (1 file changed, 24 insertions(+), 1 deletion(-))

This patch adds a few goodies in table construction:

- `{ =x }` is a shortcut for `{ x=x }` 
- `{ [x] }` is a shortcut for `{ [x]=true }` 
- `{ .x }` is a shortcut for `{ x=true }`, and `{ .x=value }` is also accepted as equivalent to `{ x=value }` 

### Default values for function parameters
Branch: default-params

Download [default-params.patch](default-params.patch) (1 file changed, 51 insertions(+), 2 deletions(-))

This patch allows to set default values for function parameters, as in JavaScript, Python and many other languages.

```
function (a, b='one', c='two')
  print(a, b, c)
end
```

Is equivalent to:

```
function (a, b, c)
  b = b or 'one'
  c = c or 'two'
  print(a, b, c)
end
```

- You can set, or not, a default value for all parameters independently, i.e. setting a default value for parameter N doesn't oblige you to set a default value for parameter N+1, N+2 and so on, as it's the case for example inC++.
- You can use whatever expression you want in the default value, including function call, table construction, upvalues, or use previous parameters
- Be careful that the standard or operator is used, so a default value will overwrite a nil, but also a false value passed explicitely

### Stared expand in table constructor
Branch: star-expand

Download [star-expand.patch](star-expand.patch) (3 files changed, 19 insertions(+), 9 deletions(-))

Well known by pythonists, this patch brings the unary `*` operator to lua, but it works only in table constructor to expand multiple arguments returned by a function. It's far from what Python allows, but better than nothing.

```lua
function foo (a)
  return a, a+1, a+2
end

print(table.unpack{ foo(1), foo(10) }) -- 1, 10, 11, 12
print(table.unpack{ *foo(1), foo(10) }) -- 1, 2, 3, 10, 11, 12
```

However, it doesn't work in other contexts. Due to how the parser and VM are built, it isn't possible to allow it elsewhere.
In function calls, for example, You need to use table.unpack as shown above, it doesn't work directly:

```lua
print(*foo(1), foo(10)) -- Syntax error !
print(table.unpack{ *foo(1), foo(10) }) -- OK
```

Neither it works in assignments:

```lua
a, b, c, d = *foo(10), 13 -- Syntax error !
a, b, c, d = table.unpack{ *foo(10), 13 } -- OK
```

The two later are impossible, or they would require a lot of changes in the bytecode and/or the VM.

### Multiple expand in table constructor
Branch: semicolon-expand

Download [semicolon-expand.patch](semicolon-expand.patch) (3 files changed, 19 insertions(+), 9 deletions(-))

Same patch as star-expand above, but using semicolon `;` suffix instead of star `*` prefix.

```lua
function foo (a)
  return a, a+1, a+2
end

print(table.unpack{ foo(1), foo(10) }) -- 1, 10, 11, 12
print(table.unpack{ foo(1); foo(10) }) -- 1, 2, 3, 10, 11, 12
```

Same limitations as above.

### Stop implicit locale formatting
Branch: better-locale

Download [better-locale.patch](better-locale.patch) (5 files changed, 57 insertions(+), 47 deletions(-))

It's sometimes indesirable that numbers are implicitly formatted taking locale into account, both with print and with string.format.
This patch makes print and string.format always use the C locale, making them independant from locale, and so, formatting is always consistent.

This patch also adds a function os.localeconv(). It returns a table with the content of [C struct lconv](https://en.cppreference.com/w/c/locale/lconv).

### Load C modules from lua executable / statically linked lua C modules
Branch: loadlib-self

Download [loadlib-self.patch](loadlib-self.patch) (1 file changed, 2 insertions(+), 2 deletions(-))

Adds the possibility to load lua C functions from own lua executable, by passing an empty string as the first argument of package.loadlib.
For example, this allows to statically link with lua modules, using a loader like the following:

```lua
table.insert(package.searchers, 3, function (modname)
local funcname = 'luaopen_' .. modname
  local func = package.loadlib('', funcname)
  if func then
    return func, funcname
  else
    return string.format('No exported function %s in lua executable', funcname)
  end
end)
```

In C, you can add this exported function, directly in lua.c, inside your own code hosting lua, or static link with it:

```c
int __declspec(dllexport) luaopen_mylib (lua_State* L) {
  lua_pushstring(L, "It works!");
  return 1;
}
```

And then, you can use require as usual:

```lua
local mylib = require('mylib')
print(mylib) -- It works!
```
