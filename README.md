# chiptube
Authors: María de las Mercedes Borreguero Palacios, Marcos Ramos González, Tomás Rodríguez Gil.
For contact, please send an email to ramosgonzmarc@gmail.com

chiptube is a package aimed at ChIP-seq data analysis for *Arabidopsis thaliana* that is designed to be run under a Unix environment.

The main script in the package is chiptube.sh. This script requires an exhaustive series of parameters for its execution, which must be specified all together in a single .txt file. This file's path has to be indicated every time the script is run, i.e.:

  Usage: chiptube.sh <params_file> 
  
A model file containing such parameters is provided in chiptube/test/test_params.txt. We strongly reccomend to use it as a template and customise it with the user's preferred values. As for this file:

  "installation_directory:" -> the directory you have installed the package in; e.g. /home/lola_flores/packages
  
  "working_directory:" -> the directory where your analysis are to be saved; e.g. /home/lola_flores/my_chip_experiments
  
  "experiment_name:" -> the name the folders and the results of your analysis will bear; e.g. chachi_chip
  
  "number_replicas:" -> the number of replicas you have conducted for your study, e.g. 3.
  
  "path_genome:" -> the path that has to be followed to access the genome of the organism you have done your experiment with; e.g. /home/lola_flores/my_genomes/atha_genome.fa
  
  "path_annotation:" -> the path that has to be followed to access the annotations for the genome of the organism you have done your experiment with; e.g. /home/lola_flores/my_annotations/atha_anno.gtf
  
  "path_sample_chip_i:" (with i being a natural number) -> the path that has to be followed to access the ChIP-seq data of the sample no. i you have processed; e.g. /home/lola_flores/my_chip_experiment/sample_chip_i.fq.gz. If you have paired end files, you must write both paths in the same row, separated by space.
  
  "path_sample_input_i" (with i being a natural number) -> the path that has to be followed to access the input data relating to the sample no. i you have processed; e.g. /home/lola_flores/my_chip_experiment/sample_input_i.fq.gz. If you have paired end files, you must write both paths in the same row, separated by space.
  
  "universe_chromosomes:" -> the ID(s) of the chromosome(s) of your organism you want to use as your genetic universe for GO and KEGG terms enrichment, separated by commas without spaces; e.g. 2,3. In case you want to use all the available chromosomes, write "all".
  
  "p_value_cutoff_go:" -> the p-value threshold for GO terms enrichment statistical analysis. e.g. 0.05
  
  "p_value_cutoff_kegg:" -> the p-value threshold for kegg pathways enrichment statistical analysis. e.g. 0.05
  
  "type_of_peak:" -> the shape of the peaks you are looking for. The value of this parameter must be either 1 (narrow peaks, used for TF binding) or 2 (broad peaks, used for histone modifications).
  
  "single_or_paired:" -> the type of reads of the files. The value of this parameter must be either 1 (single end reads) or 2 (paired end reads).
  
  "tss_upstream:" ->  the upstream number of bases for defining the TSS region.
  
  "tss_downstream:" -> the downstream number of bases for defining the TSS region. Must be positive. This way, setting the TSS region in (-1000,1000) would be done writing a 1000 in both tss_upstream and tss_downstream parameters.
  
A summary of the steps followed by chiptube.sh when executed is shown below:

Parameters are loaded -> Work space is generated -> Index for the reference genome is created -> Processing individual samples

The last of these steps is carried out through an auxiliary script named sample_processing, which itself does as follows for every sample:

Parameters are loaded -> Sample quality control -> Mapping to the reference genome -> Conversion of sam into sorted bam -> Peak calling

Next, a message is written on a blackboard file for every processed sample. When the number of messages equals that of samples, further steps are followed:

The results of all samples are intersected -> Motifs are found

For the visualisation and the statistical analysis of the results, a further third script (this time in R) is used. This one works as follows:

Parameters are loaded -> Defining promoter regions -> Calculating the peak distribution along the genome -> Annotating peaks according to the types of DNA regions they bind to -> Saving peaks that bind to promoter regions -> Listing genes affected by the TF (its regulome) -> GO terms enrichment -> KEGG terms enrichment 

chiptube define the regulome differently for narrow and broad peaks. For narrow, chiptube makes the analysis for genes in which TF binds the promotor, while for broad it uses genes in which the modification binds the promotor, introns, exons or UTRs. If the user wants different regions to be consider, please customize chiptube.R script. 
