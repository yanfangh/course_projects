library(plyr)
library(car)
library(ggplot2)
library(emmeans)
library(multcomp)
library(cowplot)

# read data
hrd.o <- read.csv("prep_hrd.csv",header = TRUE)
hrd <- hrd.o[c('MarriedID','EmploymentStatus','Department','PositionLevel','PayRate','Sex','Race','PerfScoreID','Age','LengthofWork','EngagementSurvey','SpecialProjectsCount','Termd','EmpSatisfaction')]
dummys <- c("MarriedID","EmploymentStatus","Department","PositionLevel","Sex","Race","PerfScoreID","SpecialProjectsCount","EmpSatisfaction")
hrd[dummys] <- lapply(hrd[dummys],factor)
hrd$PositionLevel <- factor(hrd$PositionLevel,levels = c("Low","Middle","High"))
hrd$SpecialProjectsCount <- factor(hrd$SpecialProjectsCount,levels=c('0','>=1'))
levels(hrd$Department)[3]<-"Production"

hrd1<-hrd[-c(58,118,299),]
#------------------------------------------------------------------------------------------
regressors <- c('MarriedID','Department','PositionLevel','Sex','Race','PerfScoreID','SpecialProjectsCount','Age','LengthofWork','EngagementSurvey')
# for categorical variables
box_plot <- function(predictor){
  ggplot(hrd,aes_string(x=predictor,y="PayRate"))+
    # geom_jitter(aes_string(color=predictor),width=0.2)+
    geom_boxplot(aes_string(fill=predictor),alpha=0.5)+
    theme(legend.position = "none")
}

# for continuous variables
scatter_plot <- function(predictor){
  ggplot(hrd,aes_string(x=predictor,y="PayRate"))+
    geom_point(color="black")+
    theme(legend.position = "none")
}

plt <- c()
for (i in 1:length(regressors)) {
  if (regressors[i] %in% dummys) {
    plt[i] <- list(box_plot(regressors[i]))
  }
  else {plt[i] <- list(scatter_plot(regressors[i]))}
}
plot_grid(plotlist=plt)

#-------------------------------------------------------------------------------------------------
# model g0: full model
g0 <- lm(PayRate ~ MarriedID+Department+PositionLevel+Sex+Race+PerfScoreID+SpecialProjectsCount+Age+LengthofWork+EngagementSurvey,data = hrd)
summary(g0)
anova(g0) #sequential SS
Anova(g0) #adjusted SS
par(mfrow=c(2,2))
plot(g0)

# identify influential points
lev <- lm.influence(g1)$hat
high.lev <- which(lev > 3*mean(lev))
plot(lev,ylab="Leverages",main="Index plot of leverages")
outliers <- which(rstandard(g1)>3)
cook <- cooks.distance(g1)
plot(cook, main = "Index plot of cook distance")

# model g0a: remove outliers
g0a <- lm(PayRate ~ MarriedID+Department+PositionLevel+Sex+Race+PerfScoreID+SpecialProjectsCount+Age+LengthofWork++EngagementSurvey,data=hrd1)
summary(g0a)
anova(g0a) #sequential SS
Anova(g0a) #adjusted SS


# model building
step(g0a,direction = "both")
step(g0)
# model g1a before removing outliers
g1a <- lm(PayRate ~ Department+PositionLevel+SpecialProjectsCount, data = hrd)
summary(g1a)
par(mfrow=c(2,2))
plot(g1a)
# model g1: reduced model
g1 <- lm(PayRate ~ Department+PositionLevel+SpecialProjectsCount, data = hrd1)
summary(g1)
Anova(g1) #adjusted SS
plot(rstandard(g1),ylab="rstandard",main="Index plot of standardized residuals")
plot(g1$fitted.values,rstandard(g1))
par(mfrow=c(2,2))
plot(g1)
crPlots(g1)
anova(g1,g0a)
# ggplot(hrd,aes(x=Department,y=SpecialProjectsCount))+geom_boxplot(aes(fill=Department))
# ggplot(hrd1,aes(x=PositionLevel,y=SpecialProjectsCount))+
#   geom_jitter(aes(color=PositionLevel:SpecialProjectsCount))
# ggplot(hrd1,aes(x=Department,y=SpecialProjectsCount))+
#   geom_jitter(aes(color=Department:SpecialProjectsCount))
# ggplot(hrd1,aes(x=Department,y=PositionLevel))+
#   geom_jitter(aes(color=Department:PositionLevel))

# #model g1aw
# wts <- 1/(abs(g1a$residuals))
# g1aw <- lm(PayRate ~ Department+PositionLevel+SpecialProjectsCount,data=hrd1,weights = wts)
# summary(g1aw)
# plot(g1aw)

#interception effect
dev.off()
interaction.plot(x.factor = hrd1$Department,trace.factor = hrd1$PositionLevel,response = hrd1$PayRate,
                 fun=mean,type="b",col=c('black','red','green4'),pch=c(19,17,15),
                 fixed=TRUE,leg.bty="o",lwd=2)

interaction.plot(x.factor = hrd1$Department,trace.factor = hrd1$SpecialProjectsCount,response = hrd1$PayRate,
                 fun=mean,type="b",col=c('red','green4'),pch=c(19,17,15),
                 fixed=TRUE,leg.bty="o",lwd=2)

interaction.plot(x.factor = hrd1$SpecialProjectsCount,trace.factor = hrd1$PositionLevel,response = hrd1$PayRate,
                 fun=mean,type="b",col=c('black','red','green'),pch=c(19,17,15),
                 fixed=TRUE,leg.bty="o",lwd=2)

# model g2: add interaction term
g2 <- lm(PayRate ~ Department+PositionLevel+Department:PositionLevel,data=hrd1)
summary(g2)
anova(g2)
Anova(g2)


par(mfrow=c(2,2))
plot(g2)

# group mean pair comparasion
payrate.emm <- emmeans(g2,~Department:PositionLevel)
plot(emmeans(g2,~Department|PositionLevel),comparisons = TRUE,horizontal=FALSE)
plot(emmeans(g2,~PositionLevel|Department),comparisons = TRUE,horizontal=FALSE)
#coef(pairs(payrate.emm))
dep.pos <- pairs(emmeans(g2,~Department|PositionLevel))
pos.dep <- pairs(emmeans(g2,~PositionLevel|Department))
# tuk <- TukeyHSD(aov(g2),"Department:PositionLevel")
# lsmeans(mod, pairwise ~ Department | PositionLevel)
# dep.pos <- pairs(lsmeans(g2,~Department|PositionLevel))
# pos.dep <- pairs(lsmeans(g2,~PositionLevel|Department))
# rbind(dep.pos,pos.dep)
# test(rbind(dep.pos,pos.dep),adjust="tukey")

g2a <- lm(PayRate~Department+PositionLevel+SpecialProjectsCount+PositionLevel:SpecialProjectsCount,data=hrd1)
summary(g2a)
anova(g2a)

#model g3
dep.pos <- interaction(hrd1$Department,hrd1$PositionLevel)
g3<-lm(PayRate ~ Department+PositionLevel+dep.pos,data=hrd1)
summary(g3)
anova(g3)
plot(g3)
pay.emm<-summary(emmeans(g3,~dep.pos))
ggplot(g2,aes(x=PositionLevel,y=PayRate)) + 
  geom_bar(position  = 'stack', stat="identity",width = 0.5)+
  facet_grid(.~Department)

plot(g3)
crPlots(g3)

par(mfrow=c(1,2))
ggplot(hrd,aes(x=SpecialProjectsCount,y=PayRate))+geom_jitter(aes(color=SpecialProjectsCount))
ggplot(hrd,aes(x=SpecialProjectsCount,y=Termd))+geom_jitter(aes(color=SpecialProjectsCount))+geom_boxplot(aes(fill=SpecialProjectsCount))

pay <- aggregate(PayRate~Department+PositionLevel,hrd1,mean)
ggplot(g2,aes(x=PositionLevel,y=PayRate)) + 
  geom_bar(position  = 'stack', stat="identity",width = 0.5)+
  facet_grid(.~Department)


ggplot(pay,aes(x=PositionLevel,y=PayRate,color=Department,group=Department))+
  geom_line()+
  geom_point()+
  scale_linetype_manual(values = c(1,2))+
  scale_shape_manual(values = c(21,23))+
  scale_fill_manual(values = c('red','black'))+
  facet_grid(.~SpecialProjectsCount)






#--------------------------------------------------------------
#Termd model
addmargins(xtabs(~Department+Termd, data=hrd1))

#PayRate,LengthofWork,Age,SpecialProjectsCount,Department,PositionLevel
lg<-glm(Termd ~ LengthofWork+Age+Department,data=hrd1,family=binomial(link = "logit"))
anova(lg,test = "Chisq")
summary(lg)
lg1<-glm(Termd ~ Department,data=hrd1,family=binomial(link='logit'))
summary(lg1)
lg2<-glm(Termd ~ SpecialProjectsCount,data=hrd1,family=binomial(link='logit'))
summary(lg2)
lg7<-glm(Termd ~ LengthofWork+PayRate+SpecialProjectsCount+Age+Department,data=hrd1,family=binomial(link = "logit"))
summary(lg7)
anova(lg7,"chisq")


summary(glht(lg, mcp(Department="Tukey")))

# correlation analysis between categorical variables
tb0 <- addmargins(xtabs(~Department+SpecialProjectsCount, data=hrd1))
chisq.test(tb0)
lg1<-glm(Termd ~ Department,data=hrd1,family=binomial(link='logit'))
summary(lg1)
anova(lg1,test="Chisq")
lg2<-glm(Termd ~ SpecialProjectsCount,data=hrd1,family=binomial(link='logit'))
summary(lg2)
anova(lg2,test="Chisq")
lg.12<-glm(Termd ~ Department+SpecialProjectsCount,data=hrd1,family=binomial(link='logit'))
summary(lg.12)
anova(lg.12,test="Chisq")
lg.21<-glm(Termd ~ SpecialProjectsCount+Department,data=hrd1,family=binomial(link='logit'))
summary(lg.21)
anova(lg.21,test="Chisq")

# correlation analysis between continuous variables
lg3<-glm(Termd ~ Age,data=hrd1,family=binomial(link='logit'))
summary(lg3)
anova(lg3,test="Chisq")
lg4<-glm(Termd ~ LengthofWork,data=hrd1,family=binomial(link='logit'))
summary(lg4)
anova(lg4,test="Chisq")
lg.34<-glm(Termd ~ Age+LengthofWork,data=hrd1,family=binomial(link='logit'))
summary(lg.34)
anova(lg.34,test="Chisq")
lg.43<-glm(Termd ~ LengthofWork+Age,data=hrd1,family=binomial(link='logit'))
summary(lg.43)
anova(lg.43,test="Chisq")

summary(lg1)
anova(lg1,test="Chisq")
lg3<-glm(Termd ~ LengthofWork,data=hrd1,family=binomial(link='logit'))
summary(lg3)
anova(lg3,test="Chisq")
lg.13<-glm(Termd ~ Department+LengthofWork,data=hrd1,family=binomial(link='logit'))
summary(lg.13)
anova(lg.13,test="Chisq")
lg.31<-glm(Termd ~ LengthofWork+Department,data=hrd1,family=binomial(link='logit'))
summary(lg.31)
anova(lg.31,test="Chisq")


ggplot(hrd2,aes(x=PayRate,y=Termd))+
  geom_jitter(aes(color=Termd))

plot(lg1$fitted.values~hrd1$LengthofWork)

ggplot(lg1)+
  geom_point(aes(LengthofWork,Termd))+
  geom_smooth(aes(x=LengthofWork,y=lg1$fitted.values),method = "glm",method.args=list(family="binomial"),se=FALSE)

ggplot(lg1)+
  geom_point(aes(PayRate,Termd))+
  geom_smooth(aes(x=PayRate,y=lg1$fitted.values),method = "glm",method.args=list(family="binomial"),se=FALSE)

ggplot(lg1)+
  geom_jitter(aes(SpecialProjectsCount,Termd))+
  geom_smooth(aes(x=SpecialProjectsCount,y=lg1$fitted.values),method = "glm",method.args=list(family="binomial"),se=FALSE)



crPlots(lg1)
cook <- cooks.distance(lg1)
influentials <- which(cook>4/(nrow(hrd1)-length(lg1$coefficients)))
plot(residuals(lg1)~lg1$fitted.values)
plot(lg1)

