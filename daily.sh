REP=hurriedreformist
export REP
for i in 30 31 40
do
    (cd $i;./daily.sh)
done

docker push $REP/gnucobol
