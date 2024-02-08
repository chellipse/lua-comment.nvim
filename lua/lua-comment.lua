local M = {}

-- dev
M.reload = function()
    vim.cmd "Lazy reload lua-comment"
end

-- dev
local lines = {
    "This is a test.", -- No comment
    "  -- This is a commented line", -- Comment with leading space
    "-- This is another comment", -- Comment without leading space
    "Not a comment -- but has comment syntax inline"
}

local patternMap = {
    lua = {
        checkComment = "^%s*%-%-",
        getComment = "%-%-%s?",
    },
}

local function get_comment_pattern()
    local fileName = vim.fn.expand("%:t")
    local ext = string.match(fileName, "%.([^%.]+)$")
    local pattern = patternMap[ext]
    return pattern
end

-- local function toggle_comment()
--     local line = vim.api.nvim_get_current_line()
--     local cursor_pos = vim.api.nvim_win_get_cursor(0)
--     local pattern = get_comment_pattern()
--     local is_commented = string.find(line, pattern.checkComment)

--     if is_commented then
--         local uncommented_line = string.gsub(line, pattern.getComment, "", 1)
--         vim.api.nvim_set_current_line(uncommented_line)
--     else
--         local leadingSpaces, restOfLine = string.match(line, "^(%s*)(.*)")
--         vim.api.nvim_set_current_line(leadingSpaces .. "-- " .. restOfLine)
--     end

--     vim.api.nvim_win_set_cursor(0, cursor_pos)
-- end

M.ToggleComment = function(start_line, end_line)
    -- Retrieve the current cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    -- Default to the current line if no range is specified
    start_line = start_line or cursor_pos[1]
    end_line = end_line or cursor_pos[1]
    -- Iterate over each line in the specified range
    for line_num = start_line, end_line do
        -- Retrieve the line from the buffer
        local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
        local pattern = get_comment_pattern()
        local is_commented = string.find(line, pattern.checkComment)
        if is_commented then
            -- Uncomment the line
            local uncommented_line = string.gsub(line, pattern.getComment, "", 1)
            vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, {uncommented_line})
        else
            -- Comment the line
            local leadingSpaces, restOfLine = string.match(line, "^(%s*)(.*)")
            vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, {leadingSpaces .. "-- " .. restOfLine})
        end
    end
    -- Restore the cursor position
    vim.api.nvim_win_set_cursor(0, cursor_pos)
end

function M.setup()
    vim.api.nvim_create_user_command("ReloadComment", M.reload, {})
    -- vim.api.nvim_create_user_command('ToggleComment', toggle_comment, {})
    vim.api.nvim_create_user_command(
    'ToggleComment',
    function(opts)
        M.ToggleComment(opts.line1, opts.line2)
    end,
    {range = true}
    )
    -- vim.api.nvim_create_user_command('CommentTest', test, {})
    vim.api.nvim_set_keymap('n', 'tt', ':ToggleComment<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap('v', 'tt', ':ToggleComment<CR>', {noremap = true, silent = true})
end

return M
