# nvim

Personal Neovim config based on `kickstart.nvim`, tuned for backend-heavy work
in JavaScript/TypeScript, C/C++, Kubernetes, and server development.

For the hands-on shortcut and motion guide, start with [MANUAL.md](MANUAL.md).

This README is the working manual for what is configured, why it exists, and
how to use it quickly.

## Design principles

- Additive, not disruptive: new plugins and mappings are added without replacing
  existing behavior.
- Modular plugin specs: each concern lives in `lua/custom/plugins/*.lua`.
- Terminal-friendly workflow: most actions map to short leader sequences and
  preserve CLI-first habits.
- Keep startup stable: major features are lazy-loaded by command, filetype, or
  explicit keymaps where possible.

## Repository layout

- `init.lua`: base options, core plugin setup, LSP, formatting, treesitter.
- `lua/custom/plugins/*.lua`: modular plugin specs and custom behavior.
- `doc/nvim.txt`: Vim help document (`:help nvim-config`).
- `lazy-lock.json`: plugin lockfile managed by lazy.nvim.

## Quick validation commands

Run these after config changes:
Kickstart.nvim targets *only* the latest
['stable'](https://github.com/neovim/neovim/releases/tag/stable) and latest
['nightly'](https://github.com/neovim/neovim/releases/tag/nightly) of Neovim.
If you are experiencing issues, please make sure you have at least the latest
stable version. Most likely, you want to install neovim via a [package
manager](https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-package).
To check your neovim version, run `nvim --version` and make sure it is not
below the latest
['stable'](https://github.com/neovim/neovim/releases/tag/stable) version. If
your chosen install method only gives you an outdated version of neovim, find
alternative [installation methods below](#alternative-neovim-installation-methods).

### Install External Dependencies

External Requirements:
- Basic utils: `git`, `make`, `unzip`, C Compiler (`gcc`)
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation),
  [fd-find](https://github.com/sharkdp/fd#installation)
- [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md#installation)
- Clipboard tool (xclip/xsel/win32yank or other depending on the platform)
- A [Nerd Font](https://www.nerdfonts.com/): optional, provides various icons
  - if you have it set `vim.g.have_nerd_font` in `init.lua` to true
- Emoji fonts (Ubuntu only, and only if you want emoji!) `sudo apt install fonts-noto-color-emoji`
- Language Setup:
  - If you want to write Typescript, you need `npm`
  - If you want to write Golang, you will need `go`
  - etc.

> [!NOTE]
> See [Install Recipes](#Install-Recipes) for additional Windows and Linux specific notes
> and quick install snippets

### Install Kickstart

> [!NOTE]
> [Backup](#FAQ) your previous configuration (if any exists)

Neovim's configurations are located under the following paths, depending on your OS:

| OS | PATH |
| :- | :--- |
| Linux, MacOS | `$XDG_CONFIG_HOME/nvim`, `~/.config/nvim` |
| Windows (cmd)| `%localappdata%\nvim\` |
| Windows (powershell)| `$env:LOCALAPPDATA\nvim\` |

#### Recommended Step

[Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this repo
so that you have your own copy that you can modify, then install by cloning the
fork to your machine using one of the commands below, depending on your OS.

> [!NOTE]
> Your fork's URL will be something like this:
> `https://github.com/<your_github_username>/kickstart.nvim.git`

You likely want to remove `lazy-lock.json` from your fork's `.gitignore` file
too - it's ignored in the kickstart repo to make maintenance easier, but it's
[recommended to track it in version control](https://lazy.folke.io/usage/lockfile).

#### Clone kickstart.nvim

> [!NOTE]
> If following the recommended step above (i.e., forking the repo), replace
> `nvim-lua` with `<your_github_username>` in the commands below

<details><summary> Linux and Mac </summary>

```sh
nvim --headless "+qa"
nvim --headless "+checkhealth" "+qa"
luac -p init.lua lua/custom/**/*.lua
```

Useful maintenance commands:

```sh
nvim --headless "+Lazy! sync" "+qa"
nvim --headless "+MasonToolsInstallSync" "+qa"
```

## Keymap manual

### Git workflow

- `<leader>Gg`: open Neogit UI
- `<leader>Gd`: open Diffview
- `<leader>GD`: close Diffview
- `<leader>Gf`: Diffview file history (current file)
- `<leader>GF`: Diffview repo history
- `<leader>h...`: Gitsigns hunk actions (`:which-key <leader>h`)

### Diagnostics and code navigation

- `<leader>gd`: goto definition
- `<leader>gD`: goto declaration
- `<leader>gr`: goto references
- `<leader>gi`: goto implementation
- `<leader>gt`: goto type definition
- `<leader>xx`: Trouble diagnostics
- `<leader>xw`: Trouble workspace diagnostics
- `<leader>xd`: Trouble current buffer diagnostics
- `<leader>xq`: Trouble quickfix list
- `<leader>xl`: Trouble location list
- `<leader>tc`: toggle treesitter context header
- `<leader>jm` / `<leader>jk`: next/previous function start
- `<leader>jM` / `<leader>jK`: next/previous function end
- `<leader>jc` / `<leader>jC`: next/previous class start
- Textobject select (operator-pending/visual): `af`/`if` for function, `ac`/`ic` for class

### Yank references (AI-friendly)

- `<leader>ya`: yank absolute reference with location and symbol
- `<leader>yr`: yank relative reference with location and symbol
- `<leader>yf`: yank current buffer file as `@relative/path`
- `<leader>yd`: yank current buffer parent directory as `@relative/dir`

### Tests and debug

- `<leader>nr`: neotest run nearest
- `<leader>nf`: neotest run current file
- `<leader>ns`: neotest run suite (cwd)
- `<leader>nd`: neotest debug nearest via DAP
- `<leader>nn`: neotest summary toggle
- `<leader>no`: neotest output for nearest test
- `<leader>nO`: neotest output panel toggle
- `<leader>na`: attach to running neotest process
- `<leader>nS`: stop neotest run

Existing DAP keys are unchanged:

- `<F5>` continue/start, `<F1>` step into, `<F2>` step over, `<F3>` step out
- `<F7>` toggle dap-ui, `<leader>b` toggle breakpoint, `<leader>B` conditional bp

### Search, replace, and explorer
After installing all the dependencies continue with the [Install Kickstart](#install-kickstart) step.

- `<leader>sR`: project search/replace with grug-far
- `<leader>eo`: open Oil explorer view (optional, non-default explorer)

### CMake workflow (optional)

- `<leader>cg`: CMake generate
- `<leader>cb`: CMake build
- `<leader>cr`: CMake run
- `<leader>ct`: CMake test
- `<leader>cc`: CMake select build type

## Plugin stack by workflow

### LSP and language intelligence

- `nvim-lspconfig` + `mason-lspconfig` + `mason-tool-installer`
- Vue integration:
  - `vue_ls` enabled
  - `ts_ls` scoped to `vue` with `@vue/typescript-plugin`
  - keeps `typescript-tools.nvim` available for TS/JS workflows
- Kubernetes/Helm integration:
  - `yamlls` with schema mappings for Kubernetes, Helm chart, Helmfile,
    and Kustomize
  - `helm_ls` enabled
  - `vim-helm` added for Helm syntax support

### Treesitter and structural editing

- `nvim-treesitter` uses current API (`require('nvim-treesitter').setup()`).
- `nvim-treesitter-context` provides sticky scope context.
- `nvim-treesitter-textobjects` adds structure-aware function/class jumps.

### Debugging
2. install all requirements using choco, exit the previous cmd and
open a new one so that choco path is set, and run in cmd as **admin**:
```
choco install -y neovim git ripgrep wget fd unzip gzip mingw make tree-sitter
```
</details>
<details><summary>WSL (Windows Subsystem for Linux)</summary>

```
wsl --install
wsl
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep fd-find tree-sitter-cli unzip git xclip neovim
```
</details>

- Core: `nvim-dap`, `nvim-dap-ui`, `mason-nvim-dap`, `nvim-dap-go`.
- JS/TS: `nvim-dap-vscode-js` configured with `js-debug-adapter` and
  `pwa-node` launch/attach defaults.
- C/C++: `codelldb` installation via Mason and baseline launch profile
  (`Launch current file (codelldb)`).

### Testing

- `neotest` core with adapters:
  - `neotest-jest`
  - `neotest-vitest`
  - `neotest-gtest`
```
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep fd-find tree-sitter-cli unzip git xclip neovim
```
</details>
<details><summary>Debian Install Steps</summary>

```
sudo apt update
sudo apt install make gcc ripgrep fd-find tree-sitter-cli unzip git xclip curl

Notes for C++ tests:

- `neotest-gtest` needs executable mapping per project (use `:ConfigureGtest`
  from the neotest summary window).

### Formatting and linting
```
sudo dnf install -y gcc make git ripgrep fd-find tree-sitter-cli unzip neovim
```
</details>

- Formatting via `conform.nvim`:
  - JS/TS/JSON/YAML: `prettierd` -> `prettier`
  - C/C++: `clang_format`
  - Lua: `stylua`
- Linting via `nvim-lint`:
  - markdown: `markdownlint`
  - dockerfile: `hadolint`
  - yaml / yaml.helm-values: `yamllint`

Linting is executable-aware for configured linters to avoid noisy diagnostics
when a linter binary is unavailable.

### Project workflow plugins

- `trouble.nvim`: focused diagnostics/issues panel
- `grug-far.nvim`: project-wide search/replace
- `oil.nvim`: optional file editing explorer (does not replace default explorer)
- `cmake-tools.nvim`: CMake build/run/test helpers (lazy and optional)

## Mason-managed tools and servers

This config ensures installation for key tools used by the workflows above,
including:

- `prettierd`, `prettier`, `clang-format`
- `hadolint`, `yamllint`, `markdownlint`, `stylua`
- `js-debug-adapter`, `codelldb`
- configured LSP servers from `servers` table (including `helm_ls`)

Check with `:Mason` and install manually if needed.

## Typical workflows

### JS/TS service workflow

1. Edit with LSP + treesitter context.
2. Run nearest test with `<leader>nr` or file with `<leader>nf`.
3. Debug test or code path with `<leader>nd` / `<F5>`.
4. Use `<leader>sR` for safe project refactors.

### C/C++ workflow

1. Navigate symbols with `<leader>jm/jk/jc/jC`.
2. Build/test with CMake mappings if project uses CMake.
3. Debug using existing DAP keys and select `Launch current file (codelldb)`.
4. Run gtest via neotest after `:ConfigureGtest` setup.

### Kubernetes/Helm workflow

1. Edit manifests with `yamlls` schema-backed completion/validation.
2. Edit charts/templates with Helm support (`helm_ls`, `vim-helm`).
3. Use `<leader>sR` for scoped multi-file YAML refactors.

## Troubleshooting

- Verify startup: `nvim --headless "+qa"`
- Verify health: `nvim --headless "+checkhealth" "+qa"`
- Verify LSP clients in current buffer: `:LspInfo`
- Verify formatter mapping: `:ConformInfo`
- Verify Mason state: `:Mason`
- Re-sync plugins: `:Lazy sync`

If a new feature appears missing, first confirm lazy-loading trigger
(keymap/filetype/command) was actually used.

## Help docs

This repo ships a Vim help file:

- `:help nvim-config`
- `:help nvimn-config`
```
sudo pacman -S --noconfirm --needed gcc make git ripgrep fd tree-sitter-cli unzip neovim
```
</details>

### Alternative neovim installation methods

For some systems it is not unexpected that the [package manager installation
method](https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-package)
recommended by neovim is significantly behind. If that is the case for you,
pick one of the following methods that are known to deliver fresh neovim versions very quickly.
They have been picked for their popularity and because they make installing and updating
neovim to the latest versions easy. You can also find more detail about the
available methods being discussed
[here](https://github.com/nvim-lua/kickstart.nvim/issues/1583).


<details><summary>Bob</summary>

[Bob](https://github.com/MordechaiHadad/bob) is a Neovim version manager for
all platforms. Simply install
[rustup](https://rust-lang.github.io/rustup/installation/other.html),
and run the following commands:

```bash
rustup default stable
rustup update stable
cargo install bob-nvim
bob use stable
```

</details>

<details><summary>Homebrew</summary>

[Homebrew](https://brew.sh) is a package manager popular on Mac and Linux.
Simply install using [`brew install`](https://formulae.brew.sh/formula/neovim).

</details>

<details><summary>Flatpak</summary>

Flatpak is a package manager for applications that allows developers to package their applications
just once to make it available on all Linux systems. Simply [install flatpak](https://flatpak.org/setup/)
and setup [flathub](https://flathub.org/setup) to [install neovim](https://flathub.org/apps/io.neovim.nvim).

</details>

<details><summary>asdf and mise-en-place</summary>

[asdf](https://asdf-vm.com/) and [mise](https://mise.jdx.dev/) are tool version managers,
mostly aimed towards project-specific tool versioning. However both support managing tools
globally in the user-space as well:

<details><summary>mise</summary>

[Install mise](https://mise.jdx.dev/getting-started.html), then run:

```bash
mise plugins install neovim
mise use neovim@stable
```

</details>

<details><summary>asdf</summary>

[Install asdf](https://asdf-vm.com/guide/getting-started.html), then run:

```bash
asdf plugin add neovim
asdf install neovim stable
asdf set neovim stable --home
asdf reshim neovim
```

</details>

</details>
