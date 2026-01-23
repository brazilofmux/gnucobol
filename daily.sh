REP=274462252673.dkr.ecr.us-west-2.amazonaws.com
export REP
for i in 4.0
do
    (cd $i;./daily.sh)
done

#podman push $REP/gnucobol
