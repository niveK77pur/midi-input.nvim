local uv = vim.loop
local JOB = require('nvim-midi-input.job')

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
--                                   Functions
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function _G.write_stream(s)
    -- without the newline, Rust won't take the input
    local result = uv.write(JOB.stdin, string.format('%s\n', vim.trim(s)))
    print('>> Write:', vim.inspect(result))
end

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
            _G.write_stream(string.format('key=%s', choice))
        end)
    else
        _G.write_stream(string.format('key=%s', key))
    end
end --  }}}

local function updateMidiAccidentals(accidentals) --  {{{
    if not accidentals then
        vim.ui.select({
            'Sharps',
            'Flats',
        }, { prompt = 'Chose an accidentals style' }, function(choice)
            _G.write_stream(string.format('accidentals=%s', choice))
        end)
    else
        _G.write_stream(string.format('accidentals=%s', accidentals))
    end
end --  }}}

local function updateMidiMode(mode) --  {{{
    if not mode then
        vim.ui.select({
            'Single',
            'Chord',
            'Pedal',
        }, { prompt = 'Chose a MIDI input mode' }, function(choice)
            _G.write_stream(string.format('mode=%s', choice))
        end)
    else
        _G.write_stream(string.format('mode=%s', mode))
    end
end --  }}}

local function updateMidiAlterations(alts) --  {{{
    print('TODO: update alterations')
end --  }}}

local function updateMidiGlobalAlterations(galts) --  {{{
    print('TODO: update global alterations')
end --  }}}

local function updateMidiOptions() --  {{{
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
    JOB:start('out')
end, { desc = 'Start MIDI Input Listener' })

vim.api.nvim_create_user_command('MidiInputStop', function()
    JOB:stop()
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
        JOB:stop()
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
