# About

This NeoVim plugin is effectively a wrapper — albeit a pretty advanced one — around [lilypond-midi-input][lmi], inspired by how [Frescobaldi][frescobaldi] and [Denemo][denemo] handle MIDI input. The main goal is to allow using a MIDI keyboard to insert notes into your lilypond scores.

The main reason a MIDI handler was not implemented in Lua and thus directly into NeoVim, is because of a seeming lack of comprehensive libraries. There are a few MIDI related libraries, but by their descriptions they only appear to work on MIDI files, not real-time MIDI input from a device. (Also it was a good excuse for me to use Rust again, and the resulting backend could in theory be used outside NeoVim)

# Features

- All features from [lilypond-midi-input][lmi-features], reflected during inserting/replacing of notes
- Respects vim modes (see `:h vim-modes`)
    - Notes are only inserted when in *Insert mode*
    - Notes are replaced when in *Replace mode*
    - Nothing will happen in any other mode
    - <details><summary>Open to view demo</summary>

        TODO: Demo screencast showing how it works in the various modes

      </details>
- <details><summary>Always puts cursor right after inserted/replaced note for quick editing (i.e. add articulations, etc.)</summary>

    TODO: Demo showing cursor after note to insert dynamics, etc

  </details>
- <details><summary>Puts appropriate spacing around inserted notes</summary>

    Shows inserting note when cursor is located
    - right **after** a character
    - right **before** a character
    - **inside** a word
    - already surrounded by spaces

  </details>
- Options to change behaviour
    - See all [options from lilypond-midi-input][lmi-options]
    - (Global) alterations can be given as lua tables in the config
    - <details><summary><code>replace_q</code> on whether to replace a <a href="https://lilypond.org/doc/v2.24/Documentation/learning/combining-notes-into-chords"><code>q</code></a>. If disabled, behaves like <a href="https://frescobaldi.org/">Frescobaldi</a>'s replace.</summary>

        TODO: Demo video

      </details>
    - `debug` for debugging issues or undesired behaviour; will disable note input
- <details><summary>List of MIDI devices to select from when none is specified, or when the specified one is not available</summary>

    Show video selecting midi device

  </details>
- <details><summary>Comprehensive update menu for discoverable options (<code>:MidiInputUpdateOptions</code>)</summary>

    TODO: show menu for key signature and modes

  </details>
- Autocommands to make for a more seamless experience
    - Stop MIDI input upon closing vim (if forgotten to stop manually with `:MidiInputStop`)
    - <details><summary>Find the previous chord upon entering insert/replace mode (and sets <a href="https://github.com/niveK77pur/lilypond-midi-input#options"><code>previous-chord</code></a>)</summary>

        - Shows entering chords (on multiple lines)
        - Shows a repeated chord inserts `q`
        - Shows the same chord won't be inserted as `q` if it is not also the previous chord
        - Shows repeating the previous chord at cursor position being inserted as `q`
        - Shows repeating the previous chord between chords in the same line

      </details>
    - <details>Find the previous key signature upon entering insert/replace mode (and sets <a href="https://github.com/niveK77pur/lilypond-midi-input#options">`key`</a>)</summary>

        Shows notes being inserted
        - after a `\key b \major`
        - after a `\key ces \major`
        - after going back to the `\key b \major`

    </details>
    - <details><summary>Finds arbitrary options in the lilypond source file for <a href="https://github.com/niveK77pur/lilypond-midi-input#options">lilypond-midi-input</a> which are passed as-is to the backend</summary>

        Shows inserting notes:
        - after accidentals were set to sharps
        - after accidentals were set to flats
        - after going back to where they were set as sharps

      </details>

# Installation

The [lilypond-midi-input][lmi] must be available in the `PATH`. Please see its installation instructions.

Once the program and its dependencies are set in place, you can install this plugin with the following using [lazy.nvim][lazy]. Note that no options/configurations are required.

```lua
{
    'niveK77pur/midi-input.nvim',
    ft = { 'lilypond' },
}
```

You can run `:checkhealth nvim-midi-input` to see if everything is set up accordingly. (Unfortunately, it cannot check if the [PortMidi library][lmi-install] is available, so check this if the backend is not working)

# Usage

When the plugin is loaded, you can start the MIDI input using the following command. Note that when `device` was not set as an option, or it is not available, you will be prompted with a [list of available devices][lmi-usage]. You can also append the device name to the command.

```vim
:MidiInputStart
:MidiInputStart my-midi-device
```

If successful, you can go into *Insert* mode and enter notes using your MIDI keyboard. In *Replace* you can replace existing notes, it will not add or insert notes.

When finished, you can stop the MIDI input using the following command; it will terminate the `lilypond-midi-input` process. In case you forget, an autocommand will also handle this for you upon exiting NeoVim.

```vim
:MidiInputStop
```

You can manually change options with the following command. A sequence of menus will be shown to guide you towards the option you are willing to change and its values. See also the [options section](#options) below.

```vim
:MidiInputUpdateOptions
```

# Options

There are three ways to set options for the plugin and the [`lilypond-midi-input`][lmi] backend. For a list of all available options, see the [below](#list-of-options).

## At plugin initialization

A `setup` function is provided to initialize the plugin with user defined values. The setup function does only that, set initial values, nothing else.

Note that these options will only be set once during initialization; the other methods will overwrite these values.

```lua
require('nvim-midi-input').setup({
    device = 'My device name',
})
```

In the case of [lazy.nvim][lazy] you can therefore set the options either using the `config` or `opts` field; both will yield identical results.

```lua
{
    'niveK77pur/midi-input.nvim',
    ft = { 'lilypond' },
    config = function()
        require('nvim-midi-input').setup({
            device = 'My device name',
        })
    end,
}
```

Or alternatively in a shorter fashion:

```lua
{
    'niveK77pur/midi-input.nvim',
    ft = { 'lilypond' },
    opts = {
        device = 'My device name',
    },
}
```

## Using the update menus

The `:MidiInputUpdateOptions` command should be quite self-explanatory. It uses `vim.ui.select()` to provide the menu, hence any other plugin providing UIs for this function can be used to make it look and function nicer, such as [fzf-lua](https://github.com/ibhagwan/fzf-lua).

A note should be made on the (global) alterations, which will request for user input. Here, you insert the alterations, just like for the [modeline-like alternative](#vim-modeline-like-settings-in-the-file) (the part after the `=` sign); i.e. as if you would input them directly into [`lilypond-midi-input`'s stdin][lmi-changing-options] stream. Also see [`lilypond-midi-input`'s options][lmi-options] for available keys and values, there you will also find shorthand notations for quicker input.

## Vim `modeline`-like settings in the file

Anywhere in the lilypond file, you can add the following comment to set options that will be set in `lilypond-midi-input`.

Note that you MUST have a `%` comment character, followed by one or more spaces, followed by exactly `lmi:`, followed by one or more spaces, and the desired options. The options will be provided *as-is* to `lilypond-midi-input`'s stdin stream. This also means that anything following `% lmi: ` will be passed to the backend, regardless of its content; no sanitizing or filtering is performed.

```lilypond
% lmi: accidentals=Flats
<some music> % lmi: a=f
```

An autocommand will search backwards from the current cursor position for such comments, upon entering insert mode. If options are found, they will be sent and thus set in `lilypond-midi-input`.

If no options are found searching backwards, then currently set options (either form the [plugin config](#at-plugin-initialization), or the [update menu](#using-the-update-menus)) will be restored. If an option has not been specified, its default value will be `nil` (due to how Lua works); you will see an error by the backend saying that `nil` is an invalid value. This error can be ignored, but it also means that the corresponding option cannot be *reset*. If you always want a default fallback option, it is encouraged to specify all relevant option in the [plugin config](#at-plugin-initialization).

A special first value of `disable` allows *disabling* this modeline-like functionality and using the previous config values (same as those if no options were found). Anything after this point will behave as if no `% lmi: ` options were given. Note that the value MUST be the first value among the provided options; any following options will of course be ignored then.

```lilypond
% lmi: disable
% lmi: disable these options here will be ignored
```

## List of options

The name of the device to be used. If set and available, `:MidiInputStart` will directly launch the backend without asking to select a device.

```lua
device = 'USB-MIDI MIDI 1',
```

Set the input mode for the backend. See [`lilypond-midi-input`'s options table][lmi-options].

```lua
mode = 'pedal-chord',
```

Whether a `q` should be replaced in *Replace* mode. A value of `false` will make it behave like [Frescobaldi][lmi]'s replacement mode. Default is `true`.

```lua
replace_q = true,
```

Currently, the plugin has a very rudimentary and not fully functional way to detect comments. This option allows notes to be replaced within a comment. Default is `false`.

```lua
replace_in_comment = false,
```

How to handle out-of-key accidental notes by the backend. See [`lilypond-midi-input`'s options table][lmi-options].

```lua
accidentals = 'flats',
```

Specify a key signature for the backend. See [`lilypond-midi-input`'s options table][lmi-options].

```lua
key = 'besM',
```
Specify (global) alterations within an octave for the backend. See [`lilypond-midi-input`'s options table][lmi-options].

Note that you can also pass in a Lua table instead of a string when defined in the `setup` function. The key must be given as a string, however, due to Lua shenanigans.

```lua
alterations = {
    ['0'] = 'YO',
    ['4'] = 'BYE',
},
global_alterations = '80:SIKE',
```

Debugging this plugin can be done by setting either of the following (they are mutually exclusive, and only 1 can be set). Text input will be disabled, and the corresponding action will be debugged. This includes printing relevant information, as well as setting extmarks to see which regions were matched/found when searching backwards by the correspondin autocommand.

```lua
debug = 'input options'
debug = 'key signature'
debug = 'previous chord'
debug = 'replace mode'
```

# TODO

- [x] Plugin options are not taken into account
- [x] MIDI start does not check if already running (creates an orphaned process)
- [x] Pedal modes do not seem to work?
- [x] Starting replacement inside ~~chord~~ last note causes error
- [x] Replacement inside last chord before closing bracket `}` does not work (no error though)
- [x] Find last chord and tell it to the backend (allows improved addition of `q`)
- [x] Add debug option to highlight start and end of found regions (replace, find last note/chord, etc)
- [ ] Repeated notes could insert duration as shorthand (similar to `q`)
- [x] Option to have `q`s be replaced as well
- [x] Remove/Replace prints from development
- [x] Find previously set key
- [x] Place config options into the lilypond file at specific points (similar to bar line counting)
- [x] Add/Create health checks (backend is installed? Portmidi installed? Necessary options are provided?) `:h health-dev`
- [x] Update option for changing `q` replacement
- [ ] Option to toggle automatic key setting (previously found key)
- [ ] Option to toggle automatic config options setting?
- [x] Refactor debugging
- [x] Do not replace within comments
- [ ] Completely ignore comments
- [ ] Create help page? (avialable options? other useful information for on-the-fly look up)
- [ ] Add `build.lua` for [lazy.nvim][lazy]
- [x] `MidiInputUpdateOptions` should also change internal values
- [x] `% lmi: ` should revert to default options if not found (but do not set if found)
- [x] `% lmi: ` should have a special key to revert to using default options
- [ ] Appears to sometimes randomly exit job

[lmi]: https://github.com/niveK77pur/lilypond-midi-input
[lmi-install]: https://github.com/niveK77pur/lilypond-midi-input#installation
[lmi-usage]: https://github.com/niveK77pur/lilypond-midi-input#basic-usage
[lmi-features]: https://github.com/niveK77pur/lilypond-midi-input#features
[lmi-changing-options]: https://github.com/niveK77pur/lilypond-midi-input#changing-options
[lmi-options]: https://github.com/niveK77pur/lilypond-midi-input#options
[frescobaldi]: https://frescobaldi.org/
[denemo]: https://denemo.org/
[lazy]: https://github.com/folke/lazy.nvim
