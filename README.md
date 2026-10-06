# ragtag

`ragtag` packages RagTag for TAFFISH.

Package identity:

- name: `ragtag`; command: `taf-ragtag`; kind: `tool`
- version: `2.1.1-r1`; packaging license: Apache-2.0
- upstream: [RagTag](https://github.com/malonge/RagTag), MIT
- release: [v2.1.1](https://github.com/malonge/RagTag/releases/tag/v2.1.1)
- runtime: `ragtag.py --version` reports `v2.1.1`
- image: `ghcr.io/taffish/ragtag:2.1.1-r1`
- native platforms: `linux/amd64,linux/arm64`

## What This App Packages

RagTag performs reference-guided assembly correction, scaffolding, patching and
scaffold merging. Its utilities handle AGP, FASTA, PAF, delta, GFF and assembly
statistics. Version 2.1.1 fixes reverse-strand query-gap calculation during
careful alignment merging. Scaffold orientation, order and inferred gaps may
therefore differ from 2.1.0. Recompute in a fresh output directory; an existing
alignment cache is not automatically revalidated after an upgrade.

The source is pinned to commit `179158843b010fbb677ed03528efa44f79f88f5e` and the
official tag archive SHA256
`ef19fbd09b7431e97371f35c7523d02f9bbe4418ce3143abb611d2cef8a2b451`.
Scientific algorithms are unchanged from that source. One explicit packaging
patch makes `ragtag.py` propagate its 11 child-command exit codes (signals use
128+signal) and return 2 for an unknown command. The original dispatcher
discarded child failures and returned 0; direct helper behavior is unchanged.
The original dispatcher and provenance remain under
`/opt/ragtag/share/doc/ragtag/`; patch logic is in `docker/patch-dispatch.py`.

MUMmer's noninteractive plot helper also has two narrow compatibility fixes:
only signal a real forked listener PID greater than 1, never the upstream PID 1
sentinel; and use Perl's access-based permission tests for ACL/VM-shared paths,
while actual file opens still enforce permissions. These prevent contained
Apptainer interruption and macOS Podman false write-denial respectively.
Original files remain under `/opt/mummer/share/doc/mummer4/*.original`;
`docker/patch-mummer.pl` records the exact changes. Alignment and plot-data
algorithms are unchanged.

## Scope

This app supports:

- `ragtag.py correct`, `scaffold`, `patch`, and `merge`
- `agp2fa`, `agpcheck`, `asmstats`, `splitasm`, `delta2paf`,
  `paf2delta`, `updategff`, and direct upstream helper scripts
- optional Hi-C BAM link counting and read-validation helpers
- minimap2, unimap, nucmer/MUMmer utilities, and samtools
- headless MUMmer dot plots with `mummerplot --png` or `--postscript`

It does not download references, choose biological thresholds, supply production
assemblies/Hi-C data, or replace scientific review of the resulting assembly.
No GPU, web service or reference database is needed for the CLI runtime.

## Container Contents

- RagTag 2.1.1, Python 3, numpy, pysam, networkx, intervaltree
- minimap2 2.31-r1302 (default correction/scaffolding aligner)
- unimap 0.1-r41 (optional correction/scaffolding aligner)
- MUMmer4 4.0.1 (nucmer; default patch aligner), Perl and gnuplot-nox
- samtools 1.16.1, bgzip, tabix, bash and standard Unix utilities
- `/opt/ragtag/share/testdata/upstream-tests/`: official tiny regression tests
- `ragtag-smoke MODE`: isolated offline packaging checks, not a user workflow

Compiler toolchains, pip, setuptools, source trees, MUMmer headers and static
development libraries stay in build stages. Runtime shared libraries, command
scripts, plotting assets and licenses are retained.

## Usage

After this release is published and indexed, install the pinned version with
`taf install ragtag 2.1.1-r1`. `taf-ragtag --version` shows wrapper identity.

```sh
taf-ragtag -- --help
taf-ragtag -- --version
taf-ragtag ragtag.py scaffold -t 8 -u -o scaffold_out ref.fa draft.fa
taf-ragtag ragtag.py correct -t 8 -o correct_out ref.fa draft.fa
taf-ragtag ragtag.py patch -t 8 -u -o patch_out target.fa query.fa
taf-ragtag ragtag.py merge -o merge_out draft.fa first.agp second.agp
taf-ragtag ragtag.py scaffold --aligner nucmer -o nucmer_out ref.fa draft.fa
taf-ragtag ragtag.py agpcheck scaffold_out/ragtag.scaffold.agp
taf-ragtag ragtag.py agp2fa scaffold_out/ragtag.scaffold.agp draft.fa > scaffolds.fa
taf-ragtag mummerplot --png -p dot alignment.delta
```

Use `-f`, filtering/confidence parameters and aligner options according to
assembly properties. Tiny smoke thresholds are not production recommendations.

## Backend Usage and Capability Matrix

```sh
TAFFISH_CONTAINER_BACKEND=docker taf-ragtag -- --version
TAFFISH_CONTAINER_BACKEND=podman taf-ragtag -- --version
TAFFISH_CONTAINER_BACKEND=apptainer taf-ragtag -- --version
```

| Capability | Docker | Podman | Apptainer |
| --- | --- | --- | --- |
| CLI and headless plots | Linux container/VM | Linux container/VM | Linux host, read-only SIF |
| Optional shared reference | `-v ROOT:/references:ro` | `-v ROOT:/references:ro` | `--bind ROOT:/references:ro` |
| Interactive X11/noVNC | not provided | not provided | not provided |

Apptainer is not a native macOS runtime; use a Docker/Podman Linux VM there.
CPU/memory/disk scale with assembly size and selected aligner.
No app-intrinsic backend arguments are needed; the optional reference mounts
below are per-invocation/site policy, not hidden app requirements.

## Command Mode

The two-line `src/main.taf` retains TAFFISH automatic command mode:
`taf-ragtag ragtag.py scaffold ...` selects the upstream dispatcher, whereas
`taf-ragtag minimap2 --version` selects a packaged executable. Do not use bare
`taf-ragtag scaffold`: there is no executable named scaffold.
Option-leading default-command calls use `taf-ragtag -- --help`.
Wrapper metadata/help/compile remain `--version`, `--help`, `--compile`.

## Inputs

| Input | Purpose | Preparation |
| --- | --- | --- |
| reference/target and query FASTA | correction/scaffolding/patching | pre-index before read-only sharing |
| AGP | assembly layout and merge/annotation conversion | AGP 2.1 |
| PAF/delta | alignments and conversion utilities | compatible alignment coordinates/CIGAR |
| GFF | annotation coordinate conversion | sequence IDs must match components |
| BAM | optional Hi-C/read validation | Hi-C link counting expects query-name sorting |

`taf-ragtag samtools sort -n -o hic.qname.bam hic.bam` prepares query-name order.
Uncompressed FASTA is the portable aligner input. bgzipped FASTA can be used by
FASTA-reading utilities with `.fai` and `.gzi`; do not assume ordinary gzip is
BGZF or that every aligner accepts every compression format.

## Output Notes

Use explicit `-o DIR`; the upstream default is `ragtag_output`. Keep separate
output directories per analysis. Typical outputs are `ragtag.*.agp`,
`ragtag.*.fasta`, `.paf`/`.delta`, confidence/statistics tables, logs and
helper `.err` files. Some utilities write to stdout, so redirect it.
Existing intermediates may be reused; `-w` intentionally overwrites caches,
not a guarantee that old caches match the new tool/input version.

## Resources, Databases, and Platform

Resource classification: references, queries, annotations and Hi-C data are
project-specific inputs, not an upstream fixed database or pretrained model. RagTag
has no resource catalog or reference downloader and does not fetch data during
analysis. Thus a standardized automatic downloader/model installer, catalog
inventory, automatic discovery and AUTO_MOUNT switch are N/A here. This is not
an exemption merely because the user selects a reference. No upstream resource
unit exists to pin/download automatically; filenames and argv explicitly select
the scientific input. User data retain their own licenses and access rules.

Large project references can nevertheless be prepared once and shared read-only:

1. Obtain a reference from its authoritative provider under its license. Record
   accession/assembly release, original URL, provider checksum and a local
   SHA256 inventory. Do not silently replace an existing assembly directory.
2. Use a versioned personal path such as
   `~/.local/share/taffish/resources/ragtag/<assembly-id>/`, or ask the site
   administrator to prepare
   `/usr/local/share/taffish/resources/ragtag/<assembly-id>/`. An administrator
   can instead choose `/opt/taffish/resources/ragtag/<assembly-id>/`.
3. In a writable staging directory, run `taf-ragtag samtools faidx ref.fa`;
   keep `.fai` beside FASTA, plus `.gzi` for BGZF. Verify checksums and promote
   the complete directory on the same filesystem. Use readable files (typically
   0644) and traversable directories (0755); do not make references world-writable.
4. Bind the resolved prepared directory read-only. Ordinary users need no root
   privilege, additional download or private copy. Output goes to their own
   writable project directory. Pre-index query FASTA too, or keep it writable.

```sh
TAFFISH_CONTAINER_BACKEND=docker \
  TAFFISH_DOCKER_RUN_ARGS="-v /absolute/reference-root:/references:ro" \
  taf-ragtag ragtag.py scaffold -o out /references/ref.fa draft.fa
TAFFISH_CONTAINER_BACKEND=podman \
  TAFFISH_PODMAN_RUN_ARGS="-v /absolute/reference-root:/references:ro" \
  taf-ragtag ragtag.py scaffold -o out /references/ref.fa draft.fa
TAFFISH_CONTAINER_BACKEND=apptainer \
  TAFFISH_APPTAINER_RUN_ARGS="--bind /absolute/reference-root:/references:ro" \
  taf-ragtag ragtag.py scaffold -o out /references/ref.fa draft.fa
```

Repeat the inline mount setting for each later shared-input invocation; unset
it/omit the mount to stop using it. Explicit argv is the override, with no
implicit personal/site search. Use resolved paths without spaces/colons for
these mount strings. If sharing is unavailable, copy the chosen input into a
private writable project directory and index it there. No production reference
catalog or root-owned system deployment is claimed by synthetic sharing tests.

Runtime write map: `-o` and redirected outputs are persistent user output;
FASTA `.fai`/`.gzi` are adjacent preparation sidecars; smoke/temp files use
unique writable scratch. The installed Python/tools tree is read-only and
bytecode generation is disabled. There is no runtime installation or hidden
network/cache download.

## Boundaries

The official RagTag package, scripts, README/wiki and installation metadata
were reviewed for extras, entry points, plugins and companion GUI requirements;
RagTag itself provides CLI workflows, not a bundled GUI. MUMmer's optional
`mummerplot` defaults to X11 upstream, but this image intentionally provides
`gnuplot-nox` and the explicit headless PNG/PostScript path instead. Interactive
X11, browser/noVNC service, ports and GUI lifecycle are not exposed; use
`mummerplot --png` and open the resulting image in a host viewer. No shell/UI
wrapper replaces RagTag's normal command interface.

## Troubleshooting

- Missing `.fai`/`.gzi` on read-only input: prepare them as owner before sharing.
- Subcommand error: read stderr and the output directory's `.err` files; the
  dispatcher now returns failure instead of a misleading zero exit.
- Existing intermediates: use a fresh directory after changing inputs/version.
- No display in mummerplot: use `--png` or `--postscript`, not default X11.
- Large intermediate files: put `-o` on a filesystem with sufficient space.

## Testing

Each manifest test is independent and offline. The 13 modes cover pinned
identity/imports, all dispatcher help, linkage, four upstream reverse-strand
unit regressions, three aligner scaffold paths, correct, patch, merge, AGP/FASTA
reconstruction, PAF/delta round-trip, GFF reverse-strand coordinate conversion,
Hi-C BAM links, headless PNG and negative exit-code propagation.
The 35 executable probes are checked individually and as one combined probe.

Build-time checks are limited to versions/imports/linkage/help and a 30 kb
minimap2 scaffold. Full plot/render and additional workflow tests run afterward,
not inside the canonical native build gate. Action is a whole-file exact copy
of the current fresh `taf new` template, with root context `.`.

Packaging validation (2026-10-03, candidate; not published):

- Native root-context builds: amd64 on Linux/xjp; arm64 on the local Linux VM.
- Docker and Podman: 49/49 exact probes in both normal and read-only roots on
  each native platform. Apptainer: 49/49 in a real read-only amd64 SIF built
  from the same candidate OCI, with clean/contained/offline execution.
- Total: 441/441 direct probes across nine matrices; 167/167 real wrapper
  checks across five platform/backend routes, including persistent outputs,
  prepared FASTA/BGZF read-only binds, missing-index rejection, and output UID.
- Docker additionally proves another ordinary UID can reuse a prepared
  reference. No system directory was changed, and no production reference was
  downloaded. ARM Apptainer is not separately validated; the narrow Perl
  lifecycle/permission fixes pass native ARM Docker/Podman and AMD Apptainer.
- 35/35 external negative checks cover original exit codes, bounded diagnostic
  logs, child signal propagation, unwritable output and safe interception of
  the old PID 1 bug. Patched/unpatched plot output is byte-identical in that
  controlled comparison. No backend exception is used.
- Final uncompressed image sizes: amd64 340,667,901 bytes; arm64 347,894,055
  bytes. Major runtime directories: MUMmer 16 MB, minimap2 about 1 MB,
  unimap below 1 MB, RagTag below 1 MB; Python and system shared libraries
  account for most remaining payload. Inspect/history/du and package inventories
  were recorded. Build-only payload was excluded before final-stage COPY;
  no percentage reduction against an old registry image is claimed.

No full production assembly or biological correctness claim follows from smoke.

## License and Citation

TAFFISH packaging: Apache-2.0. RagTag, minimap2 and unimap: MIT. MUMmer4:
Artistic-2.0; bundled Debian packages retain their own copyright files.
RagTag/dependency licenses are kept under their `/opt/*/share/licenses/` paths.
The unimap tag lacks a standalone license, so its MIT text is pinned from
upstream commit `cb7ad7560cf56a354d3abb91fc1bdf75108f9380`.

Alonge M, et al. Automated assembly scaffolding elevates a new tomato system
for high-throughput genome editing. Genome Biology (2022).
[DOI:10.1186/s13059-022-02823-7](https://doi.org/10.1186/s13059-022-02823-7).
