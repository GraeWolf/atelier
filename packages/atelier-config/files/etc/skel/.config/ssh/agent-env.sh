# Shared ssh-agent for this login/X session.
# Sourced from ~/.xinitrc and /etc/bash/bashrc.d/atelier.sh — do not execute.
# Socket is fixed under XDG_RUNTIME_DIR so new terminals find the same agent.
# Does not load keys (no ssh-add of identities); first git/ssh may still prompt once.

# Keep a forwarded or already-working agent.
if [ -n "${SSH_AUTH_SOCK:-}" ]; then
	ssh-add -l >/dev/null 2>&1
	if [ $? -ne 2 ]; then
		unset _ssh_dir _ssh_sock _ssh_need_start
		return 0 2>/dev/null || true
	fi
fi

_ssh_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
_ssh_sock="${_ssh_dir}/ssh-agent.socket"
_ssh_need_start=1

if [ ! -d "$_ssh_dir" ]; then
	mkdir -p "$_ssh_dir" 2>/dev/null || true
	chmod 700 "$_ssh_dir" 2>/dev/null || true
fi

if [ -S "$_ssh_sock" ]; then
	SSH_AUTH_SOCK="$_ssh_sock" ssh-add -l >/dev/null 2>&1
	if [ $? -ne 2 ]; then
		_ssh_need_start=0
	else
		rm -f "$_ssh_sock"
	fi
else
	rm -f "$_ssh_sock"
fi

if [ "$_ssh_need_start" -eq 1 ]; then
	command -v ssh-agent >/dev/null 2>&1 && ssh-agent -a "$_ssh_sock" >/dev/null
fi

if [ -S "$_ssh_sock" ]; then
	export SSH_AUTH_SOCK="$_ssh_sock"
fi

unset _ssh_dir _ssh_sock _ssh_need_start
