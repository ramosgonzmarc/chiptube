# chipseq_bag2020
*chipseq_bag2020* is a *repository* aimed at ChIP-seq analysis that is designed to be run under a Unix environment.

The main file in the *repository* is chiptube.sh, which requires an exhaustive series of parameters for its execution. These need to be introduced altogether in a single .txt file whose pathway must be specified, thus:

  bash chiptube.sh random_folder/random_subfolder/my_parameters.txt 
  
A model file containing such parameters is provided in *chipseq_bag2020*/test/. We strongly reccomend to use this file as a template and customise it with the user's preferred values. As for this file:

