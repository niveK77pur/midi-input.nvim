local debug = require('nvim-midi-input.debug')
local options = require('nvim-midi-input.options')

---Table of callbacks for each desired mode. See `:help mode()`.
---@private
local modeCallback = {
    ---Callback for insert mode
    ---@param data string
    ['i'] = function(data)
        if debug.enabled() then
            return
        end
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))

        local prev_char_is_space = true
        local next_char_is_space = true
        if col > 0 then
            prev_char_is_space = vim.api.nvim_buf_get_text(0, row - 1, col - 1, row - 1, col, {})[1]:match('%s')
        end
        if col < vim.api.nvim_get_current_line():len() then
            next_char_is_space = vim.api.nvim_buf_get_text(0, row - 1, col, row - 1, col + 1, {})[1]:match('%s')
        end

        data =
            string.format('%s%s%s', prev_char_is_space and '' or ' ', vim.trim(data), next_char_is_space and '' or ' ')

        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { data })
        vim.api.nvim_win_set_cursor(0, { row, col + data:len() + (next_char_is_space and 0 or -1) })
    end,
    ---Callback for replace mode
    ---@param data string
    ['R'] = function(data)
        -- search for next note/chord
        local search_pattern = [[\v%(^|\s+)\zs[abcdefg]%([ie]?s)*[',]*\=?[',]*|\<[^>]{-}\>]]
        if options.get().replace_q then
            search_pattern = search_pattern .. [[|\s+\zsq]]
        end
        local s_row, s_col = unpack(vim.fn.searchpos(search_pattern, 'cnW'))
        local e_row, e_col = unpack(vim.fn.searchpos(search_pattern, 'cnWe'))
        if (s_col > e_col or s_row > e_row) or (s_col == 0 and s_row == 0) then
            -- we are inside a note and must search backwards for its beginning
            s_row, s_col = unpack(vim.fn.searchpos(search_pattern, 'cnWb'))
        end
        if debug.enabled('replace mode') then
            print(s_row, s_col, e_row, e_col)
            debug.markStartEnd(s_row - 1, s_col - 1, e_row - 1, e_col - 1)
        end
        if not options.get().replace_in_comment then
            -- check if inside a comment
            vim.api.nvim_win_set_cursor(0, { s_row, s_col - 1 })
            local c_row, c_col = unpack(vim.fn.searchpos([[%[{}]\@!]], 'cnbW'))
            if c_row ~= 0 and c_col ~= 0 and c_row == s_row and c_col < s_col then
                if debug.enabled('replace mode') then
                    vim.api.nvim_err_writeln('Next note/chord is inside a single-line comment')
                end
                return
            end
            local ms_row, ms_col = unpack(vim.fn.searchpos([[%{]], 'cnbW'))
            local me_row, me_col = unpack(vim.fn.searchpos([[%}]], 'cnW'))
            if
                (ms_row ~= 0 and ms_col ~= 0 and me_row ~= 0 and me_col ~= 0)
                and (
                    (ms_row < s_row and s_row < me_row)
                    or (ms_row == s_row and ms_col < s_col)
                    or (me_row == e_row and s_col < me_col)
                )
            then
                if debug.enabled('replace mode') then
                    print(c_row, c_col, ms_row, ms_col, me_row, me_col)
                    vim.api.nvim_err_writeln('Next note/chord is inside a multi-line comment')
                end
                return
            end
        end
        if debug.enabled() then
            return
        end

        if -- a match was found
            not (s_row == 0 and s_col == 0) and not (e_row == 0 and e_col == 0)
        then
            data = vim.trim(data)
            vim.api.nvim_buf_set_text(0, s_row - 1, s_col - 1, e_row - 1, e_col, { data })
            vim.api.nvim_win_set_cursor(0, { s_row, s_col - 1 + data:len() })
        end
    end,
}

local C = {}

---Helper notify to wrap callback notifications into vim.schedule
---@param msg string
---@param level integer|nil
---@param opts table|nil
function C.notify(msg, level, opts)
    vim.schedule(function()
        vim.notify(msg, level, opts)
    end)
end

---Callback for handling the stdout stream from job
---@param data string A single string coming in from the job's output stream
function C.stdout(data) --  {{{
    local callback = modeCallback[vim.api.nvim_get_mode().mode]
    if callback then
        callback(data)
    end
end --  }}}

---Callback for handling the stderr stream from the job
---@param data string A single string coming in from the job's error stream
function C.stderr(data) --  {{{
    local info = data:match([[^:: (.*)]])
    local error = data:match([[^!! (.*)]])
    if info then
        C.notify(string.format('MIDI Input: %s', info), vim.log.levels.INFO, require('nvim-midi-input').notify_table)
    elseif error then
        C.notify(
            string.format('MIDI Input Error: %s', error),
            vim.log.levels.ERROR,
            require('nvim-midi-input').notify_table
        )
    else
        C.notify(
            string.format('lilypond-midi-input: %s', data),
            vim.log.levels.ERROR,
            require('nvim-midi-input').notify_table
        )
    end
end --  }}}

---Callback for handling proper closing of the job upon exiting
---@param code integer
---@param signal integer
---@see uv.spawn
function C.exit(code, signal) --  {{{
    C.notify(
        string.format('MIDI Input Listener exited (%s) (%s).', code, signal),
        vim.log.levels.INFO,
        require('nvim-midi-input').notify_table
    )
    require('nvim-midi-input.job'):clear()
end --  }}}

return C

-- vim: fdm=marker
