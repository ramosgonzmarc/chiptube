#! /bin/bash

## Help message: when no parameter is provided
if [ $# -ne 1 ]
then
  echo "The number of arguments is: $#"
  echo "Usage: bash chipseq <params_file>"
  echo ""
  echo "params.file: Input file with the parameters"
  echo "An example of params can be found in the test folder"
  exit
fi


##Reading in parameter file 

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
NUMREPLICAS=$(grep number_replicas: $PARAMS | awk '{print($2)}')
echo "Number of replicas = $NUMREPLICAS"
GENOME=$(grep path_genome: $PARAMS | awk '{print($2)}')
echo "Reference genome = $GENOME"
ANNOTATION=$(grep path_annotation: $PARAMS | awk '{print($2)}')
echo "Annotation= $ANNOTATION"

SAMPLES=()
i=0
while [ $i -lt $NUMREPLICAS ]
do
        j=$(($i + 1))
        SAMPLES[$i]=$(grep path_sample_chip_$j: $PARAMS | awk '{print($2)}')
        SAMPLES[$i]=$(grep path_sample_input_$j: $PARAMS | awk '{print($2)}')
        ((i++))
done

echo "Samples ="
echo "${SAMPLES[@]}"


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

cd ../samples
i=1
while [ $i -le $NUMREPLICAS ]
do
        mkdir replica_$i
        cd replica_$i
        mkdir chip input
        cd chip 
        j=$(($i - 1))
        cp ${SAMPLES[$j]} sample_chip_$i.fq.gz
        cd ..
        cd input
        cp ${SAMPLES[$j]} sample_input_$i.fq.gz
        cd ../..
        ((i++))
done


##Generating reference genome index
cd ../genome
bowtie2-build genome.fa index

echo "File size:" du -h*
######## esto de du -h* no se como ponerlo para que funcione

echo ""
echo "============="
echo "INDEX CREATED"
echo "============="
echo ""


##Processing individual samples 

cd ../results

i=1
while [ $i -le $NUMREPLICAS ]
do
<<<<<<< HEAD
        qsub -o sample_chip_$i -N sample_chip_$i $INSDIR/tarea/chipseq_bag2020/sample_processing $WD/$EXP/samples/replica_$i $i $EXP
        
        qsub -o sample_input_$i -N sample_input_$i $INSDIR/tarea/chipseq_bag2020/sample_processing $WD/$EXP/samples $i $EXP
=======
	j=$(($i - 1))
	qsub -o sample_$i -N sample_$i $INSDIR/chipseq/chipseq_sample_processing $WD/$EXP/samples/sample_$i $i $TYPE[$j] $EXP
>>>>>>> bd98511c8651c38ec5d3430dfaf9a842546ee579
        ((i++))
done

echo ""
echo "================================="
echo "| PROCESSING INDIVIDUAL SAMPLES |"
echo "================================="
echo ""

