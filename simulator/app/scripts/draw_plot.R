source("scripts/libraries.R")
source("scripts/Utils.R")
source("scripts/Population.R")
source("scripts/Local_Params.R")
source("scripts/Population_with_size_nmut.R")

args<-commandArgs(trailingOnly = TRUE)
if(interactive()){
  args <- c("raw","output")
}
path_in<-args[1]
path_out<-args[2]

load(paste(path_in,"/obs_tumor.RData",sep=""))
load(paste(path_in,"/Parameters.RData",sep=""))

plot<-get_my_muller_plot(obs_Pop_ID = obs_tumor$obs_Pop_ID,
                         obs_tumor_tibble = obs_tumor$obs_tumor_tibble,
                         functional_effects = parameters@functional_effects,
                         freq = FALSE,
                         palette = c(1))

plot<-plot+
  theme(panel.margin = unit(0,"null"),
        plot.margin = rep(unit(0,"null"),4),
        axis.ticks.length = unit(0,"cm"),
        axis.ticks.margin = unit(0,"cm"))

ggsave(plot,device = "png",
       path = path_out,
       width = 9,height = 5,
       filename="plot.png")
