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

function O.query_devices(func)
    local choices = {}
    for _, line in
        ipairs(vim.fn.systemlist('lilypond-midi-input --list-devices'))
    do
        table.insert(choices, string.match(line, [[^[^:]+:%s*(.*)]]))
        print(vim.inspect(choices))
    end
    vim.ui.select(
        choices,
        { prompt = 'Chose a MIDI input controller' },
        function(choice)
            func(choice)
        end
    )
end

return O
