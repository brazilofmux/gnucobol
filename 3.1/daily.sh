for i in builder runtime hello
do
    (cd $i;podman build -t gnucobol:3.1-$i .)
    podman tag gnucobol:3.1-$i $REP/gnucobol:3.1-$i
done
