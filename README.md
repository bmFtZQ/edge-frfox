# Edge-Frfox
A Firefox userChrome.css theme that aims to recreate the look and feel of the Chromium version of Microsoft Edge.

![thumbnail](screenshots/thumbnail.png)
###### Screenshot taken with macOS Monterey / Firefox Nightly 96.0a1 (2021-11-30)

## How to install
1. Go to `about:support` and click the "Open Folder/Show in Finder" button for the root directory of your browser profile/s.
2. Download and copy the `chrome` folder into the profile folder.
3. Go to about:config and change these preferences:
   ###### For all operating systems:
   1. `toolkit.legacyUserProfileCustomizations.stylesheets` = `true`
   2. `svg.context-properties.content.enabled` = `true`
   3. `layout.css.color-mix.enabled` = `true`

   ###### On macOS:
   1. To use the Edge style context menu on macOS then set `widget.macos.native-context-menus` = `false` **(Not Implemented Yet!)**

   ##### Recommended:
   1. `browser.tabs.tabMinWidth` = `66`
   2. `browser.tabs.tabClipWidth` = `66`
   
**Note: Most frequently tested on macOS**

## Tweaks
Certain tweaks can be applied to the theme, to enable them navigate to `about:config` and create a boolean key for each tweak and set it to `true` and restart the browser.

To disable a tweak, set the key to false or delete it and restart the browser.

|disable drag space above tabs|
|-|
|`uc.tweak.disable-drag-space`|

|force tab background colour to `--toolbar-bg` (useful for Proton themes)|
|-|
|**NOTE: can cause readability issues with some themes! (eg. white text on white bg)**|
|`uc.tweak.force-tab-colour`|

|only show Firefox account button when in private mode (useful as a private browsing indicator)|
|-|
|**NOTE: all functionality of this button can still be accessed from the app menu.**|
|`uc.tweak.fxa-button-as-private-indicator`|

|remove tab separators|
|-|
|`uc.tweak.remove-tab-separators`|

|remove extra padding from permissions button (older functionality)|
|-|
|`uc.tweak.less-permissions-button-padding`|

## Acknowledgements
[muckSponge](https://github.com/muckSponge) - [MaterialFox](https://github.com/muckSponge/MaterialFox)

[Microsoft](https://github.com/microsoft) - [Fluent UI System Icons](https://github.com/microsoft/fluentui-system-icons)

---

Old version can be found [here](https://github.com/bmFtZQ/edge-frfox/tree/v91.0-archive).
