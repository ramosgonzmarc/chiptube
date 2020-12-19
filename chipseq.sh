#! /bin/bash

##Help message: when no parameter is provided
if [ $# -ne 1 ]
then
  echo "The number of arguments is: $#"
  echo "Usage: bash chipseq <params_file>"
  echo ""
  echo "params.file: Input file with the parameters"
  echo "An example of params can be found in the test folder"
  exit
fi

PARAMS=$1

echo ""
echo "==================="
echo "LOADING PARAMETERS:"
echo "==================="
echo ""

INSDIR=$(grep installation_directory: $PARAMS | awk '{print($2)}')
echo "Installation directory=$INSDIR"
WD=$(grep working_directory: $PARAMS | awk '{print($2)}')
echo "Working directory = $WD"
EXP=$(grep experiment_name: $PARAMS | awk '{ print($2)}')
echo "Experiment name= $EXP"
NUMSAMPLES=$(grep number_samples: $PARAMS | awk '{print($2)}')
echo "Number of samples = $NUMSAMPLES"

GENOME=$(grep path_genome: $PARAMS | awk '{print($2)}')
echo "Reference genome = $GENOME"
ANNOTATION=$(grep path_annotation: $PARAMS | awk '{print($2)}')
echo "Annotation= $ANNOTATION"

SAMPLES=()
i=0
while [ $i -lt $NUMSAMPLES ]
do
        j=$(($i + 1))
        SAMPLES[$i]=$(grep path_sample_$j: $PARAMS | awk '{print($2)}')
        ((i++))
done

echo "Samples="
echo "${SAMPLES[@]}"

TYPE=()
i=0
while [ $i -lt $NUMSAMPLES ]
do
        j=$(($i + 1))
        TYPE[$i]=$(grep sample_type_$j: $PARAMS | awk '{print($2)}')
        ((i++))
done

echo "Sample type="
echo "${TYPE[@]}"

##Generating work space
echo ""
echo "====================="
echo "GENERATING WORK SPACE"
echo "====================="
echo ""

cd $WD
mkdir $EXP
cd $EXP
mkdir genome annotation results samples

cd genome
cp $GENOME genome.fa
cd ../annotation
cp $ANNOTATION annotation.gtf

##Generating reference genome index
cd ../genome
bowtie2-build genome.fa index

echo ""
echo "============="
echo "INDEX CREATED"
echo "============="
echo ""

cd ../samples
i=1
while [ $i -le $NUMSAMPLES ]
do
        mkdir sample_$i
        cd sample_$i
        j=$(($i - 1))
        cp ${SAMPLES[$j]} sample_$i.fq.gz
        cd ..
        ((i++))
done

cd ../results

i=1
while [ $i -le $NUMSAMPLES ]
do
	j=$(($i - 1))
	qsub -o sample_$i -N sample_$i $INSDIR/chipseq/chipseq_sample_processing $WD/$EXP/samples/sample_$i $i $TYPE[$j] $EXP
        ((i++))
done

echo ""
echo "================================="
echo "| PROCESSING INDIVIDUAL SAMPLES |"
echo "================================="
echo ""

