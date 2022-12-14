# paper_hist
library(ggplot2)
library(dplyr)

file_names <-list.files('./others/Pubmed_phenomics/download_files/')
full_file_names <- paste0('./others/Pubmed_phenomics/download_files/',file_names)
full_file_names

data <- sapply(full_file_names,function(full_file_name){
  # full_file_name <- full_file_names[8]
  a <- scan(full_file_name,what = 'c')
  # a <- readLines(full_file_name)
  a <- paste(a,collapse=' ') 
  a_li <- strsplit(a,'PMID-') 
  papaers <- a_li[[1]]
  # 不要直接查看papers，会卡
  total_Phenomics_papers <- length(papaers)-1
  China_Phenomics_papers <- length(grep('China',papaers,ignore.case = T)) 
  Fudan_Phenomics_papers <- length(grep('Fudan',papaers,ignore.case = T))
  
  China_NonFudan_Phenomics_papers <- China_Phenomics_papers - Fudan_Phenomics_papers
  Overseas_Phenomics_papers <- total_Phenomics_papers - China_Phenomics_papers
  
  out <- c(total_Phenomics_papers = total_Phenomics_papers,
           China_Phenomics_papers = China_Phenomics_papers,
           Fudan_Phenomics_papers = Fudan_Phenomics_papers)
  return(out)
}) 
df <- as.data.frame(t(data))
rownames(df) <- substr(file_names,1,4)

df$China_NonFudan_Phenomics_papers <- df$China_Phenomics_papers - df$Fudan_Phenomics_papers
df$Overseas_Phenomics_papers <- df$total_Phenomics_papers - df$China_Phenomics_papers
df$year <- rownames(df)
df <- df[,c('Fudan_Phenomics_papers', 'China_NonFudan_Phenomics_papers', 'Overseas_Phenomics_papers', 'year')]
head(df)

plot_data <- reshape2::melt(df)
DATA <- plot_data %>% 
  group_by(year) %>%
  mutate(total = sum(value),
         prop = value/total) %>%
  ungroup() 
DATA$variable <- factor(DATA$variable,levels = rev(levels(DATA$variable)),
                        labels = c('Overseas', 'Chinese (non-Fudan)', 'Fudan'))


DATA$year[which(DATA$year == '2022')] <- '2022YTD'
colnames(DATA) <- c('Years','Institution','Number','total','prop')
DATA$prop2 <- DATA$prop
DATA$prop2[which(DATA$prop2 < .1)] <- 10
DATA$prop2 <- paste0(round(DATA$prop2*100,0),'%')
DATA$prop2[which(DATA$prop2 == '1000%')] <- ''

ggplot(DATA) + 
  geom_bar(aes(x = Years, y = Number,fill = Institution, group = Institution,color = Institution), stat = "identity",width = .6) +
  geom_text(aes(x = Years,y = Number,label = prop2),position = position_stack(.5)) + 
  geom_text(aes(x = Years,y = total,label = total),position = position_dodge(0.8), vjust = -0.5) + 
  theme_light() + 
  theme(legend.position = "top",legend.title = element_blank(),legend.text = element_text(size = 15))



