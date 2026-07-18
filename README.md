# LCPCs P03 Kernel - Arch

A custom **P03 Kernel × Arch** Linux Kernel, tuned for a **(x86-64-v3)** +
**RTX 5090 (Blackwell)**. Using using CachyOS but should be able to run on most Arch systems.

> Name from *Serial Experiments Lain* (the Navi runs "LCPCs P03 Kernel - Arch").
> `os-release` keeps `ID=lcpcs` so garuda tooling/hooks keep working — only the branding + package
> source + hardware layer differ.

## What's in it

- **Optimized base** — `cachyos-znver3`/`-core`/`-extra` + `cachyos` repos injected **above**
  `core/extra/multilib` so prebuilt x86-64-v4 packages win by priority; garuda-* metas remain.
- **Kernel / GPU** — `linux-cachyos-rc` + matching prebuilt `linux-cachyos-rc-nvidia-open`

## Layout

| Path | What |
|---|---|
| `build-tools/build-local-repo.sh` | builds the AUR/custom packages into the `blackwell-local` repo |
| `build-tools/llama-cpp-blackwell/` | `llama.cpp` PKGBUILD (CUDA sm_120) |
| `build-tools/linux-tkg-p03/` | optional `linux-tkg` p03 kernel config |

## Custom package repo (`lcpcs-p03-kernel`)

AUR/locally-built packages (`lcpcs-p03-kernel`, `llama.cpp-blackwell`,…) are
built with `build-tools/build-local-repo.sh` and published to this repo's **GitHub Releases** (tag
`pkgs`) — a real online repo, reachable at build time and on the installed system.

```ini
[`lcpcs-p03-kernel`]
SigLevel = Never
Server = https://github.com/Kin9Loui3/lcpcs-p03-kernel/releases/download/pkgs
```

## Build

Repo packages stay prebuilt `znver3` (90% of the gain, zero compile). Build with garuda-tools:

```bash
sudo buildiso -p gnome   # run from this iso-profiles dir; output to /var/cache/garuda-tools/...
```

Requires an **AVX-512 (x86-64-v4)** CPU; the image targets NVIDIA. The 197 MB `Slot-Dark-Icons`
theme is not vendored here — drop your icon theme into the desktop-overlay before building.

## Credits

Built on [Copland-OS](https://github.com/Sigmachan/copland-os/tree/main/) (`build-tools`)
[CachyOS](https://cachyos.org/) repos. Gaming/Game-Mode patterns ported from Bazzite, Nobara,
SteamOS and ChimeraOS. and 
[CatPieLeaf-linux-p03](https://github.com/CatPieLeaf/linux-p03/) (`P03-kernel`)
