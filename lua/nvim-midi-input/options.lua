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

return O
