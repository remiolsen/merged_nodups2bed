#!/bin/bash

usage() { echo "Usage: $0 -i <file> -o <bed_file>" 1>&2; exit 1; }

# Faking this for now. Don't know if it matters...
readlen=150

while getopts ":i:o:" opt; do
  case ${opt} in
    i) infile=${OPTARG} ;;
    o) outfile=${OPTARG} ;;
    *) usage;;
  esac
done

shift $((OPTIND-1))
if [ -z "${infile}" ] || [ -z "${outfile}" ]; then
    usage
fi

awk '{
      if($1==0){r1strand="+"}else{r1strand="-"};
      if($5==0){r2strand="+"}else{r2strand="-"};
      print $2,$3,$3+'$readlen',$15,$9,r1strand;
      print $6,$7,$7+'$readlen',$16,$12,r2strand
    }' < $infile | sort -k 4 > $outfile
