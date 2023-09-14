local job = require('nvim-midi-input.job')
local debug = require('nvim-midi-input.debug')

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
        local e_row, e_col = unpack(vim.fn.searchpos(search_pattern, 'Wbe'))
        local s_row, s_col = unpack(vim.fn.searchpos(search_pattern, 'nWb'))
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
            debug.markStartEnd(s_row - 1, s_col - 1, e_row - 1, e_col - 1)
            return
        end
        print('Chord: ', chord)
        job:write(string.format('previous-chord=%s', chord))
    end,
})
