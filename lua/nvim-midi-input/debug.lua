local options = require('nvim-midi-input.options')

local namespace_name = 'nvim-midi-input-debug'
local namespace = vim.api.nvim_create_namespace(namespace_name)
vim.api.nvim_set_hl(namespace, 'NoteStart', { bg = '#ff0000' })
vim.api.nvim_set_hl(namespace, 'NoteEnd', { bg = '#00ff00' })

local D = {}

---Mark start and end of a region using virtual text overlays.
--
--Allows for easier debugging through visual feedback in case search patterns
--are not working properly. Without this, one would have to look at the
--`s_row`, `s_col`, `e_row` and `e_col` values and try to determine where
--exactly they point to in the buffer.
---@param s_row number start row, 0-based
---@param s_col number start column, 0-based
---@param e_row number end row, 0-based
---@param e_col number end column, 0-based
function D.markStartEnd(s_row, s_col, e_row, e_col)
    vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
    vim.api.nvim_set_hl_ns(namespace)
    vim.api.nvim_buf_set_extmark(0, namespace, s_row, s_col, {
        virt_text = { { '[', 'NoteStart' } },
        virt_text_pos = 'overlay',
    })
    vim.api.nvim_buf_set_extmark(0, namespace, e_row, e_col, {
        virt_text = { { ']', 'NoteEnd' } },
        virt_text_pos = 'overlay',
    })
end

---Check if the debugging option is set or not.
---@return boolean is_enabled
---@nodiscard
function D.enabled()
    return options.get().debug
end

return D
