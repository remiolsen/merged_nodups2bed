#!/bin/bash

usage() { echo "Usage: $0 -i <file> -o <bed_file> -r <read_length=150> -a <awk_threads=8> -s <sort_threads=8> -h" 1>&2; exit 1; }

if [[ ${#} -eq 0 ]]; then
   usage
fi

while getopts ":i:o:r:a:s:h" opt; do
  case ${opt} in
    i) infile=${OPTARG} ;;
    o) outfile=${OPTARG} ;;
    r) readlen=${OPTARG} ;;
    a) awk_t=${OPTARG} ;;
    s) sort_t=${OPTARG} ;;
    h) usage ;;
    *) usage ;;
  esac
done

# Faking this for now. Don't know if it matters...
readlen=150
awk_t=8
sort_t=8

ma=`awk '{print match($15, "/")}' $infile | head -n 1`

shift $((OPTIND-1))
if [ -z "${infile}" ] || [ -z "${outfile}" ]; then
    usage
fi

if hash parallel 2>/dev/null; then
  export readlen
  export ma
  parallel -j $awk_t --block -1 --pipepart -a $infile awk \'{if\(\$1==0\){r1strand=\"+\"}else{r1strand=\"-\"}\;if\(\$5==0\){r2strand=\"+\"}else{r2strand=\"-\"}\;if\(\'\$ma\' \> 0\){r1=\$15}else{r1=\$15\"/1\"}\;if\(\'\$ma\' \> 0\){r2=\$16}else{r2=\$16\"/2\"}\;print \$2,\$3,\$3+\'\$readlen\',r1,\$9,r1strand\;print \$6,\$7,\$7+\'\$readlen\',r2,\$12,r2strand}\' | \
  sort -k 4 --parallel=$sort_t > $outfile
else
  awk '{
        if($1==0){r1strand="+"}else{r1strand="-"};
        if($5==0){r2strand="+"}else{r2strand="-"};
        if('$ma' > 0){r1=$15}else{r1=$15"/1"};
        if('$ma' > 0){r2=$16}else{r2=$16"/2"};
        print $2,$3,$3+'$readlen',r1,$9,r1strand;
        print $6,$7,$7+'$readlen',r2,$12,r2strand
      }' $infile | sort -k 4 > $outfile
fi
