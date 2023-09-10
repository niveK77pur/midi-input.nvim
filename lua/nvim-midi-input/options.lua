local options = {
    device = nil,
    key = nil,
    accidentals = nil,
    mode = nil,
    alterations = nil,
    global_alterations = nil,
}

local O = {}

function O.set(opts)
    options = vim.tbl_deep_extend('force', options, opts)
end

function O.get()
    return options
end

function O.get_devices()
    local devices = {}
    for _, line in
        ipairs(vim.fn.systemlist('lilypond-midi-input --list-devices'))
    do
        table.insert(devices, string.match(line, [[^[^:]+:%s*(.*)]]))
    end
    return devices
end

function O.query_devices(func)
    vim.ui.select(
        O.get_devices(),
        { prompt = 'Chose a MIDI input controller' },
        function(choice)
            func(choice)
        end
    )
end

return O
