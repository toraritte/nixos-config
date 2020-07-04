# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# how the fuck does one get fetchFromGitHub to work here?
# Doesn't really matter because fetchGit and git-based ilk is a bad idea here, because `git` has to be installed and there is no `git` at initial configuration.nix, so this will fail anyway (even if it is specified in environment.systemPackages; at this point in execution only the builtins/primops can be used, or anything from the previous system build - which is non-existent on a fresh install). `fetchTarball` is a builtin so yay.
let
#   home-manager = builtins.fetchGit {
  home-manager = builtins.fetchTarball "https://github.com/rycee/home-manager/archive/1f174f668109765183f96b43d56ee24ab02c1c05.tar.gz";
#     url  = "https://github.com/rycee/home-manager.git";
#     rev    = "1f174f668109765183f96b43d56ee24ab02c1c05";
#     # sha256 = "06ba3nxkzva9q6dxzymyy62x75kf1qf7y8x711jwjravgda14bsq";
#   };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  home-manager.users.toraritte = {

    home.packages = with pkgs; [
      cifs-utils
      dmenu
      ffmpeg
      fzf
      google-chrome
      mc
      nixops
      par
      remmina
      signal-desktop
      silver-searcher
      st
      tor-browser-bundle-bin
    ];

    # the meaning is the same as `services.<x>.enable` in nixos - install and use with settings

    programs.bash = {
      enable = true;
      historyControl = [ "ignoredups" ];
      historySize = 1000000;
      historyFileSize = 1000000;

      # TODO source from file (e.g., .bashrc)
      initExtra = ''
        # If not running interactively, don't do anything
        # ... aaand what the hell this check means and why
        #     it matters.
        # http://unix.stackexchange.com/questions/257571/why-does-bashrc-check-whether-the-current-shell-is-interactive
        case $- in
            *i*) ;;
              *) return;;
        esac

        set -o vi

        # ==============================================================
        # prompt =======================================================
        # ==============================================================
        # + for staged, * if unstaged.
        GIT_PS1_SHOWDIRTYSTATE=1¬
        # $ if something is stashed.
        GIT_PS1_SHOWSTASHSTATE=1¬
        # % if there are untracked files.
        GIT_PS1_SHOWUNTRACKEDFILES=1¬
        # <,>,<> behind, ahead, or diverged from upstream.
        GIT_PS1_SHOWUPSTREAM=1
        # "She's saying ... a bunch of stuff. Look, have you tried drugs?"
        PS1='\[\e[33m\]$(__git_ps1 "%s") \[\e[m\]\[\e[32m\]\u@\h \[\e[m\] \[\e[01;30m\][\w]\[\033[0m\]\n\j \[\e[01;30m\][\t]\[\033[0m\] '
        # ==============================================================
        # history ======================================================
        # ==============================================================
        HISTCONTROL=ignoredups # no duplicate lines in history
        HISTSIZE=200000
        HISTFILESIZE=200000
        HISTTIMEFORMAT='%Y/%m/%d-%H:%M	'
        # ==============================================================
        # miscellaneous ================================================
        # ==============================================================
        # Make sure that tmux uses the right variable in order to
        # display vim colors correctly.
        TERM="screen-256color"
        EDITOR=$(which vim)
        MANWIDTH=80
        ERL_AFLAGS="-kernel shell_history enabled"

        # Android Studio would only open up with blank windows
        # https://unix.stackexchange.com/questions/368817/blank-android-studio-window-in-dwm/428908#428908
        export _JAVA_AWT_WM_NONREPARENTING=1

        # These are unnecessary on  NixOS, but who knows where
        # this file ends up.
        # LANG=en_US.UTF-8
        # LC_ALL="en_US.UTF-8"
        # LC_CTYPE="en_US.UTF-8"
        # LC_MESSAGES="C"

        # ==============================================================
        # fzf ==========================================================
        # ==============================================================
        FZF_DEFAULT_COMMAND='find .'
        FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
        FZF_ALT_C_COMMAND=$FZF_DEFAULT_COMMAND

        FZF_DEFAULT_OPTS="--height 70% +i"
        FZF_CTRL_R_OPTS=$FZF_DEFAULT_OPTS

        FZF_TMUX=$(which fzf-tmux)
        FZF_TMUX_OPTS=$FZF_DEFAULT_OPTS
        FZF_TMUX_HEIGHT="70%"

        FZF_ALT_C_OPTS=$FZF_DEFAULT_OPTS" --multi"
        FZF_CTRL_T_OPTS=$FZF_ALT_C_OPTS" --preview='head -$LINES {}'"
        FZF_COMPLETION_OPTS=$FZF_CTRL_T_OPTS
        # ==============================================================
        # unified bash history =========================================
        # ==============================================================
        # HIT ENTER FIRST IF LAST COMMAND IS NOT SEEN IN ANOTHER WINDOW
        # http://superuser.com/questions/37576/can-history-files-be-unified-in-bash
        # (`histappend` in `shellOptions` above is also part of this)
        PROMPT_COMMAND="''\${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r" # help history
        shopt -s histappend # man shopt
        # ==============================================================
        # shell options (cont.) ========================================
        # ==============================================================
        # Glob hidden files too with *
        shopt -s dotglob
        # Check the window size after each command and, if necessary,
        # update the values of LINES and COLUMNS.
        shopt -s checkwinsize
        # If set, the pattern "**" used in a pathname expansion context will
        # Match all files and zero or more directories and subdirectories.
        shopt -s globstar

        # Make `less` friendlier for non-text input files.
        # See lesspipe(1)
        [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

        # Set variable identifying the chroot you work in (used in the prompt below)
        if [ -z "''\${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
            debian_chroot=$(cat /etc/debian_chroot)
        fi

        # Enable bash support for FZF
        source "$(fzf-share)/key-bindings.bash"
        source "$(fzf-share)/completion.bash"

        # aliases ======================================================
        alias ll='ls -alF --group-directories-first --color'
        alias g='egrep --colour=always -i'
        alias ag='ag --hidden'
        alias b='bc -lq'
        alias dt="date +%Y/%m/%d-%H:%M"
        alias r='fc -s' # repeat the last command
        alias tmux='tmux -2' # make tmux support 256 color
        alias gl='git v --color=always | less -r'
        alias ga='git van --color=always | less -r'
        alias gd='git vn --color=always | less -r'
        alias glh="gl | head"
        alias gah="ga | head"
        alias gdh="gd | head"

        # http://www.gnu.org/software/bash/manual/bashref.html#Special-Parameters
        tl() {
          tree -C $@ | less -R
        }
      '';
      # TODO anything declared  in here only seem  to be set
      # from tmux  (some of  them) but  not on  st terminal;
      # maybe the way bash{rc,_profile} are handled?
      # sessionVariables = {
      # };
      # NOTE  As  `sessionVariables`  didn't seem  to  work,
      # leaving  this empty  too and  putting everything  in
      # `extraConfig` to make bash config less scattered.
      # shellAliases = {
      # };
    };

    programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;

      userName  = "Attila Gulyas";
      userEmail = "toraritte@gmail.com";

      delta.enable = true;
      delta.options = [ "--dark" ];

      aliases = {
        co = "checkout";
	br = "branch";
	ci = "commit";
	st = "status";
        lo = "log --pretty=format:\"%C(yellow)%h%Creset %s%n%C(magenta)%C(bold)%an%Creset %ar\" --graph";
	# https://stackoverflow.com/questions/21116069/decent-git-branch-visualization-tool#21116982
        van = "log --pretty=format:'%C(yellow)%h%Creset %ad %C(magenta)%C(bold)%cn%Creset %s %C(auto)%d%C(reset)' --all --graph --date=format:%Y/%m/%d_%H%M";
        vn = "log --pretty=format:'%C(yellow)%h%Creset %ad %s %C(auto)%d%C(reset)' --all --graph --date=format:%Y/%m/%d_%H%M";
        v = "log --graph --oneline --decorate --all";
	vo = "log --graph --decorate --all";
      };

      extraConfig = {
        merge = { tool = "vimdiff";};
        diff  = { tool = "vimdiff";};
      };
    };

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        commentary
        fastfold
        fugitive
        fzf-vim
        goyo
        limelight-vim
        repeat
        # seoul256
        surround
        tabular
        undotree
        vim-airline
        vim-airline-themes
        vim-bufferline
        vim-elixir
        vim-obsession
        vim-peekaboo
        # Consider using fugitive's `:Gdiff :0` instead
        # see https://stackoverflow.com/questions/15369499/how-can-i-view-git-diff-for-any-commit-using-vim-fugitive
        # vim-signify
        vim-unimpaired
        vim-vinegar
        wombat256
        gruvbox-community
        # yankring TODO: doesn't work and there is an update from 2019 that is not is vimPlugins yet
        YouCompleteMe
      ];
      # TODO read it from a .vimrc instead
      extraConfig = ''

        " colorscheme wombat256mod
        set background=dark
        let g:gruvbox_contrast_dark = 'hard'
        colorscheme gruvbox

        set encoding=utf-8
        set noequalalways
        set foldlevelstart=99
        set foldtext=substitute(getline(v:foldstart),'/\\*\\\|\\*/\\\|{{{\\d\\=',''\'','g')
        set modeline
        set autoindent expandtab smarttab
        set shiftround
        set nocompatible
        set cursorline
        " set list
        set number
        set relativenumber
        set incsearch hlsearch
        " set showcmd
        set laststatus=2
        set backspace=indent,eol,start
        set wildmenu
        set autoread
        set history=5000
        set noswapfile
        set fillchars="vert:|,fold: "
        set showmatch
        set matchtime=2
        set hidden
        set listchars=tab:⇥\ ,trail:␣,extends:⇉,precedes:⇇,nbsp:·,eol:¬
        set ignorecase
        set smartcase

        autocmd FileType erl setlocal ts=4 sw=4 sts=4 et

        " https://vi.stackexchange.com/questions/6/how-can-i-use-the-undofile
        if !isdirectory($HOME."/.vim")
            call mkdir($HOME."/.vim", "", 0770)
        endif
        if !isdirectory($HOME."/.vim/undo-dir")
            call mkdir($HOME."/.vim/undo-dir", "", 0700)
        endif
        set undodir=~/.vim/undo-dir
        set undofile

        " TODO airline-ify
        " set statusline=   " clear the statusline for when vimrc is reloaded
        " set statusline+=[%-6{fugitive#head()}]
        " set statusline+=%f\                          " file name
        " set statusline+=[%2{strlen(&ft)?&ft:'none'},  " filetype
        " set statusline+=%2{strlen(&fenc)?&fenc:&enc}, " encoding
        " set statusline+=%2{&fileformat}]              " file format
        " set statusline+=[%L\,r%l,c%c]            " [total lines,row,column]
        " set statusline+=[b%n,                      " buffer number
        " " window number, alternate file in which window (-1 = not visible)
        " set statusline+=w%{winnr()}]
        " set statusline+=%h%m%r%w                     " flags

        " === Scripts   {{{1
        " ===========

        " _$ - Strip trailing whitespace {{{2
        nnoremap _$ :call Preserve("%s/\\s\\+$//e")<CR>
        function! Preserve(command)
          " Preparation: save last search, and cursor position.
          let _s=@/
          let l = line(".")
          let c = col(".")
          " Do the business:
          execute a:command
          " Clean up: restore previous search history, and cursor position
          let @/=_s
          call cursor(l, c)
        endfunction

        " MakeDirsAndSaveFile (:M) {{{2

        " Created to be able to save a file opened with :edit where the path
        " contains directories that do not exist yet. This script will create
        " them and if they exist, `mkdir` will run without throwing an error.

        command! M :call MakeDirsAndSaveFile()
        " https://stackoverflow.com/questions/12625091/how-to-understand-this-vim-script
        " or
        " :h eval.txt
        " :h :fu
        function! MakeDirsAndSaveFile()
          " https://vi.stackexchange.com/questions/1942/how-to-execute-shell-commands-silently
          :silent !mkdir -p %:h
          :redraw!
          " ----------------------------------------------------------------------------------
          :write
        endfunction

        " === Key mappings    {{{1
        " ================

        " Temporarily enable/disable YouCompleteMe
        nnoremap <leader>e :unlet b:ycm_largefile<CR>
        " editing commands without YCM
        nnoremap <leader>i :let b:ycm_largefile = 1<CR>i
        nnoremap <leader>I :let b:ycm_largefile = 1<CR>I
        nnoremap <leader>o :let b:ycm_largefile = 1<CR>o
        nnoremap <leader>O :let b:ycm_largefile = 1<CR>O
        nnoremap <leader>a :let b:ycm_largefile = 1<CR>a
        nnoremap <leader>A :let b:ycm_largefile = 1<CR>A

        " Auto-close mappings {{{2
        " https://stackoverflow.com/a/34992101/1498178
        inoremap <leader>" ""<left>
        inoremap ` ``<left>
        inoremap <leader>' ''\''<left>
        inoremap <leader>( ()<left>
        inoremap <leader>[ []<left>
        inoremap <leader>{ {}<left>
        inoremap <leader>{<CR> {<CR>}<ESC>O
        autocmd FileType nix inoremap {<CR> {<CR>};<ESC>O

        " 44 instead of <C-^> {{{2
        nnoremap 44 <C-^>
        " 99 instead of <C-w>w {{{2
        nnoremap 99 <C-w>w

        " \yy - copy entire buffer to system clipboard {{{2
        nnoremap <leader>yy :%yank +<CR>

        " \ys - copy entire buffer to * {{{2
        nnoremap <leader>ys :%yank *<CR>

        " vil - inner line {{{2
        nnoremap vil ^vg_

        " <Leader>l - change working dir for current window only {{{2
        nnoremap <Leader>l :lcd %:p:h<CR>:pwd<CR>

        " <Space> instead of 'za' (unfold the actual fold) {{{2
        nnoremap <Space> za

        " <Leader>J Like gJ, but always remove spaces {{{2
        fun! JoinSpaceless()
            execute 'normal gJ'

            " Character under cursor is whitespace?
            if matchstr(getline('.'), '\%' . col('.') . 'c.') =~ '\s'
                " When remove it!
                execute 'normal dw'
            endif
        endfun
        nnoremap <Leader>J :call JoinSpaceless()<CR>

        " in NORMAL mode CTRL-j splits line at cursor {{{2
        nnoremap <NL> i<CR><ESC>

        " <C-p> and <C-n> instead of <Up>,<Down> on command line {{{2
        cnoremap <C-p> <Up>
        cnoremap <C-n> <Down>

        " {visual}* search {{{2
        xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
        xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>
        function! s:VSetSearch()
          let temp = @s
          norm! gv"sy
          let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
          let @s = temp
        endfunction

        "gp - http://vim.wikia.com/wiki/Selecting_your_pasted_text
        nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

        " === Plugin configuration   {{{1
        " ========================

        " peekaboo {{{2
        let g:peekaboo_window = 'belowright 30new'

        " airline {{{2
        let g:airline_theme='distinguished'
        let g:airline#extensions#bufferline#overwrite_variables = 0

        " fzf-vim {{{2
        nnoremap <leader><C-n> :History:<CR>
        nnoremap <leader><C-m> :History/<CR>
        nnoremap <leader><C-o> :Files<CR>
        nnoremap <leader><C-l> :Lines<CR>
        nnoremap <leader><C-r> :BLines<CR>
        nnoremap <leader><C-k> :Buffers<CR>
        nnoremap <leader><C-j> :Ag<CR>
        nnoremap <leader><C-w> :Windows<CR>
        nnoremap <leader><C-g> :Commits<CR>
        nnoremap <leader><C-p> :BCommits<CR>
        nnoremap <leader><C-h> :History<CR>
        nnoremap <leader><C-u> :Marks<CR>
        nnoremap <leader><C-i> :BD<CR>
        " TODO this may not be needed now that YouCompleteMe is used
        " imap <c-x><c-l> <plug>(fzf-complete-line)

        " https://github.com/junegunn/fzf.vim/pull/733#issuecomment-559720813
        function! s:list_buffers()
          redir => list
          silent ls
          redir END
          return split(list, "\n")
        endfunction

        function! s:delete_buffers(lines)
          execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
        endfunction

        command! BD call fzf#run(fzf#wrap({
          \ 'source': s:list_buffers(),
          \ 'sink*': { lines -> s:delete_buffers(lines) },
          \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
        \ }))

        " bufferline {{{2
        let g:bufferline_active_buffer_left = '['
        let g:bufferline_active_buffer_right = ']'
        let g:bufferline_fname_mod = ':.'
        let g:bufferline_pathshorten = 1
        let g:bufferline_rotate = 1

        " UndoTree {{{2
        let g:undotree_ShortIndicators = 1
        let g:undotree_CustomUndotreeCmd = 'vertical 32 new'
        let g:undotree_CustomDiffpanelCmd= 'belowright 12 new'

        " Goyo {{{2

        let g:goyo_width = 104

        function! s:goyo_enter()
          Limelight0.4
          UndotreeToggle
          " ...
        endfunction

        function! s:goyo_leave()
          Limelight!
          UndotreeToggle
          " ...
        endfunction

        autocmd! User GoyoEnter nested call <SID>goyo_enter()
        autocmd! User GoyoLeave nested call <SID>goyo_leave()

        " FastFold {{{2
        let g:markdown_folding = 1

        " netrw {{{2
        let g:netrw_winsize   = 30
        let g:netrw_liststyle = 3
      '';
    };

    # TODO only enable works
    # programs.fzf = {
    #   enable = true;
    #   # enableBashIntegration = true;
    #   # changeDirWidgetCommand = "pushd";
    #   # defaultCommand = "find .";
    # };

    programs.tmux = {
      enable = true;
      clock24 = true;
      historyLimit = 1000000;
      keyMode = "vi";
      extraConfig = ''
        set -g activity-action other
        # set -g assume-paste-time 1
        # set -g bell-action any
        # set -g default-command ""
        # set -g default-shell "/bin/bash"
        # set -g destroy-unattached off
        # set -g detach-on-destroy on
        set -g display-panes-active-colour red
        set -g display-panes-colour blue
        set -g display-panes-time 1000
        set -g display-time 750
        set -g key-table "root"
        set -g lock-after-time 0
        set -g lock-command "lock -np"
        set -g message-command-style fg=yellow,bg=black
        set -g message-style fg=black,bg=yellow
        set -g prefix C-b
        set -g prefix2 None
        set -g renumber-windows off
        set -g repeat-time 500
        set -g set-titles off
        set -g set-titles-string "#S:#I:#W - \"#T\" #{session_alerts}"
        set -g silence-action other
        set -g status on
        set -g status-interval 15
        set -g status-justify left
        set -g status-keys vi
        set -g status-left "[#S] "
        set -g status-left-length 10
        set -g status-left-style default
        set -g status-position bottom
        set -g status-right-length 100
        set -g status-right " #{=21:pane_title} %H:%M %d-%b-%y #(cat /sys/class/power_supply/BAT0/capacity) "
        set -g status-right-style default
        set -g status-style fg=black,bg=green
        set -g update-environment[0] "DISPLAY"
        set -g update-environment[1] "SSH_ASKPASS"
        set -g update-environment[2] "SSH_AUTH_SOCK"
        set -g update-environment[3] "SSH_AGENT_PID"
        set -g update-environment[4] "SSH_CONNECTION"
        set -g update-environment[5] "WINDOWID"
        set -g update-environment[6] "XAUTHORITY"
        set -g visual-activity off
        set -g visual-bell off
        set -g visual-silence off
        # set -g window-active-style bg=black,fg=colour249
        set -g window-style bg=colour234,fg=white
        set -g word-separators " -_@"

        # ctrl-b ctrl-F9 will toggle statuts bar visibility
        bind-key -n C-F9 set-option -g status
      '';
    };

  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # trace: warning: In file /etc/nixos/configuration.nix
  # a list is being assigned to the option config.boot.initrd.luks.devices.
  # This will soon be an error as type loaOf is deprecated.
  # See https://github.com/NixOS/nixpkgs/pull/63103 for more information.
  # Do
  #   boot.initrd.luks.devices =
  #     { root = {...}; }
  # instead of
  #   boot.initrd.luks.devices =
  #     [ { name = "root"; ...} ]
  boot.initrd.luks.devices = {
    luksroot = {
      device = "/dev/" CHANGE THIS;
      preLVM = true;
    };
  };

  networking.hostName = CHANGE THIS; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # Use `i18n.extraLocaleSettings`  to set  other locale
  # settings, but not needed  so far, because everything
  # is UTF8 (will see when it comes to postgres))
  # https://www.reddit.com/r/NixOS/comments/dck6o1/how_to_change_locale_settings/
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  # time.timeZone = "America/Sacramento";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # Leaving most of this empty and putting rest into the
    # `home-manager`  config.  Yes,  there  won't  be  any
    # `vim`  in  root  so  just  do  `sudo  $(which  vim)`
    # (maybe alias  it?) or,  if logged  in as  root, just
    # invoke `nix-shell '<nixpkgs>' -p vim` and Bob's your
    # uncle.'
    bind # for `dig` &c
    curl
    git
    htop
    mc
    pavucontrol
    tree
  ];

  # services.freeswitch.enable = true;
  services.tor.client.enable = true;

  # https://releases.nixos.org/nix-dev/2015-July/017657.html
  # https://nixos.org/nixos/options.html#services.logind
  # https://www.freedesktop.org/software/systemd/man/logind.conf.html
  services.logind.extraConfig = ''
    RuntimeDirectorySize=12G
    HandleLidSwitchDocked=ignore
  '';
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";
  services.xserver.windowManager.xmonad.enable = true;
  # TODO: how to configure xmobar? 14 pages, 14 different ways...

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  services.xserver.libinput.tapping = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.toraritte = {
    createHome = true;
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" ]; # Enable ‘sudo’ for the user.
    group = "users";
    home = "/home/toraritte";
    uid = 1000;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

