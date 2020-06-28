for i in builder runtime hello
do
    (cd $i;docker build -t gnucobol:4.0-$i .)
    docker tag gnucobol:4.0-$i $REP/gnucobol:4.0-$i
done
