local options = require('nvim-midi-input.options')

local M = {}

---Convenience setup function which sets the plugin options
---@param opts MidiOptions
function M.setup(opts)
    options.set(opts)
end

return M
