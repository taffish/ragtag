ARG RAGTAG_VERSION=2.1.1
ARG RAGTAG_TAG=v2.1.1
ARG RAGTAG_SHA256=ef19fbd09b7431e97371f35c7523d02f9bbe4418ce3143abb611d2cef8a2b451
ARG MINIMAP2_VERSION=2.31
ARG MINIMAP2_INTERNAL_VERSION=2.31-r1302
ARG MINIMAP2_SHA256=c1351de6319c123369c2f4f37ba0ccf18c7ace47e2b1c0a35e30056b4a3bd9c9
ARG MUMMER_VERSION=4.0.1
ARG MUMMER_SHA256=bc20ae2701a0b2e323e4e515b7cfa18a0f0cb34a4ff5844b289b2de0154e3d3e
ARG MUMMER_LICENSE_SHA256=bfa1e6460e4086c49f80a22ee90305e11461c77983c20f2beaa480953a66fa05
ARG MUMMER_COPYRIGHT_SHA256=9469bbabef5583edf9995e2bc5b0f62d8c611ccb22374e2a0f6f2567f1b6a146
ARG UNIMAP_VERSION=0.1
ARG UNIMAP_INTERNAL_VERSION=0.1-r41
ARG UNIMAP_SHA256=d5d7831e1fa78c943a96ef78ba22ec88eebf39368bdb135c30554f052f0dbc5c
ARG UNIMAP_LICENSE_COMMIT=cb7ad7560cf56a354d3abb91fc1bdf75108f9380
ARG UNIMAP_LICENSE_SHA256=ee3d43f5a37f90c3f85e7688c3e7e705777b3fd757f51adfefaf7ab0168b7518

FROM debian:12-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251 AS minimap2-builder

ARG MINIMAP2_VERSION
ARG MINIMAP2_INTERNAL_VERSION
ARG MINIMAP2_SHA256
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get -o Acquire::Retries=5 update; \
    for attempt in 1 2 3 4 5; do \
        if apt-get -o Acquire::Retries=5 install -y --no-install-recommends \
            bzip2 \
            build-essential \
            ca-certificates \
            curl \
            zlib1g-dev; then \
            break; \
        fi; \
        if [ "$attempt" = 5 ]; then exit 1; fi; \
        apt-get -o Acquire::Retries=5 update; \
        sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/minimap2-build

RUN set -eux; \
    curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      "https://github.com/lh3/minimap2/releases/download/v${MINIMAP2_VERSION}/minimap2-${MINIMAP2_VERSION}.tar.bz2" \
      -o minimap2.tar.bz2; \
    echo "${MINIMAP2_SHA256}  minimap2.tar.bz2" | sha256sum -c -; \
    tar -xjf minimap2.tar.bz2 --strip-components=1; \
    arch="$(uname -m)"; \
    case "$arch" in \
      x86_64|amd64) make_flags="" ;; \
      aarch64|arm64) make_flags="arm_neon=1 aarch64=1" ;; \
      *) echo "Unsupported minimap2 build architecture: $arch" >&2; exit 1 ;; \
    esac; \
    make -j"$(nproc)" ${make_flags}; \
    mkdir -p /opt/minimap2/bin /opt/minimap2/share/doc/minimap2 /opt/minimap2/share/licenses/minimap2; \
    install -m 0755 minimap2 /opt/minimap2/bin/minimap2; \
    install -m 0644 README.md FAQ.md NEWS.md cookbook.md /opt/minimap2/share/doc/minimap2/; \
    install -m 0644 LICENSE.txt /opt/minimap2/share/licenses/minimap2/LICENSE.txt; \
    /opt/minimap2/bin/minimap2 --version | grep -Fx "${MINIMAP2_INTERNAL_VERSION}" >/dev/null

FROM debian:12-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251 AS unimap-builder

ARG UNIMAP_VERSION
ARG UNIMAP_INTERNAL_VERSION
ARG UNIMAP_SHA256
ARG UNIMAP_LICENSE_COMMIT
ARG UNIMAP_LICENSE_SHA256
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get -o Acquire::Retries=5 update; \
    for attempt in 1 2 3 4 5; do \
        if apt-get -o Acquire::Retries=5 install -y --no-install-recommends \
            build-essential \
            ca-certificates \
            curl \
            libsimde-dev \
            zlib1g-dev; then \
            break; \
        fi; \
        if [ "$attempt" = 5 ]; then exit 1; fi; \
        apt-get -o Acquire::Retries=5 update; \
        sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/unimap-build

RUN set -eux; \
    curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      "https://github.com/lh3/unimap/archive/refs/tags/v${UNIMAP_VERSION}.tar.gz" \
      -o unimap.tar.gz; \
    echo "${UNIMAP_SHA256}  unimap.tar.gz" | sha256sum -c -; \
    tar -xzf unimap.tar.gz --strip-components=1; \
    arch="$(uname -m)"; \
    case "$arch" in \
      x86_64|amd64) make -j"$(nproc)" ;; \
      aarch64|arm64) make -j"$(nproc)" arm_neon=1 aarch64=1 CPPFLAGS="-DHAVE_KALLOC -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES" ;; \
      *) echo "Unsupported unimap build architecture: $arch" >&2; exit 1 ;; \
    esac; \
    mkdir -p /opt/unimap/bin /opt/unimap/share/doc/unimap /opt/unimap/share/licenses/unimap; \
    install -m 0755 unimap /opt/unimap/bin/unimap; \
    install -m 0644 README.md /opt/unimap/share/doc/unimap/; \
    curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      "https://raw.githubusercontent.com/lh3/unimap/${UNIMAP_LICENSE_COMMIT}/LICENSE.txt" \
      -o /opt/unimap/share/licenses/unimap/LICENSE.txt; \
    echo "${UNIMAP_LICENSE_SHA256}  /opt/unimap/share/licenses/unimap/LICENSE.txt" | sha256sum -c -; \
    /opt/unimap/bin/unimap --version | grep -Fx "${UNIMAP_INTERNAL_VERSION}" >/dev/null

FROM debian:12-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251 AS mummer-builder

ARG MUMMER_VERSION
ARG MUMMER_SHA256
ARG MUMMER_LICENSE_SHA256
ARG MUMMER_COPYRIGHT_SHA256
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get -o Acquire::Retries=5 update; \
    for attempt in 1 2 3 4 5; do \
        if apt-get -o Acquire::Retries=5 install -y --no-install-recommends \
            ca-certificates \
            curl \
            g++ \
            gawk \
            make \
            perl; then \
            break; \
        fi; \
        if [ "$attempt" = 5 ]; then exit 1; fi; \
        apt-get -o Acquire::Retries=5 update; \
        sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/mummer-build

RUN set -eux; \
    curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      "https://github.com/mummer4/mummer/releases/download/v${MUMMER_VERSION}/mummer-${MUMMER_VERSION}.tar.gz" \
      -o mummer.tar.gz; \
    echo "${MUMMER_SHA256}  mummer.tar.gz" | sha256sum -c -; \
    tar -xzf mummer.tar.gz --strip-components=1; \
    ./configure --prefix=/opt/mummer --disable-dependency-tracking; \
    make -j"$(nproc)"; \
    make install; \
    mkdir -p /opt/mummer/share/doc/mummer4 /opt/mummer/share/licenses/mummer4; \
    cp README.md INSTALL.md ChangeLog /opt/mummer/share/doc/mummer4/; \
    curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      "https://raw.githubusercontent.com/mummer4/mummer/v${MUMMER_VERSION}/LICENSE.md" \
      -o /opt/mummer/share/licenses/mummer4/LICENSE.md; \
    echo "${MUMMER_LICENSE_SHA256}  /opt/mummer/share/licenses/mummer4/LICENSE.md" | sha256sum -c -; \
    curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      "https://raw.githubusercontent.com/mummer4/mummer/v${MUMMER_VERSION}/COPYRIGHT" \
      -o /opt/mummer/share/licenses/mummer4/COPYRIGHT; \
    echo "${MUMMER_COPYRIGHT_SHA256}  /opt/mummer/share/licenses/mummer4/COPYRIGHT" | sha256sum -c -; \
    /opt/mummer/bin/nucmer -V 2>&1 | grep -Fx "${MUMMER_VERSION}" >/dev/null; \
    rm -rf /opt/mummer/include /opt/mummer/lib/pkgconfig; \
    find /opt/mummer/lib -type f \( -name '*.a' -o -name '*.la' \) -delete

COPY docker/patch-mummer.pl /tmp/patch-mummer.pl
RUN perl /tmp/patch-mummer.pl /opt/mummer \
 && perl -c /opt/mummer/bin/mummerplot

FROM debian:12-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251 AS ragtag-src

ARG RAGTAG_TAG
ARG RAGTAG_SHA256
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get -o Acquire::Retries=5 update; \
    apt-get -o Acquire::Retries=5 install -y --no-install-recommends ca-certificates curl; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/ragtag-src

RUN set -eux; \
    curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      "https://github.com/malonge/RagTag/archive/refs/tags/${RAGTAG_TAG}.tar.gz" \
      -o ragtag.tar.gz; \
    echo "${RAGTAG_SHA256}  ragtag.tar.gz" | sha256sum -c -; \
    tar -xzf ragtag.tar.gz --strip-components=1; \
    rm ragtag.tar.gz

FROM ragtag-src AS ragtag-builder

ARG RAGTAG_TAG
ARG RAGTAG_SHA256
RUN apt-get -o Acquire::Retries=5 update \
 && apt-get install -y --no-install-recommends python3-pip python3-setuptools python3-wheel \
 && rm -rf /var/lib/apt/lists/*
COPY docker/patch-dispatch.py /tmp/patch-dispatch.py
RUN set -eux; \
    mkdir -p /opt/ragtag/share/doc/ragtag /opt/ragtag/share/licenses/ragtag /opt/ragtag/share/testdata; \
    cp README.md ragtag.py /opt/ragtag/share/doc/ragtag/; \
    cp LICENSE /opt/ragtag/share/licenses/ragtag/; \
    cp -R tests /opt/ragtag/share/testdata/upstream-tests; \
    python3 /tmp/patch-dispatch.py ragtag.py; \
    python3 -m pip install --no-cache-dir --no-build-isolation --no-deps --root /opt/ragtag-install .; \
    printf 'Tag: %s\nSHA256: %s\nPatch: child exit status and unknown-command failure only\n' "$RAGTAG_TAG" "$RAGTAG_SHA256" > /opt/ragtag/share/doc/ragtag/source.txt

FROM debian:12-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251

ARG RAGTAG_VERSION
ARG MINIMAP2_INTERNAL_VERSION
ARG MUMMER_VERSION
ARG UNIMAP_INTERNAL_VERSION
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get -o Acquire::Retries=5 update; \
    for attempt in 1 2 3 4 5; do \
        if apt-get -o Acquire::Retries=5 install -y --no-install-recommends \
            bash \
            ca-certificates \
            coreutils \
            file \
            findutils \
            gawk \
            gnuplot-nox \
            grep \
            gzip \
            libgomp1 \
            libstdc++6 \
            perl \
            python3 \
            python3-intervaltree \
            python3-networkx \
            python3-numpy \
            python3-pysam \
            samtools \
            sed \
            tabix \
            zlib1g; then \
            break; \
        fi; \
        if [ "$attempt" = 5 ]; then exit 1; fi; \
        apt-get -o Acquire::Retries=5 update; \
        sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

COPY --from=minimap2-builder /opt/minimap2 /opt/minimap2
COPY --from=unimap-builder /opt/unimap /opt/unimap
COPY --from=mummer-builder /opt/mummer /opt/mummer
COPY --from=ragtag-builder /opt/ragtag-install/usr/local /usr/local
COPY --from=ragtag-builder /opt/ragtag /opt/ragtag
COPY docker/ragtag-smoke /usr/local/bin/ragtag-smoke

ENV PATH=/opt/minimap2/bin:/opt/unimap/bin:/opt/mummer/bin:/opt/mummer/libexec/mummer:${PATH}
ENV LD_LIBRARY_PATH=/opt/mummer/lib

RUN set -eux; \
    chmod 0755 /usr/local/bin/ragtag-smoke; \
    for cmd in /opt/mummer/bin/* /opt/mummer/libexec/mummer/* /opt/minimap2/bin/* /opt/unimap/bin/*; do \
        if [ -x "$cmd" ] && [ ! -e "/usr/local/bin/$(basename "$cmd")" ]; then \
            ln -s "$cmd" "/usr/local/bin/$(basename "$cmd")"; \
        fi; \
    done

ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=ragtag
ENV PYTHONDONTWRITEBYTECODE=1

RUN set -eux; \
    for cmd in ragtag.py ragtag_correct.py ragtag_scaffold.py ragtag_patch.py ragtag_merge.py ragtag_agp2fa.py ragtag_agpcheck.py ragtag_asmstats.py ragtag_delta2paf.py ragtag_paf2delta.py ragtag_splitasm.py ragtag_update_gff.py ragtag_rename.py ragtag_stats.py minimap2 unimap nucmer delta-filter show-coords samtools python3 bash; do \
        command -v "$cmd" >/dev/null; \
    done; \
    ragtag.py --version | grep -Fx "v${RAGTAG_VERSION}" >/dev/null; \
    ragtag.py --help 2>&1 | grep -F "Tools for fast and flexible genome assembly scaffolding" >/dev/null; \
    ragtag.py scaffold --help 2>&1 | grep -F "Homology-based assembly scaffolding" >/dev/null; \
    ragtag.py patch --help 2>&1 | grep -F "Homology-based assembly patching" >/dev/null; \
    minimap2 --version | grep -Fx "${MINIMAP2_INTERNAL_VERSION}" >/dev/null; \
    unimap --version | grep -Fx "${UNIMAP_INTERNAL_VERSION}" >/dev/null; \
    nucmer -V 2>&1 | grep -Fx "${MUMMER_VERSION}" >/dev/null; \
    samtools --version 2>&1 | grep -F "samtools" >/dev/null; \
    python3 -c 'import ragtag_utilities, intervaltree, networkx, numpy, pysam; print("ok")' | grep -Fx "ok" >/dev/null; \
    python3 -m py_compile \
        "$(command -v ragtag.py)" \
        "$(command -v ragtag_correct.py)" \
        "$(command -v ragtag_scaffold.py)" \
        "$(command -v ragtag_patch.py)" \
        "$(command -v ragtag_merge.py)" \
        "$(command -v ragtag_agp2fa.py)" \
        "$(command -v ragtag_delta2paf.py)" \
        "$(command -v ragtag_paf2delta.py)"; \
    tmp=/tmp/taf-ragtag-build-check; \
    rm -rf "$tmp"; \
    mkdir -p "$tmp"; \
    cd "$tmp"; \
    python3 -c 'import random; random.seed(7); seq = "".join(random.choice("ACGT") for _ in range(30000)); open("ref.fa", "w").write(">ref\n" + seq + "\n"); open("query.fa", "w").write(">ctg1\n" + seq + "\n")'; \
    ragtag.py scaffold -f 1000 -t 1 -o mm2 ref.fa query.fa > mm2.log 2>&1 || { cat mm2.log >&2; exit 1; }; \
    test -s mm2/ragtag.scaffold.agp; \
    test -s mm2/ragtag.scaffold.fasta; \
    grep -F "ctg1" mm2/ragtag.scaffold.agp >/dev/null; \
    ragtag.py agpcheck mm2/ragtag.scaffold.agp > agpcheck.txt 2>&1; \
    grep -F "complete with no errors" agpcheck.txt >/dev/null; \
    ragtag.py asmstats mm2/ragtag.scaffold.fasta > asmstats.tsv; \
    grep -F "N50" asmstats.tsv >/dev/null; \
    cd /; \
    rm -rf "$tmp"; \
    find /opt/minimap2 /opt/unimap /opt/mummer -type f -perm /111 -exec sh -c 'for f do if file "$f" | grep -q "ELF"; then ldd "$f"; fi; done' sh {} + > /tmp/ragtag-ldd.txt; \
    find /usr/lib/python3/dist-packages /usr/local/lib/python3.*/dist-packages -type f -name "*.so" -exec ldd {} + >> /tmp/ragtag-ldd.txt; \
    if grep -F "not found" /tmp/ragtag-ldd.txt; then exit 1; fi; \
    rm -f /tmp/ragtag-ldd.txt

WORKDIR /work
