for i in builder runtime hello
do
    (cd $i;docker build -t gnucobol:3.2-$i .)
    docker tag gnucobol:3.2-$i $REP/gnucobol:3.2-$i
done
