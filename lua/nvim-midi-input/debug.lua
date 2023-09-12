local options = require('nvim-midi-input.options')

local namespace_name = 'nvim-midi-input-debug'
local namespace = vim.api.nvim_create_namespace(namespace_name)
vim.api.nvim_set_hl(namespace, 'NoteStart', { bg = '#ff0000' })
vim.api.nvim_set_hl(namespace, 'NoteEnd', { bg = '#00ff00' })

local D = {}

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

function D.enabled()
    return options.get().debug
end

return D
