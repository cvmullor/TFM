
# Realizar los tests de Kruskal-Wallis y Wilcoxon (si el anterior es significativo)
# para resultados de varios parámetros (almacenados en el mismo data.frame) entre referencias

mydir = "/home/carlos/Documentos/tfm/results/stats_map/stat_test"
setwd(mydir)

# read data
mstat = read.table("Mt_mapdata_v4b.csv", header = T)

levels(mstat$reference)

# Kruskal-Wallis + Wilcoxon
for(i in 1:(ncol(mstat)-1)){
  columns <- names(mstat[i])
  kruskalresult<- kruskal.test(mstat[,i]~reference,data=mstat)
  
  print(columns)
  print(kruskalresult$p.value)
  
  if(kruskalresult$p.value[1] < 0.05) {
    wilcoxresult = pairwise.wilcox.test(mstat[,i], mstat$reference, p.adj = "bonf")
    print(wilcoxresult$p.value)
  }
}

