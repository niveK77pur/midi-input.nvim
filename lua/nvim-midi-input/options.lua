local O = {
    device = nil,
    key = nil,
    accidentals = nil,
    mode = nil,
    alterations = nil,
    global_alterations = nil,
}

function O:set(opts)
    vim.tbl_deep_extend('force', self, opts)
end

function O:update(opts)
    self:set(opts)
end

return O
