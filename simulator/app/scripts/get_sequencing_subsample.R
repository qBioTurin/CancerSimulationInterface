source("scripts/libraries.R")
source("scripts/Utils.R")
source("scripts/Population.R")
source("scripts/Local_Params.R")
source("scripts/Population_with_size_nmut.R")

args<-commandArgs(trailingOnly = TRUE)
if(interactive()){
  args <- c("raw",30,"output")
}
path_in<-args[1]
path_out<-args[3]

load(paste(path_in,"/Parameters.RData",sep=""))
load(paste(path_in,"mut_names_tbl.RData",sep="/"))


num_seq<-as.numeric(args[2])
Nexp<-1

load(paste(path_in,"/sim",Nexp,"/Zprovv",num_seq,".RData",sep=""))

time_provv<-parameters@print_time[which.min(abs(time_provv-parameters@print_time))]
pop<-lapply(Zprovv,Population)
Pop_ID<-1:length(pop)

ncells<-sapply(Zprovv,Ncells)
gen<-lapply(pop,genotype)
fun_eff<-lapply(pop,functional_effect)
fun_eff_label<-lapply(fun_eff,function(f){names(parameters@functional_effects)[f]})
unique_mut_id<-lapply(gen,function(g){
  unique_id_mut<-vector()
  for(i in 1:length(g)){
    unique_id_mut<-c(unique_id_mut,paste(g[1:i],collapse="_"))
  }
  return(unique_id_mut)
})

daughters<-lapply(pop,
                  function(p){
                    return(which(
                      sapply(pop,
                             function(p1){
                               is_parent(p1,p)
                             }))
                    )
                  })

clones<-lapply(Pop_ID,function(i){c(i,daughters[[i]])})

ncells_clone=sapply(clones,function(c){
  sum(ncells[c])
})

root<-setdiff(Pop_ID,unique(unlist(daughters[lengths(daughters)>0])))
pop_with_sons<-which(lengths(daughters)>0)

if(length(root)>1){
  Pop_ID<-c(0,Pop_ID)
  ncells_clone<-c(sum(ncells_clone[root]),ncells_clone)
  ncells<-c(0,ncells)
  pop_with_sons<-c(0,pop_with_sons)
  daughters<-append(list(root),daughters)
  root<-0
}

Clones_df<-tibble(clone=Pop_ID,Ncells_clone=ncells_clone,Ncells=ncells)%>%
  filter(clone%in%root)%>%
  mutate(y_lower=-Ncells_clone/2,
         y_upper=Ncells_clone/2)

for(p in pop_with_sons){
  daughters_p<-daughters[Pop_ID==p][[1]]
  n_siblings_d<-length(daughters_p)
  
  for(d in daughters_p){
    sibling_number<-which(daughters_p==d)
    older_siblings<-daughters_p[0:(sibling_number-1)]
    
    prop_y_start<-sibling_number/(n_siblings_d+1)
    
    center_parent<-Clones_df%>%
      filter(clone==p)%>%
      mutate(center=(y_upper+y_lower)/2)%>%
      pull(center)
    
    Ncells_d<-ncells[Pop_ID==d]
    
    Ncells_parent<-ncells[Pop_ID==p]
    
    Ncells_parent_clone<-ncells_clone[Pop_ID==p]
    
    Ncells_older_siblings<-ncells_clone[Pop_ID%in%older_siblings]%>%
      sum()
    
    d_df<-tibble(
      clone=d,
      Ncells_clone=ncells_clone[Pop_ID==d],
      Ncells=Ncells_d,
      Ncells_p=Ncells_parent,
      Ncells_p_clone=Ncells_parent_clone,
      Ncells_s=Ncells_older_siblings,
      center=center_parent
    )%>%
      mutate(y_lower=sum(center,prop_y_start*Ncells_p,-Ncells_p_clone/2,Ncells_s,na.rm=TRUE),
             y_upper=y_lower+Ncells_clone)%>%
      dplyr::select(clone,Ncells_clone,y_lower,y_upper,Ncells)
    
    Clones_df<-rbind(Clones_df,d_df)
  }
}
Clones_df<-Clones_df%>%
  filter(clone!=0)

if(root==0){
  ncells_clone<-ncells_clone[-1]
  ncells<-ncells[-1]
  pop_with_sons<-pop_with_sons[-1]
  root<-daughters[[1]]
  daughters<-daughters[-1]
  Pop_ID<-Pop_ID[-1]
  }

trasl<-min(Clones_df$y_lower)
Clones_df$y_lower<-Clones_df$y_lower-trasl
Clones_df$y_upper<-Clones_df$y_upper-trasl
Clones_df$clone<-factor(Clones_df$clone,levels=Pop_ID)

Clones_df<-distinct(Clones_df)

save(Clones_df,file = paste(path_in,"Clones_ordered_muller.RData",sep="/"))

n_seq_cells<-round(0.1*sum(ncells))
seq_min_y<-runif(1,min(Clones_df$y_lower),max(Clones_df$y_upper)-n_seq_cells)
seq_max_y<-seq_min_y+n_seq_cells

pcr<-function(ncells_start,ncycles){
  ncells<-ncells_start
  for(i in 1:ncycles){
    num_dupl<-rbinom(1,ncells,0.85)
    ncells<-ncells+num_dupl
  }
  return(ncells)
}

Clones_df_seq<-Clones_df%>%
  filter(y_lower<seq_max_y,y_upper>seq_min_y)%>%
  merge(tibble(clone=Pop_ID,
               mut=sapply(unique_mut_id,function(muts){muts[length(muts)]}),
               fun_eff=sapply(fun_eff_label,function(funcs){funcs[length(funcs)]})))%>%
  rowwise()%>%
  mutate(Ncells_seq=round(min(y_upper,seq_max_y)-max(y_lower,seq_min_y)),
         prob=Ncells_seq/(2*(seq_max_y-seq_min_y)))%>%
  ungroup()%>%
  dplyr::select(mut,fun_eff,Ncells_seq,prob)

load("dens.RData")

sample_DP<-round(sample(x = dens_coverage$x, nrow(Clones_df_seq), prob = dens_coverage$y, replace=TRUE) + rnorm(1, 0, dens_coverage$bw))
sample_DP[sample_DP<0]<-0
sample_AD<-mapply(rbinom,prob=Clones_df_seq$prob,size=sample_DP,MoreArgs = list(n=1))

vcf_sample<-Clones_df_seq%>%
  bind_cols(sample_DP=sample_DP,sample_AD=sample_AD)%>%
  filter(sample_AD>0)%>%
  mutate(VAF=sample_AD/sample_DP)%>%
  merge(mut_names_tbl)%>%
  dplyr::select(-c(prob,Ncells_seq,mut))%>%
  rename("mut"="names")
  


write(toJSON(vcf_sample),file=paste(path_out,"vcf_sampled.json",sep="/"))

load(paste(path_in,"Clones_df_absolute.RData",sep="/"))

range_plot_zoom_x<-unique(Clones_df_absolute$time)[which(sort(unique(Clones_df_absolute$time))==time_provv)+c(-1,1)]
range_plot_zoom_y<-c(min(Clones_df_absolute$y_lower[Clones_df_absolute$time==time_provv]),
                     max(Clones_df_absolute$y_lower[Clones_df_absolute$time==time_provv]))
xmin_rect<-time_provv-diff(range_plot_zoom_x)/50
xmax_rect<-time_provv+diff(range_plot_zoom_x)/50
y_trasl<-min(Clones_df_absolute$y_lower[Clones_df_absolute$time==time_provv])

p<-plot_show_absolute+
  coord_cartesian(xlim =range_plot_zoom_x,
                  ylim = range_plot_zoom_y)+
  geom_vline(xintercept = time_provv,color="white",alpha=0.4)+
  geom_rect(aes(xmin = xmin_rect,
                xmax = xmax_rect,
                ymin = seq_min_y+y_trasl,
                ymax=seq_max_y+y_trasl),
            fill="transparent",
            color="black",
            linetype = 2,
            linewidth = 0.5)
p
vcf_sample

ggsave(plot=p,filename = "zoom_sequence_plot.png",device = "png",width = 5,height = 5,path = path_out)
