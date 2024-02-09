local M = {}

M = {
    hash = {
        txt = "# ",
        check = "^%s*#",
        get = "#%s?",
    },
    double_dash = {
        txt = "-- ",
        check = "^%s*%-%-",
        get = "%-%-%s?",
    },
    double_slash = {
        txt = "// ",
        check = "^%s*//",
        get = "//%s?",
    },
    semi_colon = {
        txt = "; ",
        check = "^%s*;",
        get = ";%s?",
    },
    double_quote = {
        txt = "\" ",
        check = "^%s*\"",
        get = "\"%s?",
    },
    -- #
    sh = { link = "hash" }, -- Sh
    bash = { link = "hash" }, -- Bash
    py = { link = "hash" }, -- Python
    jl = { link = "hash" }, -- Julia
    nix = { link = "hash" }, -- Nix
    s = { link = "hash" }, -- GAS
    yml = { link = "hash" }, -- Yaml
    yaml = { link = "hash" }, -- Yaml
    toml = { link = "hash" }, -- Toml
    -- --
    lua = { link = "double_dash" }, -- Lua
    hs = { link = "double_dash" }, -- Haskell
    -- //
    c = { link = "double_slash" }, -- C
    h = { link = "double_slash" }, -- C/C++ header
    cpp = { link = "double_slash" }, -- C++
    rs = { link = "double_slash" }, -- Uust
    js = { link = "double_slash" }, -- Javascript
    ts = { link = "double_slash" }, -- Typescript
    java = { link = "double_slash" }, -- Java
    go = { link = "double_slash" }, -- Go
    -- ;
    asm = { link = "semi_colon" }, -- Assembly
    clj = { link = "semi_colon" }, -- Clojure
    lisp = { link = "semi_colon" }, -- Common lisp
    el = { link = "semi_colon" }, -- Emacs lisp
    scm = { link = "semi_colon" }, -- Scheme
    -- "
    vim = { link = "double_quote" }, -- Viml
}

return M

