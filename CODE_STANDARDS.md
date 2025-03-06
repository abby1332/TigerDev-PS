# CODE STANDARDS

TODO - Add guideline for how to go about implementing new features (e.g. When to use subclasses or entire scenes for something).

### Static typing
Use static typing any time you initially declare a variable, with some very specific exceptions. You must justify why static typing is impossible/difficult when suppressing the warning. \
Use the following format:
```gdscript
@warning_ignore("untyped_declaration") #reasoning: type of var is unknown until runtime
var _last_wall_clinged_to = null
```
With static typing, prefer to do full type declarations (`var my_variable: int = 0`) at the root level of a file (outside of any functions). Any other time you can use the shortcut declaration (`var my_variable := 0`) which sets the type and declares the variable at the same time using the `:=` operator.
