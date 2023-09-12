local debug = require('nvim-midi-input.debug')
local options = require('nvim-midi-input.options')
local C = {}

function C.stdout(data) --  {{{
    local nvim_mode = vim.api.nvim_get_mode().mode
    if nvim_mode == 'i' then
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))

        local prev_char_is_space = true
        local next_char_is_space = true
        if col > 0 then
            prev_char_is_space = vim.api
                .nvim_buf_get_text(0, row - 1, col - 1, row - 1, col, {})[1]
                :match('%s')
        end
        if col < vim.api.nvim_get_current_line():len() then
            next_char_is_space = vim.api
                .nvim_buf_get_text(0, row - 1, col, row - 1, col + 1, {})[1]
                :match('%s')
        end

        data = string.format(
            '%s%s%s',
            prev_char_is_space and '' or ' ',
            vim.trim(data),
            next_char_is_space and '' or ' '
        )

        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { data })
        vim.api.nvim_win_set_cursor(
            0,
            { row, col + data:len() + (next_char_is_space and 0 or -1) }
        )
    elseif nvim_mode == 'R' then
        -- search for next note/chord
        local search_pattern =
            [[\v%(^|\s+)\zs[abcdefg]%([ie]?s)*[',]*\=?[',]*|\<[^>]{-}\>]]
        if options.get().replace_q then
            search_pattern = search_pattern .. [[|\s+\zsq]]
        end
        local s_row, s_col = unpack(vim.fn.searchpos(search_pattern, 'cnW'))
        local e_row, e_col = unpack(vim.fn.searchpos(search_pattern, 'cnWe'))
        if s_col > e_col or s_row > e_row then
            -- we are inside a note and must search backwards for its beginning
            s_row, s_col = unpack(vim.fn.searchpos(search_pattern, 'cnWb'))
        end
        if debug.enabled() then
            debug.markStartEnd(s_row - 1, s_col - 1, e_row - 1, e_col - 1)
            return
        end

        if -- a match was found
            not (s_row == 0 and s_col == 0)
            and not (e_row == 0 and e_col == 0)
        then
            data = vim.trim(data)
            vim.api.nvim_buf_set_text(
                0,
                s_row - 1,
                s_col - 1,
                e_row - 1,
                e_col,
                { data }
            )
            vim.api.nvim_win_set_cursor(0, { s_row, s_col - 1 + data:len() })
        end
    end
end --  }}}

function C.stderr(data) --  {{{
    local info = data:match([[^:: (.*)]])
    local error = data:match([[^!! (.*)]])
    if info then
        print('MIDI Input:', info)
    elseif error then
        vim.api.nvim_err_writeln(string.format('Midi Input Error: %s', error))
    end
end --  }}}

function C.exit(code, signal) --  {{{
    print(string.format('MIDI Input Listener exited (%s) (%s).', code, signal))
    require('nvim-midi-input.job'):clear()
end --  }}}

return C

-- vim: fdm=marker
