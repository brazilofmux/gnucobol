for i in builder runtime hello
do
    (cd $i;docker build -t gnucobol:3.1-$i .)
    docker tag gnucobol:3.1-$i $REP/gnucobol:3.1-$i
done
