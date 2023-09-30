local job = require('nvim-midi-input.job')
local debug = require('nvim-midi-input.debug')
local options = require('nvim-midi-input.options')

local augroup_midideviceinput =
    vim.api.nvim_create_augroup('midideviceinput', {})

vim.api.nvim_create_autocmd({ 'ExitPre', 'QuitPre' }, {
    group = augroup_midideviceinput,
    pattern = { '*' },
    desc = 'Quit the MIDI Input Listener',
    callback = function()
        job:stop()
    end,
})

vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
    group = augroup_midideviceinput,
    pattern = { '*' },
    desc = 'Find and set previous chord',
    callback = function()
        if not (job:is_running(false) or debug.enabled()) then
            return
        end
        local search_pattern = [[\v\<@<!\<\<@![^>]{-}\>]]
        local cursor = vim.api.nvim_win_get_cursor(0)
        local e_row, e_col = unpack(vim.fn.searchpos(search_pattern, 'Wbe'))
        local s_row, s_col = unpack(vim.fn.searchpos(search_pattern, 'nWb'))
        vim.api.nvim_win_set_cursor(0, cursor)
        if debug.enabled() then
            print(e_row, e_col, s_row, s_col)
            debug.markStartEnd(s_row - 1, s_col - 1, e_row - 1, e_col - 1)
        end
        if e_row == 0 and e_col == 0 then
            if debug.enabled() then
                print('no match was found')
                return
            end
            job:write('previous-chord=clear')
            return
        end
        local chord = string.gsub(
            vim.api.nvim_buf_get_text(
                0,
                s_row - 1,
                s_col,
                e_row - 1,
                e_col - 1,
                {}
            )[1],
            '%s+',
            ':'
        )
        if debug.enabled() then
            print('Chord: ', chord)
            return
        end
        print('Chord: ', chord)
        job:write(string.format('previous-chord=%s', chord))
    end,
})

vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
    group = augroup_midideviceinput,
    pattern = { '*' },
    desc = 'Find and set previous key signature',
    callback = function()
        if not (job:is_running(false) or debug.enabled()) then
            return
        end
        local key_pattern = [[\v\\key\s+]]
            .. '[[:alpha:]]'
            .. [[+\s+\\%(major|minor)]]
        local s_row, s_col = unpack(vim.fn.searchpos(key_pattern, 'bWn'))
        local e_row, e_col = unpack(vim.fn.searchpos(key_pattern, 'bWne'))
        if s_row == 0 and s_col == 0 and e_row == 0 and e_col == 0 then
            if debug.enabled() then
                vim.api.nvim_err_writeln('No previous key signature found.')
            end
            if job:is_running(false) then
                job:write(string.format('key=%s', options.get().key or 'cM'))
            end
            return
        elseif s_row > e_row or s_col > e_col then
            if debug.enabled() then
                vim.api.nvim_err_writeln('Inside a key signature definition.')
            end
            return
        end
        local key, scale = string.match(vim.api.nvim_buf_get_text(
            0,
            s_row - 1,
            s_col - 1,
            e_row - 1,
            e_col,
            {}
        )[1], [[\key%s+(%w+)%s\(%w+)]])
        local scale_short
        if scale == 'minor' then
            scale_short = 'm'
        elseif scale == 'major' then
            scale_short = 'M'
        else
            vim.api.nvim_err_writeln(string.format("Unknown scale provided: %s", scale))
        end
        if debug.enabled() then
            print('Key, Scale:', key, scale, scale_short)
            debug.markStartEnd(s_row - 1, s_col - 1, e_row - 1, e_col - 1)
            return
        end
        job:write(string.format('key=%s', key .. scale_short))
    end,
})
