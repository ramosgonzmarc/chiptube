## Loading packages.
library("ChIPseeker")
library("org.At.tair.db")
library("TxDb.Athaliana.BioMart.plantsmart28")
library("clusterProfiler")
library("pathview")

## Loading parameters from the previous script.
args <- commandArgs(trailingOnly = TRUE)
peak.file <- args[[1]]
chromosomes <- as.character(args[[2]])
p.value.go <- as.numeric(args[[3]])
p.value.kegg <- as.numeric(args[[4]])

## Defining regions around promoters as potential binding sites for the TF.
peaks <- readPeakFile(peakfile = peak.file,header= FALSE)
txdb <- TxDb.Athaliana.BioMart.plantsmart28
promoter <- getPromoters(TxDb=txdb, upstream=1000, downstream=1000)

## Calculating the distribution of peaks along the genome.
covplot(peaks,weightCol = "V5")

## Annotating peaks based on the types of DNA regions they bind to.
peakAnno <- annotatePeak(peak = peaks, 
                         tssRegion=c(-1000, 1000),
                         TxDb=txdb,annoDb = "org.At.tair.db")
plotAnnoPie(peakAnno)

## Saving the peaks that bind to genetic promoters.
df.annotation <- as.data.frame(peakAnno)
promoter.df.annotation <- subset(df.annotation,annotation=="Promoter")

## Defining genes affected by the TF (its regulome).
regulome <- promoter.df.annotation$geneId
write.table(regulome,file = "regulome.txt",sep = "\n",row.names = F)

## Defining universe for GO & kegg terms enrichment.
genes.atha <- as.data.frame(genes(txdb))
{
  if (chromosomes == "all")
  {
    my.universe<-genes.atha$gene_id
  }
  else
  {
    chromosomes.for.universe <- as.vector(strsplit(chromosomes,",")[[1]])
    genes.of.my.universe <- subset(genes.atha,seqnames==chromosomes.for.universe)
    my.universe <- genes.of.my.universe$gene_id
  }
}

## GO terms enrichment.
ego <- enrichGO(gene          = regulome,
                universe      = my.universe,
                OrgDb         = org.At.tair.db,
                ont           = "BP",
                keyType = "TAIR", pvalueCutoff = p.value.go)
GO.enrichment <- as.data.frame(ego)
write.table(GO.enrichment,file = "go_terms.tsv",sep="\t",row.names = F)

if(nrow(GO.enrichment) == 0)
{
  print("No enrichment of GO terms detected.")
}

if(nrow(GO.enrichment) != 0)
{
  barplot(ego,showCategory = 30)
}

if(nrow(GO.enrichment) != 0)
{
  dotplot(ego, showCategory=30)
}

if(nrow(GO.enrichment) != 0)
{
  cnetplot(ego)
}

if(nrow(GO.enrichment) != 0)
{
  emapplot(ego)
}

## kegg terms enrichment.
pathway.enrich <- as.data.frame(enrichKEGG(gene=regulome, keyType = "kegg", 
                                           organism="ath", pvalueCutoff = p.value.kegg, pAdjustMethod = "BH"))
write.table(pathway.enrich,file = "kegg_terms.tsv",sep="\t",row.names = F)
{
  if (nrow(pathway.enrich) == 0)
  {
    print("No enrichment of KEGG pathways detected.")
  }
  else
  {
    for (i in 1:nrow(pathway.enrich))
    {
      pathway.current.id <- pathway.enrich[i,1]
      pathview(gene.data = regulome, pathway.id = pathway.current.id,species = "ath",
               gene.idtype = "TAIR", kegg.dir = "kegg_images/")
    }
  }
}
