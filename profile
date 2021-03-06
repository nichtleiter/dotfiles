# ~/.profile: sourced by login shells and display managers.

# Adjust PATH.
# For pipsi:
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.dotfiles/usr/bin" ] && PATH="$HOME/.dotfiles/usr/bin:$PATH"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"

# Setup minimal pyenv environemt, to make it available for e.g. firefox started from awesome, calling gvim.
# Also done in ~/.zshenv.
if [ -d ~/.pyenv ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  PATH="$PYENV_ROOT/bin:$PATH"
  eval "$("$PYENV_ROOT"/bin/pyenv init -)"
  # Unset PYENV_SHELL=lightdm-session etc.  It will use $SHELL then by default.
  unset PYENV_SHELL
fi

# Enable core files (if apport ignores the crash, e.g. for Vim).
# 1048576 blocks =~ 512mb
# NOTE: controlled via /etc/security/limits.conf ?! (2015-05-05).
# ulimit -c 1048576

# Disable XON/XOFF flow control; this is required to make C-s work in Vim.
# NOTE: also in ~/.zshrc, to fix display issues during Vim startup (with
# subshell/system call).
stty -ixon 2>/dev/null

# Nix/NixOS.
# Ref: https://github.com/NixOS/nixpkgs/issues/6698
# export GTK_PATH="$GTK_PATH:$HOME/.nix-profile/lib/gtk-2.0:/usr/lib/gtk-2.0"
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Update/set tty information for gpg-agent.
# This should not get done for gnupg before 2.1 and/or on remote systems?!
if [ -f ~/.gnupg/gpg-agent.conf ]; then
  GPG_TTY="$(tty)"
  export GPG_TTY
  if grep -q '^enable-ssh-support' ~/.gnupg/gpg-agent.conf; then
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
      for i in "/var/run/user/$(id -u)/gnupg/S.gpg-agent.ssh" \
          "$HOME/.gnupg/S.gpg-agent.ssh"; do
        if [ -e "$i" ]; then
          export SSH_AUTH_SOCK="$i"
          break
        fi
      done
      unset i
    fi
  fi
fi

# For bash as a login-shell, also source ~/.bashrc (skipped then).
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi

# vim: ft=sh
