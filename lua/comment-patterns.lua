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
}
-- #
M.sh = M.hash -- Sh
M.bash = M.hash -- Bash
M.py = M.hash -- Python
M.jl = M.hash -- Julia
M.nix = M.hash -- Nix
M.s = M.hash -- GAS
M.yml = M.hash -- Yaml
M.yaml = M.hash -- Yaml
M.toml = M.hash -- Toml
-- --
M.lua = M.double_dash -- Lua
M.hs = M.double_dash -- Haskell
-- //
M.c = M.double_slash -- C
M.h = M.double_slash -- C/C++ header
M.cpp = M.double_slash -- C++
M.rs = M.double_slash -- Uust
M.js = M.double_slash -- Javascript
M.ts = M.double_slash -- Typescript
M.java = M.double_slash -- Java
M.go = M.double_slash -- Go
-- ;
M.asm = M.semi_colon -- Assembly
M.clj = M.semi_colon -- Clojure
M.lisp = M.semi_colon -- Common lisp
M.el = M.semi_colon -- Emacs lisp
M.scm = M.semi_colon -- Scheme
-- "
M.vim = M.double_quote -- Viml

return M

