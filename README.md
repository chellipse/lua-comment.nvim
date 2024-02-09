
# lua-comment.nvim

A Neovim plugin for quickly commenting/un-commenting lines.

## Install

### Example using Lazy.nvim

```lua
{
    'chellipse/lua-comment.nvim',
    config = function ()
        require("lua-comment").setup()
    end,
},
```

## Configuration

Default config can be found in [default-config.lua](lua/default-conf.lua)

Currently available patterns for linking are:

* hash (#)
* double_dash (--)
* double_slash (//)
* semi_colon (;)
* double_quote (")

### Example Configuration

```lua
{
    map = {
        n = "tt", -- keymap for Normal mode
        v = "", -- keymap for Visual mode (if value == "" then no keymap will be set)
    },
    patterns = { -- table filetype specs
        hash = { -- file extension to match
            txt = "# ", -- comment text to insert
            check = "^%s*#", -- Lua pattern to check whether a line is commented or not
            get = "#%s?", --  Lua pattern to replace a comment
        },
        sh = {
            link = "hash" -- patterns.sh will now read as patterns.hash
        }
    },
}
```

