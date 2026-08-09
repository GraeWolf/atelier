#!/bin/sh
# Build Atelier personal packages into repo/out (local XBPS repository).
#
# Uses xbps-create + xbps-rindex (no void-packages clone required).
# Suitable for metapackages and pure config packages in packages/.
#
# Usage:
#   ./scripts/build-repo.sh           # sync configs, build all, index
#   ./scripts/build-repo.sh --no-sync # skip config sync
#
# Output: repo/out/*.xbps and architecture repodata
# Never places or requires private signing keys.
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
# shellcheck source=lib/atelier-common.sh
. "$SCRIPT_DIR/lib/atelier-common.sh"

ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
PACKAGES_DIR="$ROOT/packages"
REPO_OUT="$ROOT/repo/out"
STAGE_ROOT="$ROOT/repo/work/stage"
BUILD_WITH="atelier-build-repo/0.1"

DO_SYNC=1
for arg in "$@"; do
	case "$arg" in
	--no-sync) DO_SYNC=0 ;;
	-h | --help)
		sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*)
		atelier_die "unknown argument: $arg"
		;;
	esac
done

command -v xbps-create >/dev/null 2>&1 || atelier_die "xbps-create not found (install xbps)"
command -v xbps-rindex >/dev/null 2>&1 || atelier_die "xbps-rindex not found (install xbps)"

# Package build order
PACKAGE_ORDER="atelier-base atelier-config atelier-desktop atelier-installer atelier-nvidia atelier-xlibre-repo atelier-void-repo"

if [ "$DO_SYNC" -eq 1 ]; then
	atelier_info "Syncing configs → atelier-config FILESDIR"
	"$ROOT/scripts/sync-atelier-config-files.sh"
	atelier_info "Syncing installer → atelier-installer FILESDIR"
	"$ROOT/scripts/sync-atelier-installer-files.sh"
	atelier_info "Syncing NVIDIA configs"
	"$ROOT/scripts/sync-atelier-nvidia-files.sh"
	atelier_info "Syncing Xlibre repo configs"
	"$ROOT/scripts/sync-atelier-xlibre-files.sh"
	atelier_info "Syncing GraeWolf void-repo configs"
	"$ROOT/scripts/sync-atelier-void-repo-files.sh"
fi

if [ -d "$STAGE_ROOT" ]; then
	if ! rm -rf "$STAGE_ROOT" 2>/dev/null; then
		mv "$STAGE_ROOT" "$STAGE_ROOT.stale.$$" 2>/dev/null || \
			atelier_die "cannot replace $STAGE_ROOT (root-owned from sudo ISO build?). Fix ownership and retry"
	fi
fi
mkdir -p "$STAGE_ROOT" "$REPO_OUT"

# Stage file tree for packages that ship files/
stage_from_files() {
	_stage=$1
	_files=$2
	[ -d "$_files" ] || atelier_die "missing $_files"
	mkdir -p "$_stage"
	# Copy top-level dirs (etc, usr, …) into stage root
	for _ent in "$_files"/*; do
		[ -e "$_ent" ] || continue
		cp -a "$_ent" "$_stage/"
	done
}

# Empty destdir for metapackages
stage_empty() {
	mkdir -p "$1"
}

build_one() {
	_name=$1
	_tpl="$PACKAGES_DIR/$_name/template"
	[ -f "$_tpl" ] || atelier_die "missing template: $_tpl"

	_pkgname=$(atelier_template_field "$_tpl" pkgname)
	_version=$(atelier_template_field "$_tpl" version)
	_revision=$(atelier_template_field "$_tpl" revision)
	_short=$(atelier_template_field "$_tpl" short_desc)
	_maint=$(atelier_template_field "$_tpl" maintainer)
	_license=$(atelier_template_field "$_tpl" license)
	_home=$(atelier_template_field "$_tpl" homepage)
	_depends=$(atelier_template_field "$_tpl" depends)
	# XBPS expects versioned dep patterns (e.g. foo>=0), matching Void templates.
	_depends=$(atelier_normalize_depends "$_depends")

	[ -n "$_pkgname" ] && [ -n "$_version" ] && [ -n "$_revision" ] || \
		atelier_die "template missing pkgname/version/revision: $_tpl"

	_full="${_pkgname}-${_version}_${_revision}"

	_stage="$STAGE_ROOT/$_pkgname"
	rm -rf "$_stage"
	mkdir -p "$_stage"

	case "$_pkgname" in
	atelier-config) stage_from_files "$_stage" "$PACKAGES_DIR/atelier-config/files" ;;
	atelier-installer) stage_from_files "$_stage" "$PACKAGES_DIR/atelier-installer/files" ;;
	atelier-nvidia) stage_from_files "$_stage" "$PACKAGES_DIR/atelier-nvidia/files" ;;
	atelier-xlibre-repo) stage_from_files "$_stage" "$PACKAGES_DIR/atelier-xlibre-repo/files" ;;
	*) stage_empty "$_stage" ;;
	esac

	atelier_info "Creating $_full (noarch)"

	# xbps-create writes the .xbps into the current directory
	_tmpcreate=$(mktemp -d)
	# shellcheck disable=SC2086
	(
		cd "$_tmpcreate"
		set -- \
			-A noarch \
			-n "$_full" \
			-s "$_short" \
			-m "$_maint" \
			-H "$_home" \
			-l "$_license" \
			-B "$BUILD_WITH"
		if [ -n "$_depends" ]; then
			set -- "$@" -D "$_depends"
		fi
		xbps-create "$@" "$_stage"
	)

	_xbps=$(find "$_tmpcreate" -maxdepth 1 -name '*.xbps' | head -n 1)
	[ -n "$_xbps" ] && [ -f "$_xbps" ] || atelier_die "xbps-create failed for $_pkgname"
	mv -f "$_xbps" "$REPO_OUT/"
	atelier_info "  → $REPO_OUT/$(basename "$_xbps")"
	rm -rf "$_tmpcreate"
}

atelier_info "Building packages into $REPO_OUT"
for pkg in $PACKAGE_ORDER; do
	build_one "$pkg"
done

atelier_info "Indexing repository (unsigned)"
# Force-add so re-runs replace same pkgver entries
for f in "$REPO_OUT"/*.xbps; do
	[ -f "$f" ] || continue
	xbps-rindex -f -a "$f"
done

atelier_info "Repository packages:"
xbps-query --repository="$REPO_OUT" -Rs atelier 2>/dev/null || \
	xbps-query --repository="$REPO_OUT" -s atelier 2>/dev/null || true

# List files for humans
ls -la "$REPO_OUT"

atelier_info "Done. Use with:"
printf '  xbps-query  --repository=%s -Rs atelier\n' "$REPO_OUT"
printf '  xbps-install --repository=%s -S atelier-desktop\n' "$REPO_OUT"
printf '  # or enable: repo/conf/10-repository-atelier-local.conf (see repo/README.md)\n'
