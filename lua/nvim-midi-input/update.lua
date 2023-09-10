local job = require('nvim-midi-input.job')
local U = {}

local function getOptions(arg)
    local choices = {}
    for _, line in
        ipairs(
            vim.fn.systemlist(
                string.format('lilypond-midi-input --list-options %s', arg)
            )
        )
    do
        local value = line:match('^([^%s]+)')
        table.insert(choices, value)
    end
    return choices
end

function U.updateMidiKey(key) --  {{{
    if not job:is_running() then
        return
    end
    if not key then
        vim.ui.select(
            getOptions('key'),
            { prompt = 'Chose a musical key' },
            function(choice)
                job:write(string.format('key=%s', choice))
            end
        )
    else
        job:write(string.format('key=%s', key))
    end
end --  }}}

function U.updateMidiAccidentals(accidentals) --  {{{
    if not job:is_running() then
        return
    end
    if not accidentals then
        vim.ui.select(
            getOptions('accidentals'),
            { prompt = 'Chose an accidentals style' },
            function(choice)
                job:write(string.format('accidentals=%s', choice))
            end
        )
    else
        job:write(string.format('accidentals=%s', accidentals))
    end
end --  }}}

function U.updateMidiMode(mode) --  {{{
    if not job:is_running() then
        return
    end
    if not mode then
        vim.ui.select(
            getOptions('mode'),
            { prompt = 'Chose a MIDI input mode' },
            function(choice)
                job:write(string.format('mode=%s', choice))
            end
        )
    else
        job:write(string.format('mode=%s', mode))
    end
end --  }}}

function U.updateMidiAlterations(alts) --  {{{
    if not job:is_running() then
        return
    end
    print('TODO: update alterations')
end --  }}}

function U.updateMidiGlobalAlterations(galts) --  {{{
    if not job:is_running() then
        return
    end
    print('TODO: update global alterations')
end --  }}}

function U.updateMidiOptions() --  {{{
    if not job:is_running() then
        return
    end
    vim.ui.select({
        'key',
        'accidentals',
        'mode',
        'alterations',
        'global alterations',
    }, { prompt = 'Select an option' }, function(choice)
        ({
            key = U.updateMidiKey,
            accidentals = U.updateMidiAccidentals,
            mode = U.updateMidiMode,
            alterations = U.updateMidiAlterations,
            ['global alterations'] = U.updateMidiGlobalAlterations,
        })[choice]()
    end)
end --  }}}

return U

-- vim: fdm=marker
