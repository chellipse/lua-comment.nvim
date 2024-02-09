local M = {}

-- global variable to track pattern for the current filetype
PATTERN = nil

local function get_comment_pattern(patternMap)
    local fileName = vim.fn.expand("%:t")
    local ext = string.match(fileName, "%.([^%.]+)$")
    local mapped_pattern = patternMap[ext]
    if mapped_pattern then
        if mapped_pattern.link then -- link != nil then we replace with the link's value
            mapped_pattern = patternMap[mapped_pattern.link]
        end
        -- set global to the matched pattern
        PATTERN = mapped_pattern
    else
        -- if there wasn't a match, set a default
        PATTERN = patternMap["hash"]
    end
end

M.ToggleComment = function(start_line, end_line)
    if not PATTERN then
        print(PATTERN)
        return
    end
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

-- local function printTable(t, indent)
    -- indent = indent or ""
    -- if type(t) ~= "table" then
        -- print(indent .. tostring(t))
    -- else
        -- for key, value in pairs(t) do
            -- if type(value) == "table" then
                -- print(indent .. tostring(key) .. ":")
                -- printTable(value, indent .. "  ")
            -- else
                -- print(indent .. tostring(key) .. ": " .. tostring(value))
            -- end
        -- end
    -- end
-- end

-- local function dev(config)
    -- printTable(config)
-- end

function M.setup(user_config)
    local user_config = user_config or {}
    local default_config = require('default-conf')
    local conf = vim.tbl_deep_extend("force", default_config, user_config)

    -- vim.api.nvim_create_augroup("Dev", {clear = true})
    -- vim.api.nvim_create_autocmd({"CursorHold"}, {
        -- group = "Dev",
        -- pattern = "*",
        -- callback = function() dev(conf.patterns) end,
    -- })

    vim.api.nvim_create_user_command(
    'ToggleComment',
    function(opts)
        M.ToggleComment(opts.line1, opts.line2)
    end,
    {range = true})

    if not conf.map.n == "" then
        vim.api.nvim_set_keymap('n', conf.map.n, ':ToggleComment<CR>', {noremap = true, silent = true})
    end
    if not conf.map.v == "" then
        vim.api.nvim_set_keymap('v', conf.map.v, ':ToggleComment<CR>', {noremap = true, silent = true})
    end

    -- create autocmd to update PATTERN global var
    vim.api.nvim_create_augroup("GetCommentPattern", {clear = true})
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
        group = "GetCommentPattern",
        pattern = "*",
        callback = function() get_comment_pattern(conf.patterns) end
    })
    -- seemingly not needed?
    -- get_comment_pattern(conf.patterns)
end

return M
