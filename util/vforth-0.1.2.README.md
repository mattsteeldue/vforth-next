# vForth for VS Code

Language support and CSpect tools for [vForth](https://github.com/mattsteeldue/vforth-next),
the Forth system for the ZX Spectrum Next.

- **Language support**: syntax highlighting, `NEEDS`/`INCLUDE` diagnostics,
  hover help, go to definition, outline, semantic colouring.
- **CSpect SD image tools**: push the file you are editing to the SD image,
  and edit the Screens and Blocks of `!Blocks-64.bin` directly from VS Code,
  while CSpect is running.

The extension works on a vForth source tree (the one holding `src/F18e.f`,
`inc/`, `lib/`, `help/`), not on files of its own.

## Features

### Language support

- **Syntax highlighting** generated from the core source. The core vocabulary
  is the set of active `RENAME old NEW` lines at the end of `src/F18e.f`;
  commented `\ RENAME` lines are excluded.
- **NEEDS diagnostics**: a word provided by `inc/` or `lib/` that is used
  before the corresponding `NEEDS` is flagged, with the `NEEDS` to add.
  Availability is sequential and follows the real `NEEDS` / `INCLUDE`
  closure, including the files loaded by the loaded files.
- **Unresolvable `NEEDS`** (no `inc/` nor `lib/` file) and `INCLUDE` paths
  not found under the vForth root.
- **7-bit ASCII check**: any non-ASCII character is an error, except inside
  comments (`\ ...` and `( ... )`), where Latin-1 bytes (e.g. `ß`, `$DF`) are
  allowed, matching text left behind by old editors such as UltraEdit.
- **Hover**: the `help/` page of the word, located through `MAP-FN` exactly
  as `HELP` does, plus where the word is defined and which `NEEDS` loads it.
- **Go to definition**: local definition first, then core (`src/F18e.f`),
  then `inc/` and `lib/`. The core always prevails over `inc/` and `lib/`.
  On a `NEEDS` or `INCLUDE` argument it opens the file.
- **Outline**: definitions of the current file.
- **Semantic colouring**: library words (`vforthLibrary`) and words defined
  in the current file (`vforthLocal`) are told apart from core words.

### CSpect SD image tools

| Command | What it does |
|---|---|
| *vForth: Send file to SD image* | Writes the active file into the SD image. |
| *vForth: Pick file from SD image* | Overwrites the active file with its copy from the SD image. |
| *vForth: Open Screen #* | Edits a Screen (16 x 64) of `!Blocks-64.bin` as text. |
| *vForth: Open Block # (hex)* | Edits a Block (512 bytes) of `!Blocks-64.bin` in a hex editor. |
| *vForth: Next Screen/Block* (`Ctrl+Shift+F8`) | Opens the next Screen or Block. |
| *vForth: Previous Screen/Block* (`Ctrl+Shift+F7`) | Opens the previous Screen or Block. |
| *vForth: Reload index*, *vForth: Show log* | Housekeeping. |

They all use `hdfmonkey`, which writes into the SD image directly: no
exclusive lock, no `REMOUNT` cycle, so they work while CSpect is running and
a running vForth session sees the change immediately. See the sections below.

## Requirements

No compilation and no npm dependencies are needed to run this extension
itself (plain JavaScript). Two external tools are needed for the CSpect SD
image tools, not for language support:

- [`hdfmonkey`](https://github.com/simonowen/hdfmonkey) — required by
  *Send file to SD image*, *Open Screen #* and *Open Block # (hex)*. Set
  `vforth.hdfmonkeyPath` to its executable unless it is already on `PATH`.
- [Hex Editor](https://marketplace.visualstudio.com/items?itemName=ms-vscode.hexeditor)
  (`ms-vscode.hexeditor`) — required only by *Open Block # (hex)*, which
  delegates the byte-level editing UI to it. The command offers to install it
  if it is missing.

## Settings

| Setting | Default | Example (author's setup) | Meaning |
|---|---|---|---|
| `vforth.root` | `""` | `C:\Zx\Forth\F18\tools\vForth\` | vForth root (holds `src/F18e.f`). Empty: auto-detect in the workspace. |
| `vforth.preloaded` | `[]` | `[]` | `NEEDS` arguments assumed already loaded before any file is opened. See below. |
| `vforth.diagnostics.enable` | `true` | `true` | Enable diagnostics. |
| `vforth.sdImage` | `""` | `C:\Zx\CSpect\cspect-next-2gb.img` | The CSpect SD card image (`.img`). Required by the SD image tools. |
| `vforth.hdfmonkeyPath` | `"hdfmonkey"` | `C:\Zx\CSpect\hdfmonkey.exe` | Path to the `hdfmonkey` executable. |
| `vforth.sdDestPrefix` | `""` | `/tools/vforth` | Where the vForth root is mirrored inside the image; prepended to a file's path relative to `vforth.root`. |
| `vforth.sdExcludeTopDirs` | `["dev","doc","dot","emu","forum","project","prompts","tools","version"]` | (default) | Top-level directories not normally deployed to the SD card; pushing from one asks for confirmation. |

The author's setup, as it appears in `settings.json`:

```json
"vforth.root": "C:\\Zx\\Forth\\F18\\tools\\vForth\\",
"vforth.sdImage": "C:\\Zx\\CSpect\\cspect-next-2gb.img",
"vforth.hdfmonkeyPath": "C:\\Zx\\CSpect\\hdfmonkey.exe",
"vforth.sdDestPrefix": "/tools/vforth"
```

Notes:

- `vforth.sdImage` is the SD card **image** itself (the `.img` CSpect loads,
  with a FAT filesystem inside), not `!Blocks-64.bin` and not any other file
  that lives *inside* that image. Pointing it at `!Blocks-64.bin` is an easy
  slip (that path is right there in `vforth.root`) and fails with `hdfmonkey`
  unable to read a FAT filesystem from it.
- `vforth.hdfmonkeyPath` needs the full path unless `hdfmonkey` is already on
  `PATH`; a bare `hdfmonkey` that is not on `PATH` fails with `spawn hdfmonkey
  ENOENT`.
- `vforth.sdDestPrefix` is `/tools/vforth` here because the SD image mirrors
  the project under `/tools/vforth`, so `inc/word.f` lands in
  `/tools/vforth/inc/word.f` and the block store is read from
  `/tools/vforth/!Blocks-64.bin`. Leading and trailing slashes are optional. File names in the image are matched
  case-insensitively (FAT).
- `vforth.preloaded` is empty on purpose. `AUTOEXEC` is self-cleaning: it
  removes what it defines for the splash screen with `MARKER`. What it loads
  afterwards (`REMOUNT WHERE .S EDIT DUMP HEAP S" SEE`) depends on the answer
  to its `ASK-Y/N` prompt, so there is no sensible fixed default. Set this only
  if your own workflow loads extra utilities by hand before editing; the
  diagnostics then stop flagging their words.

For `.f` files the extension sets UTF-8 (identical to ASCII for 7-bit
text), LF line endings and whitespace-only word separators, so that a
double click selects a whole Forth word.

Colours can be tuned with `editor.semanticTokenColorCustomizations`:

```json
"editor.semanticTokenColorCustomizations": {
  "rules": { "vforthLibrary": "#4EC9B0", "vforthLocal": "#DCDCAA" }
}
```

## Send file to SD image

Writes the active file into the SD image with `hdfmonkey put`, so an edited
`.f` file can be tested without leaving VS Code. Unlike mounting the image
with imdisk (as `W:`, e.g. for a full-tree sync), `hdfmonkey` needs no
exclusive lock, so it works while CSpect is running. It pushes a single file:
it does not replace a full sync. It is a manual command (bind it to a key of
your choice); nothing is pushed on save. Files under a directory listed in
`vforth.sdExcludeTopDirs` ask for confirmation first.

No `REMOUNT` cycle is needed, unlike with `hdfm-gooey`: reads and writes both
work at any time, CSpect open or closed, and a running vForth session sees a
pushed file immediately (`NEEDS`/`INCLUDE` right after the push). The
`NEEDS`/`INCLUDE` itself stays manual.

## Pick file from SD image

The inverse of *Send file to SD image*: fetches the SD image's copy of the
active file (same relative path, same `vforth.sdDestPrefix`) with
`hdfmonkey get` and overwrites the local file. It asks for confirmation
first, warning that unsaved changes are lost, and does nothing if the two
copies are identical. Useful to bring back a file edited inside vForth on the
Spectrum side.

## Open Screen #

Opens a Screen (1024 bytes = 16 lines x 64 columns, 2 Blocks) from
`!Blocks-64.bin` in the SD image as an ordinary text document. It prompts for
the screen number, e.g. `11` for the AUTOEXEC screen. Saving (`Ctrl+S`)
validates all 16 lines (max 64 chars each, 7-bit ASCII, no NUL: a NUL
silently aborts `LOAD`) and only if valid patches the 1024 bytes back into
`!Blocks-64.bin`, leaving the rest of the block store untouched. On any
violation it reports the line and column instead of writing anything.

**Where the data lives.** A Screen is never a file on your PC: the only
persistent copy is inside `!Blocks-64.bin` on the SD image, and there is no
`nnn.f` counterpart in your workspace.

- *Open*: `hdfmonkey get` copies `!Blocks-64.bin` out of the image into a
  scratch file in the system temp folder; the extension decodes the 1024 bytes
  of the Screen from it and shows them as text.
- *Save*: the text is validated, the 1024 bytes are patched into a fresh
  scratch copy, and `hdfmonkey put` writes the whole file back into the image.
- The scratch file (`vforth-blocks-scratch.bin` in the temp folder) is only a
  transit area, overwritten on every open/save and never read back as a source
  of truth; it can be deleted at any time.

To move source between a Screen and a local `.f` file, copy and paste the text
by hand: the extension does not convert between them.

A ruler at column 64 and a border under line 16 mark the Screen's boundaries;
syntax highlighting matches `.f` files, since a Screen is ordinary vForth
source.

There is no byte-range read/write in `hdfmonkey`, so every open and every save
round-trips the whole 16 MB block store through it (`get`, then on save `put`).
It measured about 0.3 s combined against a real image with CSpect running.
The same applies to Blocks.

Known limit: the whole file is read, patched locally and written back, so a
write from inside CSpect to *another* block during that short window could in
principle be lost. It has not been observed.

## Open Block # (hex)

Opens a single Block (512 bytes, half a Screen) from `!Blocks-64.bin` as raw
bytes in the Hex Editor extension. Unlike *Open Screen #* there is no text
decoding or ASCII validation: any byte value is valid, so this is the way to
inspect and edit a Block that is not vForth source (a Layer 2 image, a sprite
table, a `PERSISTENCE` snapshot, the error-message table). Saving requires the
byte count to stay exactly 512: the size of the file must never change.

The data flow is the same as for Screens: nothing is stored on your PC beyond
the temporary scratch copy of `!Blocks-64.bin`; open is `hdfmonkey get`, save
patches the 512 bytes and writes the whole file back with `hdfmonkey put`.

## Next/Previous Screen or Block

With a Screen or Block editor active, `Ctrl+Shift+F8` / `Ctrl+Shift+F7` open
the next/previous one, replacing the current tab. The same pair of commands
works for both kinds of editor; outside a Screen/Block editor they do nothing
and show a warning. Rebind them from *Keyboard Shortcuts* if they clash with
something else in your setup (the `when` clause that scopes them is not
reliable while a Hex Editor webview has focus, which is why the keys are
`F7`/`F8` rather than more common combinations).

## Model

- Core: `src/F18e.f`, active `RENAME` table, plus `\` (defined directly).
- Index 1, `NEEDS` targets: `inc/*.f` then `lib/*.f`, by file name through
  `MAP-FN` (`: ? / * | \ < > "` -> `_ ^ % & $ _ { } ~`), case-insensitive.
  As in `NEEDS`, `lib/` is tried only if the word is still undefined after
  `inc/`.
- Index 2, providers: every word defined inside `inc/*.f` and `lib/*.f`.
  For a word defined in a multi-word file (e.g. `KEY-SCAN` in
  `inc/KEYBOARD.f`) the suggested `NEEDS` is the file's own word.
- `inc/doc/`, `lib/doc/`, `dev/`, `version/` are ignored. Files under
  `src/`, `version/`, `inc/doc/`, `lib/doc/` get no word diagnostics.
- User defining words (a colon body using `CREATE`, `<BUILDS` or another
  defining word, e.g. `LAYER:`), user parsing words (a colon body using
  `CHAR`, `WORD`, `PARSE`) and user comment words (a colon body doing
  `[COMPILE] \`) are inferred from the sources.
- `{ a b -- c }` locals are local definitions.
- `HEX` / `DECIMAL` / `BINARY` are tracked for number recognition.
- Every word referenced by a loaded file counts as available: a file that
  loads successfully had all of them defined.

Known limits: numbers in a `BASE` set by other means are not recognised
(they are ignored, never flagged); words created by unusual mechanisms
(e.g. `1FAMILY,` in the assembler) are not indexed as providers.

## Install

No compilation is required. Either copy this directory to
`%USERPROFILE%\.vscode\extensions\mattsteeldue.vforth-0.1.2` and reload
VS Code, or package it with `npx @vscode/vsce package` and install the
resulting `.vsix` with *Extensions: Install from VSIX...*.

If another extension (e.g. a Fortran one) also claims `.f`, pin it:

```json
"files.associations": { "*.f": "vforth" }
```

## Build and checks

The grammar is generated from the core source; regenerate it whenever the
`RENAME` table changes:

```
perl build/vforth-build.pl
perl build/vforth-build.pl --report help-report.txt
```

`--report` also writes a help coverage report: words without a `help/`
page, pages matching no definition, and inconsistencies of the
"Available after NEEDS" line.

Standalone checks against a vForth tree, no VS Code needed (Node.js):

```
node test/selftest.js <vForth root> [file.f ...]
node test/sweep.js <vForth root>
```

They cover the scanner and the model. The SD/Screen/Block commands are only
tested by hand in VS Code.
