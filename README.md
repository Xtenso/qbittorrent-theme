# Nightseed — a qBittorrent theme

A dark qBittorrent theme inspired by Ario Seno's
[Redesign Concept of Qbittorent](https://dribbble.com/shots/7841153-Redesign-Concept-of-Qbittorent)
on Dribbble. The menus and toolbar share one floating rounded card. The sidebar
and the torrent details panel are cards too, and all of them sit on a
near-black canvas with the transfer list. It has green gradient progress bars,
rows coloured by torrent state, rounded row and pill-shaped selections, and
colour-coded Material icons in Apple's palette.

[![Nightseed: qBittorrent with the theme, showing the transfer list, sidebar and toolbar](assets/compressed/01-hero.webp)](assets/originals/01-hero.png?raw=true)

Nightseed is for the **qBittorrent desktop app**. It is tested on
**qBittorrent 5.3.0 (Qt 6.11) and 5.2.3 (Qt 6.10) on Windows 11** and targets
qBittorrent 5.x. It has also been reported to work on **macOS**. There the menus
sit in the system menu bar and the toolbar joins the title bar, so the top of the
window looks different from the screenshots. It should also load on 4.6.x (also
Qt 6) and on Linux, but those are untested.

It doesn't work with the **Web UI**. That's a qBittorrent limitation: themes only
apply to the desktop app, and the Web UI can't load them.

## Screenshots

<p align="center">
  <a href="assets/originals/02-transfers.png?raw=true"><img src="assets/compressed/02-transfers.webp" width="49%" alt="Transfer list with gradient progress bars, with row colours on (the default) and off"></a>
  <a href="assets/originals/03-filters.png?raw=true"><img src="assets/compressed/03-filters.webp" width="49%" alt="Sidebar filters with pill-shaped selections"></a>
  <a href="assets/originals/04-details.png?raw=true"><img src="assets/compressed/04-details.webp" width="49%" alt="Details panel with the speed graph"></a>
  <a href="assets/originals/05-menus.png?raw=true"><img src="assets/compressed/05-menus.webp" width="49%" alt="Right-click menu and a submenu"></a>
  <a href="assets/originals/06-settings.png?raw=true"><img src="assets/compressed/06-settings.webp" width="49%" alt="Options dialog, Behavior page"></a>
  <a href="assets/originals/07-add-torrent.png?raw=true"><img src="assets/compressed/07-add-torrent.webp" width="49%" alt="Add torrent dialog"></a>
</p>

## Four versions

Each release has four theme files, built from the same source:

- **Nightseed** (`Nightseed.qbtheme`) is the theme in the screenshots above. Its
  rows are coloured by torrent state by default, and you can switch that off
  (step 5 of [Install](#install)). The transfer list screenshot shows both; the
  others have it off. The progress bars keep the theme's rounded green gradient
  whatever the state.
- **Nightseed Alternative** (`Nightseed-Alternative.qbtheme`) adds a state icon
  at the start of each row, and its progress bars can take each state's colour
  too (step 5 of [Install](#install)). For that, qBittorrent draws the bars itself:
  they have smaller corners and a thin outline, in the transfer list and in file
  lists. Downloading and seeding rows use a slightly darker green and blue, so
  the percentage stays readable on a coloured bar.
- **Nightseed OLED** (`Nightseed-OLED.qbtheme`) is Nightseed on true black: the
  canvas and the transfer list are `#000000` instead of `#121212`, so an OLED
  screen switches those pixels off. Everything else matches Nightseed, so the
  cards stand out a little more.
- **Nightseed Transparent** (`Nightseed-Transparent.qbtheme`) lets whatever is
  behind qBittorrent show through, blurred. The theme makes its backgrounds
  see-through, but the blur itself comes from a separate tool on Windows 11:
  either the [Windhawk](https://windhawk.net) mod
  [Translucent Windows](https://windhawk.net/mods/translucent-windows) (its
  default Blur, or Acrylic or Mica), or
  [Mica For Everyone](https://github.com/MicaForEveryone/MicaForEveryone) with a
  rule for `qbittorrent.exe` set to Mica or Acrylic, with **Extend frame into
  client area** on. Without one of them, the see-through parts are black. See
  [Known limitations](#known-limitations).

<p align="center">
  <a href="assets/originals/08-alternative.png?raw=true"><img src="assets/compressed/08-alternative.webp" width="49%" alt="Nightseed Alternative: state icons, and rows and progress bars coloured by state"></a>
  <a href="assets/originals/09-alternative-settings.png?raw=true"><img src="assets/compressed/09-alternative-settings.webp" width="49%" alt="Nightseed Alternative: both Transfer List colour settings ticked in Options"></a>
</p>

<p align="center">
  <a href="assets/originals/10-oled.png?raw=true"><img src="assets/compressed/10-oled.webp" width="49%" alt="Nightseed OLED: the canvas and transfer list in pure black"></a>
  <a href="assets/originals/11-transparent.png?raw=true"><img src="assets/compressed/11-transparent.webp" width="49%" alt="Nightseed Transparent with the Windhawk Translucent Windows mod: the wallpaper shows through the window, blurred"></a>
</p>

## Install

1. Download one theme file from the latest release (see
   [Four versions](#four-versions)):
   [**Nightseed.qbtheme**](https://github.com/Xtenso/qbittorrent-theme/releases/latest/download/Nightseed.qbtheme),
   [**Nightseed-Alternative.qbtheme**](https://github.com/Xtenso/qbittorrent-theme/releases/latest/download/Nightseed-Alternative.qbtheme),
   [**Nightseed-OLED.qbtheme**](https://github.com/Xtenso/qbittorrent-theme/releases/latest/download/Nightseed-OLED.qbtheme)
   or [**Nightseed-Transparent.qbtheme**](https://github.com/Xtenso/qbittorrent-theme/releases/latest/download/Nightseed-Transparent.qbtheme).
2. Open qBittorrent → **Tools → Options → Behavior → Interface**.
3. Tick **Use custom UI Theme** and browse to the downloaded **`.qbtheme`** file.
4. In the same section, set **Style: System** (recommended) and **Color scheme:
   Dark** (for a dark title bar).
   - **Fusion** works too, and qBittorrent itself recommends it for Windows dark
     mode, but with this theme its menus and drop-down lists have square corners.
5. On the same page, under **Transfer List**, keep **Use different text colors by
   torrent states** ticked (it is by default). Each row is then coloured by its
   torrent's state: green downloading, blue seeding, purple completed, grey
   stopped, red errored. Untick it for plain white rows.
   - **Make progress bars follow text colors**, just below it: with **Nightseed
     Alternative**, tick it to colour the bars by state too. With the other three
     versions it does nothing, and the bars stay green (grey when stopped or
     errored). See [Known limitations](#known-limitations).
   - Both settings are new in qBittorrent 5.2. Older versions always colour the
     rows and never the bars.
6. Click **OK** and **restart qBittorrent**. Themes are only loaded at start-up.

If you delete or move the theme file later, qBittorrent falls back to its default look.

## WebUI

Running qBittorrent headless, in Docker or on a NAS? [`webui/`](webui) has
Nightseed for the browser interface too: Nightseed, Alternative, OLED, and Auto
versions of Nightseed and Alternative that add a light design for the WebUI's
light mode. A start-up script for the
linuxserver Docker image rebuilds it for each qBittorrent version. See
[its README](webui/README.md).

## Known limitations

- **Progress bar colours**: in **Nightseed** the bars stay green whatever the
  torrent's state (grey when stopped or errored). qBittorrent's *Make progress
  bars follow text colors* only works when Qt draws the bars itself, and a theme
  can't tell whether you ticked it. So a theme that supports it gets Qt's plainer
  bars for everyone, ticked or not. That is the trade-off **Nightseed Alternative**
  makes: without the tick, its bars are plain green, stopped and errored ones too.
- **State icons** in the Name column are hidden on purpose in **Nightseed**, and
  row colours show the state instead. **Nightseed Alternative** shows them.
- **Nightseed Transparent** needs one of the tools in
  [Four versions](#four-versions): qBittorrent can't blur what's behind its
  window by itself. Menus, drop-down lists and tooltips stay solid, because
  they are separate windows that these tools leave alone. With a bright window
  right behind qBittorrent, white text gets hard to read.
- **Nightseed OLED**: Windows draws the title bar, so it stays dark grey rather
  than black.
- **Shared icons**: a theme gets one icon per id. The toolbar *Resume* button
  and the sidebar *Running* filter share one (white here). *Downloading* and
  *Seeding* share theirs with the status bar's download and upload speeds (the
  green and blue arrows).
- **Details panel tab buttons** (General, Trackers, …) sit just below the details
  card rather than inside it. qBittorrent gives them no container a theme could
  draw as part of the card.
- **Piece bars** (the *Progress* and *Availability* bars on the details panel's
  General tab): qBittorrent paints them itself as plain rectangles. A theme only
  sets their colours, so their corners can't be rounded.
- **Row highlight, right end**: while the columns are wider than the list (it
  scrolls sideways), the row runs off the edge, so that end stays square.
- **First toolbar button inset**: the theme finds that button by its English
  text ("Open"). In other languages it sits about 6px closer to the card's left
  edge.

## License and credits

Nightseed is released under the [MIT License](LICENSE).

Icons are based on Google's [Material Icons](https://fonts.google.com/icons)
(Round), licensed under Apache 2.0 (see `tools/material-icons/LICENSE`).

Nightseed was inspired by
[Redesign Concept of Qbittorent](https://dribbble.com/shots/7841153-Redesign-Concept-of-Qbittorent)
by [Ario Seno](https://dribbble.com/ariosenodsgn) on Dribbble.
