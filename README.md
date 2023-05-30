# FORMENU
A script/module to aid with the creation of [GameGuardian](https://gameguardian.net/)'s selection dialog (menus)
# FEATURES
See the [USAGE](https://github.com/SCHEFR/FORMENU/blob/main/README.md#usage) section below for examples of each feature
- __Organised__: Your buttons' functions are all in one scope.
- __Formation__: Call your menus whenever you need with method `form`, with an additional wrapper method `wrap` to loop the formation. **
- __Enhancements__:
  - Dialog type `doubleChoice`: designed to include two types of buttons inside a menu: one for items and one for functions.
  - Parameter `next`: Used as a shortcut to create inner dialogs. Useful for creating complex menus with multiple levels.
  - Parameter `link`: Used to create a shortcut to another existing button, either inside or outside the scope. It helps to organise your functions.
- __Headers__:
  - Parameter `default_message`: Allows you to set a default message of the header of your dialog.
  - Parameter `return_message`: Allows you to return a message to the header of parent dialog.
# USAGE
Any functional/cheaty examples are not to be taken seriously.
## LOADING
For the examples shown, `FORMENU.lua` is going to be loaded as `frm`
```LUA
-- Load straight from Github (requires net)
frm = load(gg.makeRequest('https://raw.githubusercontent.com/SCHEFR/FORMENU/main/FORMENU.lua').content)()

-- Or load from your local storage. path = path to the FORMENU file.
frm = require(path)
```
## BASIC
To start off, here's how you create a simple menu with 3 empty buttons (of the regular `choice` type):
```LUA
-- Method `dialog` creates a new selection dialog (menu) that consists of `functions` (titles, buttons)
frm:dialog({
    type = 'choice',
    functions = {
        { title = 'Button #1' },
        { title = 'Button #2' },
        { title = 'Button #3' }
    }
})

```
- `type` specifies the type of the dialog, there are three types of dialogs: `'choice'`, `'multiChoice'`, `'doubleChoice'`
- `functions` is the list of buttons in the dialog you're creating.
- `title` decides the title of the button, while `func` will be the function executed when you choose it.
- You can set a header message of a dialog with the `default_message` parameter
- `return_message` will display an additional message when `func` completes.
```LUA
-- A menu with one functional button
main = frm:dialog{
    default_message = 'Player-Related Cheats' -- The default header of this dialog
    type = 'choice',
    functions = {
        { title = 'Set Player Health to 20',
           func = function() --use an anonymous function/any other function pointer
               -- here go the instructions
               player.health = 20
           end
        -- `func` will be called if the title was chosen by the user
           return_message = 'Player Health was set to 20!'
        -- optional: `return_message` will show a message in the header of the parent dialog after the function completes.
        }
    }
}
```
Now that you've created a menu, you can then show by calling the `form` method like so:
```LUA
main:form('WELCOME')
-- The first argument provided to `form` will show the string in the header message of the dialog.
```
You could then use the `wrap` method to loop the formation (for main menus of running scripts):
```LUA
main:wrap()
```
### DIALOG TYPES
#### choice
Rework of the regular `gg.choice` function, basic usage as follows:
```LUA
-- Basic `choice` dialog usage example
frm:dialog{
    type = 'choice',
    functions = {
       { title = 'Teleport to Home',
         func = function() teleportTo(64,65,1022) end
       }, 
       { title = 'Teleport to Farm Area', 
         func = function() teleportTo(64,65,1022) end
       },
       { title = 'Teleport to Arena',
         func = function() teleportTo(32,70,251) end
       }
    }
}
```
#### multiChoice
If you want to make a `gg.multiChoice` menu instead of the regular `choice`, simply specify it in the `type` parameter. Any selected title will be executed by their order in `functions`.
```LUA
-- Basic `multiChoice` dialog usage example
daily = frm:dialog{
   default_message = 'Daily Functions'
   type = 'multiChoice',
   functions = {
      { title = 'Daily Farms' },
      { title = 'Claim Daily Rewards' },
      { title = 'Daily Material Shopping' } 
   }
}
```
#### doubleChoice
`doubleChoice` is an another type of dialog that is a mix between two types of buttons - items and functions. Say, you have to make a menu from a list of items ('gadgets' in this example) and include additional functions, for example `Add gadget`
```LUA
-- Basic `doubleChoice` dialog usage example
frm:dialog{
    type = 'doubleChoice', 
    items = { -- Come first, their titles are taken from `name`
       {name= 'gadget1', id = 8831},
       {name= 'gadget2', id = 3362}
    }, 
    itemFunction = function(gadget) -- the item selected will be provided to this function.
       tools.upgrade(gadget)
    end,
    functions = { -- Will appear after the items.
       { title = 'Add gadget', func = promptToAddGadget},
       { title = 'Create Category'}
    }
}
```
- `doubleChoice` allows you to have have a separate function for the items you list.
## ADVANCED
### Next inner dialog
You can create a shortcut to writing inner dialogs of a button using the `next` parameter. For example, if you want to shorten this:
```LUA
-- Inner dialogs without the `next` parameter
frm:dialog{
  type = 'choice', 
  functions = {
    { title = 'Outer',
      func = function()
        frm:dialog{
          type = 'choice',
          functions = {
             { title = 'Inner' }
          }
        }
      end
    }
  }
}
```
You'd use `next` to shorten it:
```LUA
-- Inner dialogs with the `next` parameter
frm:dialog{
   type = 'choice',
   functions = {
      { title = 'Outer',
        next = {
           type = 'choice',
           functions = {
              { title = 'Inner' }
           }
        }
      }
   }
}
```

### Creating button shortcuts
You can create links to buttons (creating a pointer, copying a button) using the `link` parameter. This is usually useful for creating shortcuts for inner functions.
```LUA
-- Example of creating a shortcut to a button with the `link` parameter
frm:dialog{
   type = 'choice',
   functions = {
      { title = 'Button #1' }, 
      { link = 1 }, -- shortcut to the first button ('Button #1') in this table
      { title = 'Outer',
         next = {
            type = 'choice',
            functions = {
               { title = 'Inner'}
            }
         }
      },
      { link = {3,1} } -- from the third button here ('Outer') retrieves the first function ('Inner'). This path can go infinitely
   }
}
```
you could also `link` to a button from elsewhere in the script *as long as the menu is a variable*:
```LUA
-- Example of linking a button from elsewhere
otherMenu = frm:dialog{type = 'choice',functions = {{title = 'Other button'}}}

mainMenu = frm:dialog{
   type = 'choice',
   functions = {
      {
         link = {self = 'otherMenu', 1} --link to the first button in `otherMenu`
      }
   }
}
```
# INFORMATION
You're free to include FORMENU in any of your scripts, modify it to fit your needs and free to share it around as a raw file.
You can open an issue here in `Issues` in case you stumbled upon one.
If you have any feedback, ideas or anything, you could discuss it in `Discussions`.
For anything else, even if it is just a question, reach out to me:

Telegram: [@Scheffr](https://t.me/Scheffr)
Discord: Sch#1613
