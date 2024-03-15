{ inputs, config, pkgs, ...}: 
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in 

{

  # imports (keep it minimal here)
  imports = [
    ./hardware-configuration.nix
  ];

  # bootloader options
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  # boot.loader.systemd-boot.enable = true;
  # boot.extraModprobeConfig = "options nvidia NVreg_RegistryDwords=\"PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3;\"\n";

  # networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # time 
  time.timeZone = "Europe/Berlin";

  # locale
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # configure console keymap
  console.keyMap = "de";

  # configure keymap in X11
  services.xserver = {
    #enable = true;
    layout = "de";
    xkbVariant = "";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ 
      # pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  # nvidia
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  programs.xwayland.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # nixfeatures
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowInsecure = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  system.stateVersion = "23.11";

  # sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # default user
  users.users.hallow = {
    password = "hallow";
    isNormalUser = true;
    description = "default user";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      vscode.fhs
    ];
  };


  # autologin
  services.getty.autologinUser = "hallow";

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER = "vulkan";
    NIXOS_OZONE_WL = "1";
  };

  environment.interactiveShellInit = ''
    alias e='nvim'
    alias nix-dev-rust='nix-shell ~/nixos/nix-shell/rust.nix'
  '';

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    font-awesome
  ];

  environment.systemPackages = with pkgs; [
    # tui/cli
    kitty
    vim
    neovim
    xclip
    git
    pipewire
    ranger
    btop
    unzip

    # gui
    unstable.hyprland # window manager
    pwvucontrol # audio control
    firefox-wayland # browser
    rofi-wayland # app launcher
    waybar (waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      })
    ) # top bar
    wev # get keyboard inputs
    dunst
    swww
    # flameshot
    unstable.hyprshot # screenshot
    feh # terminal image viewer

    # code
    python3

    # gui personal
    unstable.xwaylandvideobridge # does not work
    freetube
    obs-studio
    bottles

    # communication
    unstable.vesktop # discord but better
    unstable.discord
    # xdg-desktop-portal-wlr
    # xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland

    # flashy
    openrgb-with-all-plugins

    # productive
    unstable.obsidian

    # gaming
    minecraft
    prismlauncher # better minecraft launcher
    zulu17 # java for minecraft
    steam
    lutris

    # cursor theme
    glib
    gnome3.adwaita-icon-theme
    lxappearance-gtk2
  ];

}
