{ config, pkgs, ... }:

{
    home.username = "ayush";
    home.homeDirectory = "/home/ayush";
    home.stateVersion = "25.11";

    targets.genericLinux.enable = true;
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
        brave
            vscode
            zed-editor
            mpv
            qbittorrent
            onlyoffice-desktopeditors
            kdePackages.kate
            localsend
            fastfetch
            btop
            code-cursor
            opencode
            codex
            alacritty
            nwg-look
            wayland-pipewire-idle-inhibit
            nerd-fonts.agave
    ];

    xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;

    programs.git = {
        enable = true;
        settings.user.name = "Ayush Sharma";
        settings.user.email = "sharmaayush4636@gmail.com";
    };

    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableZshIntegration = true;
    };

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        oh-my-zsh = {
            enable = true;
            plugins = [
                "git"
                    "z"
                    "python"
            ];
            theme = "robbyrussell";
        };

        shellAliases = {
            ll = "ls -la";
            update = "sudo nixos-rebuild switch";
        };

    };

    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        extraPackages = with pkgs; [
            ripgrep
                fd

                nil
                gopls
                rust-analyzer
                clang-tools
                pyright
                typescript-language-server
        ];

        plugins = with pkgs.vimPlugins; [
            catppuccin-nvim

                nvim-treesitter.withAllGrammars

                nvim-lspconfig
                telescope-nvim
                lualine-nvim
                nvim-cmp
                cmp-nvim-lsp
                cmp-buffer
                cmp-path
                luasnip
                cmp_luasnip
                friendly-snippets
                lspkind-nvim
        ];

        extraLuaConfig = ''
            -- == CORE OPTIONS ==
            vim.opt.number = true
            vim.opt.relativenumber = true
            vim.opt.clipboard = 'unnamedplus'
            vim.opt.tabstop = 4
            vim.opt.shiftwidth = 4
            vim.opt.expandtab = true
            vim.opt.incsearch = true
            vim.opt.ignorecase = true
            vim.opt.smartcase = true
            vim.opt.smartindent = true
            vim.opt.termguicolors = true

            -- == THEME & UI ==
            vim.cmd[[colorscheme catppuccin]]
            require('lualine').setup()

            -- == KEYBINDS ==
            vim.g.mapleader = " "
            vim.keymap.set('n', '<leader>o', ':Ex<CR>')

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files)
            vim.keymap.set('n', '<leader>fg', builtin.live_grep)

            -- == 1. AUTOCOMPLETION ENGINE ==
            local cmp = require('cmp')
            local luasnip = require('luasnip')
            local lspkind = require('lspkind') -- Load the icon plugin

            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                    -- Add beautiful rounded borders to the autocomplete windows
                    window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                    },
                    -- Configure the icons and formatting
                    formatting = {
                    format = lspkind.cmp_format({
                            mode = 'symbol_text', -- Show icon AND text
                            maxwidth = 50,        -- Prevent the box from getting too wide
                            ellipsis_char = '...',
                            menu = {              -- Show where the suggestion came from
                            buffer = "[Buf]",
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snip]",
                            path = "[Path]",
                            }
                            })
                    },
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                            end,
                    },
                    mapping = cmp.mapping.preset.insert({
                            ['<C-Space>'] = cmp.mapping.complete(),
                            ['<C-e>'] = cmp.mapping.abort(),
                            ['<Tab>'] = cmp.mapping(function(fallback)
                                    if cmp.visible() then
                                    cmp.confirm({select = true})
                                    else
                                    fallback()
                                    end
                                    end, { 'i' , 's' }),
                            ['<S-Tab>'] = cmp.mapping(function(fallback)
                                    if cmp.visible() then
                                    cmp.select_next_item()
                                    elseif luasnip.expand_or_jumpable() then
                                    luasnip.expand_or_jump()
                                    else
                                    fallback()
                                    end
                                    end, { 'i' , 's' }),
                            }),
                    sources = cmp.config.sources({
                            { name = 'nvim_lsp' },
                            { name = 'luasnip' },
                            }, {
                            { name = 'buffer' },
                            { name = 'path' },
                            })
            })

        -- == 2. LANGUAGE SERVERS (Neovim 0.11+ Native API) ==
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            vim.lsp.config('*', { capabilities = capabilities })

            vim.lsp.enable('nil_ls')
            vim.lsp.enable('gopls')
            vim.lsp.enable('rust_analyzer')
            vim.lsp.enable('clangd')
            vim.lsp.enable('pyright')
            vim.lsp.enable('ts_ls') -- Modern lspconfig uses 'ts_ls' for TypeScript

            -- LSP Keybinds
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
            '';
    };
}
