#!/bin/bash

# *** Make sure you have a new enough getopt to handle long options (see the man page)
getopt -T &>/dev/null
if [[ $? -ne 4 ]]; then echo "Getopt is too old!" >&2 ; exit 1 ; fi

declare {setwd,memarg,temparg,timearg,xfile,yfile,afile,lambda,npc,nfolds,sparams,ykernel,akernel,c1,maxiter,delta,filter,minmaxsep}
OPTS=$(getopt -u -o '' -a --longoptions 'setwd:,memarg:,temparg:,timearg:,xfile:,yfile:,afile:,lambda:,npc:,nfolds:,sparams:,ykernel:,akernel:,c1:,maxiter:,delta:,filter:,minmaxsep:' -n "$0" -- "$@")
    # *** Added -o '' ; surrounted the longoptions by ''
if [[ $? -ne 0 ]] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
    # *** This has to be right after the OPTS= assignment or $? will be overwritten

set -- $OPTS
    # *** As suggested by chepner

while true; do
  case $1 in
	--setwd )
		setwd=$2
		shift 2
		;;
	--memarg )
		memarg=$2
		shift 2
		;;
	--temparg )
		temparg=$2
		shift 2
		;;
	--timearg )
		timearg=$2
		shift 2
		;;
	--xfile )
        	xfile=$2
        	shift 2
        	;;
	--yfile )
        	yfile=$2
        	shift 2
        	;;
	--afile )
		afile=$2
		shift 2
		;;
	--lambda )
		lambda=$2
		shift 2
		;;
	--npc )
        	npc=$2
        	shift 2
        	;;
	--nfolds )
        	nfolds=$2
        	shift 2
        	;;
	--sparams )
		sparams=$2
		shift 2
		;;
	--ykernel )
		ykernel=$2
		shift 2
		;;
	--akernel )
		akernel=$2
		shift 2
		;;
	--c1 )
		c1=$2
		shift 2
		;;
	--maxiter )
		maxiter=$2
		shift 2
		;;
	--delta )
		delta=$2
		shift 2
		;;
	--filter )
		filter=$2
		shift 2
		;;
	--minmaxsep )
		minmaxsep=$2
		shift 2
		;;
	--)
        	shift
        	break
        	;;
    *)
  esac
done
echo "setwd: $setwd"
echo "xfile: $xfile"
echo "yfile: $yfile"
echo "afile: $afile"
echo "lambda: $lambda"
echo "npc: $npc"
echo "nfolds: $nfolds"
echo "sparams: $sparams"
echo "ykernel: $ykernel"
echo "akernel: $akernel"
echo "c1: $c1"
echo "maxiter: $maxiter"
echo "delta: $delta"
echo "filter: $filter"
echo "minmaxsep: $minmaxsep"
module load R/4.3.0-openblas
mkdir ${setwd}temp
mkdir ${setwd}temp/sbatch_logs
sbatch --time $timearg --mem $memarg --tmp $temparg --job-name data_partition --output ${setwd}temp/sbatch_logs/data_partition.out --error ${setwd}temp/sbatch_logs/data_partition.err ${setwd}prelim_data_acsspca_r.sh --setwd $setwd --xfile $xfile --yfile $yfile --afile $afile --lambda $lambda --npc $npc --nfolds $nfolds --sparams $sparams --ykernel $ykernel --akernel $akernel --c1 $c1 --maxiter $maxiter --delta $delta --filter $filter --minmaxsep $minmaxsep
tempvar=temp/param.txt
paramdir=$setwd$tempvar
until [ -f $paramdir ]
do
sleep 1
done
totalrows=$(< $paramdir wc -l)
echo "total rows: $totalrows"
numrows=$(expr $totalrows - 1)
echo "parameter rows: $numrows"
indexarray=$(seq -s ' ' 1 $numrows)
#echo "array: $indexarray"
mkdir ${setwd}temp/cv_outputs
for i in $indexarray
do
sbatch --time $timearg --mem $memarg --tmp $temparg --job-name cv_job_${i} --output ${setwd}/temp/sbatch_logs/cv_job_${i}.out --error ${setwd}/temp/sbatch_logs/cv_job_${i}.err ${setwd}cv_partition_acsspca.sh --setwd $setwd --index $i --lambda $lambda --npc $npc --nfolds $nfolds --ykernel $ykernel --akernel $akernel --c1 $c1 --maxiter $maxiter --delta $delta --filter $filter --minmaxsep $minmaxsep
echo "Submitted Job: $i"
sleep 0.25
done

exit 0
