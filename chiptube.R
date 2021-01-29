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

## Defining promoter regions.
peaks <- readPeakFile(peakfile = peak.file,header= FALSE)
txdb <- TxDb.Athaliana.BioMart.plantsmart28
promoter <- getPromoters(TxDb=txdb, upstream=1000, downstream=1000)

## Calculating the peak distribution along the genome.
covplot(peaks,weightCol = "V5")

## Annotating peaks according to the types of DNA regions they bind to.
peakAnno <- annotatePeak(peak = peaks, 
                         tssRegion=c(-1000, 1000),
                         TxDb=txdb,annoDb = "org.At.tair.db")
plotAnnoPie(peakAnno)

## Saving peaks that bind to promoter regions.
df.annotation <- as.data.frame(peakAnno)
promoter.df.annotation <- subset(df.annotation,annotation=="Promoter")

## Listing genes affected by the TF (its regulome).
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

## GO terms BP enrichment.
ego <- enrichGO(gene          = regulome,
                universe      = my.universe,
                OrgDb         = org.At.tair.db,
                ont           = "BP",
                keyType = "TAIR", pvalueCutoff = p.value.go)
GO.enrichment <- as.data.frame(ego)
write.table(GO.enrichment,file = "go_terms.tsv",sep="\t",row.names = F)

{
  
if(nrow(GO.enrichment) == 0)
{
  print("No enrichment of GO terms for biological processes detected.")
}

else
{
  pdf(file = "plots_go_bp.pdf",width = 16, height = 16)
  
  a <- emapplot(ego,showCategory = 30)
  plot(a)
  
  b <- goplot(ego,showCategory = 30)
  plot(b)
  
  c <- barplot(ego,showCategory = 30)
  plot(c)
  
  d <- dotplot(ego, showCategory=30)
  plot(d)
  
  e <- cnetplot(ego)
  plot(e)
  
  dev.off()
}
}

#GO terms MF enrichment.
ego.mf <- enrichGO(gene          = regulome,
                universe      = my.universe,
                OrgDb         = org.At.tair.db,
                ont           = "MF",
                keyType = "TAIR", pvalueCutoff = p.value.go)
GO.enrichment.mf <- as.data.frame(ego.mf)
write.table(GO.enrichment.mf,file = "go_terms_mf.tsv",sep="\t",row.names = F)

{

if(nrow(GO.enrichment.mf) == 0)
{
  print("No enrichment of GO terms for molecular functions detected.")
}

else
{
  pdf(file = "plots_go_mf.pdf",width = 16, height = 16)
  
  a <- emapplot(ego.mf,showCategory = 30)
  plot(a)
  
  b <- goplot(ego.mf,showCategory = 30)
  plot(b)
  
  c <- barplot(ego.mf,showCategory = 30)
  plot(c)
  
  d <- dotplot(ego.mf, showCategory=30)
  plot(d)
  
  e <- cnetplot(ego.mf)
  plot(e)
  
  dev.off()
}
}

#GO terms CC enrichment.
ego.cc <- enrichGO(gene          = regulome,
                   universe      = my.universe,
                   OrgDb         = org.At.tair.db,
                   ont           = "CC",
                   keyType = "TAIR", pvalueCutoff = p.value.go)
GO.enrichment.cc <- as.data.frame(ego.cc)
write.table(GO.enrichment.cc,file = "go_terms_cc.tsv",sep="\t",row.names = F)

{

if(nrow(GO.enrichment.cc) == 0)
{
  print("No enrichment of GO terms for celular components detected.")
}

else
{
  pdf(file = "plots_go_cc.pdf",width = 16, height = 16)
  
  a <- emapplot(ego.cc,showCategory = 30)
  plot(a)
  
  b <- goplot(ego.cc,showCategory = 30)
  plot(b)
  
  c <- barplot(ego.cc,showCategory = 30)
  plot(c)
  
  d <- dotplot(ego.cc, showCategory=30)
  plot(d)
  
  e <- cnetplot(ego.cc)
  plot(e)
  
  dev.off()
}
}

## KEGG terms enrichment.
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
