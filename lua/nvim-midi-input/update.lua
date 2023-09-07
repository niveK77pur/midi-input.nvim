local job = require('nvim-midi-input.job') local U = {}

function U.updateMidiKey(key) --  {{{
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
            job:write(string.format('key=%s', choice))
        end)
    else
        job:write(string.format('key=%s', key))
    end
end --  }}}

function U.updateMidiAccidentals(accidentals) --  {{{
    if not accidentals then
        vim.ui.select({
            'Sharps',
            'Flats',
        }, { prompt = 'Chose an accidentals style' }, function(choice)
            job:write(string.format('accidentals=%s', choice))
        end)
    else
        job:write(string.format('accidentals=%s', accidentals))
    end
end --  }}}

function U.updateMidiMode(mode) --  {{{
    if not mode then
        vim.ui.select({
            'Single',
            'Chord',
            'Pedal',
        }, { prompt = 'Chose a MIDI input mode' }, function(choice)
            job:write(string.format('mode=%s', choice))
        end)
    else
        job:write(string.format('mode=%s', mode))
    end
end --  }}}

function U.updateMidiAlterations(alts) --  {{{
    print('TODO: update alterations')
end --  }}}

function U.updateMidiGlobalAlterations(galts) --  {{{
    print('TODO: update global alterations')
end --  }}}

function U.updateMidiOptions() --  {{{
    if not job.pid then
        print('Midi input is not running. Aborting.')
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
