local uv = vim.loop
local api = vim.api

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

local job = {
    handle = nil,
    pid = nil,
}
local streams = {
    stdin = uv.new_pipe(false),
    stdout = uv.new_pipe(false),
    stderr = uv.new_pipe(false),
}

local callbacks = {
    stdout = function(data) --  {{{
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
    end, --  }}}
    stderr = function(data) --  {{{
        vim.api.nvim_err_writeln(data)
    end, --  }}}
    exit = function(code, signal) --  {{{
        print(
            string.format('MIDI Input Listener exited (%s) (%s).', code, signal)
        )
        job.handle = nil
        job.pid = nil
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
end --  }}}

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
end --  }}}

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

local function closeMidi()
    if job.handle then
        local result = uv.process_kill(job.handle, 1)
        print('MIDI CLOSED:', result)
        job.handle = nil
        job.pid = nil
    end
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                   Commands
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim.api.nvim_create_user_command('MidiInputStart', function()
    if job.pid then
        print('A MIDI Input Listener is already running.')
        return
    end

    job.handle, job.pid = uv.spawn('lilypond-midi-input', {
        args = { options.device },
        stdio = { streams.stdin, streams.stdout, streams.stderr },
    }, callbacks.exit)

    uv.read_start(streams.stdout, function(err, data)
        assert(not err, err)
        if data then
            vim.schedule(function()
                -- when input is arriving very fast, it can happen that
                -- multiple lines in stdin will be merged into a single `data`
                for _, line in ipairs(vim.fn.split(data, [[\n]])) do
                    callbacks.stdout(line)
                end
            end)
        end
    end)

    uv.read_start(streams.stderr, function(err, data)
        assert(not err, err)
        if data then
            vim.schedule(function()
                callbacks.stderr(data)
            end)
        end
    end)

    print(
        string.format(
            'Started MIDI Input Listener (%s) (%s).',
            job.handle,
            job.pid
        )
    )
end, { desc = 'Start MIDI Input Listener' })

vim.api.nvim_create_user_command('MidiInputStop', function()
    closeMidi()
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
        closeMidi()
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
