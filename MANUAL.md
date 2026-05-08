# Neovim Field Manual

This is a hands-on guide for this config. It focuses on the shortcuts, motions,
and working habits that are most useful day to day.

Leader is `<Space>`.

## First Moves

| Goal | Keys | Notes |
| --- | --- | --- |
| See available leader groups | `<Space>` | `which-key` opens immediately. |
| Find files | `<leader>sf` | Telescope file picker. |
| Search text in project | `<leader>sg` | Uses ripgrep through Telescope. |
| Search current buffer | `<leader>/` | Compact in-buffer fuzzy search. |
| Switch buffers | `<leader><leader>` | Telescope buffer picker. |
| Previous / next buffer | `<S-h>` / `<S-l>` | Bufferline navigation. |
| Reveal file tree | `\` | Neo-tree reveal. |
| Open Oil explorer | `<leader>eo` | Editable directory buffer. |
| Format buffer | `<leader>f` | Conform, with LSP fallback. |
| Exit terminal mode | `<Esc><Esc>` | Easier than `<C-\><C-n>`. |

## Motions Worth Practicing

### Cursor and file movement

| Motion | Meaning | Practice |
| --- | --- | --- |
| `h j k l` | left, down, up, right | Use these before arrow keys. |
| `w` / `b` | next / previous word start | Move through identifiers quickly. |
| `e` / `ge` | next / previous word end | Useful before `c` and `d`. |
| `0` / `^` / `$` | line start, first nonblank, line end | Combine with `d`, `y`, `c`. |
| `gg` / `G` | file top / bottom | Prefix `G` with a line number. |
| `%` | matching pair | Parentheses, braces, brackets. |
| `{` / `}` | paragraph or block-ish movement | Good in Markdown and code blocks. |
| `<C-d>` / `<C-u>` | half-page down / up | Your `scrolloff=10` keeps context visible. |
| `<C-o>` / `<C-i>` | jump back / forward | `jumpoptions=clean,view` restores view better. |

### Search movement

| Motion | Meaning |
| --- | --- |
| `/text` | search forward |
| `?text` | search backward |
| `n` / `N` | next / previous match |
| `*` / `#` | search word under cursor forward / backward |
| `<Esc>` | clear search highlight |

Search is smart-case: lowercase searches are case-insensitive, mixed-case
searches become case-sensitive.

### One-character targeting

| Motion | Meaning | Example |
| --- | --- | --- |
| `f<char>` | move to next char | `f)` |
| `F<char>` | move to previous char | `F(` |
| `t<char>` | move before next char | `dt,` deletes until comma. |
| `T<char>` | move after previous char | `cT.` changes back to after dot. |
| `;` / `,` | repeat char search forward / backward | Works after `f`, `F`, `t`, `T`. |

## Editing Grammar

Vim editing is usually:

```text
operator + motion
```

| Operator | Meaning | Example |
| --- | --- | --- |
| `d` | delete | `dw`, `d$`, `di"` |
| `c` | change | `ciw`, `cib`, `ct,` |
| `y` | yank | `yiw`, `yap`, `y$` |
| `>` / `<` | indent / unindent | `>ip`, `<ap` |
| `=` | auto-indent | `=ip`, `gg=G` |
| `gq` | format text with `formatexpr` | Works with LSP when supported. |

Repeat with `.` after a good edit. This is the fastest way to turn one precise
edit into a batch of edits.

## Text Objects

Built-in text objects:

| Text object | Meaning | Example |
| --- | --- | --- |
| `iw` / `aw` | inner / around word | `ciw`, `daw` |
| `i"` / `a"` | inside / around quotes | `ci"`, `ya"` |
| `i'` / `a'` | inside / around single quotes | `ci'` |
| `i)` / `a)` | inside / around parentheses | `di)` |
| `i]` / `a]` | inside / around brackets | `ci]` |
| `i}` / `a}` | inside / around braces | `di}` |
| `ip` / `ap` | inner / around paragraph | `yap` |

Configured structural text objects:

| Text object | Meaning | Example |
| --- | --- | --- |
| `if` / `af` | inner / around function | `vaf`, `yif`, `daf` |
| `ic` / `ac` | inner / around class | `vac`, `yic`, `dac` |

`mini.ai` adds better around/inside behavior, and Treesitter textobjects add
function/class awareness.

## Search and Replace

| Goal | Keys |
| --- | --- |
| Help tags | `<leader>sh` |
| Keymaps | `<leader>sk` |
| Files | `<leader>sf` |
| Builtin pickers | `<leader>ss` |
| Word under cursor | `<leader>sw` |
| Live grep | `<leader>sg` |
| Diagnostics | `<leader>sd` |
| Resume last picker | `<leader>sr` |
| Recent files | `<leader>s.` |
| Commands | `<leader>sc` |
| Open-file grep | `<leader>s/` |
| Neovim config files | `<leader>sn` |
| Project search and replace | `<leader>sR` |

Hands-on flow:

1. Use `<leader>sg` to find a symbol or string.
2. Use `<C-q>` in Telescope when you want a quickfix list.
3. Use `<leader>sR` for real project edits with preview.
4. Use `<leader>f` after edits to format.

## LSP and Code Intelligence

| Goal | Keys |
| --- | --- |
| Rename symbol | `grn` |
| Code action | `gra` |
| References | `grr` or `<leader>gr` |
| Implementation | `gri` or `<leader>gi` |
| Definition | `grd` or `<leader>gd` |
| Declaration | `grD` or `<leader>gD` |
| Document symbols | `gO` |
| Workspace symbols | `gW` |
| Type definition | `grt` or `<leader>gt` |
| Toggle inlay hints | `<leader>th` |

This config also enables LSP CodeLens when the server supports it and linked
editing for servers that expose `textDocument/linkedEditingRange`.

## Diagnostics

| Goal | Keys |
| --- | --- |
| Previous diagnostic | `[d` |
| Next diagnostic | `]d` |
| Diagnostic details | `<leader>de` |
| Diagnostics location list | `<leader>q` |
| Yank diagnostic context | `<leader>dy` |
| Trouble all diagnostics | `<leader>xx` |
| Trouble workspace diagnostics | `<leader>xw` |
| Trouble current document | `<leader>xd` |
| Trouble quickfix | `<leader>xq` |
| Trouble loclist | `<leader>xl` |

Diagnostic display is intentionally quieter:

- Virtual text shows warnings and errors.
- Underlines are limited to errors.
- Diagnostic floats use rounded borders.
- Jumping diagnostics opens a focused-on-cursor float through `jump.on_jump`.

## Git

### Repository-level UI

| Goal | Keys |
| --- | --- |
| Open Neogit | `<leader>Gg` |
| Open Diffview | `<leader>Gd` |
| Close Diffview | `<leader>GD` |
| Current file history | `<leader>Gf` |
| Repository history | `<leader>GF` |

### Hunk-level work

| Goal | Keys |
| --- | --- |
| Next / previous hunk | `]c` / `[c` |
| Stage hunk | `<leader>hs` |
| Reset hunk | `<leader>hr` |
| Stage buffer | `<leader>hS` |
| Undo staged hunk | `<leader>hu` |
| Reset buffer | `<leader>hR` |
| Preview hunk | `<leader>hp` |
| Preview hunk inline | `<leader>hi` |
| Blame current line | `<leader>hb` |
| Diff against index | `<leader>hd` |
| Diff against last commit | `<leader>hD` |
| All hunks to quickfix | `<leader>hQ` |
| Current buffer hunks to quickfix | `<leader>hq` |
| Toggle current-line blame | `<leader>tb` |
| Toggle word diff | `<leader>tw` |
| Toggle deleted lines | `<leader>tD` |

In visual mode, `<leader>hs` and `<leader>hr` stage or reset the selected hunk
range.

## Buffers, Windows, and Sessions

| Goal | Keys |
| --- | --- |
| Previous / next buffer | `<S-h>` / `<S-l>` |
| Pick buffer | `<leader>bp` |
| Delete current buffer | `<leader>bd` |
| Delete all listed buffers | `<leader>bD` |
| Move left / right window | `<leader>wh` / `<leader>wl` |
| Move lower / upper window | `<leader>wj` / `<leader>wk` |
| Tmux-aware navigation | `<C-h/j/k/l>` |
| Restore session | `<leader>wr` |
| Restore last session | `<leader>wl` |
| Stop session save | `<leader>wd` |

Splits open to the right and below by default.

## Files and AI-Friendly References

| Goal | Keys |
| --- | --- |
| Neo-tree reveal | `\` |
| Oil explorer | `<leader>eo` |
| Harpoon add file | `<leader>a` |
| Harpoon menu | `<leader>hm` or `<C-e>` |
| Harpoon previous / next | `<C-S-P>` / `<C-S-N>` |
| Yank absolute file location | `<leader>ya` |
| Yank relative file location | `<leader>yr` |
| Yank current file as `@path` | `<leader>yf` |
| Yank current directory as `@dir` | `<leader>yd` |

The reference yanks include file, range, and symbol context when available.
They are useful for prompts, review comments, and issue descriptions.

## Tests and Debugging

### Neotest

| Goal | Keys |
| --- | --- |
| Run nearest test | `<leader>nr` |
| Run current file | `<leader>nf` |
| Run suite from cwd | `<leader>ns` |
| Debug nearest test | `<leader>nd` |
| Toggle summary | `<leader>nn` |
| Open output | `<leader>no` |
| Toggle output panel | `<leader>nO` |
| Attach | `<leader>na` |
| Stop run | `<leader>nS` |

### DAP

| Goal | Keys |
| --- | --- |
| Continue / start | `<F5>` |
| Step into | `<F1>` |
| Step over | `<F2>` |
| Step out | `<F3>` |
| Toggle breakpoint | `<leader>b` |
| Conditional breakpoint | `<leader>B` |
| Toggle DAP UI | `<F7>` |

Configured adapters include Go through `dap-go` when `dlv` exists, JS/TS through
`js-debug-adapter`, and C/C++ through `codelldb`.

## CMake, Markdown, and Code Context

| Goal | Keys |
| --- | --- |
| CMake generate | `<leader>cg` |
| CMake build | `<leader>cb` |
| CMake run | `<leader>cr` |
| CMake test | `<leader>ct` |
| CMake config | `<leader>cc` |
| Markdown preview | `<leader>mp` |
| Toggle Treesitter context | `<leader>tc` |
| Next function start | `<leader>jm` |
| Next function end | `<leader>jM` |
| Previous function start | `<leader>jk` |
| Previous function end | `<leader>jK` |
| Next class start | `<leader>jc` |
| Previous class start | `<leader>jC` |
| Open all folds | `zR` |
| Close all folds | `zM` |

## Completion and Snippets

Completion uses `blink.cmp` with LSP, paths, and snippets.

| Goal | Keys |
| --- | --- |
| Open completion/docs | `<C-Space>` |
| Next / previous item | `<C-n>` / `<C-p>` |
| Accept completion | `<C-y>` |
| Hide menu | `<C-e>` |
| Toggle signature help | `<C-k>` |

Supermaven is active on insert:

| Goal | Keys |
| --- | --- |
| Accept suggestion | `<Tab>` |
| Clear suggestion | `<C-]>` |
| Accept word | `<C-j>` |

## Config-Specific Habits

- Use `<leader>` groups by memory shape: `s` for search, `g` for goto, `G` for
  git UI, `h` for git hunks, `x` for Trouble, `n` for tests, `w` for windows
  and sessions, `y` for reference yanks.
- Keep relative line numbers on. For example, `d5j` deletes five lines down,
  and `y3k` yanks three lines up.
- Use `.` after focused edits. Example: `ciwnew_name<Esc>` then jump and press
  `.` to repeat.
- Prefer text objects over visual selection when possible: `ci"`, `di)`,
  `yaf`, `dac`.
- Use `<C-o>` after LSP jumps. Your jump list preserves view, so returning to
  the previous context is less disorienting.
- Use `<leader>dy`, `<leader>yr`, and `<leader>yf` when copying context for AI
  agents or code reviews.
- Do not rely on modelines for project settings. This config disables modelines
  for safer project-local behavior.

## Five-Minute Drill

1. Open a project with `nvim .`.
2. Press `<leader>sf`, open a file.
3. Use `/`, `n`, `N`, `w`, `b`, `%`, `<C-d>`, and `<C-u>` to move without the mouse.
4. Change a word with `ciw`, repeat the edit elsewhere with `.`.
5. Select a function with `vaf`, then try `yaf` and `daf` in a scratch file.
6. Jump to definition with `<leader>gd`, return with `<C-o>`.
7. Open diagnostics with `<leader>xx`, then jump with `[d` and `]d`.
8. Preview a git hunk with `<leader>hp`, then stage it with `<leader>hs`.
9. Run the nearest test with `<leader>nr`.
10. Copy an AI-friendly reference with `<leader>yr`.
