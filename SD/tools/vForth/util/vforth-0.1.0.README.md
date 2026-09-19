# vForth for VS Code -- quick start

`vforth-0.1.0.vsix` is a Visual Studio Code extension for editing vForth
source. It gives you syntax colouring, `NEEDS` checking, hover help, go to
definition, and lets you push the file you are editing to the CSpect SD
image and edit Screens and Blocks of `!Blocks-64.bin` while CSpect is
running.

Full documentation: `README.md` of the extension repository,
<https://github.com/mattsteeldue/vscode-vforth>.

## 1. Install

You need VS Code 1.75 or later. Either:

- Extensions view, `...` menu (top right), **Install from VSIX...**, then
  pick `vforth-0.1.0.vsix`; or
- from a terminal, in this folder:

  ```
  code --install-extension vforth-0.1.0.vsix
  ```

Then reload the window (`Ctrl+Shift+P`, **Developer: Reload Window**).

To update, install the newer `.vsix` the same way. Nothing updates by itself.

## 2. Language support (no setup beyond the folder)

Open the vForth folder (the one holding `src/F18e.f`, `inc/`, `lib/`,
`help/`) with **File > Open Folder**. The extension finds it by itself and
every `.f` file is recognised as vForth.

What you get:

- **Colours**: core words, library words (from `inc/` and `lib/`) and words
  defined in the current file are told apart.
- **Diagnostics**: a library word used before its `NEEDS` is flagged, with
  the `NEEDS` line to add; a `NEEDS` or `INCLUDE` that cannot be resolved,
  and any non-ASCII character (except in comments), are flagged too.
- **Hover** a word: its `help/` page, where it is defined, which `NEEDS`
  loads it.
- **Go to definition** (`F12`, or `Ctrl+click`): on a `NEEDS` or `INCLUDE`
  argument it opens the file.
- **Outline** (`Ctrl+Shift+O`): the definitions of the current file.

If the folder you work in is not the vForth root, set `vforth.root` (next
section).

If another extension (e.g. a Fortran one) also claims `.f`, add to
`settings.json`: `"files.associations": { "*.f": "vforth" }`.

## 3. Settings for the SD image tools

Push, Screens and Blocks need two things: the SD image and `hdfmonkey`
(<https://github.com/simonowen/hdfmonkey>). Open *Settings*, search for
`vforth`; the SD ones are under **vForth: SD image**. Or edit
`settings.json`:

```json
"vforth.root": "C:\\Zx\\Forth\\F18\\tools\\vForth\\",
"vforth.sdImage": "C:\\Zx\\CSpect\\cspect-next-2gb.img",
"vforth.hdfmonkeyPath": "C:\\Zx\\CSpect\\hdfmonkey.exe",
"vforth.sdDestPrefix": "/tools/vforth"
```

| Setting | What to put |
|---|---|
| `vforth.root` | The vForth folder. Leave empty to auto-detect. |
| `vforth.sdImage` | The CSpect `.img` file itself. Not `!Blocks-64.bin`. |
| `vforth.hdfmonkeyPath` | Full path of `hdfmonkey`, or just `hdfmonkey` if it is on `PATH`. |
| `vforth.sdDestPrefix` | The folder of the SD image where the vForth tree is mirrored. A file `inc/word.f` is written to `<prefix>/inc/word.f`. |

Use your own paths, of course.

## 4. Daily use

Open the command palette (`Ctrl+Shift+P`) and type `vForth`.

| Command | What it does |
|---|---|
| **Push file to SD image** | Copies the active file into the SD image. |
| **Open Screen #** | Asks for a Screen number and opens it as text (16 lines x 64 columns). |
| **Open Block # (hex)** | Opens one Block (512 bytes) in a hex editor. |
| **Next / Previous Screen/Block** | `Ctrl+Shift+F8` / `Ctrl+Shift+F7`. |
| **Reload index**, **Show log** | Housekeeping and troubleshooting. |

### Edit, push, test

1. Edit a `.f` file in VS Code.
2. **vForth: Push file to SD image**.
3. In vForth, in CSpect: `NEEDS` or `INCLUDE` the file again.

CSpect can stay open. No `REMOUNT` is needed and no other tool must be
closed. Nothing is pushed on save: bind the command to a key if you like
(*Keyboard Shortcuts*, search for `vForth: Push`). Files under `dev`, `doc`,
`dot`, `emu`, `forum`, `project`, `prompts`, `tools`, `version` are not
normally on the SD card: pushing one asks for confirmation.

### Edit a Screen

**Open Screen #**, type e.g. `11` (the AUTOEXEC Screen). Edit, then
`Ctrl+S`. The extension checks all 16 lines (at most 64 characters each,
7-bit ASCII, no NUL) and writes them back only if valid; otherwise it says
which line and column is wrong and writes nothing. The ruler at column 64 and
the border under line 16 show the Screen's limits.

### Edit a Block

**Open Block # (hex)** is for Blocks that are not source text (graphics,
`PERSISTENCE` snapshots, the message table). It uses the Microsoft *Hex
Editor* extension and offers to install it the first time. The size must stay
exactly 512 bytes.

## 5. If something does not work

- `spawn hdfmonkey ENOENT`: `vforth.hdfmonkeyPath` is not the full path of
  `hdfmonkey.exe` and it is not on `PATH`.
- `hdfmonkey` cannot read a FAT filesystem: `vforth.sdImage` points to
  something that is not the SD image (typically `!Blocks-64.bin`).
- A pushed file is not where you expect: check `vforth.sdDestPrefix`.
- No colours or no diagnostics: check `vforth.root`, then run
  **vForth: Reload index**; **vForth: Show log** says what was found.
- Words you load by hand before editing are flagged: list their `NEEDS`
  arguments in `vforth.preloaded`.
