-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = { 'git', 'clone', '--filter=blob:none', 'https://github.com/nvim-mini/mini.nvim', mini_path }
  local result = vim.fn.system(clone_cmd)
  if vim.v.shell_error ~= 0 then
	  error("Failed to clone mini.nvim:\n" .. result)
  end
  vim.notify("Installed git directory at: " .. mini_path)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

require('mini.deps').setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later


now(function() 
  -- Space as the leader key
  vim.g.mapleader = ' '

  -- Other
  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.autoindent = true
  vim.o.wrap = false
  vim.o.smartcase = true
  vim.o.ignorecase = true
  vim.o.hlsearch = false
  vim.o.expandtab = true
  vim.o.tabstop = 4
  vim.o.shiftwidth = 4
  vim.o.softtabstop = 4
end)

now(function()
  -- Colorscheme
  -- add({ source = "catppuccin/nvim", name = "catppuccin" })
  add({ source = "folke/tokyonight.nvim", name = "tokyonight" })
  vim.cmd.colorscheme "tokyonight-night"
end)

now(function()
    require("mini.surround").setup()
end)

-- Status Line
now(function()
  add({
    source = 'nvim-lualine/lualine.nvim',
    depends = {'nvim-tree/nvim-web-devicons'}
  })
  require('lualine').setup()
end)

now(function()
  add({
    source = 'stevearc/oil.nvim'
  })
  require('oil').setup()
  vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
end)

-- Telescope fuzzy findr
now(function()
  add({
    source = 'nvim-telescope/telescope.nvim',
    depends = {'nvim-lua/plenary.nvim'}
  })
  require('telescope').setup({})
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
  vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
end)

-- Conform
now(function()
  add({
    source = 'stevearc/conform.nvim'
  })

  require('conform').setup({
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      markdown = { "prettier" },
      yaml = { "prettier" }
    }
  })
  -- Auto format on save
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",  -- or restrict to certain filetypes like "*.ts,*.tsx,*.lua"
    callback = function()
      require("conform").format({ async = false })  -- false = synchronous, true = async
    end
  })

  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
end)

-- LSP
now(function()
  add({
    source = 'williamboman/mason.nvim'
  })
  require('mason').setup()
end)

now(function()
  add({
    source = 'neovim/nvim-lspconfig',
    -- Supply dependencies near target plugin
    depends = { 'williamboman/mason.nvim' },
  })
end)

-- Completion
now(function()
  -- Core plugin
  add({ source = 'hrsh7th/nvim-cmp' })

  -- Completion sources
  add({ source = 'hrsh7th/cmp-nvim-lsp' })
  add({ source = 'hrsh7th/cmp-buffer' })
  add({ source = 'hrsh7th/cmp-path' })
  add({ source = 'hrsh7th/cmp-cmdline' })

  local cmp = require('cmp')

  -- Minimal config
  cmp.setup({
    mapping = cmp.mapping.preset.insert({
      ['<C-n>'] = cmp.mapping.select_next_item(),      -- Next suggestion
      ['<C-p>'] = cmp.mapping.select_prev_item(),      -- Previous suggestion
      ['<CR>']  = cmp.mapping.confirm({ select = true }), -- Confirm selection
      ['<C-Space>'] = cmp.mapping.complete(),          -- Trigger menu manually
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'buffer' },
      { name = 'path' },
    }),
    completion = {
      completeopt = 'menu,menuone,noinsert,noselect',
    },
  })

  -- Cmdline completion
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
    }
  })

  local lspconfig = require('lspconfig')
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- on_attach function to set keymaps for LSP
  local on_attach = function(client, bufnr)
    local opts = { noremap=true, silent=true, buffer=bufnr }

    -- Common LSP mappings
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)         -- Go to definition
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)               -- Hover documentation
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)     -- Go to implementation
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)     -- Rename
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts) -- Code actions
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)         -- List references
  end

  -- List of servers
  local servers = {
    'lua_ls', 'pyright', 'vtsls', 'jsonls', 'marksman',
    'cssls', 'emmet_ls', 'html', 'tailwindcss'
  }

  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup{
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end
end)

later(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    -- Use 'master' while monitoring updates in 'main'
    checkout = 'master',
    monitor = 'main',
    -- Perform action after every checkout
    hooks = { post_checkout = function()
      vim.cmd('TSUpdate')
    end },
  })

  -- Possible to immediately execute code which depends on the added plugin
  require('nvim-treesitter.configs').setup({
    ensure_installed = { 'lua', 'vimdoc', 'vim', 'css', 'elm', 'gitcommit', 'html', 'javascript', 'json', 'json5', 'typescript', 'tsx'},
    highlight = { enable = true },
  })
end)
