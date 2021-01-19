# chipseq_bag2020
*chipseq_bag2020* is a package aimed at ChIP-seq data analysis that is designed to be run under a Unix environment.

The main script in the package is chiptube.sh. This script requires an exhaustive series of parameters for its execution, which must be specified all together in a single .txt file. This file's path has to be indicated every time the script is run, so for example:

  bash chiptube.sh /home/lola_flores/my_chip_experiment/my_parameters.txt 
  
A model file containing such parameters is provided in *chipseq_bag2020*/test/test_params.txt. We strongly reccomend to use it as a template and customise it with the user's preferred values. As for this file:

  "installation_directory:" -> the directory you have installed the package in; e.g. /home/lola_flores/packages
  "working_directory:" -> the directory where your analysis are to be saved; e.g. /home/lola_flores/my_chip_experiment
  "experiment_name:" -> the name the folders and the results of your analysis will bear; e.g. chachi_chip
  "number_replicas:" -> the number of replicas you have conducted for your study, e.g. 3
  "path_genome:" -> the path that has to be followed to access the genome of the organism you have done your experiment with; e.g. /home/lola_flores/my_genomes/atha_genome.fa
  "path_annotation:" -> the path that has to be followed to access the annotations for the genome of the organism you have done your experiment with; e.g. /home/lola_flores/my_annotations/atha_anno.fa
  "path_sample_chip_#:" (with # being a natural number) -> the path that has to be followed to access the ChIP-seq data of the first sample you have processed; e.g. /home/lola_flores/my_chip_experiment/sample_chip_#.fq.gz
  "path_sample_input_#" (with # being a natural number) -> the path that has to be followed to access the input data relating to the first sample you have processed; e.g. /home/lola_flores/my_chip_experiment/sample_input_#.fq.gz
  "universe_chromosomes:" -> the number of chromosomes of your organism that you have taken ChIP-seq data from; e.g. 2
  "p_value_cutoff_go:" -> *
  "p_value_cutoff_kegg:" -> *
  "type_of_peak:" -> the type of peak you want *narrowPeak* to produce. The value of this parameter must be either 1 (narrow peak) or 2 (broad peak).
