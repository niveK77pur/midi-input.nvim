local options = require('nvim-midi-input.options')

local M = {}

function M.setup(opts)
    options.set(opts or {
        key = 'cM',
        accidentals = 'sharps',
        mode = 'chord',
    })
end

return M
