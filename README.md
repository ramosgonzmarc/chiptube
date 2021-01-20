# chipseq_bag2020
*chipseq_bag2020* is a package aimed at ChIP-seq data analysis that is designed to be run under a Unix environment.

The main script in the package is chiptube.sh. This script requires an exhaustive series of parameters for its execution, which must be specified all together in a single .txt file. This file's path has to be indicated every time the script is run, i.e.:

  Usage: chiptube.sh <params_file> 
  
A model file containing such parameters is provided in *chipseq_bag2020*/test/test_params.txt. We strongly reccomend to use it as a template and customise it with the user's preferred values. As for this file:

  "installation_directory:" -> the directory you have installed the package in; e.g. /home/lola_flores/packages
  "working_directory:" -> the directory where your analysis are to be saved; e.g. /home/lola_flores/my_chip_experiments
  "experiment_name:" -> the name the folders and the results of your analysis will bear; e.g. chachi_chip
  "number_replicas:" -> the number of replicas you have conducted for your study, e.g. 3
  "path_genome:" -> the path that has to be followed to access the genome of the organism you have done your experiment with; e.g. /home/lola_flores/my_genomes/atha_genome.fa
  "path_annotation:" -> the path that has to be followed to access the annotations for the genome of the organism you have done your experiment with; e.g. /home/lola_flores/my_annotations/atha_anno.gtf
  "path_sample_chip_i:" (with i being a natural number) -> the path that has to be followed to access the ChIP-seq data of the sample no. i you have processed; e.g. /home/lola_flores/my_chip_experiment/sample_chip_i.fq.gz
  "path_sample_input_i" (with i being a natural number) -> the path that has to be followed to access the input data relating to the sample no. i you have processed; e.g. /home/lola_flores/my_chip_experiment/sample_input_i.fq.gz
  "universe_chromosomes:" -> the ID(s) of the chromosome(s) of your organism you want to use as your genetic universe for GO and kegg terms enrichment, separated by commas without spaces; e.g. 2,3 In case you want to use all the available chromosomes, write "all".
  "p_value_cutoff_go:" -> the p-value threshold for GO terms enrichment statistical analysis. e.g. 0.05
  "p_value_cutoff_kegg:" -> the p-value threshold for kegg pathways enrichment statistical analysis. e.g. 0.05
  "type_of_peak:" -> the shape of the peaks you are looking for. The value of this parameter must be either 1 (narrow peaks, used for TF binding) or 2 (broad peaks, used for histone modification).
  
A summary of the steps followed by chiptube.sh when executed is shown below:

Parameters are loaded -> Work space is generated -> Index for the reference genome is created -> Processing individual samples

The last of these steps is carried out through an auxiliary script named sample_processing, which itself does as follows for every sample:

Parameters are loaded -> Sample quality control -> Mapping to the reference genome -> Conversion of sam into sorted bam -> Peak calling

Next, a message is written on a blackboard file for every processed sample. When the number of messages equals that of samples, further steps are followed:

The results of all samples are intersected -> Motifs finding -> Visualisation

For the visualisation, a further third script (this time in R) is used. This one works as follows:



