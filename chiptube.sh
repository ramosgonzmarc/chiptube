#! /bin/bash

## A help message is provided when no parameters file is specified.
if [ $# -ne 1 ]
then
  echo "The number of arguments provided is: $#"
  echo "The number of arguments provided is wrong."
  echo "Usage: bash chiptube.sh <params_file>"
  echo "chiptube.sh requires a params_file with values for ALL the necessary parameters."
  echo "An example of this can be found in the test folder."
  echo "For more info, check README.md"
  exit
fi

## Reading in params_file.
echo ""
echo "======================"
echo "| LOADING PARAMETERS |"
echo "======================"
echo ""

PARAMS=$1
INSDIR=$(grep installation_directory: $PARAMS | awk '{print($2)}')
echo "Installation directory = $INSDIR"
WD=$(grep working_directory: $PARAMS | awk '{print($2)}')
echo "Working directory = $WD"
EXP=$(grep experiment_name: $PARAMS | awk '{ print($2)}')
echo "Experiment name = $EXP"
NUMREPLICAS=$(grep number_replicas: $PARAMS | awk '{print($2)}')
echo "Number of replicas = $NUMREPLICAS"
GENOME=$(grep path_genome: $PARAMS | awk '{print($2)}')
echo "Reference genome = $GENOME"
ANNOTATION=$(grep path_annotation: $PARAMS | awk '{print($2)}')
echo "Annotation = $ANNOTATION"
CHR=$(grep universe_chromosomes: $PARAMS | awk '{print($2)}')
echo "Chromosomes for universe = $CHR"
PVALUEGO=$(grep p_value_cutoff_go: $PARAMS | awk '{print($2)}')
echo "P value cutoff for GO enrichment = $PVALUEGO"
PVALUEKEGG=$(grep p_value_cutoff_kegg: $PARAMS | awk '{print($2)}')
echo "P value cutoff for KEGG enrichment = $PVALUEKEGG"
PEAK=$(grep type_of_peak: $PARAMS | awk '{print($2)}')
echo "Narrow/broad peak = $PEAK"
SINGLE=$(grep single_or_paired: $PARAMS | awk '{print($2)}')
echo "Single/paired read = $SINGLE"
TSSUP=$(grep tss_upstream: $PARAMS | awk '{print($2)}')
echo "TSS region upstream = $TSSUP"
TSSDOWN=$(grep tss_downstream: $PARAMS | awk '{print($2)}')
echo "TSS region downstream = $TSSDOWN"

## Creating arrays for ChIP and input samples and filling them with the paths of the previously specified files.
CHIPS=()
INPUTS=()
i=0

if [ $SINGLE -eq 1 ]
then
  while [ $i -lt $NUMREPLICAS ]
  do
        j=$(($i + 1))
        CHIPS[$i]=$(grep path_sample_chip_$j: $PARAMS | awk '{print($2)}')
        INPUTS[$i]=$(grep path_sample_input_$j: $PARAMS | awk '{print($2)}')
        ((i++))
  done
  
elif [ $SINGLE -eq 2 ]
then
  while [ $i -lt $NUMREPLICAS ]
  do
        j=$(($i + 1))
        k=$(($i * 2))
        l=$(($k + 1))
        CHIPS[$k]=$(grep path_sample_chip_$j: $PARAMS | awk '{print($2)}')
        CHIPS[$l]=$(grep path_sample_chip_$j: $PARAMS | awk '{print($3)}')
        INPUTS[$k]=$(grep path_sample_input_$j: $PARAMS | awk '{print($2)}')
        INPUTS[$l]=$(grep path_sample_input_$j: $PARAMS | awk '{print($3)}')
        ((i++))
  done
else
  echo "No allowed input for single/paired reads determination"
fi

echo "Samples ="
echo "${CHIPS[@]}"
echo "${INPUTS[@]}"

## Generating work space.
echo ""
echo "========================="
echo "| GENERATING WORK SPACE |"
echo "========================="
echo ""

cd $WD
mkdir $EXP
cd $EXP
mkdir genome annotation results samples
cd genome
cp $GENOME genome.fa
cd ../annotation
cp $ANNOTATION annotation.gtf
cd ../samples


if [ $SINGLE -eq 1 ]
then
  i=1
  while [ $i -le $NUMREPLICAS ]
  do
  	mkdir replica_$i
  	cd replica_$i
      	mkdir chip input replica_results
      	cd chip 
      	j=$(($i - 1))
      	cp ${CHIPS[$j]} sample_chip_$i.fq.gz
      	cd ..
      	cd input
      	cp ${INPUTS[$j]} sample_input_$i.fq.gz
      	cd ../..
      	((i++))
  done
  
elif [ $SINGLE -eq 2 ]
then
  i=1
  while [ $i -le $NUMREPLICAS ]
  do
  	mkdir replica_$i
  	cd replica_$i
      	mkdir chip input replica_results
      	cd chip 
      	j=$(($i - 1))
      	k=$(($j * 2))
      	l=$(($k + 1))
      	cp ${CHIPS[$k]} sample_chip_${i}_1.fq.gz
      	cp ${CHIPS[$l]} sample_chip_${i}_2.fq.gz
      	cd ..
      	cd input
      	cp ${INPUTS[$k]} sample_input_${i}_1.fq.gz
      	cp ${INPUTS[$l]} sample_input_${i}_2.fq.gz
      	cd ../..
      	((i++))
  done
else
  echo "No allowed input for single/paired reads determination"
fi

## Generating reference genome index.
echo ""
echo "=================="
echo "| CREATING INDEX |"
echo "=================="
echo ""

cd ../genome
bowtie2-build genome.fa index
echo "Files size:" du -h *

## Processing individual samples. 
echo ""
echo "================================="
echo "| PROCESSING INDIVIDUAL SAMPLES |"
echo "================================="
echo ""

cd ../results
i=1
while [ $i -le $NUMREPLICAS ]
do
        bash $INSDIR/chiptube/sample_processing $WD/$EXP/samples/replica_$i $i $EXP $NUMREPLICAS $GENOME $INSDIR $PEAK | tee output_$i.txt
        ((i++))
done

## Intersecting the peaks from the different replicas and creating a final merged file.

cd ..

if [ $PEAK -eq 1 ]
then
  EXT=$(echo 'narrowPeak')

elif [ $PEAK -eq 2 ]
then
  EXT=$(echo 'broadPeak')
fi

i=3
if [ $NUMREPLICAS -eq 1 ]
then
	mv samples/replica_1/replica_results/1_peaks.${EXT} results/merged_2.${EXT}
else
	bedtools intersect -a samples/replica_1/replica_results/1_peaks.${EXT} -b samples/replica_2/replica_results/2_peaks.${EXT} > results/merged_2.${EXT}
	if [ $NUMREPLICAS -ge 3 ]
	then
    		while [ $i -le $NUMREPLICAS ]
    		do
      			j=$(($i-1))
      			bedtools intersect -a results/merged_$((j)).${EXT} -b samples/replica_$i/replica_results/$((i))_peaks.${EXT} > results/merged_$((i)).${EXT}
      			((i++))
    		done
  fi
fi

cd results
i=$(($i-1))

## Running R script for visualisation and statistical analysis.
mkdir kegg_images
Rscript $INSDIR/chiptube/chiptube.R merged_$((i)).${EXT} $CHR $PVALUEGO $PVALUEKEGG $TSSUP $TSSDOWN $PEAK

## Motif finding.
findMotifsGenome.pl merged_$((i)).${EXT} $GENOME . -len 9 -size 100

