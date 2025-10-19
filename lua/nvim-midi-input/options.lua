---@alias Alterations string|table<number, string>

---@class MidiOptions
---@field device string? MIDI input device name
---@field key string? Musical key to use
---@field accidentals string? Accidental style to use for out-of-key notes
---@field mode string? Input mode to use
---@field language string? Note language to use
---@field octave_entry string? Octave entry to use
---@field alterations Alterations? Custom alterations within an octave
---@field global_alterations Alterations? Global alterations over all notes
---@field replace_q boolean Whether or not a `q` should be replaced in Replace mode
---@field replace_in_comment boolean Whether or not to replace inside comments in Replace mode
---@field debug string? Whether or not debugging should be enabled, and which one; will disable certain functionalities

---@type MidiOptions
local options = {
    device = nil,
    key = nil,
    accidentals = nil,
    mode = nil,
    language = nil,
    octave_entry = nil,
    alterations = nil,
    global_alterations = nil,
    replace_q = true,
    replace_in_comment = false,
    debug = nil,
}

local O = {}

---Set and override options
---@param opts MidiOptions
function O.set(opts)
    options = vim.tbl_deep_extend('force', options, opts)
end

---Retrieve the current set of options
---@return MidiOptions
---@nodiscard
function O.get()
    return options
end

---Obtain a list of MIDI input device names
---@return string[]
function O.get_devices()
    local devices = {}
    for _, line in ipairs(vim.fn.systemlist('lilypond-midi-input --list-devices')) do
        table.insert(devices, string.match(line, [[^[^:]+:%s*(.*)]]))
    end
    return devices
end

---Let user select from a list of MIDI input device names
---@param func fun(choice: string) Function to apply on the chosen device name
function O.query_devices(func)
    vim.ui.select(O.get_devices(), { prompt = 'Chose a MIDI input controller' }, function(choice)
        if choice == nil then
            vim.notify(
                'No MIDI input controller selected. Aborting.',
                vim.log.levels.ERROR,
                require('nvim-midi-input').notify_table
            )
            return
        end
        func(choice)
    end)
end

---Parse alterations
---@param alts Alterations|string If a `string`, the alterations are taken as-is. If a `table`, the data is instead represented as a key-value pair. See documentation for `lilypond-midi-input` on alterations.
---@return string? # If `nil`, the alterations could not be parsed; an error message will be shown.
function O.parse_alterations(alts)
    if type(alts) == 'string' then
        return alts
    elseif type(alts) == 'table' then
        local s = ''
        for key, value in pairs(alts) do
            s = string.format('%s,%s:%s', s, key, value)
        end
        return s
    else
        vim.notify(
            'Invalid type for alterations. String or Table.',
            vim.log.levels.ERROR,
            require('nvim-midi-input').notify_table
        )
        return nil
    end
end

return O
