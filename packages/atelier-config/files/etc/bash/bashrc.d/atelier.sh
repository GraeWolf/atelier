# Atelier — bash snippet (installed under /etc/bash/bashrc.d/ or sourced from skel)
# Safe to source multiple times.

# Starship prompt (themed file from atelier-theme when present)
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/starship.toml" ]; then
	export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/starship.toml"
fi
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/shell-colors.sh" ]; then
	# shellcheck source=/dev/null
	. "${XDG_CONFIG_HOME:-$HOME/.config}/atelier/current/shell-colors.sh"
fi
if command -v starship >/dev/null 2>&1; then
	eval "$(starship init bash)"
fi

# Friendly aliases for PLAN CLI tools (eza replaces exa)
if command -v eza >/dev/null 2>&1; then
	alias ls='eza'
	alias ll='eza -l --group-directories-first'
	alias la='eza -la --group-directories-first'
	alias tree='eza --tree'
fi

if command -v bat >/dev/null 2>&1; then
	alias cat='bat --paging=never'
fi
