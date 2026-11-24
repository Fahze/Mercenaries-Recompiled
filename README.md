# Mercenaries Recompiled: USA + EU-FR

A native Windows port of **Mercenaries: Playground of Destruction** that works
with the **USA** and the **French (EU-FR)** retail Xbox discs.

> This is a fork of
> [KraftMacAndChee/Mercenaries-Recompiled](https://github.com/KraftMacAndChee/Mercenaries-Recompiled).
> The upstream project only accepts the USA disc. This fork adds the French
> PAL disc and a RecompLauncher package. It otherwise follows upstream, and its
> changes are proposed back in
> [KraftMacAndChee/Mercenaries-Recompiled#22](https://github.com/KraftMacAndChee/Mercenaries-Recompiled/pull/22).

[Play with RecompLauncher](#play-with-recomplauncher) ·
[Build from source](#build-from-source) ·
[Report a problem](#reporting-a-problem) ·
[Build guide](ports/mercenaries/README.md) ·
[Documentation](docs/README.md) ·
[Architecture](ARCHITECTURE.md) ·
[Contributing](CONTRIBUTING.md)

## En français

Ce dépôt permet de jouer à Mercenaries Recompiled avec le **disque Xbox PAL
français** (Redump « Mercenaries (France) »), en plus du disque USA. Le jeu
s'affiche en français. Tu as besoin de ta propre image du disque (.iso) : ce
dépôt ne contient aucun fichier du jeu.

- **Avec RecompLauncher** (le plus simple) : installe la
  [dernière release](https://github.com/Fahze/Mercenaries-Recompiled/releases/latest),
  choisis ton ISO et clique sur Set Up. Le jeu est compilé sur ton PC à partir
  de ton disque, puis se lance avec Play.
- **À la main** : suis la section [Build from source](#build-from-source)
  ci-dessous en indiquant ton ISO française.

Testé sur le disque FR : première mission terminée et sauvegarde fonctionnelle,
y compris en passant par RecompLauncher. Pour signaler un problème, ouvre une
[issue sur ce dépôt](https://github.com/Fahze/Mercenaries-Recompiled/issues).

## What this fork adds

| | Upstream | This fork |
| --- | --- | --- |
| USA retail disc | ✔ | ✔ |
| EU-FR (France) retail disc | ✘ | ✔, in French |
| RecompLauncher package | Prebuilt player package, USA only | Built from your own disc, USA or EU-FR |

**Supported discs** (`default.xbe` SHA-256):

```text
AA08EA21D952AC35F49C02C7E2ED08AA25AD7535FBBBCCC95636775F37BE99D7  USA
9DD26D6CE030F467462A4A8132AC82217ECEA69ECFEF5FAB9238392642FDC356  EU-FR (Redump "Mercenaries (France)")
```

How EU-FR support works:
- **Same code.** The EU-FR executable has the same code, section layout and
  entry point as the USA one; only its certificate differs. Every translated
  function and every generated patch of the upstream port applies unchanged.
- **Disc language.** The French disc ships only `DATAxbox/french.dsk` (405
  files instead of 434). The virtual console reports the language of the
  installed language pack, as a real PAL console would.
- **What was changed.** The XBE gates in the scripts, the runtime and the
  launcher accept both hashes, and the launcher validates each disc's own
  inventory.

Other PAL languages (German, Italian, Spanish) are not supported yet: each
needs its own XBE hash and inventory profile.

## Play with RecompLauncher

The [releases](https://github.com/Fahze/Mercenaries-Recompiled/releases) are
RecompLauncher packages. They contain a `recomplauncher.json` manifest and a
setup step, and **no game code or game data**. Setup works like this:

1. You pick your disc image (.iso or XISO). The launcher checks it is an Xbox
   disc.
2. Setup installs Python 3.12 and the Visual Studio 2022 Build Tools (MSVC
   14.44, Windows SDK 10.0.26100) if they are missing and you ticked them.
   That is several GB, and Windows asks for admin rights once.
3. It downloads this repository at the release's tag and builds the game from
   your disc. This takes about 5 minutes on a fast PC, up to 40 on a slow one.
4. It installs the game in `Game`. Saves (`Game\saves`, `Game\mod-saves`) and
   settings (`Game\*.ini`) are kept across updates, and `setup.log` records
   every step.

The game's page in RecompLauncher shows the port's options. They are written to
`Game\mercenaries_recomp.ini`, the same file as the in-game Recomp Options menu:

- **Display**: resolution, display mode, screen shape, frame rate cap, V-Sync.
- **Graphics**: texture filtering, field of view, haze, character detail, PS2
  upgrades.
- **Controls**: button prompts (match your device, or keep the original Xbox
  ones).
- **Gameplay** (advanced): NPC wake distance, original bugs.

The runtime also speaks RecompLauncher's channel (`RL_SESSION`), through the
vendored [Recomp Achievements](https://github.com/elripalda/RecompAchievements)
SDK in [`third_party/rl-achievements`](third_party/rl-achievements). With it:
- RecompLauncher can load a list for this game, with a rich presence line and
  achievements written against Xbox guest memory;
- the presence line replaces "via RecompLauncher" on Discord and on the
  player's profile;
- opening the developer tools (F9 menu, free camera) marks the session as
  Casual.

RecompLauncher only opens that channel for its achievement testers for now.
Outside RecompLauncher every call is a no-op.
`tools/recomp/test_recomplauncher_channel_native.py` checks the channel end to
end against a built runtime.

The package sources are in
[`ports/mercenaries/recomplauncher`](ports/mercenaries/recomplauncher).

## Build from source

Install these prerequisites:

- Python **3.12**, available through the Windows `py` launcher.
- Visual Studio **2022**, with the C++ desktop build tools, MSVC
  **14.44.35207**, and Windows SDK **10.0.26100.0**.
- PowerShell 7 or Windows PowerShell 5.1.
- Your legally obtained **USA or EU-FR (France) retail Xbox Mercenaries ISO**.
  A PS2 disc is not a substitute for the Xbox build input.

From the repository root in PowerShell:

```powershell
& .\ports\mercenaries\scripts\Build-From-Iso.ps1 -IsoPath 'D:\Games\Mercenaries.iso'
```

The example ISO path is a placeholder. Setup creates `.venv` and installs the
pinned Python dependencies; this step needs access to the Python package index
or an appropriate local cache. The extractor and required runtime libraries are
bundled with their notices. Visual Studio and the Windows SDK must already be
installed.

The script does the following:
1. extracts the retail input and verifies it;
2. generates the translated C and applies the port's patches;
3. builds the runtime and the launcher;
4. writes build provenance.

Default output:

```text
build/mercenaries/bin/Release/
    Mercenaries Recompiled.exe    # First-launch setup and launcher
    mercenaries_recomp.exe        # Internal game runtime
```

Keep the DLLs and supporting directories beside those executables. Start
`Mercenaries Recompiled.exe` and select your ISO when prompted. See the
[port guide](ports/mercenaries/README.md) for the installation contract. A
root-only CMake build produces toolkit libraries, not the game executable.

Do not edit `ports/mercenaries/src/recomp/gen` to make permanent fixes. Its
contents are regenerated; durable patches belong in the maintained generator,
patch script, or port integration code.

## Reporting a problem

Use this repository's
[Issues tab](https://github.com/Fahze/Mercenaries-Recompiled/issues) for
anything about the EU-FR disc or the RecompLauncher package. A problem that
also happens with the USA disc on an upstream build belongs
[upstream](https://github.com/KraftMacAndChee/Mercenaries-Recompiled/issues).

Include the following:
- your disc (USA or EU-FR) and the release or executable hash;
- your Windows version, CPU, GPU and RAM, resolution and control device;
- the steps to reproduce, and what you expected versus what happened;
- any mods or changed settings.

For an install problem, attach `setup.log` from the install folder. A
screenshot or a short recording can help with rendering issues.

For a runtime log, set `logging=1` under `[Developer]` in `developer.ini`,
restart, and reproduce the problem. Press **F8** while the game has focus to
mark the event in `preview-logs`. Logging is off by default. The optional F9
developer menu separately requires `developer_menu=1` and a restart.

Review logs before attaching them; they can contain local paths. Do not upload
disc images, extracted game data, or memory dumps to a public issue.

## Staying in sync with upstream

This fork tracks
[KraftMacAndChee/Mercenaries-Recompiled](https://github.com/KraftMacAndChee/Mercenaries-Recompiled):
- **The branches.** The EU-FR changes are on the
  [`eu-fr-support`](https://github.com/Fahze/Mercenaries-Recompiled/tree/eu-fr-support)
  branch, which PR #22 proposes upstream. `master` adds this README and the
  RecompLauncher package on top.
- **If upstream merges the EU-FR support.** This fork then only needs to
  carry the RecompLauncher package.

## Contributing and validation

Read [CONTRIBUTING.md](CONTRIBUTING.md) before changing guest-memory behavior,
generated-code interfaces, rendering, audio, threading, or timing. Compatibility
code can have ordering and lifetime requirements that ordinary refactoring
would accidentally change.

Tests are under `tools/`. The isolated runner lists and selects tests without
importing unrelated modules:

```powershell
& .\.venv\Scripts\python.exe -m pip install pytest
& .\.venv\Scripts\python.exe -X utf8 -B tools/recomp/run_tests.py --list
& .\.venv\Scripts\python.exe -X utf8 -B tools/recomp/run_tests.py --match eu_fr_revision --output artifacts/eu-fr-check
```

Use a new output directory for each run. See
[validation status](docs/maintenance-validation.md) for the upstream baseline
and known failures; it is not an all-green test suite or a gameplay guarantee.

## Finding your way around

| Path | Responsibility |
| --- | --- |
| `ports/mercenaries/recomplauncher` | RecompLauncher manifest, setup step and release packaging (this fork) |
| `ports/mercenaries/src` | Game integration, controls, options, launcher, manual overrides |
| `ports/mercenaries/scripts` | Extraction, generation patches, builds, packaging |
| `ports/mercenaries/resources` | Embedded launcher resources and optional upgrade assets |
| `src`, `include` | Shared Xbox runtime and interfaces |
| `tools/recomp`, `tools/disasm`, `tools/func_id`, `tools/xbe_parser` | Translation pipeline and regression tests |
| `tools/diagnostics`, `tools/debug` | Optional investigation utilities |
| `templates` | Starting points for other Xbox ports |
| `docs` | Current guides and dated investigation records |
| `third_party`, `ports/mercenaries/third_party` | Dependencies, corresponding sources where bundled, notices |

Start with [ARCHITECTURE.md](ARCHITECTURE.md) and [CODE_MAP.md](CODE_MAP.md).
The [documentation index](docs/README.md) gives the full maintainer reading order.

## Credits and licensing

Mercenaries Recompiled is by Trenton Turner (KraftMacAndChee), building on
sp00nz's xboxrecomp toolkit and work from the Xbox emulation and modding
communities. The upstream project was built with the assistance of Codex 5.6 Sol
and Astra. EU-FR disc support and the RecompLauncher package in this fork are by
Fahze, written with Claude Code. This is an unofficial fan project, not an
official game release.

The root [MIT license](LICENSE) retains the toolkit's copyright notice. It does
not replace imported components' licenses. xemu-derived code carries per-file
LGPL notices; SDL2, DSP56300, Lua, fonts, and other dependencies retain their own
licenses. The bundled Windows SDK shader compiler has separate redistribution
terms. Consult the [dependency inventory](docs/dependencies.md) and accompanying
notice files before redistributing a modified package.

Maintainer-supplied artwork, controller prompts, and optional upgrade resources
are retained. Their inclusion does not grant new rights to those assets under
the root MIT license. Mercenaries and its game assets belong to their respective
owners.
