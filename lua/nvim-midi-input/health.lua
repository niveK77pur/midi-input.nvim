local M = {}
local opts = require('nvim-midi-input.options')

function checkExecutable()
    vim.health.report_start('External dependency')
    if vim.fn.executable('lilypond-midi-input') == 1 then
        vim.health.report_ok(
            string.format(
                'External command `lilypond-midi-input` found in %s',
                vim.fn.exepath('lilypond-midi-input')
            )
        )
    else
        vim.health.report_error(
            'External command `lilypond-midi-input` not found'
        )
    end
end

function checkDevice()
    vim.health.report_start('Default MIDI device')
    if opts.get().device then
        vim.health.report_ok('Default MIDI device is set')
    else
        vim.health.report_warn('No default MIDI device specified', {
            'Get device names using the `lilypond-midi-input --list-devices` command',
            'A list of device names is presented by this plugin if no device is specified upon starting the job',
        })
    end
end

function checkDebug()
    vim.health.report_start('Debugging')
    local debug = opts.get().debug
    local debug_values = {
        'input options',
        'key signature',
        'previous chord',
        'replace mode',
    }
    if not debug then
        vim.health.report_info('Debugging is disabled.')
        return
    end
    for _, debug_value in ipairs(debug_values) do
        if debug == debug_value then
            vim.health.report_warn(
                string.format('Debugging is enabled for: %s', debug),
                {
                    'Setting the debug option will disable certain functionalities',
                    'Note input will not be working anymore',
                    'Instead of performing operations, information will be presented',
                }
            )
            return
        end
    end
    vim.health.report_error(
        string.format('Invalid value for debugging: `%s`', debug)
    )
end

function checkOptions()
    vim.health.report_start('Plugin options')
    local options = {
        { 'device', opts.get().device },
        { 'key', opts.get().key },
        { 'accidentals', opts.get().accidentals },
        { 'mode', opts.get().mode },
        { 'alterations', opts.get().alterations },
        { 'global_alterations', opts.get().global_alterations },
        { 'replace_q', opts.get().replace_q },
        { 'replace_in_comment', opts.get().replace_in_comment },
    }
    local final_warning = false
    for _, option in ipairs(options) do
        key, value = option[1], option[2]
        if value == nil and value ~= false then
            final_warning = true
            vim.health.report_warn(
                string.format([[Option '%s' has not been given a value.]], key)
            )
        else
            vim.health.report_ok(
                string.format([[Option '%s' was set to '%s']], key, value)
            )
        end
    end
    if final_warning then
        vim.health.report_warn('Some options have not been given a value', {
            'Some minor things may not work as expected without default values',
            'Plugin will be unable to fallback to default options if required',
        })
    end
end

function M.check()
    checkExecutable()
    checkDevice()
    checkDebug()
    checkOptions()
end

return M
