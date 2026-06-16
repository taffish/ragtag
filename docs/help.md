ragtag 2.1.0-r1

Purpose:
  RagTag is a toolkit for reference-guided genome assembly improvement:
  correction, scaffolding, patching, scaffold merging, and AGP/PAF/Delta
  assembly utilities.

Usage:
  taf-ragtag -- --help
  taf-ragtag -- --version
  taf-ragtag ragtag.py scaffold ref.fa query.fa -o ragtag_scaffold
  taf-ragtag ragtag.py correct ref.fa query.fa -o ragtag_correct
  taf-ragtag ragtag.py patch target.fa query.fa -o ragtag_patch
  taf-ragtag ragtag.py merge query.fa scf1.agp scf2.agp -o ragtag_merge

Common workflows:
  taf-ragtag ragtag.py scaffold -t 8 ref.fa draft.fa -o scaffold_out
  taf-ragtag ragtag.py scaffold --aligner nucmer ref.fa draft.fa -o nucmer_out
  taf-ragtag ragtag.py patch target.fa query.fa -o patch_out
  taf-ragtag ragtag.py agpcheck ragtag.scaffold.agp
  taf-ragtag ragtag.py agp2fa ragtag.scaffold.agp draft.fa > scaffolds.fa
  taf-ragtag ragtag.py asmstats draft.fa ragtag.scaffold.fasta

Packaged commands:
  ragtag.py             upstream command dispatcher
  ragtag_correct.py     correction subcommand implementation
  ragtag_scaffold.py    scaffolding subcommand implementation
  ragtag_patch.py       patching subcommand implementation
  ragtag_merge.py       merge subcommand implementation
  ragtag_agp2fa.py      AGP plus components to FASTA
  ragtag_agpcheck.py    AGP v2.1 validation checks
  ragtag_asmstats.py    assembly statistics
  ragtag_delta2paf.py   MUMmer delta to PAF conversion
  ragtag_paf2delta.py   PAF with CIGAR to delta conversion
  minimap2              default RagTag aligner
  unimap                optional assembly-to-reference aligner
  nucmer                MUMmer4 aligner used by patch and optional workflows
  samtools              utility for BAM/SAM workflows

Upstream help and version:
  taf-ragtag -- --help
  taf-ragtag -- --version
  taf-ragtag ragtag.py scaffold --help
  taf-ragtag ragtag.py patch --help
  taf-ragtag minimap2 --version
  taf-ragtag nucmer -V

Inputs:
  reference/target FASTA    reference-guided correction/scaffolding/patching
  query FASTA               draft assembly or query sequence set
  AGP/PAF/delta/GFF/BAM     utility and merge/update inputs where applicable

Key outputs:
  ragtag.*.agp             scaffold/correction/patch AGP structure
  ragtag.*.fasta           resulting assembly FASTA where a command writes one
  ragtag.*.paf/delta       intermediate alignments
  confidence/stat files     command-specific reports and utility summaries

Platform and resources:
  Native container builds are requested for linux/amd64 and linux/arm64.
  No external database, network service, GPU, or bundled reference genome is
  required at run time. CPU, memory, and disk use scale with assembly size and
  with the selected aligner.

Boundaries:
  This app does not download reference genomes or choose biological thresholds.
  Large production runs should tune aligner parameters and inspect AGP/FASTA
  outputs. Hi-C merge support expects user-supplied BAM files.

Detailed documentation:
  https://github.com/malonge/RagTag
  https://github.com/malonge/RagTag/wiki

Wrapper options:
  taf-ragtag --help       Show this TAFFISH help.
  taf-ragtag --version    Show TAFFISH wrapper version.
  taf-ragtag --compile    Compile the TAFFISH wrapper.
  taf-ragtag -- --help    Pass option-leading arguments to the default command.

Notes:
  Command mode is enabled. Prefer explicit commands such as
  taf-ragtag ragtag.py scaffold ... because RagTag subcommands are not container
  executables named "scaffold" or "patch" by themselves.
