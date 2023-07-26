# Edge-Frfox
A Firefox userChrome.css theme that aims to recreate the look and feel of the Chromium version of Microsoft Edge.

<!-- use <img> element to set a maximum width -->
<img src="screenshots/thumbnail.png" alt="thumbnail screenshot" title="Screenshot taken with macOS Monterey / Firefox Nightly 96.0a1 (2021-11-30)" width="800">

## How to install
1. Go to `about:support` and click the "Open Folder/Show in Finder" button for the root directory of your browser profile/s.
2. Download and copy the `chrome` folder into the profile folder.
3. Go to about:config and change these preferences:

   ### For all operating systems:
   1. `toolkit.legacyUserProfileCustomizations.stylesheets` = `true`
   2. `svg.context-properties.content.enabled` = `true`
   3. `layout.css.color-mix.enabled` = `true`

   ### On macOS:
   1. To use the Edge style context menu on macOS then set `widget.macos.native-context-menus` = `false`

   ### Recommended:
   1. `browser.tabs.tabMinWidth` = `66`
   2. `browser.tabs.tabClipWidth` = `86`
   3. `general.smoothScroll.currentVelocityWeighting` = `0`
   4. `general.smoothScroll.mouseWheel.durationMaxMS` = `250`
   5. `general.smoothScroll.stopDecelerationWeighting` = `0.28`
   6. `mousewheel.min_line_scroll_amount` = `25`
   7. `general.smoothScroll.msdPhysics.enabled` = `true`

   ### Optional:
   1. To use the light theme in private browsing mode set `browser.theme.dark-private-windows` = `false`

   Additional tweaks can also be applied to the theme, such as Mica (Windows 11 Only), Floating Tabs and more. See [Tweaks](#tweaks).

**Note: Most frequently tested on macOS**

## Screenshots
| Theme                               | Light                                   | Dark                                   |
| ----------------------------------- | --------------------------------------- | -------------------------------------- |
| Default (Windows 11)                | ![Light][s-l]                           | ![Dark][s-d]                           |
| Floating Tabs (Windows 11)          | ![Light, Floating Tabs][s-lf]           | ![Dark, Floating Tabs][s-df]           |
| Mica (Windows 11)                   | ![Light, Mica][s-lm]                    | ![Dark, Mica][s-dm]                    |
| Mica and Floating Tabs (Windows 11) | ![Light, Mica and Floating Tabs][s-lmf] | ![Dark, Mica and Floating Tabs][s-dmf] |
| GTK (GNOME 42, [adw-gtk3][1] theme) | ![Light, GTK][s-lgtk]                   | ![Dark, GTK][s-dgtk]                   |

## Tweaks
Certain tweaks can be applied to the theme, to enable them navigate to `about:config` and create a boolean key for each tweak you want to use and set it to `true`, then restart the browser.

To disable a tweak, set the key to `false` or delete it, then restart the browser.

| use background image on newtab page                                                                |
| -------------------------------------------------------------------------------------------------- |
| **SETUP: Add an image named `background-0.(jpg/png)` to the `chrome` folder.**                     |
| **OPTIONAL: Add a second image named `background-1.(jpg/png)` for seperate dark mode background.** |
| `uc.tweak.newtab-background`                                                                       |

| hide Firefox logo on newtab page |
| -------------------------------- |
| `uc.tweak.hide-newtab-logo`      |

| disable drag space above tabs |
| ----------------------------- |
| `uc.tweak.disable-drag-space` |

| enable rounded corners     |
| -------------------------- |
| `uc.tweak.rounded-corners` |

| enable Edge style floating tabs                                                                                  |
| ---------------------------------------------------------------------------------------------------------------- |
| `uc.tweak.floating-tabs`                                                                                         |
| **OPTIONAL1: Make the top and bottom margins of the tab equal**                                                  |
| `uc.tweak.floating-tabs.equal-margin`                                                                            |
| **OPTIONAL2: Hide the separator of adjacent tabs (need to wait for Firefox support, or forced enable with bug)** |
| `layout.css.has-selector.enabled`                                                                                |

| enable Mica toolbar background *(Windows 11 only)*                  |
| ------------------------------------------------------------------- |
| **See [Mica Tweak Instructions][3] for installation instructions.** |
| **NOTE: Only works on default theme: 'System theme - auto'**        |
| `uc.tweak.win11-mica`                                               |

| force tab background colour to the same colour as the navbar background (useful for Proton themes) |
| -------------------------------------------------------------------------------------------------- |
| **NOTE: can cause readability issues with some themes! (eg. white text on white bg)**              |
| `uc.tweak.force-tab-colour`                                                                        |
| ![force tab colour example](screenshots/force-tab-colour.svg) (Left: OFF, Right: ON)               |

| Show context menu navigation buttons (Back, Forward, Reload, etc.) vertically |
| ----------------------------------------------------------------------------- |
| **NOTE: labels are only shown in the English language.**                      |
| `uc.tweak.vertical-context-navigation`                                        |

| remove tab separators            |
| -------------------------------- |
| `uc.tweak.remove-tab-separators` |

| use Firefox's default context menu font-size (only applies to Windows) |
| ---------------------------------------------------------------------- |
| `uc.tweak.smaller-context-menu-text`                                   |

| disable custom context menus   |
| ------------------------------ |
| `uc.tweak.revert-context-menu` |

| if a tab's close button is hidden, show it when hovering over tab |
| ----------------------------------------------------------------- |
| `uc.tweak.show-tab-close-button-on-hover`                         |

## Mica Tweak Instructions (Windows 11 Only)
1. Download and install [Mica For Everyone][2].
2. Create a custom process rule with the following:
   1. Name: `firefox`
   2. Titlebar Color: `System`
   3. Backdrop Type: `Mica`
3. Enable tweak in `about:config`: `uc.tweak.win11-mica`
4. Restart Firefox.

## Acknowledgements
[muckSponge](https://github.com/muckSponge) - [MaterialFox](https://github.com/muckSponge/MaterialFox)

[Microsoft](https://github.com/microsoft) - [Fluent UI System Icons](https://github.com/microsoft/fluentui-system-icons)

[KibSquib48](https://github.com/KibSquib48) - [MicaFox](https://github.com/KibSquib48/MicaFox)

<!-- links -->
[1]: https://github.com/lassekongo83/adw-gtk3
[2]: https://github.com/MicaForEveryone/MicaForEveryone
[3]: #mica-tweak-instructions-windows-11-only

<!-- light mode screenshot links -->
[s-l]: screenshots/light.png
[s-lf]: screenshots/light-floating-tabs.png
[s-lm]: screenshots/light-mica.png
[s-lmf]: screenshots/light-mica-floating-tabs.png
[s-lgtk]: screenshots/gtk-light.png

<!-- dark mode screenshot links -->
[s-d]: screenshots/dark.png
[s-df]: screenshots/dark-floating-tabs.png
[s-dm]: screenshots/dark-mica.png
[s-dmf]: screenshots/dark-mica-floating-tabs.png
[s-dgtk]: screenshots/gtk-dark.png
