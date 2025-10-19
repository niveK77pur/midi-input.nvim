local debug = require('nvim-midi-input.debug')
local job = require('nvim-midi-input.job')
local options = require('nvim-midi-input.options')

local augroup_midideviceinput = vim.api.nvim_create_augroup('midideviceinput', {})

vim.api.nvim_create_autocmd({ 'ExitPre', 'VimLeavePre' }, {
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
    desc = 'Find and set previous chord (in absolute octave entry)',
    callback = function()
        if not (job:is_running(false) or debug.enabled('previous chord')) then
            return
        end
        if not options.get().octave_entry == 'absolute' then
            return
        end
        local search_pattern = [[\v\<@<!\<\<@![^>]{-}\>]]
        local cursor = vim.api.nvim_win_get_cursor(0)
        local e_row, e_col = unpack(vim.fn.searchpos(search_pattern, 'Wbe'))
        local s_row, s_col = unpack(vim.fn.searchpos(search_pattern, 'nWb'))
        vim.api.nvim_win_set_cursor(0, cursor)
        if e_row == 0 and e_col == 0 then
            if debug.enabled('previous chord') then
                vim.api.nvim_echo({ { 'No previous chord found.' } }, true, { err = true })
                return
            end
            job:write('previous-chord=clear')
            return
        end
        if debug.enabled('previous chord') then
            print(e_row, e_col, s_row, s_col)
            debug.markStartEnd(s_row - 1, s_col - 1, e_row - 1, e_col - 1)
        end
        local chord =
            string.gsub(vim.api.nvim_buf_get_text(0, s_row - 1, s_col, e_row - 1, e_col - 1, {})[1], '%s+', ':')
        if debug.enabled('previous chord') then
            print('Chord: ', chord)
        end
        if debug.enabled() then
            return
        end
        job:write(string.format('previous-chord=%s', chord))
    end,
})

vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
    group = augroup_midideviceinput,
    pattern = { '*' },
    desc = 'Find and set previous key signature',
    callback = function()
        if not (job:is_running(false) or debug.enabled('key signature')) then
            return
        end
        local key_pattern = [[\v\\key\s+]] .. '[[:alpha:]]' .. [[+\s+\\%(major|minor)]]
        local s_row, s_col = unpack(vim.fn.searchpos(key_pattern, 'bWn'))
        local e_row, e_col = unpack(vim.fn.searchpos(key_pattern, 'bWne'))
        if s_row == 0 and s_col == 0 and e_row == 0 and e_col == 0 then
            if debug.enabled('key signature') then
                vim.api.nvim_echo({ { 'No previous key signature found.' } }, true, { err = true })
            end
            if job:is_running(false) then
                job:write(string.format('key=%s', options.get().key or 'cM'))
            end
            return
        elseif s_row > e_row or s_col > e_col then
            if debug.enabled('key signature') then
                vim.api.nvim_echo({ { 'Inside a key signature definition.' } }, true, { err = true })
            end
            return
        end
        local key, scale = string.match(
            vim.api.nvim_buf_get_text(0, s_row - 1, s_col - 1, e_row - 1, e_col, {})[1],
            [[\key%s+(%w+)%s\(%w+)]]
        )
        local scale_short
        if scale == 'minor' then
            scale_short = 'm'
        elseif scale == 'major' then
            scale_short = 'M'
        else
            vim.notify(string.format('Unknown scale provided: %s', scale), vim.log.levels.ERROR)
        end
        if debug.enabled('key signature') then
            print('Key, Scale:', key, scale, scale_short)
            debug.markStartEnd(s_row - 1, s_col - 1, e_row - 1, e_col - 1)
        end
        if debug.enabled() then
            return
        end
        job:write(string.format('key=%s', key .. scale_short))
    end,
})

vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
    group = augroup_midideviceinput,
    pattern = { '*' },
    desc = 'Set relative octave entry options',
    callback = function()
        if not job:is_running(false) then
            return
        end
        if not options.get().octave_entry == 'relative' then
            return
        end
        -- do not clear `previous-absolute-note-reference`, so that user has
        -- the ability to manually press; right before entering insert mode;
        -- the previous absolute note reference relative to which the first
        -- note after entering insert mode should be calculated.
        --
        -- If the user does not do this, there is a high chance the relative
        -- octave is wrong anyways, so we should enable the
        -- `octave-check-on-next-note` in any case.
        --
        -- This is assuming we have no way of knowing/finding the absolute
        -- octave of the note right before the cursor upon entering insert
        -- mode.
        job:write(string.format('octave-check-on-next-note=%s', true))
    end,
})

local function reset_midi_options()
    if debug.enabled('input options') then
        vim.api.nvim_echo({
            { 'No previous lilypond-midi-input settings found. Default settings:' },
            { 'accidentals=' },
            { tostring(options.get().accidentals) },
            { ' ' },
            { 'mode=' },
            { tostring(options.get().mode) },
            { ' ' },
            { 'language=' },
            { tostring(options.get().language) },
            { ' ' },
            { 'alterations=' },
            { tostring(options.parse_alterations(options.get().alterations)) },
            { ' ' },
            { 'global-alterations=' },
            { tostring(options.parse_alterations(options.get().global_alterations)) },
        }, true, { err = true })
        return
    end
    -- 'key' is managed by another autocommand
    if options.get().accidentals ~= nil then
        job:write(string.format('accidentals=%s', options.get().accidentals))
    end
    if options.get().mode ~= nil then
        job:write(string.format('mode=%s', options.get().mode))
    end
    if options.get().language ~= nil then
        job:write(string.format('language=%s', options.get().language))
    end
    if options.get().alterations ~= nil then
        job:write(string.format('alterations=%s', options.get().alterations))
    end
    if options.get().global_alterations ~= nil then
        job:write(string.format('global-alterations=%s', options.get().global_alterations))
    end
end

vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
    group = augroup_midideviceinput,
    pattern = { '*' },
    desc = 'Find and set lilypond-midi-input options',
    callback = function()
        if not (job:is_running(false) or debug.enabled('input options')) then
            return
        end
        local key_pattern = [[\v\%\s+lmi:\s+\zs.*$]]
        local s_row, s_col = unpack(vim.fn.searchpos(key_pattern, 'bWn'))
        local e_row, e_col = unpack(vim.fn.searchpos(key_pattern, 'bWne'))
        if s_row == 0 and s_col == 0 and e_row == 0 and e_col == 0 then
            if debug.enabled('input options') then
                print(s_row, s_col, e_row, e_col)
            end
            reset_midi_options()
            return
        elseif s_row > e_row or s_col > e_col then
            if debug.enabled('input options') then
                vim.api.nvim_echo({ { 'Inside an options definition.' } }, true, { err = true })
            end
            return
        end
        local lmi_options = vim.api.nvim_buf_get_text(0, s_row - 1, s_col - 1, e_row - 1, e_col, {})[1]
        if lmi_options:match('^disable') then
            reset_midi_options()
            return
        end
        if debug.enabled('input options') then
            print(vim.inspect(lmi_options))
            debug.markStartEnd(s_row - 1, s_col - 1, e_row - 1, e_col - 1)
        end
        if debug.enabled() then
            return
        end
        job:write(lmi_options)
    end,
})
