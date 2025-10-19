local job = require('nvim-midi-input.job')
local options = require('nvim-midi-input.options')
local U = {}

---@private
---Get a list of options directly from `lilypond-midi-input`
---@param arg string Option to list, see `lilypond-midi-input --list-options`
---@return string[]
local function getOptions(arg)
    local choices = {}
    for _, line in ipairs(vim.fn.systemlist(string.format('lilypond-midi-input --list-options %s', arg))) do
        local value = line:match('^([^%s]+)')
        table.insert(choices, value)
    end
    return choices
end

---Update/Change the musical key. See `lilypond-midi-input --list-options key`.
---@param key string? If not specified, the user will be prompted to select from a list of options.
function U.updateMidiKey(key) --  {{{
    if not job:is_running() then
        return
    end
    if not key then
        vim.ui.select(getOptions('key'), { prompt = 'Chose a musical key' }, function(choice)
            job:write(string.format('key=%s', choice))
            options.set({ key = choice })
        end)
    else
        job:write(string.format('key=%s', key))
        options.set({ key = key })
    end
end --  }}}

---Update/Change the accidental style. See `lilypond-midi-input --list-options accidentals`.
---@param accidentals string? If not specified, the user will be prompted to select from a list of options.
function U.updateMidiAccidentals(accidentals) --  {{{
    if not job:is_running() then
        return
    end
    if not accidentals then
        vim.ui.select(getOptions('accidentals'), { prompt = 'Chose an accidentals style' }, function(choice)
            job:write(string.format('accidentals=%s', choice))
            options.set({ accidentals = choice })
        end)
    else
        job:write(string.format('accidentals=%s', accidentals))
        options.set({ accidentals = accidentals })
    end
end --  }}}

---Update/Change the MIDI input mode. See `lilypond-midi-input --list-options mode`.
---@param mode string? If not specified, the user will be prompted to select from a list of options.
function U.updateMidiMode(mode) --  {{{
    if not job:is_running() then
        return
    end
    if not mode then
        vim.ui.select(getOptions('mode'), { prompt = 'Chose a MIDI input mode' }, function(choice)
            job:write(string.format('mode=%s', choice))
            options.set({ mode = choice })
        end)
    else
        job:write(string.format('mode=%s', mode))
        options.set({ mode = mode })
    end
end --  }}}

---Update/Change the note language. See `lilypond-midi-input --list-options language`.
---@param language string? If not specified, the user will be prompted to select from a list of options.
function U.updateMidiLanguage(language) --  {{{
    if not job:is_running() then
        return
    end
    if not language then
        vim.ui.select(getOptions('language'), { prompt = 'Chose a note language' }, function(choice)
            job:write(string.format('language=%s', choice))
            options.set({ language = choice })
        end)
    else
        job:write(string.format('language=%s', language))
        options.set({ language = language })
    end
end --  }}}

---Update/Change the octave entry mode. See `lilypond-midi-input --list-options octave-entry`.
---@param octave_entry string? If not specified, the user will be prompted to select from a list of options.
function U.updateOctaveEntry(octave_entry) --  {{{
    if not job:is_running() then
        return
    end
    if not octave_entry then
        vim.ui.select(getOptions('octave-entry'), { prompt = 'Chose an octave entry mode' }, function(choice)
            job:write(string.format('octave-entry=%s', choice))
            options.set({ octave_entry = choice })
        end)
    else
        job:write(string.format('octave-entry=%s', octave_entry))
        options.set({ octave_entry = octave_entry })
    end
end --  }}}

---Update the alterations. See `lilypond-midi-input`'s documentation.
---@param alts Alterations|string
function U.updateMidiAlterations(alts) --  {{{
    if not job:is_running() then
        return
    end
    if not alts then
        alts = vim.fn.input('Enter alterations: ')
    end
    job:write(string.format('alterations=%s', options.parse_alterations(alts)))
    options.set({ alterations = alts })
end --  }}}

---Update the global alterations. See `lilypond-midi-input`'s documentation.
---@param galts Alterations|string
function U.updateMidiGlobalAlterations(galts) --  {{{
    if not job:is_running() then
        return
    end
    if not galts then
        galts = vim.fn.input('Enter global alterations: ')
    end
    job:write(string.format('global-alterations=%s', options.parse_alterations(galts)))
    options.set({ global_alterations = galts })
end --  }}}

---Update the replace_q value.
---@param value boolean?
function U.updateReplaceQ(value) --  {{{
    if not value then
        vim.ui.select({ 'yes', 'no' }, { prompt = 'Should `q` be replaced?' }, function(choice)
            options.set({
                replace_q = (choice == 'yes'),
            })
        end)
    else
        options.set({ replace_q = value })
    end
end --  }}}

---Convenience function for updating options. It renders all options and their
---values highly discoverable by having the user navigate through a list of
---options and possible values.
function U.updateMidiOptions() --  {{{
    if not job:is_running() then
        return
    end
    vim.ui.select({
        'key',
        'accidentals',
        'mode',
        'language',
        'octave entry',
        'alterations',
        'global alterations',
        'replace q',
    }, { prompt = 'Select an option' }, function(choice)
        ({
            key = U.updateMidiKey,
            accidentals = U.updateMidiAccidentals,
            mode = U.updateMidiMode,
            language = U.updateMidiLanguage,
            ['octave entry'] = U.updateOctaveEntry,
            alterations = U.updateMidiAlterations,
            ['global alterations'] = U.updateMidiGlobalAlterations,
            ['replace q'] = U.updateReplaceQ,
        })[choice]()
    end)
end --  }}}

return U

-- vim: fdm=marker
