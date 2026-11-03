# Atelier — bash snippet (installed under /etc/bash/bashrc.d/ or sourced from skel)
# Safe to source multiple times.

# Reuse (or start) the session ssh-agent so git/ssh do not re-prompt
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/ssh/agent-env.sh" ]; then
	# shellcheck source=/dev/null
	. "${XDG_CONFIG_HOME:-$HOME/.config}/ssh/agent-env.sh"
fi

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
	# bat has no built-in "tokyonight". Ship Folke's theme and rebuild the
	# per-user cache when the installed file or the cache is stale.
	# Existing sessions already export BAT_THEME=tokyonight from atelier-theme.
	_bat_src=/usr/share/atelier/bat/tokyonight.tmTheme
	_bat_dir=${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes
	_bat_dst=$_bat_dir/tokyonight.tmTheme
	_bat_cache=${XDG_CACHE_HOME:-$HOME/.cache}/bat/themes.bin
	if [ -f "$_bat_src" ]; then
		mkdir -p "$_bat_dir" 2>/dev/null || true
		if [ ! -f "$_bat_dst" ] || [ "$_bat_src" -nt "$_bat_dst" ]; then
			cp -f "$_bat_src" "$_bat_dst" 2>/dev/null || true
		fi
		if [ -f "$_bat_dst" ] && { [ ! -f "$_bat_cache" ] || [ "$_bat_dst" -nt "$_bat_cache" ]; }; then
			bat cache --build >/dev/null 2>&1 || true
		fi
	fi
	unset _bat_src _bat_dir _bat_dst _bat_cache
	alias cat='bat --paging=never'
fi

# Prefix history: Up/Down cycle lines that start with the current prefix.
# Cursor stays on the typed prefix so further arrows keep matching that family.
# Bind CSI and SS3 sequences (Ghostty, xterm, TTY). Interactive-only here
# because Void sources /etc/bash/bashrc.d only for interactive shells.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\eOA": history-search-backward'
bind '"\eOB": history-search-forward'
