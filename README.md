# Edge-Frfox
A Firefox userChrome.css theme that aims to recreate the look and feel of the Chromium version of Microsoft Edge.

<!-- use <img> element to set a maximum width -->
<img src="screenshots/thumbnail.png" alt="thumbnail screenshot" title="Screenshot taken with macOS Monterey / Firefox Nightly 96.0a1 (2021-11-30)" width="800">

## How to install
1. Go to `about:support` and click the "Open Folder/Show in Finder" button for the root directory of your browser profile/s.
2. Download and copy the `chrome` folder into the profile folder.
3. Go to about:config and change these preferences:

   ### For all operating systems:
   * `toolkit.legacyUserProfileCustomizations.stylesheets` = `true`
   * `svg.context-properties.content.enabled` = `true`
   * `layout.css.color-mix.enabled` = `true`

   ### Firefox 119.0 and above:
   * `layout.css.light-dark.enabled` = `true`

   ### On macOS:
   * To use the Edge style context menu on macOS then set `widget.macos.native-context-menus` = `false`

   ### Recommended:
   * `browser.tabs.tabMinWidth` = `66`
   * `browser.tabs.tabClipWidth` = `86`

   ### Optional:
   * To use the light theme in private browsing mode set `browser.theme.dark-private-windows` = `false`

   Additional tweaks can also be applied to the theme, such as Floating Tabs, rounded browser corners and more. See [Tweaks](#tweaks).

**Note: Most frequently tested on macOS**

## Screenshots
| Theme                               | Light                         | Dark                         |
| ----------------------------------- | ----------------------------- | ---------------------------- |
| Default (Windows 11)                | ![Light][s-l]                 | ![Dark][s-d]                 |
| Floating Tabs (Windows 11)          | ![Light, Floating Tabs][s-lf] | ![Dark, Floating Tabs][s-df] |
| GTK (GNOME 42, [adw-gtk3][1] theme) | ![Light, GTK][s-lgtk]         | ![Dark, GTK][s-dgtk]         |

## Tweaks
Certain tweaks can be applied to the theme, to enable them navigate to `about:config` and create a boolean key for each tweak you want to use and set it to `true`, then restart the browser.

To disable a tweak, set the key to `false` or delete it, then restart the browser.

| Enable Edge style floating tabs                                |
| -------------------------------------------------------------- |
| `uc.tweak.floating-tabs`                                       |
| **OPTIONAL: Make the top and bottom margins of the tab equal** |
| `uc.tweak.disable-drag-space`                                  |

| Enable rounded corners     |
| -------------------------- |
| `uc.tweak.rounded-corners` |

| Hide Tabs Bar (Useful when using vertical tabs extensions such as Sidebery, Tree Style Tab, etc.) |
| ------------------------------------------------------------------------------------------------- |
| **NOTE: At the moment, this only supports macOS and Windows.**                                    |
| `uc.tweak.hide-tabs-bar`                                                                          |
| **OPTIONAL: Only enable in fullscreen mode (currently: macOS Only!)**                             |
| `uc.tweak.hide-tabs-bar.only-when-maximised`                                                      |

| Use background image on newtab page                                                                |
| -------------------------------------------------------------------------------------------------- |
| **SETUP: Add an image named `background-0.(jpg/png)` to the `chrome` folder.**                     |
| **OPTIONAL: Add a second image named `background-1.(jpg/png)` for seperate dark mode background.** |
| `uc.tweak.newtab-background`                                                                       |

| Hide forward button when it's disabled (like in Edge) |
| ----------------------------------------------------- |
| `uc.tweak.hide-forward-button`                        |

| Hide Firefox logo on newtab page |
| -------------------------------- |
| `uc.tweak.hide-newtab-logo`      |

| Remove extra space above the tabs |
| --------------------------------- |
| `uc.tweak.disable-drag-space`     |

| Force tab background colour to the same colour as the navbar background (useful for Proton themes) |
| -------------------------------------------------------------------------------------------------- |
| **NOTE: can cause readability issues with some themes! (eg. white text on white bg)**              |
| `uc.tweak.force-tab-colour`                                                                        |
| ![force tab colour example](screenshots/force-tab-colour.svg) (Left: OFF, Right: ON)               |

| Show context menu navigation buttons (Back, Forward, Reload, Bookmark) vertically |
| --------------------------------------------------------------------------------- |
| **NOTE: labels are only shown in the English language.**                          |
| `uc.tweak.vertical-context-navigation`                                            |

| Remove separators between tabs   |
| -------------------------------- |
| `uc.tweak.remove-tab-separators` |

| Use Firefox's default context menu font-size (only applies to Windows) |
| ---------------------------------------------------------------------- |
| `uc.tweak.smaller-context-menu-text`                                   |

| Disable custom context menus   |
| ------------------------------ |
| `uc.tweak.revert-context-menu` |

| If a tab's close button is hidden, show it when hovering over the tab |
| --------------------------------------------------------------------- |
| `uc.tweak.show-tab-close-button-on-hover`                             |

## Mica Tweak Notice
Mica is broken due to changes made in the Firefox 115 update, Mica has now been
removed from this theme.

If you still have `uc.tweak.win11-mica` set in `about:config` you can safely
delete it.

## Acknowledgements
[muckSponge](https://github.com/muckSponge) - [MaterialFox](https://github.com/muckSponge/MaterialFox)

[Microsoft](https://github.com/microsoft) - [Fluent UI System Icons](https://github.com/microsoft/fluentui-system-icons)

[KibSquib48](https://github.com/KibSquib48) - [MicaFox](https://github.com/KibSquib48/MicaFox)

<!-- links -->
[1]: https://github.com/lassekongo83/adw-gtk3

<!-- light mode screenshot links -->
[s-l]: screenshots/light.png
[s-lf]: screenshots/light-floating-tabs.png
[s-lgtk]: screenshots/gtk-light.png

<!-- dark mode screenshot links -->
[s-d]: screenshots/dark.png
[s-df]: screenshots/dark-floating-tabs.png
[s-dgtk]: screenshots/gtk-dark.png
