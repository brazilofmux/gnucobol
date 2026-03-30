#!/bin/bash
set -euo pipefail

SVN_DIR=~/gnucobol-svn
PATCHED_DIR=~/gnucobol-svn-patched
BUILDER_DIR=~/gnucobol/4.0/builder

echo "=== Updating gnucobol-svn ==="
(cd "$SVN_DIR" && svn update)

echo "=== Creating patched copy ==="
rm -rf "$PATCHED_DIR"
cp -R "$SVN_DIR" "$PATCHED_DIR"
cd "$PATCHED_DIR"

# Apply any patches here. Add/remove as needed.
# Currently: null pointer check in libcob/common.c
echo "=== Applying patches ==="
sed -i 's/if (memcmp (p+1, "bin", 3) == 0/if (p \&\& (memcmp (p+1, "bin", 3) == 0/' libcob/common.c
sed -i 's/ || memcmp (p+1, "lib", 3) == 0) {/ || memcmp (p+1, "lib", 3) == 0)) {/' libcob/common.c
echo "Patched libcob/common.c (null pointer check)"

echo "=== Building distribution tarball ==="
./autogen.sh
./configure && make
po/update_linguas.sh
make distcheck

echo "=== Finding tarball ==="
TARBALL=$(ls gnucobol-*.tar.gz 2>/dev/null | head -1)
if [ -z "$TARBALL" ]; then
    echo "ERROR: No tarball produced"
    exit 1
fi
echo "Produced: $TARBALL"

echo "=== Staging tarball ==="
cp "$TARBALL" "$BUILDER_DIR/gnucobol-4.0.tar.gz"
echo "Copied to $BUILDER_DIR/gnucobol-4.0.tar.gz"

echo "=== Cleaning up ==="
rm -rf "$PATCHED_DIR"

echo ""
echo "=== Done ==="
echo "SVN revision: $(cd "$SVN_DIR" && svn info --show-item revision)"
echo "Tarball: $TARBALL -> gnucobol-4.0.tar.gz"
echo ""
echo "If the Dockerfile patches have changed, update:"
echo "  $BUILDER_DIR/Dockerfile"
echo ""
echo "Next steps:"
echo "  cd ~/gnucobol && git add -A && git commit -m 'Update gnucobol-4.0 tarball'"
