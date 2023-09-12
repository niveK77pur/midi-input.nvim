local options = {
    device = nil,
    key = nil,
    accidentals = nil,
    mode = nil,
    alterations = nil,
    global_alterations = nil,
    replace_q = true,
    debug = false,
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
        vim.api.nvim_err_writeln(
            'Invalid type for alterations. String or Table.'
        )
    end
end

return O
