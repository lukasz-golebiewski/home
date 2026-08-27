{ config, lib, pkgs, ... }:
{
  home.activation = {
    checkAppManagementPermission = lib.mkForce (lib.hm.dag.entryAnywhere "");
    cleanupHomeManagerApps = lib.hm.dag.entryBefore [ "copyApps" ] ''
      if [ -L "$HOME/Applications/Home Manager Apps" ]; then
        $DRY_RUN_CMD rm "$HOME/Applications/Home Manager Apps"
      fi
    '';
    # RunAtLoad only fires at login. Also add the key during switch.
    sshAddDefaultKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f "$HOME/.ssh/id_rsa" ]; then
        $DRY_RUN_CMD /usr/bin/ssh-add --apple-use-keychain "$HOME/.ssh/id_rsa" >/dev/null 2>&1 || true
      fi
    '';
  };
  home.homeDirectory = "/Users/lukasz";

  # Apple OpenSSH only. Portable/Nix OpenSSH skips it via IgnoreUnknown.
  programs.ssh.settings."*".UseKeychain = "yes";

  # Reload the default key from Keychain at login. Use Apple's ssh-add — Nix
  # OpenSSH does not understand --apple-use-keychain.
  launchd.agents.ssh-add-keychain = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.writeShellScript "ssh-add-default-key" ''
          key="${config.home.homeDirectory}/.ssh/id_rsa"
          [ -f "$key" ] || exit 0
          exec /usr/bin/ssh-add --apple-use-keychain "$key"
        ''}"
      ];
      RunAtLoad = true;
    };
  };
  home.packages = with pkgs; [
    libiconv
    ntfs3g
    watch
  ];

  # Set TMPDIR correctly for macOS
  home.sessionVariables = {
    TMPDIR = "\${TMPDIR}";
  };

  programs.tmux.extraConfig = ''
    set-option -g default-shell /bin/zsh
    set-option -g default-command $SHELL
  '';

  programs.zsh = {
    shellAliases = {
      "flushdns" = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
    };
    initContent = ''
      # Source the Nix profile for proper environment
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    '';
  };
}
