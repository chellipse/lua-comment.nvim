local M = {}

local patternMap = {
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
patternMap.sh = patternMap.hash -- Sh
patternMap.bash = patternMap.hash -- Bash
patternMap.py = patternMap.hash -- Python
patternMap.jl = patternMap.hash -- Julia
patternMap.nix = patternMap.hash -- Nix
patternMap.s = patternMap.hash -- GAS
patternMap.yml = patternMap.hash -- Yaml
patternMap.yaml = patternMap.hash -- Yaml
patternMap.toml = patternMap.hash -- Toml
-- --
patternMap.lua = patternMap.double_dash -- Lua
patternMap.hs = patternMap.double_dash -- Haskell
-- //
patternMap.c = patternMap.double_slash -- C
patternMap.h = patternMap.double_slash -- C/C++ header
patternMap.cpp = patternMap.double_slash -- C++
patternMap.rs = patternMap.double_slash -- Uust
patternMap.js = patternMap.double_slash -- Javascript
patternMap.ts = patternMap.double_slash -- Typescript
patternMap.java = patternMap.double_slash -- Java
patternMap.go = patternMap.double_slash -- Go
-- ;
patternMap.asm = patternMap.semi_colon -- Assembly
patternMap.clj = patternMap.semi_colon -- Clojure
patternMap.lisp = patternMap.semi_colon -- Common lisp
patternMap.el = patternMap.semi_colon -- Emacs lisp
patternMap.scm = patternMap.semi_colon -- Scheme
-- "
patternMap.vim = patternMap.double_quote -- Viml

-- global variable to track pattern for the current filetype
PATTERN = nil

local function get_comment_pattern()
    local fileName = vim.fn.expand("%:t")
    local ext = string.match(fileName, "%.([^%.]+)$")
    print(ext)
    local mapped_pattern = patternMap[ext]
    if mapped_pattern then
        PATTERN = mapped_pattern
    else
        -- if there wasn't a match, return a default
        PATTERN = patternMap["hash"]
    end
end

M.ToggleComment = function(start_line, end_line)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    -- Default to the current line if no range is specified
    start_line = start_line or cursor_pos[1]
    end_line = end_line or cursor_pos[1]
    -- default to True until we find an uncommented line
    local is_commented = 1

    for line_num = start_line, end_line do
        local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
        if is_commented then
            -- check lines until we find an uncommented line
            is_commented = string.find(line, PATTERN.check)
            -- stop iterating once we find an uncommented line
            if not is_commented then break end
        end
    end

    for line_num = start_line, end_line do
        local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
        if is_commented then
            -- Uncomment the line
            local uncommented_line = string.gsub(line, PATTERN.get, "", 1)
            vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, {uncommented_line})
        else
            -- Comment the line
            local leadingSpaces, restOfLine = string.match(line, "^(%s*)(.*)")
            vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, {leadingSpaces .. PATTERN.txt .. restOfLine})
        end
    end
    -- Restore the cursor position
    vim.api.nvim_win_set_cursor(0, cursor_pos)
end

function M.setup()
    vim.api.nvim_create_user_command(
    'ToggleComment',
    function(opts)
        M.ToggleComment(opts.line1, opts.line2)
    end,
    {range = true}
    )
    vim.api.nvim_set_keymap('n', 'tt', ':ToggleComment<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap('v', 'tt', ':ToggleComment<CR>', {noremap = true, silent = true})

    -- create autocmd to update PATTERN global var
    vim.api.nvim_create_augroup("GetCommentPattern", {clear = true})
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
        group = "GetCommentPattern",
        pattern = "*",
        callback = get_comment_pattern
    })
end

return M
