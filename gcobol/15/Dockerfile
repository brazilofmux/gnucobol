# gcobol: GCC's COBOL front end (GCC 15), as Fedora packages it -- a second
# oracle for ~/slow-32/cobol's harness beside GnuCOBOL (docs/oracles.md).
# One image compiles and runs: the programs it builds need libgcobol.
FROM fedora:42
RUN dnf -y install gcc-gcobol libgcobol && dnf clean all \
 && gcobol --version
WORKDIR /work
