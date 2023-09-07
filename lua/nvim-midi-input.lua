local options = require('nvim-midi-input.options')

local M = {}

function M.setup(opts)
    options.set(opts)
end

return M
