local options = require('nvim-midi-input.options')

local M = {}

---Table to be passed into `vim.notify()`
M.notify_table = {
    title = 'midi-input.nvim',
}

---Convenience setup function which sets the plugin options
---@param opts MidiOptions
function M.setup(opts)
    options.set(opts)
end

return M
