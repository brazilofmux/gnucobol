REP=274462252673.dkr.ecr.us-west-2.amazonaws.com
export REP
for i in 3.0 3.1 4.0
do
    (cd $i;./daily.sh)
done

#docker push $REP/gnucobol
