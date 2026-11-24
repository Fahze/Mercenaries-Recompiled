Mercenaries Recompiled (USA + EU-FR) - RecompLauncher package
=============================================================

YOU NEED YOUR OWN COPY OF THE GAME: the original Xbox release of
Mercenaries: Playground of Destruction, as a disc image (.iso or XISO).
Supported discs:
  - USA retail
  - EU-FR, France retail (Redump "Mercenaries (France)")

This package contains NO game code and NO game data. Its setup step builds
the game on your PC from your own disc, using the public source code at
https://github.com/Fahze/Mercenaries-Recompiled, a fork of
KraftMacAndChee/Mercenaries-Recompiled that adds EU-FR disc support
(proposed upstream: https://github.com/KraftMacAndChee/Mercenaries-Recompiled/pull/22).

WHAT SETUP DOES
  1. Installs Python 3.12 and Visual Studio 2022 Build Tools (MSVC 14.44,
     Windows SDK 10.0.26100) if they are missing and you ticked them.
     That download is several GB; Windows asks for admin rights once.
  2. Downloads the source at this package's pinned version.
  3. Builds the game from your disc (20-40 minutes).
  4. Installs it in the Game folder. Saves and settings stay there across
     updates (Game\saves, Game\mod-saves, Game\*.ini).

The game runs in the language of your disc: French on the EU-FR disc.

TROUBLE
  Everything is logged to setup.log in the install folder.
  Report problems: https://github.com/Fahze/Mercenaries-Recompiled/issues
  Never post your ISO or game files publicly.
