ragtag 2.1.1-r1

Purpose:
  Correct, scaffold, patch and merge genome assemblies using local inputs.

Usage:
  taf-ragtag -- --help
  taf-ragtag -- --version
  taf-ragtag ragtag.py scaffold -t 8 -u -o scaffold_out ref.fa draft.fa
  taf-ragtag ragtag.py correct -t 8 -o correct_out ref.fa draft.fa
  taf-ragtag ragtag.py patch -t 8 -u -o patch_out target.fa query.fa
  taf-ragtag ragtag.py merge -o merge_out draft.fa first.agp second.agp
  Use ragtag.py explicitly: bare "taf-ragtag scaffold" is not a subcommand call.

Inputs and options:
  FASTA       Reference/target and query assemblies; prepare .fai before sharing.
  AGP         Scaffold layouts for merge, agpcheck, agp2fa and updategff.
  BAM/GFF     Optional Hi-C/read evidence or annotations; supplied by you.
  -o DIR      Writable output directory; keep a separate directory per analysis.
  -t N        Aligner threads. --aligner unimap or nucmer selects another aligner.
  -u          Add suffixes to unplaced sequences where supported.
  -w          Intentionally overwrite cached intermediates; otherwise reused.
  -f N        Minimum alignment length; choose it for your assembly, not blindly.

Inspect or convert results:
  taf-ragtag ragtag.py agpcheck scaffold_out/ragtag.scaffold.agp
  taf-ragtag ragtag.py agp2fa scaffold_out/ragtag.scaffold.agp draft.fa > scaffolds.fa
  taf-ragtag ragtag.py asmstats scaffolds.fa
  taf-ragtag mummerplot --png -p dot alignment.delta

Key outputs:
  DIR/ragtag.*.agp / .fasta     Assembly layout and sequence.
  DIR/ragtag.*.paf / .delta    Alignment intermediates.
  DIR/ragtag.*.err / *.log     Helper and aligner diagnostics.
  Utilities may write to stdout; redirect it to preserve results.

Backend choice:
  TAFFISH_CONTAINER_BACKEND=docker taf-ragtag -- --version
  TAFFISH_CONTAINER_BACKEND=podman taf-ragtag -- --version
  TAFFISH_CONTAINER_BACKEND=apptainer taf-ragtag -- --version
  Apptainer requires Linux; macOS uses Docker/Podman Linux VMs.

Read-only shared reference (optional):
  The owner/admin first indexes FASTA while its directory is writable:
  taf-ragtag samtools faidx ref.fa
  For bgzipped FASTA, keep both .fai and .gzi beside it; ordinary gzip is not BGZF.
  Prepare the query index too, or keep the query in a writable project directory.
  Replace /absolute/reference-root with a prepared host directory:
  TAFFISH_CONTAINER_BACKEND=docker \
    TAFFISH_DOCKER_RUN_ARGS="-v /absolute/reference-root:/references:ro" \
    taf-ragtag ragtag.py scaffold -o out /references/ref.fa draft.fa
  TAFFISH_CONTAINER_BACKEND=podman \
    TAFFISH_PODMAN_RUN_ARGS="-v /absolute/reference-root:/references:ro" \
    taf-ragtag ragtag.py scaffold -o out /references/ref.fa draft.fa
  TAFFISH_CONTAINER_BACKEND=apptainer \
    TAFFISH_APPTAINER_RUN_ARGS="--bind /absolute/reference-root:/references:ro" \
    taf-ragtag ragtag.py scaffold -o out /references/ref.fa draft.fa
  These settings apply to that command only; repeat them for later shared-input calls.
  Mount the resolved directory, not a symlink; use paths without spaces or colons.

Immediate notes:
  Inputs are project-specific: no reference downloader, database or model is bundled.
  Missing .fai/.gzi can trigger writes beside FASTA; pre-index shared inputs first.
  Hi-C BAM must be query-name sorted: taf-ragtag samtools sort -n -o hic.qname.bam hic.bam
  Use fresh output directories after upgrading; old alignment caches are not revalidated.
  2.1.1 fixes reverse-strand merging, so scaffold orientation/order/gaps can change.
  MUMmer plots use --png/--postscript; interactive X11 is not provided in this image.

More help:
  taf-ragtag ragtag.py scaffold --help
  taf-ragtag ragtag.py patch --help
  https://github.com/taffish/ragtag
  https://github.com/malonge/RagTag/wiki

Wrapper options:
  taf-ragtag --help       Show this TAFFISH help.
  taf-ragtag --version    Show wrapper identity.
  taf-ragtag --compile    Print generated shell; -- --help shows upstream help.
