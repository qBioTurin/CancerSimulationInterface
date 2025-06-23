source("scripts/libraries.R")
source("scripts/Utils.R")
source("scripts/Population.R")
source("scripts/Local_Params.R")
source("scripts/Population_with_size_nmut.R")

args<-commandArgs(trailingOnly = TRUE)
if(interactive()){
  args <- c("raw")
}
path<-args[1]

load(paste(path,"/Parameters.RData",sep=""))
Nexp<-1

filenames <- list.files(paste(path,"/sim",Nexp,sep=""), full.names = FALSE)

tumor<-lapply(filenames,function(filename){
  load(paste(path,"/sim",Nexp,"/",filename,sep=""))
  name<-stringr::str_replace(filename,"Zprovv","")
  name<-stringr::str_replace(name,".RData","")
  setNames(object = list(Zprovv), name)
})
tumor<-unlist(tumor,recursive = FALSE)
tumor<-tumor[order(as.numeric(names(tumor)))]

obs_tumor<-get_obs_tumor(parameters,tumor,10^(-3))

save(obs_tumor,file = paste(path,"/obs_tumor.RData",sep=""))
