#!/bin/bash
# Refresh a GnuCOBOL development line to an SVN revision -- by default the latest
# change on its branch -- so the oracle images track current code.
#
#   ./update.sh --check        each line's pin against its branch; changes nothing
#   ./update.sh 4.0            trunk, to its latest change
#   ./update.sh 3.3 5731       branches/gnucobol-3.x, as of r5731
#
# For <line> at r<rev> it:
#   1. normalises <rev> to the branch's own last change at or before it, so a pin
#      always names a change on that line, not just a repository-wide number;
#   2. `svn export`s that revision -- pristine source, the revision its identity.
#      SourceForge is contacted here, once; the image build never fetches;
#   3. refuses a branch whose configure.ac declares a different version (a 3.x
#      branch that moved to 3.4-dev must not be published as 3.3);
#   4. if the line's builder carries the NULL-guard patch, checks its anchors are
#      each still there exactly once -- and if upstream fixed the bug, says so and
#      stops rather than leave a build that would fail;
#   5. vendors the source as <line>/builder/gnucobol-<version>-r<rev>.tar.gz,
#      replacing the old one, and rewrites the builder's ARG pin and the pinned
#      tag in runtime/ and hello/. Changes are staged, not committed.
# It does not commit, build or publish; it prints what to run next.
#
# 3.1 and 3.2 are GNU releases: they come signed from ftp.gnu.org, not from SVN.
set -euo pipefail

cd "$(dirname "$0")"
SVN_ROOT=svn://svn.code.sf.net/p/gnucobol/code

line_branch()  { case "$1" in 3.3) echo branches/gnucobol-3.x ;; 4.0) echo trunk ;; *) return 1 ;; esac; }
line_version() { case "$1" in 3.3) echo 3.3-dev ;; 4.0) echo 4.0-early-dev ;; esac; }
pinned_rev()   { sed -n 's/^ARG GNUCOBOL_REV=\([0-9][0-9]*\)$/\1/p' "$1/builder/Dockerfile"; }
last_change()  { svn info --show-item last-changed-revision "$1" | tr -d '[:space:]'; }   # <url[@peg]>
retry()        { local n; for n in 1 2 3; do "$@" && return 0; echo "  (attempt $n failed; retrying)" >&2; sleep $((n * 5)); done; return 1; }

if [ "${1:-}" = "--check" ]; then
    for l in 3.3 4.0; do
        cur=$(pinned_rev "$l"); new=$(last_change "$SVN_ROOT/$(line_branch "$l")")
        if [ "$cur" = "$new" ]; then state="up to date"; else state="newer change: ./update.sh $l"; fi
        printf '%-4s %-22s pinned r%s, branch last changed r%s  (%s)\n' "$l" "$(line_branch "$l")" "$cur" "$new" "$state"
    done
    exit 0
fi

line=${1:-}
case "$line" in
    3.3|4.0) ;;
    3.1|3.2) echo "$line is a GNU release, not an SVN line: vendor the signed tarball from https://ftp.gnu.org/gnu/gnucobol/ and verify its .sig" >&2; exit 1 ;;
    *)       echo "usage: $0 --check | $0 <3.3|4.0> [rev]" >&2; exit 1 ;;
esac
[ -z "$(git status --porcelain -- "$line")" ] || { echo "$line/ has uncommitted changes; commit or stash them first" >&2; exit 1; }

branch=$(line_branch "$line"); version=$(line_version "$line"); url="$SVN_ROOT/$branch"
cur=$(pinned_rev "$line")
[ -n "$cur" ] || { echo "no 'ARG GNUCOBOL_REV=' in $line/builder/Dockerfile" >&2; exit 1; }
asked=${2:-HEAD}
case "$asked" in HEAD|[0-9]*) ;; *) echo "not a revision: '$asked'" >&2; exit 1 ;; esac
rev=$(last_change "$url@$asked")
case "$rev" in ''|*[!0-9]*) echo "could not read the branch's last change at $asked: '$rev'" >&2; exit 1 ;; esac
[ "$asked" = HEAD ] || [ "$asked" = "$rev" ] || echo "r$asked is not a change on $branch; its last change at or before it is r$rev -- pinning that"
if [ "$rev" = "$cur" ]; then echo "$line is already pinned at r$rev, $branch's last change"; exit 0; fi

logline=$(svn log -r "$rev" "$url@$rev" | sed -n '2p')                       # r5729 | who | 2026-10-06 ... | n lines
msg=$(svn log -r "$rev" "$url@$rev" | sed -n '4p')
who=$(echo "$logline" | awk -F' [|] ' '{print $2}')
date=$(echo "$logline" | awk -F' [|] ' '{print $3}' | cut -d' ' -f1)

work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
echo "=== exporting $branch r$rev ($date, $who) ==="
retry svn export -q "$url@$rev" "$work/src"

got=$(sed -n '/AC_INIT/,/)/p' "$work/src/configure.ac" | grep -oE '\[[0-9][^]]*\]' | head -1 | tr -d '[]')
[ "$got" = "$version" ] || { echo "$branch r$rev declares version '$got', not '$version' -- not publishing it as $line" >&2; exit 1; }

patch_note="none"
if grep -q 'if (p \\&\\& (memcmp (p+1, "bin", 3)' "$line/builder/Dockerfile"; then
    f="$work/src/libcob/common.c"
    nb=$(grep -c 'if (memcmp (p+1, "bin", 3) == 0$' "$f" || true)
    nl=$(grep -c '|| memcmp (p+1, "lib", 3) == 0) {$' "$f" || true)
    if [ "$nb" = 1 ] && [ "$nl" = 1 ]; then
        patch_note="NULL guard still needed: both anchors present exactly once"
    elif [ "$nb" = 0 ] && [ "$nl" = 0 ]; then
        echo "The NULL-guard anchors are gone from r$rev's libcob/common.c -- upstream may have fixed it." >&2
        echo "Check the code, then remove the patch block from $line/builder/Dockerfile before refreshing." >&2
        exit 1
    else
        echo "The NULL-guard anchors match $nb and $nl times (want 1 and 1) in r$rev -- inspect libcob/common.c" >&2
        exit 1
    fi
fi

# svn export stamps each file with its own last-changed time, so po/stamp-po
# (2012) is older than po/Makefile.in.in (2020) and make regenerates it, then
# fails "gettext infrastructure mismatch". Give every file the revision's commit
# time, as `git archive` does, so the tree is uniformly fresh.
stamp=$(svn info --show-item last-changed-date "$url@$rev")
python3 - "$work/src" "$stamp" <<'PY'
import os, sys, datetime
root, stamp = sys.argv[1:]
t = datetime.datetime.fromisoformat(stamp.replace("Z", "+00:00")).timestamp()
for d, dirs, files in os.walk(root):
    for n in dirs + files:
        os.utime(os.path.join(d, n), (t, t), follow_symlinks=False)
os.utime(root, (t, t))
PY

tb="gnucobol-$version-r$rev.tar.gz"
(cd "$work/src" && COPYFILE_DISABLE=1 tar -czf "$work/$tb" .)
sha=$(python3 -c 'import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest())' "$work/$tb")

old_tb=$(sed -n 's/^ARG GNUCOBOL_TARBALL=\(.*\)$/\1/p' "$line/builder/Dockerfile")
python3 - "$line" "$cur" "$rev" "$date" "$tb" "$sha" "svn export of $url@$rev" <<'PY'
import re, sys
line, cur, rev, date, tb, sha, origin = sys.argv[1:]
def rewrite(path, subs):
    s = open(path).read()
    for pat, rep in subs:
        s, n = re.subn(pat, rep, s, flags=re.M)
        if n != 1 and not pat.startswith("gnucobol"):
            sys.exit("%s: %r matched %d times, want 1" % (path, pat, n))
    open(path, "w").write(s)
rewrite(line + "/builder/Dockerfile", [
    (r"^ARG GNUCOBOL_REV=.*$",       "ARG GNUCOBOL_REV=" + rev),
    (r"^ARG GNUCOBOL_REV_DATE=.*$",  "ARG GNUCOBOL_REV_DATE=" + date),
    (r"^ARG GNUCOBOL_TARBALL=.*$",   "ARG GNUCOBOL_TARBALL=" + tb),
    (r"^ARG GNUCOBOL_SHA256=.*$",    "ARG GNUCOBOL_SHA256=" + sha),
    (r"^ARG GNUCOBOL_ORIGIN=.*$",    'ARG GNUCOBOL_ORIGIN="%s"' % origin),
])
old = "gnucobol:%s-r%s-" % (line, cur)
for sub in ("runtime", "hello"):
    p = "%s/%s/Dockerfile" % (line, sub)
    s = open(p).read()
    n = s.count(old)
    if n == 0: sys.exit("%s names no %s* -- its pinned tag is not where expected" % (p, old))
    open(p, "w").write(s.replace(old, "gnucobol:%s-r%s-" % (line, rev)))
PY

git rm -q "$line/builder/$old_tb"
cp "$work/$tb" "$line/builder/$tb"
git add "$line/builder/$tb" "$line/builder/Dockerfile" "$line/runtime/Dockerfile" "$line/hello/Dockerfile"

cat <<EOF

$line: r$cur -> r$rev   ($date, $who: $msg)
  tarball  $tb
  sha256   $sha
  patch    $patch_note
Staged, not committed. Next:
  ./daily.sh $line                                   # build and run it here first
  git commit -m "$line: $branch r$rev" && git push
  cd ~/builder && ./launch.sh jobs/gnucobol.sh       # builds the new pin; others are skipped
  ./manifest.sh && VARIANTS="$line-builder $line-runtime $line-hello" ./publish.sh --push
EOF
