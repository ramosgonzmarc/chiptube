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
echo "Type of peak = $PEAK"

## Creating arrays for ChIP and input samples and filling them with the paths of the previously specified files.
CHIPS=()
INPUTS=()
i=0
while [ $i -lt $NUMREPLICAS ]
do
        j=$(($i + 1))
        CHIPS[$i]=$(grep path_sample_chip_$j: $PARAMS | awk '{print($2)}')
        INPUTS[$i]=$(grep path_sample_input_$j: $PARAMS | awk '{print($2)}')
        ((i++))
done
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
        qsub -o replica_$i -N replica_$i $INSDIR/chiptube/sample_processing $WD/$EXP/samples/replica_$i $i $EXP $NUMREPLICAS $GENOME $INSDIR $CHR $PVALUEGO $PVALUEKEGG $PEAK
        ((i++))
done
