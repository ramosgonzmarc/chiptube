# chipseq_bag2020
*chipseq_bag2020* is a package aimed at ChIP-seq data analysis that is designed to be run under a Unix environment.

The main script in the package is chiptube.sh. This script requires an exhaustive series of parameters for its execution, which must be specified all together in a single .txt file. This file's path has to be indicated every time the script is run, so for example:

  bash chiptube.sh random_folder/random_subfolder/my_parameters.txt 
  
A model file containing such parameters is provided in *chipseq_bag2020*/test/test_params.txt. We strongly reccomend to use it as a template and customise it with the user's preferred values. As for this file:

  "installation_directory:" -> the directory you have installed the package in; e.g. /home/your_user_name
  "working_directory:" -> the directory where your analysis are to be saved; e.g. /home/your_user_name/my_chip_results
  "experiment_name:" -> the name the folders and the results of your analysis will bear; e.g. chachi_chip
  "number_replicas:" -> the number of replicas you have conducted for your study, e.g. 3
  "path_genome:" -> the path that has to be followed to access the genome of the organism you have done your experiment with; e.g. /home/your_user_name/my_genomes/atha_genome.fa
  ""
  ""
  ""
  ""
  ""
  ""
  ""
  ""
  

