for i in builder runtime hello
do
    (cd $i;podman build -t gnucobol:3.0-$i .)
    podman tag gnucobol:3.0-$i $REP/gnucobol:3.0-$i
done
