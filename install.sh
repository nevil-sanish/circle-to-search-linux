#!/usr/bin/env bash
# Install Circle to Search for Hyprland: deps, script, user service, keybinds.
# ./install.sh            install / update
# ./install.sh uninstall  remove everything except your API-key config
set -euo pipefail
cd "$(dirname "$0")"
BIN=~/.local/bin/circle-to-search
UNIT=~/.config/systemd/user/circle-to-search.service
MARK="# circle-to-search keybinds"

if [ "${1:-}" = uninstall ]; then
	systemctl --user disable --now circle-to-search 2>/dev/null || true
	rm -f "$BIN" "$UNIT"
	systemctl --user daemon-reload
	echo "Removed. Delete the '$MARK' lines from your Hyprland config yourself; keys stay in ~/.config/circle-to-search."
	exit 0
fi

[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || echo "warning: not inside Hyprland; it only works on Hyprland." >&2

check() {
	python3 - <<'PY' 2>/dev/null && command -v grim >/dev/null && command -v xdg-open >/dev/null
import gi, cairo, requests
gi.require_version("Gtk", "3.0"); gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, GtkLayerShell
PY
}

if ! check; then
	echo "Installing dependencies (sudo)…"
	if command -v pacman >/dev/null; then
		sudo pacman -S --needed --noconfirm python-gobject python-cairo gtk3 gtk-layer-shell grim python-requests xdg-utils
	elif command -v apt-get >/dev/null; then
		sudo apt-get install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-gtklayershell-0.1 grim python3-requests xdg-utils
	elif command -v dnf >/dev/null; then
		sudo dnf install -y python3-gobject python3-cairo gtk3 gtk-layer-shell grim python3-requests xdg-utils
	elif command -v zypper >/dev/null; then
		sudo zypper install -y python3-gobject python3-gobject-cairo gtk3 typelib-1_0-GtkLayerShell-0_1 grim python3-requests xdg-utils
	else
		echo "Unknown distro. Install: PyGObject, pycairo, GTK3, gtk-layer-shell, grim, python requests, xdg-utils." >&2
		exit 1
	fi
	check || { echo "Dependencies still missing, see above." >&2; exit 1; }
fi

install -Dm755 circle-to-search "$BIN"
install -Dm644 circle-to-search.service "$UNIT"
CTS_TEST=1 "$BIN" >/dev/null
systemctl --user daemon-reload
systemctl --user enable circle-to-search >/dev/null 2>&1
systemctl --user restart circle-to-search

# Keybinds: Ryoku user.lua, plain Lua config, or classic hyprland.conf.
H=~/.config/hypr
if [ -f "$H/user.lua" ]; then CONF=$H/user.lua; elif [ -f "$H/hyprland.lua" ]; then CONF=$H/hyprland.lua; else CONF=$H/hyprland.conf; fi
if ! grep -q "circle-to-search" "$CONF" 2>/dev/null; then
	if [ "${CONF##*.}" = lua ]; then
		cat >>"$CONF" <<'LUA'

-- circle-to-search keybinds: Ctrl+Alt+G = search with hidden answer, hold Ctrl+Alt+A = show it
hl.bind("CTRL + ALT + G", hl.dsp.exec_cmd("pkill -USR1 -f '/circle-to-search$'"))
hl.bind("CTRL + ALT + A", hl.dsp.exec_cmd("pkill -USR2 -f '/circle-to-search$'"), { repeating = true })
LUA
	else
		cat >>"$CONF" <<'CONF'

# circle-to-search keybinds: Ctrl+Alt+G = search with hidden answer, hold Ctrl+Alt+A = show it
bind = CTRL ALT, G, exec, pkill -USR1 -f '/circle-to-search$'
binde = CTRL ALT, A, exec, pkill -USR2 -f '/circle-to-search$'
CONF
	fi
	echo "Added keybinds to $CONF"
	hyprctl reload >/dev/null 2>&1 || true
fi

echo
echo "Done. Shake the mouse hard (or press Ctrl+Alt+G) and drag a box."
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "Add ~/.local/bin to your PATH for the next command." ;; esac
echo "For 'Ask AI', add a key and pick a model:  circle-to-search setup"
