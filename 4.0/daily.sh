for i in builder runtime hello
do
    (cd $i;podman build -t gnucobol:4.0-$i .)
    podman tag gnucobol:4.0-$i $REP/gnucobol:4.0-$i
done
