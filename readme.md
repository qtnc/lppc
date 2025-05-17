# Lua Power Patch Collection
This repository contains several lua power patchs compatible with lua 5.4.7.
Each power patch is its own branch and independent from one another, making patch application as easy as it could be.

## What is a power patch ?
A [power patch](http://lua-users.org/wiki/LuaPowerPatches) as described on [lua-users.org](http://lua-users.org/) is a small modification of code made on the original distribution in order to add or modify some features to lua, such as new syntaxes, syntactic suggars, or additional options to standard library functions.
A power patch usually changes core language features otherwise impossible to do with a regular library. It has normally to stay small, because it isn't supported officially, and so need to be updated in order to follow the official lua distribution updates.

## How to apply a patch ?
Applying a patch is very easy: 

1. Download lua from [lua.org](http://lua.org/) or just clone this repository which just holds a copy of the latest compatible version (to this date 5.4.7)
2. git merge the branch of the patch you want. Most of the patches can be combined with each other, but you will need to handle conflicts yourself.
3. Build lua as normal, by following [original build instructions](doc/readme.html).


## AVailable patchs in this collection

### Compound operators
Branch: compound-operators

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

## Table extraction in local variables
Branch: table-extract

This patch brings a little syntax suggar to extract multiple table fields into local variables at once.

- Add the syntax `local a, b, ... in expr `
- Only works when declaring local variables, doesn't work with regular multiple assignments without local keyword

```lua
local floor, cos, log in math
print(log(64, 2), floor(17.25), cos(0)) -- 6.0 17 1.0
```

### Syntax suggar for defining methods in tables
Branch: methods-in-tables

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

### Better numbers
Branch: better-numbers

This simple patch allows binary literals with 0b and thousend separators in  literals for better readability.

- Add underscore `_` thousend separator syntax in the code, e.g. `1_234_567` inspired by Java and JavaScript
- Add binary literals with 0b or 0B prefix as it exists in several languages: Java, JavaScript, modern C/C++
- These new syntaxes are also supported in lua by the tonumber function

```lua
local a = 0b1000
local b = 1_234_567
print(a+b) 1234575
```


### Default type metatable
Branch: default-type-mt

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

### Stared expand in table constructor
Branch: star-expand

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
```

Neither it works in assignments:

```lua
a, b, c, d = *foo(10), 13 -- Syntax error !
```

The two later are impossible, or they would require a lot of changes in the bytecode and/or the VM.

