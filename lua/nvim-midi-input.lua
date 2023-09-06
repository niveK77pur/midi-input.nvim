--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                    Options
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local options = {
    device = nil,
    key = 'cM',
    accidentals = 'sharps',
    mode = 'pedal',
    alterations = {},
    global_alterations = {},
}

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                   Variables
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local job_id

local callbacks = {
    on_stdout = function(job_id, data, event) --  {{{
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
                vim.trim(vim.fn.join(data)),
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
            [[\v\s+\zs[abcdefg]%([ie]?s)*[',]*\=?[',]*|\<[^>]{-}\>]]
            local s_row, s_col = unpack(vim.fn.searchpos(search_pattern, 'cnW'))
            local e_row, e_col =
                unpack(vim.fn.searchpos(search_pattern, 'cnWe'))

            if -- a match was found
                not (s_row == 0 and s_col == 0)
                and not (e_row == 0 and e_col == 0)
            then
                data = vim.trim(vim.fn.join(data))
                vim.api.nvim_buf_set_text(
                    0,
                    s_row - 1,
                    s_col - 1,
                    e_row - 1,
                    e_col,
                    { data }
                )
                vim.api.nvim_win_set_cursor(
                    0,
                    { s_row, s_col - 1 + data:len() }
                )
            end
        end
    end,                                      --  }}}
    on_stderr = function(job_id, data, event) --  {{{
        local msg = vim.fn.join(data)
        if not vim.fn.empty(msg) then
            vim.cmd(string.format('echoerr %s', msg))
        end
    end,                                    --  }}}
    on_exit = function(job_id, data, event) --  {{{
        print(string.format('MIDI Input Listener exited (%s).', job_id))
        job_id = nil
    end, --  }}}
}

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                   Functions
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local function updateMidiKey(key) --  {{{
    if not key then
        vim.ui.select({
            'CFlatMajor',
            'GFlatMajor',
            'DFlatMajor',
            'AFlatMajor',
            'EFlatMajor',
            'BFlatMajor',
            'FMajor',
            'CMajor',
            'GMajor',
            'DMajor',
            'AMajor',
            'EMajor',
            'BMajor',
            'FSharpMajor',
            'CSharpMajor',
            'AFlatMinor',
            'EFlatMinor',
            'BFlatMinor',
            'FMinor',
            'CMinor',
            'GMinor',
            'DMinor',
            'AMinor',
            'EMinor',
            'BMinor',
            'FSharpMinor',
            'CSharpMinor',
            'GSharpMinor',
            'DSharpMinor',
            'ASharpMinor',
        }, { prompt = 'Chose a musical key' }, function(choice)
            print('TODO: Update key with: ' .. tostring(choice))
        end)
    end
    print('TODO: Update key with: ' .. tostring(key))
end                                               --  }}}

local function updateMidiAccidentals(accidentals) --  {{{
    if not accidentals then
        vim.ui.select({
            'Sharps',
            'Flats',
        }, { prompt = 'Chose an accidentals style' }, function(choice)
            print('TODO: Update accidentals with: ' .. tostring(choice))
        end)
    end
    print('TODO: Update accidentals with: ' .. tostring(accidentals))
end                                 --  }}}

local function updateMidiMode(mode) --  {{{
    if not mode then
        vim.ui.select({
            'Single',
            'Chord',
            'Pedal',
        }, { prompt = 'Chose a MIDI input mode' }, function(choice)
            print('TODO: Update mode with: ' .. tostring(choice))
        end)
    end
    print('TODO: Update mode with: ' .. tostring(mode))
end                                               --  }}}

local function updateMidiAlterations(alts)        --  {{{
    print('TODO: update alterations')
end                                               --  }}}

local function updateMidiGlobalAlterations(galts) --  {{{
    print('TODO: update global alterations')
end                                               --  }}}

local function updateMidiOptions()                --  {{{
    vim.ui.select({
        'key',
        'accidentals',
        'mode',
        'alterations',
        'global alterations',
    }, { prompt = 'Select an option' }, function(choice)
        if choice == 'key' then
            updateMidiKey()
        elseif choice == 'accidentals' then
            updateMidiAccidentals()
        elseif choice == 'mode' then
            updateMidiMode()
        elseif choice == 'alterations' then
            updateMidiAlterations()
        elseif choice == 'global alterations' then
            updateMidiGlobalAlterations()
        end
    end)
end --  }}}

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                   Commands
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim.api.nvim_create_user_command('MidiInputStart', function()
    if job_id then
        print('A MIDI Input Listener is already running. Restarting ...')
        vim.fn.jobstop(job_id)
        job_id = nil
    end
    job_id =
        vim.fn.jobstart({ 'lilypond-midi-input', options.device }, callbacks)
    print(string.format('Started MIDI Input Listener (%s).', job_id))
end, { desc = string.format('Start MIDI Input Listener (%s)', job_id) })

vim.api.nvim_create_user_command('MidiInputStop', function()
    if job_id then
        vim.fn.jobstop(job_id)
        job_id = nil
    end
end, { desc = 'Stop MIDI Input Listener' })

vim.api.nvim_create_user_command('MidiInputUpdateOptions', updateMidiOptions, {
    desc = 'Update MIDI options',
})

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                 AutoCommands
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local augroup_midideviceinput =
    vim.api.nvim_create_augroup('midideviceinput', {})

vim.api.nvim_create_autocmd({ 'ExitPre', 'QuitPre' }, {
    group = augroup_midideviceinput,
    pattern = { '*' },
    desc = 'Quit the MIDI Input Listener',
    callback = function()
        if job_id then
            vim.fn.jobstop(job_id)
            job_id = nil
        end
    end,
})

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                    Plugin
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local M = {}

function M.setup(opts)
    print('Hello MIDI input')
    options = vim.tbl_deep_extend('force', options, opts)
end

return M
-- vim: fdm=marker
