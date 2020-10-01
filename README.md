# batch-scripts
Collection of batch scripts created over the years mostly to practice programming.
Out of all scirpts here, the most important one is `batchlib`, since it contains
the core structure and library used by all scripts here.

## Fun Facts
- Programming style is inspired by Python, C/C++ and OOP
- Each script have an option to download updates from GitHub and automatically update itself.
- There are more scripts in my early years of programming, but the code is
  so badly written that I don't feel like uploading it here :)

## Features of batchlib
- Easy to use, suitable for beginners
- Powerful, suitable for hardcore batch script users
- Does not pollute global variables (otherwise specified in documentation)
- Highly reusable (some functions can even be pasted inside a loop without modifying logic of the function)
- Extensive documentation and demo
- Advanced/critical functions have written unittest so functionality can be tested before use
- Can be used as standalone script (otherwise specified in documentation)

## How to use batchlib
`batchlib` is best used by including the functions that you want to use in your script.
It also supports being called as external script, but not all functions could work properly
(specified in documentation). Each script have its own documentation and demo function so if
you need some examples, you can just look at the demo code at `:demo.<function_name_here>`.

This is an example for calling batchlib as external script:
```
set batchlib="C:\path\to\batchlib.bat" -c call %=END=%
call %batchlib%:pow result 4 6
echo Result: %result%
```
