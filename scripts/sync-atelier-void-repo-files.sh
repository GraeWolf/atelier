#!/bin/sh
# Sync configs/void-repo + helpers → packages/atelier-void-repo/files/
set -eu

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
src="$root/configs/void-repo"
dst="$root/packages/atelier-void-repo/files"
helpers="$root/packages/atelier-void-repo/helpers"

[ -d "$src" ] || {
	printf 'error: missing %s\n' "$src" >&2
	exit 1
}

if [ -d "$dst" ]; then
	if ! rm -rf "$dst" 2>/dev/null; then
		mv "$dst" "$dst.stale.$$" 2>/dev/null || {
			printf 'error: cannot replace %s\n' "$dst" >&2
			exit 1
		}
	fi
fi

mkdir -p \
	"$dst/etc/xbps.d" \
	"$dst/var/db/xbps/keys" \
	"$dst/usr/bin" \
	"$dst/usr/share/doc/atelier" \
	"$dst/usr/share/atelier/void-repo/keys"

install -m 644 "$src/xbps.d/20-repository-graewolf.conf" \
	"$dst/etc/xbps.d/20-repository-graewolf.conf"
install -m 644 "$src/xbps-keys/94:85:7f:4b:ca:9e:0a:8c:e9:e5:42:dc:07:40:57:74.plist" \
	"$dst/var/db/xbps/keys/94:85:7f:4b:ca:9e:0a:8c:e9:e5:42:dc:07:40:57:74.plist"
install -m 755 "$helpers/atelier-setup-void-repo" \
	"$dst/usr/bin/atelier-setup-void-repo"
install -m 644 "$helpers/void-repo-README.txt" \
	"$dst/usr/share/doc/atelier/void-repo-README.txt"
# Copies for setup script paths under /usr/share/atelier/void-repo
install -m 644 "$src/xbps.d/20-repository-graewolf.conf" \
	"$dst/usr/share/atelier/void-repo/20-repository-graewolf.conf"
install -m 644 "$src/xbps-keys/94:85:7f:4b:ca:9e:0a:8c:e9:e5:42:dc:07:40:57:74.plist" \
	"$dst/usr/share/atelier/void-repo/keys/94:85:7f:4b:ca:9e:0a:8c:e9:e5:42:dc:07:40:57:74.plist"

printf 'Synced GraeWolf void-repo configs → %s\n' "$dst"
