{ config, pkgs, lib, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = "aarch64-linux";
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "copilot.vim"
      ];
    };
  };
in
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];
  home.stateVersion = "24.11";
  home.username = "cod";
  home.homeDirectory = "/home/cod";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.package = pkgs.nix;

  home.packages = with unstable; [
    wl-clipboard
    openssh
    oh-my-posh wofi waybar vim htop
    neofetch btop
    tree home-manager
    hyprshot
    hyprpolkitagent
    papirus-icon-theme
    wget
    udiskie
    exfatprogs
    pywal
    hyprpaper
    swww
    ffmpeg-full
    yt-dlp
    superfile
    brightnessctl
    pamixer
    flatpak
    xdg-utils

    # Dependencies for NixVim
    eslint_d
    pylint
    stylelint
    shellcheck
    prettierd
    black
    shfmt
    ripgrep
    fd
    gnumake
    gcc
    nodejs
    yarn
    cargo
    perl
    openssl
    libnotify
    nodePackages.graphql-language-service-cli  # Add this
  ];

  home.sessionVariables = {
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS";
    ELECTRON_DISABLE_GPU = "1";
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # NixVim Configuration
  programs.nixvim = {
    enable = true;
    
    # General Vim Settings
    globals = {
      mapleader = " ";
      # python3_host_prog = "~/.pyenv/shims/python";
    };

    opts = {
      encoding = "utf-8";
      fileencoding = "utf-8";
      number = true;
      relativenumber = true;
      title = true;
      autoindent = true;
      smartindent = true;
      hlsearch = true;
      backup = false;
      showcmd = true;
      cmdheight = 0;
      laststatus = 0;
      expandtab = true;
      scrolloff = 10;
      inccommand = "split";
      ignorecase = true;
      smarttab = true;
      breakindent = true;
      shiftwidth = 2;
      tabstop = 2;
      wrap = false;
      backspace = [ "start" "eol" "indent" ];
      path = [ "**" ];
      wildignore = [ "*/node_modules/*" ];
      splitbelow = true;
      splitright = true;
      splitkeep = "cursor";
      mouse = "";
      formatoptions = "r";
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldenable = false;
      foldlevel = 0;
      foldlevelstart = 0;
    };

    # Plugins
    plugins = {
      neo-tree.enable = true;
      notify = {
        enable = true;
        settings = {
          background_colour = "#000000";
        };
      };
      web-devicons = {
        enable = true;
      };
      nvim-tree.enable = false; # Disable default NvimTree
      lsp = {
        enable = true;
        servers = {
          lua_ls = {  # changed from lua-ls
            enable = true;
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT";
                };
                diagnostics = {
                  globals = [ "vim" "nvim" ];
                };
                workspace = {
                  library = { __raw = "vim.api.nvim_get_runtime_file('', true)"; };
                  maxPreload = 1000;
                  preloadFileSize = 1000;
                };
                telemetry = {
                  enable = false;
                };
              };
            };
          };
          ts_ls = {
            enable = true;
            filetypes = [ "javascript" "javascriptreact" "typescript" "typescriptreact" ];
            extraOptions = {
              on_attach = ''
                function(client, bufnr)
                  client.server_capabilities.documentFormattingProvider = false
                  require('nvim.lsp').common_on_attach(client, bufnr)
                end
              '';
            };
          };
          pyright.enable = true;
          tailwindcss.enable = true;
          html.enable = true;
          cssls.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;
          dockerls.enable = true;
          graphql = {
            enable = true;
            package = null;
          };
          bashls.enable = true;
          eslint.enable = true;
          emmet_ls = {  # changed from emmet-ls
            enable = true;
            filetypes = [ "html" "css" "javascript" "javascriptreact" "typescriptreact" ];
          };
          clangd.enable = true;
        };
      };
      none-ls = {
        enable = true;
      };
      treesitter = {
        enable = true;
        settings = {
          highlight = {
            enable = true;
          };
          ensure_installed = [
            "javascript" "typescript" "tsx" "python" "html" "css" "json" "yaml"
            "gitignore" "graphql" "http" "scss" "sql" "vim" "lua"
          ];
        };
      };
      telescope.enable = true;
      dap.enable = true;
      bufferline.enable = true;
      toggleterm = {
        enable = true;
        settings = {
          size = 20;
          open_mapping = "[[<c-\\>]]";
          shade_factor = 2;
          direction = "float";
          float_opts = {
            border = "curved";
          };
        };
      };
      noice.enable = true;
      transparent.enable = true;
      lualine.enable = true;
      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
            { name = "luasnip"; }
          ];
        };
      };
      luasnip.enable = true;
      indent-blankline.enable = true;
      gitsigns.enable = true;
      comment.enable = true;
      alpha = {
        enable = true;
        settings = {
          theme = "dashboard"; # Basic theme to satisfy assertion
        };
      };
    };

    # Additional Plugins
    extraPlugins = with pkgs.vimPlugins; [
      nvim-dap
      undotree
      { plugin = harpoon; config = "lua require('harpoon'):setup()"; }
      nvim-spectre
      # rainbow_csv
      vim-visual-multi
      nvim-autopairs
      avante-nvim
      # copilot-vim
      nvim-ts-autotag
      hologram-nvim
      # tailwindcss-colorizer-cmp
      which-key-nvim
      mason-nvim
      mason-lspconfig-nvim
      plenary-nvim
      nvim-navic
      nvim-ts-context-commentstring
      schemastore-nvim
      bigfile-nvim
      friendly-snippets
      tokyonight-nvim
    ];

    # Keymappings
    keymaps = [
      { mode = "n"; key = "<leader>sf"; action = "require('telescope.builtin').find_files"; }
      { mode = "n"; key = "<leader>sg"; action = "require('telescope.builtin').live_grep"; }
      { mode = "n"; key = "<C-t>"; action = ":Neotree toggle<CR>"; }
      { mode = "n"; key = "x"; action = "\"_x"; }
      { mode = "v"; key = "d"; action = "\"_d"; }
      { mode = "n"; key = "<leader>ee"; action = "vim.diagnostic.open_float"; }
      { mode = "n"; key = "<leader>ed"; action = "<cmd>Telescope diagnostics<CR>"; }
      { mode = "n"; key = "<leader>eh"; action = "<cmd>Noice all<CR>"; }
      { mode = "n"; key = "<leader>rn"; action = "vim.lsp.buf.rename"; }
      { mode = "n"; key = "<leader>u"; action = ":UndotreeToggle<CR>:UndotreeFocus<CR>"; }
      { mode = "n"; key = "<leader>ha"; action = "lua require('harpoon'):list():add()"; }
      { mode = "n"; key = "<leader>hm"; action = "lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())"; }
      { mode = "n"; key = "<leader>h1"; action = "lua require('harpoon'):list():select(1)"; }
      { mode = "n"; key = "<leader>h2"; action = "lua require('harpoon'):list():select(2)"; }
      { mode = "n"; key = "<leader>h3"; action = "lua require('harpoon'):list():select(3)"; }
      { mode = "n"; key = "<leader>h4"; action = "lua require('harpoon'):list():select(4)"; }
      { mode = "n"; key = "<leader>hp"; action = "lua require('harpoon'):list():prev()"; }
      { mode = "n"; key = "<leader>hn"; action = "lua require('harpoon'):list():next()"; }
    ];

    # Extra Lua Configuration
      extraConfigLua = ''
        require("which-key").setup({
          triggers = {"<leader>"},
        })

        require("nvim-autopairs").setup()

        local wk = require("which-key")
        wk.register({
          h = {
            name = "Harpoon",
            a = { "<cmd>lua require('harpoon'):list():add()<cr>", "Add file" },
            m = { "<cmd>lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())<cr>", "Toggle menu" },
            ["1"] = { "<cmd>lua require('harpoon'):list():select(1)<cr>", "Select file 1" },
            ["2"] = { "<cmd>lua require('harpoon'):list():select(2)<cr>", "Select file 2" },
            ["3"] = { "<cmd>lua require('harpoon'):list():select(3)<cr>", "Select file 3" },
            ["4"] = { "<cmd>lua require('harpoon'):list():select(4)<cr>", "Select file 4" },
            p = { "<cmd>lua require('harpoon'):list():prev()<cr>", "Previous file" },
            n = { "<cmd>lua require('harpoon'):list():next()<cr>", "Next file" },
          },
        }, { prefix = "<leader>" })

        wk.register({
          e = {
            name = "Diagnostics",
            e = { "<cmd>lua vim.diagnostic.open_float()<CR>", "Open Error Float" },
            d = { "<cmd>Telescope diagnostics<CR>", "Error Diagnostics" },
            h = { "<cmd>Noice all<CR>", "Noice All" },
          },
        }, { prefix = "<leader>" })

        wk.register({
          t = {
            name = "Terminals",
            ["1"] = { "<cmd>ToggleTerm 1<CR>", "Terminal 1" },
            ["2"] = { "<cmd>ToggleTerm 2<CR>", "Terminal 2" },
            ["3"] = { "<cmd>ToggleTerm 3<CR>", "Terminal 3" },
            ["4"] = { "<cmd>ToggleTerm 4<CR>", "Terminal 4" },
            ["5"] = { "<cmd>ToggleTerm 5<CR>", "Terminal 5" },
            ["6"] = { "<cmd>ToggleTerm 6<CR>", "Terminal 6" },
            ["7"] = { "<cmd>ToggleTerm 7<CR>", "Terminal 7" },
            ["8"] = { "<cmd>ToggleTerm 8<CR>", "Terminal 8" },
            ["9"] = { "<cmd>ToggleTerm 9<CR>", "Terminal 9" },
            ["0"] = { "<cmd>ToggleTerm 10<CR>", "Terminal 10" },
          },
        }, { prefix = "<leader>" })

        require("neo-tree").setup({
          close_if_last_window = true,
          filesystem = {
            window = {
              position = "right",
              width = 25,
              mapping_options = {
                noremap = true,
                nowait = true,
              },
              mappings = {
                "<leader>p" = "image_preview",
              },
            },
            commands = {
              image_preview = function(state)
                local node = state.tree:get_node()
                if node.type == "file" then
                  local hologram = require("hologram")
                  hologram.setup {
                    auto_display = false,
                  }
                  local buf = vim.api.nvim_create_buf(false, true)
                  local width = vim.o.columns * 0.5
                  local height = vim.o.lines * 0.5
                  vim.api.nvim_open_win(buf, true, {
                    relative = "editor",
                    width = math.floor(width),
                    height = math.floor(height),
                    row = math.floor((vim.o.lines - height) / 2),
                    col = math.floor((vim.o.columns - width) / 2),
                    style = "minimal",
                    border = "rounded",
                  })
                  require('hologram.image'):new(node.path):display(1, 1, buf, {})
                else
                  vim.notify("Not a valid image file!", vim.log.levels.WARN)
                end
              end,
            },
          },
        })

        -- DAP Configuration
        local dap = require('dap')
        dap.adapters.node2 = {
          type = 'executable',
          command = 'node',
          args = { "${unstable.vimPlugins.nvim-dap}/out/src/nodeDebug.js" },
        }
        dap.configurations.javascript = {
          {
            name = 'Launch',
            type = 'node2',
            request = 'launch',
            program = "$\{file}",
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            protocol = 'inspector',
          },
        }

        vim.api.nvim_create_autocmd("BufWritePre", {
          callback = function()
            vim.lsp.buf.format()
          end,
        })

        -- Format on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          callback = function()
            vim.lsp.buf.format()
          end,
        })

        -- Configure none-ls
        local none_ls = require('none-ls')
        none_ls.setup({
          sources = {
            -- Formatting sources
            none_ls.builtins.formatting.prettierd.with({
              filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact", "vue", "html", "css", "json", "yaml" },
            }),
            none_ls.builtins.formatting.black.with({
              filetypes = { "python" },
            }),
            none_ls.builtins.formatting.stylelint.with({
              filetypes = { "css", "scss", "sass", "less" },
            }),
            none_ls.builtins.formatting.shfmt.with({
              filetypes = { "sh", "bash" },
            }),
            -- Diagnostics sources
            none_ls.builtins.diagnostics.eslint_d.with({
              filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact", "vue" },
            }),
            none_ls.builtins.diagnostics.pylint.with({
              filetypes = { "python" },
            }),
            none_ls.builtins.diagnostics.stylelint.with({
              filetypes = { "css", "scss", "sass", "less" },
            }),
            none_ls.builtins.diagnostics.shellcheck.with({
              filetypes = { "sh", "bash" },
            }),
          },
        })
  '';
  };

  # Flatpak configuration
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "md.obsidian.Obsidian"
      "com.bitwarden.desktop"
      "app.zen_browser.zen"
      "com.github.tchx84.Flatseal"
    ];
    uninstallUnmanaged = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };

  xdg.desktopEntries = {
    "md.obsidian.Obsidian" = {
      name = "Obsidian";
      comment = "Knowledge base";
      exec = "flatpak run --no-sandbox --branch=stable --arch=aarch64 --command=obsidian.sh --file-forwarding md.obsidian.Obsidian --js-flags=\"--nodecommit_pooled_pages\" --disable-gpu @@u %U @@";
      icon = "md.obsidian.Obsidian";
      terminal = false;
      type = "Application";
      categories = [ "Office" ];
      mimeType = [ "x-scheme-handler/obsidian" ];
    };
    "superfile" = {
      name = "Superfile (TUI)";
      genericName = "TUI File Manager";
      comment = "Fast and modern TUI file manager";
      exec = "superfile";
      icon = "utilities-terminal";
      terminal = true;
      categories = [ "Utility" "FileTools" ];
      mimeType = [ "inode/directory" ];
    };
  };

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";
    settings = {
      program_options = {
        password_prompt = "kitty -e udiskie-unlock";
      };
      device_config = [
        {
          device = "UUID=BF75-E4C0";
          automount = true;
        }
        {
          device = "UUID=73535e6c-db20-4edb-9a7d-3fe4f869b924";
          luks = true;
          automount = true;
        }
      ];
    };
  };

  programs.ssh.enable = true;

  programs.rofi = {
    enable = true;
    package = unstable.rofi-wayland;
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus";
    };
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "simple";
      plugins = [ "git" "common-aliases" "colored-man-pages" "z" ];
    };
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = unstable.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = unstable.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "fast-syntax-highlighting";
        src = unstable.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
    ];
  };

  programs.git = {
    enable = true;
    userName = "chowe99";
    userEmail = "chowej99@gmail.com";
  };

  home.file.".zshrc" = {
    text = ''
      export EDITOR=nvim
      alias vim=nvim
      eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
      alias switch="home-manager switch --flake ~/nix-config#cod"
      alias c="clear && neofetch"
      alias open="superfile"
      neofetch
      export PATH="$HOME/Applications:$PATH"
    '';
    force = true;
  };

  home.file.".config/rofi" = {
    source = "${inputs.dotfiles}/rofi";
    recursive = true;
  };
  home.file.".config/waybar" = {
    source = "${inputs.dotfiles}/waybar";
    recursive = true;
  };
  home.file.".config/hypr" = {
    source = "${inputs.dotfiles}/hypr";
    recursive = true;
  };
  home.file.".config/kitty" = {
    source = "${inputs.dotfiles}/kitty";
    recursive = true;
  };
}
