-- Prepend mise shims to PATH so Mason/LSP can find node, go, etc.
vim.env.PATH = vim.env.HOME .. '/.local/share/mise/shims:' .. vim.env.PATH

-- Set <space> as the leader key
-- See `:help mapleader`
-- Must happen before plugins are loaded.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o`

-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Default to 2-space indentation unless overridden by filetype/plugins
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

vim.filetype.add {
  extension = {
    mdx = 'mdx',
  },
  filename = {
    ['compose.yaml'] = 'yaml.docker-compose',
    ['compose.yml'] = 'yaml.docker-compose',
    ['docker-compose.yaml'] = 'yaml.docker-compose',
    ['docker-compose.yml'] = 'yaml.docker-compose',
    ['.gitlab-ci.yaml'] = 'yaml.gitlab',
    ['.gitlab-ci.yml'] = 'yaml.gitlab',
  },
  pattern = {
    ['.*/templates/.*%.yaml'] = 'helm',
    ['.*/templates/.*%.yml'] = 'helm',
    ['.*/values.*%.yaml'] = 'yaml.helm-values',
    ['.*/values.*%.yml'] = 'yaml.helm-values',
  },
}

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Modern UI defaults and safer project-local behavior.
vim.o.winborder = 'rounded'
vim.o.pumborder = 'rounded'
vim.o.pummaxwidth = 80
vim.o.smoothscroll = true
vim.o.modeline = false
vim.o.jumpoptions = 'clean,view'

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
local function diagnostic_on_jump(diagnostic)
  if diagnostic then vim.diagnostic.open_float { scope = 'cursor', focus = false } end
end

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    severity = { min = vim.diagnostic.severity.WARN },
    format = function(diagnostic)
      if diagnostic.severity == vim.diagnostic.severity.WARN then return 'W: ' .. diagnostic.message end
      if diagnostic.severity == vim.diagnostic.severity.ERROR then return 'E: ' .. diagnostic.message end
      return nil
    end,
  },
  virtual_lines = false,
  jump = { on_jump = diagnostic_on_jump },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1 } end, { desc = 'Go to previous [D]iagnostic' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1 } end, { desc = 'Go to next [D]iagnostic' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show [D]iagnostic [E]rror details' })
vim.keymap.set('n', '<leader>dy', function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local diagnostics = vim.diagnostic.get(0, { lnum = line - 1 })
  if #diagnostics == 0 then
    vim.notify('No diagnostics on this line', vim.log.levels.INFO)
    return
  end
  local file_path = vim.api.nvim_buf_get_name(0)
  local root = vim.fs.root(file_path, { '.git' }) or vim.fn.getcwd()
  local prefix = root:match '/$' and root or (root .. '/')
  local rel = file_path:sub(1, #prefix) == prefix and file_path:sub(#prefix + 1) or file_path
  local parts = {}
  for _, d in ipairs(diagnostics) do
    table.insert(parts, string.format('@%s:%d: %s', rel, d.lnum + 1, d.message))
  end
  local result = table.concat(parts, '\n')
  vim.fn.setreg('"', result)
  pcall(vim.fn.setreg, '+', result)
  vim.notify('Yanked ' .. #diagnostics .. ' diagnostic(s)', vim.log.levels.INFO)
end, { desc = '[D]iagnostic [Y]ank to clipboard' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  NOTE: <C-h/j/k/l> are managed by vim-tmux-navigator in this config.
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<leader>wh', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<leader>wl', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<leader>wj', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<leader>wk', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

local path_on_save_group = vim.api.nvim_create_augroup('kickstart-create-path-on-save', { clear = true })

-- Only create paths inside these roots (defaults to current working directory).
-- Add more roots as needed, e.g. vim.fn.expand '~/notes'
local path_create_roots = {
  vim.fn.getcwd(),
}

local is_in_allowed_root = function(path)
  local abs_path = vim.fn.fnamemodify(path, ':p')
  for _, root in ipairs(path_create_roots) do
    local abs_root = vim.fn.fnamemodify(root, ':p')
    if abs_path:sub(1, #abs_root) == abs_root then return true end
  end
  return false
end

local ensure_owner_rwx = function(path)
  local perms = vim.fn.getfperm(path)
  if perms ~= '' and perms:sub(1, 3) ~= 'rwx' then vim.fn.setfperm(path, 'rwx' .. perms:sub(4)) end
end

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Create missing parent directories on save',
  group = path_on_save_group,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= '' then return end

    local file_path = vim.api.nvim_buf_get_name(args.buf)
    if file_path == '' or file_path:match '^%w+://' then return end

    local uv = vim.uv or vim.loop
    local abs_path = vim.fn.fnamemodify(file_path, ':p')
    if not is_in_allowed_root(abs_path) then return end

    local parent = vim.fn.fnamemodify(abs_path, ':h')

    if uv.fs_stat(parent) == nil then vim.fn.mkdir(parent, 'p', '0700') end
    ensure_owner_rwx(parent)
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

local treesitter_parsers = {
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
}

-- [[ Configure and install plugins ]]
require('lazy').setup({
  { 'NMAC427/guess-indent.nvim', opts = {} },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    ---@module 'which-key'
    ---@type wk.Opts
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },

      spec = {
        { '<leader>a', group = 'Harpoon [A]dd' },
        { '<leader>c', group = '[C]Make' },
        { '<leader>d', group = '[D]iagnostics' },
        { '<leader>e', group = '[E]xplorer' },
        { '<leader>g', group = '[G]oto' },
        { '<leader>G', group = '[G]it' },
        { '<leader>m', group = '[M]arkdown' },
        { '<leader>n', group = '[N]eotest' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>w', group = '[W]indow' },
        { '<leader>x', group = 'Trouble' },
        { '<leader>j', group = '[J]ump' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
    },
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    enabled = true,
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set(
        'n',
        '<leader>/',
        function()
          builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        { desc = '[/] Fuzzily search in current buffer' }
      )

      vim.keymap.set(
        'n',
        '<leader>s/',
        function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        { desc = '[S]earch [/] in Open Files' }
      )

      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'mason-org/mason.nvim',
        ---@module 'mason.settings'
        ---@type MasonSettings
        ---@diagnostic disable-next-line: missing-fields
        opts = {},
      },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local builtin = require 'telescope.builtin'
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', builtin.lsp_references, '[G]oto [R]eferences')
          map('<leader>gr', builtin.lsp_references, '[G]oto [R]eferences')
          map('gri', builtin.lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>gi', builtin.lsp_implementations, '[G]oto [I]mplementation')
          map('grd', builtin.lsp_definitions, '[G]oto [D]efinition')
          map('<leader>gd', builtin.lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('<leader>gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', builtin.lsp_document_symbols, 'Open Document Symbols')
          map('gW', builtin.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')
          map('<leader>gt', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')

          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end

          if client and client:supports_method('textDocument/codeLens', event.buf) then vim.lsp.codelens.enable(true, { bufnr = event.buf }) end

          if client and client:supports_method('textDocument/linkedEditingRange', event.buf) then
            vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
          end
        end,
      })

      local vue_language_server_path = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node_modules/@vue/language-server'
      local vue_typescript_plugin = {
        name = '@vue/typescript-plugin',
        location = vue_language_server_path,
        languages = { 'vue' },
        configNamespace = 'typescript',
      }
      local has_go = vim.fn.executable 'go' == 1

      local servers = {
        -- Languages
        clangd = {},
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = 'standard',
                diagnosticMode = 'openFilesOnly',
              },
            },
          },
        },
        ruff = {},
        rust_analyzer = {},
        bashls = {},
        awk_ls = {},
        cssls = {},
        html = {},
        jsonls = {},
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ['https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.1-standalone-strict/all.json'] = {
                  '*.k8s.yaml',
                  'k8s/**/*.yaml',
                  'manifests/**/*.yaml',
                  'kubernetes/**/*.yaml',
                },
                ['https://json.schemastore.org/chart'] = 'Chart.yaml',
                ['https://json.schemastore.org/helmfile.json'] = 'helmfile.yaml',
                ['https://json.schemastore.org/kustomization.json'] = 'kustomization.yaml',
              },
            },
          },
        },
        taplo = {},
        elixirls = {},
        gh_actions_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = {
                globals = { 'vim' },
              },
              workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file('', true),
              },
            },
          },
        },
        eslint = {},
        astro = {},
        vue_ls = {},
        helm_ls = {},
        ts_ls = {
          filetypes = { 'vue' },
          init_options = {
            plugins = { vue_typescript_plugin },
          },
        },
        tailwindcss = {},
        docker_language_server = {},
        docker_compose_language_service = {},
        marksman = {},
        postgres_lsp = {},
        neocmake = {},
        buf_ls = {},
      }

      if has_go then
        servers.gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
                shadow = true,
              },
              staticcheck = true,
              gofumpt = true,
            },
          },
        }
      end

      if vim.fn.executable 'jq-lsp' == 1 then servers.jqls = {} end

      servers.marksman.filetypes = { 'markdown', 'mdx' }
      servers.tailwindcss.filetypes = {
        'astro',
        'css',
        'html',
        'javascript',
        'javascriptreact',
        'less',
        'markdown',
        'mdx',
        'sass',
        'scss',
        'svelte',
        'typescript',
        'typescriptreact',
        'vue',
      }

      ---@type MasonLspconfigSettings
      ---@diagnostic disable-next-line: missing-fields
      require('mason-lspconfig').setup {
        automatic_enable = vim.tbl_keys(servers or {}),
      }

      local ensure_installed = vim.tbl_filter(function(server_name) return server_name ~= 'gopls' and server_name ~= 'jqls' end, vim.tbl_keys(servers or {}))
      vim.list_extend(ensure_installed, {
        'stylua',
        'markdownlint',
        'prettierd',
        'prettier',
        'clang-format',
        'hadolint',
        'yamllint',
        'js-debug-adapter',
        'codelldb',
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for server_name, config in pairs(servers) do
        vim.lsp.config(server_name, config)
      end
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        jsonc = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
        c = { 'clang_format' },
        cpp = { 'clang_format' },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        opts = {},
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
      },

      appearance = {
        nerd_font_variant = 'mono',
      },

      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets' },
      },

      snippets = { preset = 'luasnip' },

      fuzzy = { implementation = 'lua' },

      signature = { enabled = true },
    },
  },

  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }

      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ---@module 'todo-comments'
    ---@type TodoOptions
    ---@diagnostic disable-next-line: missing-fields
    opts = { signs = false },
  },

  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()

      local bufremove = require 'mini.bufremove'
      bufremove.setup()
      vim.keymap.set('n', '<leader>bd', function() bufremove.delete(0, false) end, { desc = '[B]uffer [D]elete' })

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = function()
      if vim.fn.executable 'tree-sitter' ~= 1 then
        vim.notify('nvim-treesitter: tree-sitter CLI is required to install parsers', vim.log.levels.WARN)
        return
      end

      local ok, treesitter = pcall(require, 'nvim-treesitter')
      if ok then treesitter.install(treesitter_parsers, { summary = true }):wait(300000) end
    end,
    config = function()
      local treesitter = require 'nvim-treesitter'
      treesitter.setup()

      vim.api.nvim_create_user_command('TSInstallConfigured', function()
        if vim.fn.executable 'tree-sitter' ~= 1 then
          vim.notify('nvim-treesitter: install tree-sitter CLI first', vim.log.levels.ERROR)
          return
        end

        treesitter.install(treesitter_parsers, { summary = true }):raise_on_error()
      end, { desc = 'Install configured Treesitter parsers' })

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true }),
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },

  { import = 'custom.plugins' },
}, { ---@diagnostic disable-line: missing-fields
  rocks = { enabled = false },
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
