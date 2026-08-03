# shellcheck shell=sh
# Shared helpers for Atelier build scripts. Source from repo scripts only.
# shellcheck disable=SC2034

atelier_root() {
	# Resolve monorepo root from a script in scripts/ or scripts/lib/
	_atelier_script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
	case "$_atelier_script_dir" in
	*/scripts/lib) CDPATH= cd -- "$_atelier_script_dir/../.." && pwd ;;
	*/scripts) CDPATH= cd -- "$_atelier_script_dir/.." && pwd ;;
	*) CDPATH= cd -- "$_atelier_script_dir/.." && pwd ;;
	esac
}

atelier_die() {
	printf 'error: %s\n' "$*" >&2
	exit 1
}

atelier_info() {
	printf '==> %s\n' "$*"
}

# Read a simple KEY=value or KEY="multi" field from a Void-style template.
# Usage: atelier_template_field <template> <key>
# Supports single-line values and double-quoted multi-line values ending at ".
atelier_template_field() {
	_tpl=$1
	_key=$2
	[ -f "$_tpl" ] || return 1

	# Multi-line double-quoted value: key=" ... "
	_val=$(awk -v key="$_key" '
		$0 ~ "^" key "=" {
			line = $0
			sub("^" key "=", "", line)
			if (line ~ /^"/) {
				sub(/^"/, "", line)
				if (line ~ /"$/) {
					sub(/"$/, "", line)
					print line
					exit
				}
				buf = line
				while ((getline line) > 0) {
					if (line ~ /"$/) {
						sub(/"$/, "", line)
						buf = buf "\n" line
						print buf
						exit
					}
					buf = buf "\n" line
				}
			} else {
				print line
				exit
			}
		}
	' "$_tpl") || true

	# Collapse depends whitespace to single spaces
	if [ "$_key" = "depends" ]; then
		_flat=$(printf '%s\n' "$_val" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//')
		printf '%s\n' "$_flat"
	else
		printf '%s\n' "$_val"
	fi
}

# Ensure each dependency token has a version constraint (Void style: pkg>=0).
# Tokens that already contain < > = or * are left unchanged.
atelier_normalize_depends() {
	_out=""
	for _dep in $1; do
		case "$_dep" in
		*[\<\>\=]* | *\**) _norm=$_dep ;;
		*) _norm="${_dep}>=0" ;;
		esac
		if [ -z "$_out" ]; then
			_out=$_norm
		else
			_out="$_out $_norm"
		fi
	done
	printf '%s\n' "$_out"
}
