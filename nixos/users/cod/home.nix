{ config, pkgs, lib, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = "aarch64-linux";
    config.allowUnfree = true;
  };
in
{
  home.stateVersion = "24.11";
  home.username = "cod";
  home.homeDirectory = "/home/cod";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.package = pkgs.nix;

  home.packages = with unstable; [
    wl-clipboard
    openssh
    oh-my-posh wofi waybar vim htop zsh
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
      python3_host_prog = "~/.pyenv/shims/python";
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
      nvim-tree.enable = false; # Disable default NvimTree
      lsp = {
        enable = true;
        servers = {
          lua-ls = {
            enable = true;
            settings = {
              Lua = {
                runtime.version = "LuaJIT";
                diagnostics.globals = [ "vim" "lvim" ];
                workspace = {
                  library = { __raw = "vim.api.nvim_get_runtime_file('', true)"; };
                  maxPreload = 1000;
                  preloadFileSize = 1000;
                };
                telemetry.enable = false;
              };
            };
          };
          tsserver = {
            enable = true;
            filetypes = [ "javascript" "javascriptreact" "typescript" "typescriptreact" ];
            extraOptions = {
              on_attach = ''
                function(client, bufnr)
                  client.server_capabilities.documentFormattingProvider = false
                  require('lvim.lsp').common_on_attach(client, bufnr)
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
          graphql.enable = true;
          bashls.enable = true;
          eslint.enable = true;
          emmet-ls = {
            enable = true;
            filetypes = [ "html" "css" "javascript" "javascriptreact" "typescriptreact" ];
          };
          clangd.enable = true;
        };
      };

      null-ls = {
        enable = true;
        sources = {
          formatting = {
            prettierd = {
              filetypes = [ "javascript" "typescript" "typescriptreact" "javascriptreact" "vue" "html" "css" "json" "yaml" ];
            };
            black = {
              filetypes = [ "python" ];
            };
            stylelint = {
              filetypes = [ "css" "scss" "sass" "less" ];
            };
            shfmt = {
              filetypes = [ "sh" "bash" ];
            };
          };
          diagnostics = {
            eslint_d = {
              filetypes = [ "javascript" "typescript" "typescriptreact" "javascriptreact" "vue" ];
            };
            pylint = {
              filetypes = [ "python" ];
            };
            stylelint = {
              filetypes = [ "css" "scss" "sass" "less" ];
            };
            shellcheck = {
              filetypes = [ "sh" "bash" ];
            };
          };
        };
      };

      treesitter = {
        enable = true;
        ensureInstalled = [
          "javascript" "typescript" "tsx" "python" "html" "css" "json" "yaml"
          "gitignore" "graphql" "http" "scss" "sql" "vim" "lua"
        ];
        highlight.enable = true;
        autotag.enable = true;
      };

      telescope.enable = true;
      dap.enable = true;
      autopairs.enable = true;
      bufferline.enable = true;
      toggleterm = {
        enable = true;
        size = 20;
        openMapping = "<c-\\>";
        shadeFactor = 2;
        direction = "float";
        floatOpts.border = "curved";
      };
      noice.enable = true;
      notify.enable = true;
      neo-tree.enable = true;
      transparent.enable = true;
    };

    # Additional Plugins
    extraPlugins = with unstable.vimPlugins; [
      nvim-dap
      undotree
      { plugin = harpoon; config = "lua require('harpoon'):setup()"; }
      nvim-spectre
      rainbow_csv
      vim-visual-multi
      avante-nvim
      github-copilot
      nvim-ts-autotag
      tailwindcss-colorizer-cmp
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
      -- DAP Configuration
      local dap = require('dap')
      dap.adapters.node2 = {
        type = 'executable',
        command = 'node',
        args = { '${unstable.vimPlugins.nvim-dap}/out/src/nodeDebug.js' },
      }
      dap.configurations.javascript = {
        {
          name = 'Launch',
          type = 'node2',
          request = 'launch',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = 'inspector',
        },
      }

      -- Format on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function()
          vim.lsp.buf.format()
        end,
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
