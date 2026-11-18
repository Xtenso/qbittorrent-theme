#!/usr/bin/with-contenv bash
# Nightseed for the qBittorrent WebUI: build the theme for whatever qBittorrent
# version this container runs.
#
# The linuxserver image runs every script in /custom-cont-init.d at start-up,
# before qBittorrent starts. This one checks the installed version and, when the
# theme was built for a different one (or not yet), downloads that release's
# WebUI from GitHub and themes it. Otherwise it does nothing, so normal restarts
# cost nothing.
#
# The linuxserver image starts init scripts with a cleaned environment;
# with-contenv (part of the image) hands them the container's variables.
#
# Choosing the style, either way (the variable wins):
#   - a file "style" in the theme sources folder, containing one word
#   - the container variable NIGHTSEED_STYLE
#   nightseed (default) | alternative | oled | auto | alternative-auto
#   (auto: Nightseed in dark mode, a light design in light mode, following the
#   WebUI's own Options -> Behavior -> Color scheme: Auto, Light or Dark;
#   alternative-auto: the same for Nightseed Alternative)
#
# Other settings (container variables, rarely needed):
#   NIGHTSEED_SRC     theme sources       (default /config/nightseed-src)
#   NIGHTSEED_OUT     built WebUI         (default /config/nightseed)
#   NIGHTSEED_ICONS   icon set            (default: icons/ in the sources folder,
#                                          or source/icons/ in a clone of the repo)
#
# Switching the style by hand: run the script with "choose" for a menu, or with
# the style's name; it saves the choice in the style file and rebuilds now:
#   docker exec -it qbittorrent bash /custom-cont-init.d/nightseed.sh choose
#   docker exec qbittorrent bash /custom-cont-init.d/nightseed.sh alternative-auto
# (at start-up the image runs it with no arguments, which only builds)
#
# In qBittorrent: Options -> WebUI -> Use alternative WebUI -> /config/nightseed

SRC="${NIGHTSEED_SRC:-/config/nightseed-src}"

log() { echo "[nightseed] $*"; }

STYLES="nightseed alternative oled auto alternative-auto"
describe() {
    case "$1" in
        nightseed) echo "rows coloured by state, green progress bars" ;;
        alternative) echo "state icons, progress bars in each state's colour" ;;
        oled) echo "Nightseed on true black" ;;
        auto) echo "Nightseed, light or dark with the WebUI's Color scheme" ;;
        alternative-auto) echo "Alternative, light or dark with the WebUI's Color scheme" ;;
    esac
}

if [ $# -gt 0 ]; then
    if [ -n "$NIGHTSEED_STYLE" ]; then
        log "the container variable NIGHTSEED_STYLE=$NIGHTSEED_STYLE sets the style and wins over the style file; change or remove it instead"
        exit 1
    fi
    if [ ! -d "$SRC" ]; then
        log "no theme sources in $SRC"
        exit 1
    fi
    CHOICE="$1"
    if [ "$CHOICE" = choose ]; then
        CURRENT="$(tr -d ' \t\r\n' < "$SRC/style" 2>/dev/null)"
        CURRENT="${CURRENT:-nightseed}"
        echo "Nightseed styles (* = current):"
        i=0
        for s in $STYLES; do
            i=$((i + 1))
            mark=" "; [ "$s" = "$CURRENT" ] && mark="*"
            printf ' %s %d) %-17s %s\n' "$mark" "$i" "$s" "$(describe "$s")"
        done
        if ! read -r -p "Choose 1-5 (Enter to cancel): " n; then
            echo
            log "no answer (to get the menu, run it with docker exec -it); nothing changed"
            exit 1
        fi
        [ -z "$n" ] && { log "cancelled; nothing changed"; exit 0; }
        CHOICE="$(echo $STYLES | cut -d' ' -f"$n" 2>/dev/null)"
        case "$n" in [1-5]) ;; *) CHOICE="" ;; esac
        if [ -z "$CHOICE" ]; then
            log "'$n' isn't 1-5; nothing changed"
            exit 1
        fi
    fi
    case " $STYLES " in
        *" $CHOICE "*) ;;
        *) log "unknown style '$CHOICE' (use choose, or one of: $STYLES)"; exit 1 ;;
    esac
    printf '%s\n' "$CHOICE" > "$SRC/style" || { log "couldn't write $SRC/style"; exit 1; }
    log "style set to $CHOICE"
fi

STYLE="$NIGHTSEED_STYLE"
if [ -z "$STYLE" ] && [ -f "$SRC/style" ]; then
    STYLE="$(tr -d ' \t\r\n' < "$SRC/style")"
fi
STYLE="${STYLE:-nightseed}"
OUT="${NIGHTSEED_OUT:-/config/nightseed}"
QBT="${NIGHTSEED_QBT:-qbittorrent-nox}"

case "$STYLE" in
    nightseed) PARTS="rows hide-state-icons bars-standard" ;;
    alternative) PARTS="rows alternative" ;;
    oled) PARTS="rows hide-state-icons bars-standard oled" ;;
    auto) PARTS="rows hide-state-icons bars-standard light" ;;
    alternative-auto) PARTS="rows alternative light" ;;
    *) log "unknown NIGHTSEED_STYLE '$STYLE' (use nightseed, alternative, oled, auto or alternative-auto); skipping"; exit 0 ;;
esac

if [ ! -f "$SRC/core.css" ]; then
    log "no theme sources in $SRC; skipping"
    exit 0
fi
for part in $PARTS; do
    if [ ! -f "$SRC/parts/$part.css" ]; then
        log "$SRC/parts/$part.css is missing (the $STYLE style needs it); leaving the theme as it is"
        exit 0
    fi
done

# the release package ships the icons inside the sources folder; in a clone of
# the repo they're the desktop theme's own, in source/icons
ICONS="${NIGHTSEED_ICONS:-$SRC/icons}"
[ -d "$ICONS" ] || ICONS="$SRC/../source/icons"
if [ ! -d "$ICONS" ]; then
    log "no icons in $SRC/icons or $SRC/../source/icons; skipping"
    exit 0
fi

# the qBittorrent version: the linuxserver image records it in /build_version
# ("Linuxserver.io version: 5.3.0_v2.1.2-ls487" -> 5.3.0); otherwise ask the
# program itself ("qBittorrent v5.3.0" -> 5.3.0), wherever the image keeps it
BUILD_VERSION="${NIGHTSEED_BUILD_VERSION:-/build_version}"
VERSION=""
if [ -f "$BUILD_VERSION" ]; then
    VERSION="$(sed -n 's/.*version:[[:space:]]*\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' "$BUILD_VERSION" | head -n 1)"
fi
if [ -z "$VERSION" ]; then
    for bin in "$QBT" /usr/bin/qbittorrent-nox /usr/local/bin/qbittorrent-nox /app/qbittorrent-nox; do
        if command -v "$bin" >/dev/null 2>&1; then
            VERSION="$("$bin" --version 2>/dev/null | sed -n 's/.*v\([0-9][0-9.]*\).*/\1/p' | head -n 1)"
            [ -n "$VERSION" ] && break
        fi
    done
fi
if [ -z "$VERSION" ]; then
    log "couldn't read the qBittorrent version; leaving the theme as it is"
    exit 0
fi

# the theme is written for the WebUI of qBittorrent 5.0 and later; older WebUIs
# are built differently, so they get the stock look (the alternative WebUI path
# keeps working, and the theme returns by itself after an upgrade)
MAJOR="${VERSION%%.*}"
THEMED=1
if [ "$MAJOR" -lt 5 ] 2>/dev/null; then
    THEMED=0
    log "qBittorrent $VERSION is older than 5.0, which the theme doesn't support: installing the stock WebUI"
fi

# the build is keyed on the version, the style and the theme sources, so a theme
# update or a style change rebuilds too
CSS="$(mktemp)"
cat "$SRC/core.css" > "$CSS"
for part in $PARTS; do
    printf '\n' >> "$CSS"
    cat "$SRC/parts/$part.css" >> "$CSS"
done
# an icon is "neutral" when every colour in it is a light grey or white (the
# toolbar and menu icons); in light mode those would vanish on white
is_neutral_icon() {
    found=0
    for c in $(grep -oiE '#[0-9a-f]{3,6}' "$1" | tr 'A-F' 'a-f' | sort -u); do
        h="${c#\#}"
        case "${#h}" in
            3) r="$(printf '%s' "$h" | cut -c1)"; g="$(printf '%s' "$h" | cut -c2)"; b="$(printf '%s' "$h" | cut -c3)"
               r="$r$r"; g="$g$g"; b="$b$b" ;;
            6) r="$(printf '%s' "$h" | cut -c1-2)"; g="$(printf '%s' "$h" | cut -c3-4)"; b="$(printf '%s' "$h" | cut -c5-6)" ;;
            *) continue ;;
        esac
        [ "$r" = "$g" ] && [ "$g" = "$b" ] && [ "$((0x$r))" -ge 176 ] || return 1
        found=1
    done
    [ "$found" = 1 ]
}

# the light design: light mode is when the WebUI hasn't set its "dark" class
if grep -q '__LIGHT__' "$CSS"; then
    NEUTRAL=""
    for svg in "$ICONS"/*.svg; do
        if is_neutral_icon "$svg"; then
            NEUTRAL="$NEUTRAL${NEUTRAL:+, }[src\$=\"/$(basename "$svg")\"]"
        fi
    done
    RULE=""
    if [ -n "$NEUTRAL" ]; then
        # (except on a blue badge, like the current category in the menu)
        RULE="__LIGHT__ img:is($NEUTRAL):not(.highlightedCategoryIcon) { filter: brightness(0) opacity(0.72) !important; }"
    fi
    awk -v rule="$RULE" '{ if ($0 == "__NEUTRAL_ICONS__") print rule; else print }' "$CSS" > "$CSS.tmp"
    sed 's/__LIGHT__/:root:not(.dark)/g' "$CSS.tmp" > "$CSS"
    rm -f "$CSS.tmp"
fi

# this script is in the stamp too, so an update to it (how pages are patched,
# the light-mode script) reaches existing builds
STAMP="$(cat "$CSS" "$ICONS"/*.svg "${BASH_SOURCE[0]:-$0}" | sha256sum | cut -c1-10)"
KEY="$VERSION $STYLE $STAMP $THEMED"

if [ -f "$OUT/.nightseed" ] && [ "$(cat "$OUT/.nightseed")" = "$KEY" ]; then
    log "theme is up to date for qBittorrent $VERSION ($STYLE)"
    rm -f "$CSS"
    exit 0
fi

log "building the theme for qBittorrent $VERSION ($STYLE)"
WORK="$(mktemp -d)"
cleanup() { rm -rf "$WORK" "$CSS"; }

URL="https://codeload.github.com/qbittorrent/qBittorrent/tar.gz/refs/tags/release-$VERSION"
if ! curl -fsSL --retry 3 --max-time 300 "$URL" -o "$WORK/src.tar.gz"; then
    log "couldn't download the WebUI for $VERSION; keeping the current theme"
    cleanup
    exit 0
fi
if ! tar -xzf "$WORK/src.tar.gz" -C "$WORK" || [ ! -d "$WORK/qBittorrent-release-$VERSION/src/webui/www/private" ]; then
    log "the download for $VERSION didn't contain a WebUI; keeping the current theme"
    cleanup
    exit 0
fi
WWW="$WORK/qBittorrent-release-$VERSION/src/webui/www"

# assemble next to the old build, then swap, so a failure never leaves a half-built folder
NEW="$OUT.new"
rm -rf "$NEW"
mkdir -p "$NEW"
cp -r "$WWW/public" "$WWW/private" "$NEW/"

if [ "$THEMED" = 1 ]; then
    for part in public private; do
        cp "$CSS" "$NEW/$part/css/nightseed.css"
    done

    # icons: qBittorrent's desktop icon ids and the WebUI image names are the same
    for svg in "$ICONS"/*.svg; do
        name="$(basename "$svg")"
        [ -f "$NEW/private/images/$name" ] && cp "$svg" "$NEW/private/images/$name"
    done

    # the stylesheet goes last in every page's <head>, after the stock ones; the
    # stamp changes with the stylesheet, so browsers fetch a new one instead of a
    # cached copy
    LINK="<link rel=\"stylesheet\" type=\"text/css\" href=\"css/nightseed.css?v=\${CACHEID}-$STAMP\">"
    find "$NEW/private" "$NEW/public" -name '*.html' | while read -r page; do
        if grep -q '</head>' "$page"; then
            sed -i "s#</head>#$LINK</head>#" "$page"
        fi
    done

    # light mode: the login page and the odd dialog page don't run the WebUI's
    # colour-scheme script, so a small one sets the same "dark" class there
    # (a dialog copies the main page; the login page follows the device)
    if [ "$STYLE" = auto ] || [ "$STYLE" = alternative-auto ]; then
        for part in public private; do
            mkdir -p "$NEW/$part/scripts"
            cat > "$NEW/$part/scripts/nightseed-scheme.js" <<'JS'
(() => {
    "use strict";
    let dark;
    try {
        if (window.parent !== window)
            dark = window.parent.document.documentElement.classList.contains("dark");
    }
    catch (e) {}
    if (dark === undefined)
        dark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    document.documentElement.classList.toggle("dark", dark);
})();
JS
        done
        SCHEME="<script src=\"scripts/nightseed-scheme.js?v=\${CACHEID}-$STAMP\"></script>"
        find "$NEW/private" "$NEW/public" -maxdepth 1 -name '*.html' | while read -r page; do
            if grep -q '</head>' "$page" && ! grep -q 'color-scheme.js' "$page"; then
                sed -i "s#</head>#$SCHEME</head>#" "$page"
            fi
        done
    fi
fi

echo "$KEY" > "$NEW/.nightseed"
rm -rf "$OUT.old"
[ -d "$OUT" ] && mv "$OUT" "$OUT.old"
mv "$NEW" "$OUT"
rm -rf "$OUT.old"

# qBittorrent runs as the image's abc user, which only needs to read the files
chmod -R a+rX "$OUT"
cleanup
log "done: point Options -> WebUI -> alternative WebUI at $OUT"
