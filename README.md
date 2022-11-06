# chiptube
Authors:  Marcos Ramos González, María de las Mercedes Borreguero Palacios, Tomás Rodríguez Gil.

For contact, please send an email to ramosgonzmarc@gmail.com

chiptube is a package aimed at ChIP-seq data analysis for *Arabidopsis thaliana* that is designed to be run under a Unix environment.

The main script in the package is chiptube.sh. This script requires an exhaustive series of parameters for its execution, which must be specified all together in a single .txt file. This file's path has to be indicated every time the script is run, i.e.:

  Usage: chiptube.sh <params_file> 
  
A model file containing such parameters is provided in chiptube/test/test_params.txt, as model samples that can be run for testing. We strongly reccomend to use it as a template and customise it with the user's preferred values. As for this file:

 - "installation_directory:" -> the directory you have installed the package in; e.g. /home/lola_flores/packages
 - "working_directory:" -> the directory where your analysis are to be saved; e.g. /home/lola_flores/my_chip_experiments
 - "experiment_name:" -> the name the folders and the results of your analysis will bear; e.g. chachi_chip
 - "number_replicas:" -> the number of replicas you have conducted for your study, e.g. 3.
 - "path_genome:" -> the path that has to be followed to access the genome of the organism you have done your experiment with; e.g. /home/lola_flores/my_genomes/atha_genome.fa
 - "path_annotation:" -> the path that has to be followed to access the annotations for the genome of the organism you have done your experiment with; e.g. /home/lola_flores/my_annotations/atha_anno.gtf
 - "path_sample_chip_i:" (with i being a natural number) -> the path that has to be followed to access the ChIP-seq data of the sample no. i you have processed; e.g. /home/lola_flores/my_chip_experiment/sample_chip_i.fq.gz. If you have paired end files, you must write both paths in the same row, separated by space.
 - "path_sample_input_i" (with i being a natural number) -> the path that has to be followed to access the input data relating to the sample no. i you have processed; e.g. /home/lola_flores/my_chip_experiment/sample_input_i.fq.gz. If you have paired end files, you must write both paths in the same row, separated by space.
 - "universe_chromosomes:" -> the ID(s) of the chromosome(s) of your organism you want to use as your genetic universe for GO and KEGG terms enrichment, separated by commas without spaces; e.g. 2,3. In case you want to use all the available chromosomes, write "all".
 - "p_value_cutoff_go:" -> the p-value threshold for GO terms enrichment statistical analysis. e.g. 0.05
 - "p_value_cutoff_kegg:" -> the p-value threshold for kegg pathways enrichment statistical analysis. e.g. 0.05
 - "type_of_peak:" -> the shape of the peaks you are looking for. The value of this parameter must be either 1 (narrow peaks, used for TF binding) or 2 (broad peaks, used for histone modifications).
 - "single_or_paired:" -> the type of reads of the files. The value of this parameter must be either 1 (single end reads) or 2 (paired end reads).
 - "tss_upstream:" ->  the upstream number of bases for defining the TSS region.
 - "tss_downstream:" -> the downstream number of bases for defining the TSS region. Must be positive. This way, setting the TSS region in (-1000,1000) would be done writing a 1000 in both tss_upstream and tss_downstream parameters.
  
A summary of the steps followed by chiptube.sh when executed is shown below:

Parameters are loaded -> Work space is generated -> Index for the reference genome is created -> Processing individual samples

The last of these steps is carried out through an auxiliary script named sample_processing, which itself does as follows for every replica:

Parameters are loaded -> Sample quality control -> Mapping to the reference genome -> Conversion of sam into sorted bam -> Peak calling

When all replicas are processed, further steps are followed:

The results of all replicas are intersected -> Motifs are found 

The last of these steps is carried out by HOMER, whose parameters may be changed according to the user's preferences. For more information, check out HOMER's website: http://homer.ucsd.edu/homer/motif/ 

For the visualisation and the statistical analysis of the results, a further third script (this time in R) is used. This one works as follows:

Parameters are loaded -> Defining promoter regions -> Calculating the peak distribution along the genome -> Annotating peaks according to the types of DNA regions they bind to -> Saving peaks that bind to proper regions -> Listing genes affected by the TF or histone modification (its regulome) -> GO terms enrichment -> KEGG terms enrichment 

chiptube defines the regulome differently for narrow and broad peaks. For narrow, chiptube makes the analysis for genes in which TF binds the promotor, while for broad it uses genes in which the modification binds the promotor, introns, exons or UTRs. If the user wants different regions to be consider, please customize chiptube.R script. Also, this script can be used for other organisms apart from *Arabidopsis*, it just takes modifying the txdb file and the organisms used for GO and KEGG terms enrichment.

As for the output, chiptube creates a directory containing the following subdirectories and files:

 - genome: contains the reference genome used for the analysis and its index.
 - annotation: contains the reference annotation used for the analysis.
 - samples: contains several directories, one for each replic. Each one of these are divided in other three: chip, input and replica_results. The chip and input directories contain the sorted bam files for the correesponding sample, the results of fastqc quality analysis for that sample and a stats.txt file with the bowtie2 alignment stats. The replica_results directory contains the peaks files generated by macs2 for the replica. It should be noted that if only one replica is used, the narrowPeak or broadPeak file is moved to the results file and cannot be find in this directory.
 - results: contains all the results for the analysis. First of all, it contains the merged peaks files of the replicas. These files are generated by iteration and there will be n-1 files for n replicas. If there are errors in one of the replicas (as indicated in the fastqc output or the bowtie2 alignment stats), just erase the proper merged files and use bedtools to intersect the previous merged file with the peak files of the rest of the replicas and execute the R script. If no errors are detected, analysis will be performed with the last merged file (higher number). Also, motifs detected by HOMER can be found in this directory. For general information about the ChIP-seq analysis such as covplot, plotAnnopie of the distribution of the typer of DNA regions which suffer the modification or the plotDistToTSS (distribution of peaks around TSS regions) see the Rplots.pdf file. Genes predicted to be affected by the TF binding or histone modification are listed in regulome.txt file. As for the GO terms analysis, chiptube calculates the GO terms enrichment for biological processes (bp), molecular functions (mf) and cellular components (cc), and all the information is saved as tables in tsv format, as well as in plots that are represented in a pdf file for each one of the three categories (goplots, barplots, dotplots and cnetplots). Finally, as for GO terms enrichment, KEEG pathways enrichment information is saved as a table in a tsv file, and the proper pathways are shown as png files in this directory, while the xml and png (without marked enzymes) files are collected in kegg_images directory.
