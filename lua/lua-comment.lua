local M = {}

-- global variable to track pattern for the current filetype
PATTERN = nil

local function get_comment_pattern(patterns)
    local fileName = vim.fn.expand("%:t")
    local ext = string.match(fileName, "%.([^%.]+)$")
    -- vim.notify("EXT: " .. vim.inspect(ext), 2)
    local mapped_pattern = patterns[ext]
    -- vim.notify("PAT EXT: " .. vim.inspect(patterns[ext]), 2)
    if mapped_pattern then
        if mapped_pattern.link then -- link != nil then we replace with the link's value
            -- vim.notify("PATTERN LINKED TO: " .. vim.inspect(patterns[mapped_pattern.link]), 2)
            mapped_pattern = patterns[mapped_pattern.link]
        end
        -- set global to the matched pattern
        -- vim.notify("MAPPED PAT: " .. vim.inspect(mapped_pattern), 2)
        PATTERN = mapped_pattern
    else
        -- if there wasn't a match, set a default
        -- vim.notify("NO PAT.", 2)
        PATTERN = patterns["hash"]
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
        if line ~= "" then
            if is_commented then
                -- check lines until we find an uncommented line
                -- vim.notify(vim.inspect(is_commented), 2)
                is_commented = string.find(line, PATTERN.check)
                -- vim.notify(vim.inspect(is_commented), 2)
                -- stop iterating once we find an uncommented line
                if not is_commented then break end
            end
        end
    end

    for line_num = start_line, end_line do
        local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]

        if line ~= "" then
            if is_commented then
                -- Uncomment the line
                local sub_line_intermediate = string.gsub(line, PATTERN.get, "", 2)
                -- vim.notify(vim.inspect(is_commented), 2)
                if PATTERN.gendl then
                    sub_line_fin = string.gsub(sub_line_intermediate, PATTERN.gendl, "", 2)
                else
                    sub_line_fin = sub_line_intermediate
                end
                -- vim.notify(vim.inspect(sub_line_fin), 2)
                vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, {sub_line_fin})
            else
                -- Comment the line
                local leadingSpaces, restOfLine = string.match(line, "^(%s*)(.*)")
                local endl
                if PATTERN.endl ~= nil then
                    endl = PATTERN.endl
                else
                    endl = ""
                end
                vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, {leadingSpaces .. PATTERN.txt .. restOfLine .. endl})
            end
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

    if conf.map.n ~= "" then
        vim.api.nvim_set_keymap('n', conf.map.n, ':ToggleComment<CR>', {noremap = true, silent = true})
    end
    if conf.map.v ~= "" then
        vim.api.nvim_set_keymap('v', conf.map.v, ':ToggleComment<CR>', {noremap = true, silent = true})
    end

    -- create autocmd to update PATTERN global var
    vim.api.nvim_create_augroup("GetCommentPattern", {clear = true})
    vim.api.nvim_create_autocmd({"BufEnter"}, {
        group = "GetCommentPattern",
        pattern = "*",
        callback = function() get_comment_pattern(conf.patterns) end
    })
    -- seemingly not needed?
    -- get_comment_pattern(conf.patterns)
end

return M
