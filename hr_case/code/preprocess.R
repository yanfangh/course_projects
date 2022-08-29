library(car)
library(plyr)

hrd <- read.csv("hrd.csv",header = TRUE,stringsAsFactors = FALSE)

hrd$EmploymentStatus[hrd$EmploymentStatus!="Active"] <- "Inactive"
hrd$Department[(hrd$Department=='Admin Offices')|(hrd$Department=='Executive Office')] <- 'Office'
hrd$RaceDesc[hrd$RaceDesc %in% c('American Indian or Alaska Native','Two or more races','Hispanic')] <- 'other races'

hrd$Department[(hrd$Department=='Software Engineering')] <- 'IT/IS'

# hrd$Position[hrd$Position %in% c('CIO','IT Director','IT Manager - DB','IT Manager - Support','IT Manager - Infra','BI Director','Sr. DBA','Director of Operations','Director of Sales','Sales Manager','Software Engineering Manager','President & CEO','Shared Services Manager'
#  )] <- 'High'
# hrd$Position[hrd$Position %in% c('Data Architect','Enterprise Architect','Principal Data Architect','Senior BI Developer','Sr. Network Engineer','Production Manager','Software Engineer','Area Sales Manager','Sr. Accountant'
#  )] <- 'Middle'
# hrd$Position[hrd$Position %in% c('BI Developer','Database Administrator','Data Analyst','IT Support','Network Engineer','Production Technician I','Production Technician II','Accountant I','Administrative Assistant'
# )] <- 'Low'

hrd$Position[hrd$Position %in% c('CIO','IT Director','IT Manager - DB','IT Manager - Support','IT Manager - Infra','BI Director','Sr. DBA','Director of Operations','Director of Sales','Software Engineering Manager','President & CEO','Shared Services Manager'
)] <- 'High'
hrd$Position[hrd$Position %in% c('Data Architect','Enterprise Architect','Principal Data Architect','Senior BI Developer','Sr. Network Engineer','Production Manager','Software Engineer','Sr. Accountant','Sales Manager'
)] <- 'Middle'
hrd$Position[hrd$Position %in% c('BI Developer','Database Administrator','Data Analyst','IT Support','Network Engineer','Production Technician I','Production Technician II','Accountant I','Administrative Assistant','Area Sales Manager'
)] <- 'Low'

# hrd$Position[hrd$Position %in% c('CIO','IT Director','IT Manager - DB','IT Manager - Support','IT Manager - Infra','BI Director','Director of Operations','Director of Sales','Software Engineering Manager','President & CEO','Shared Services Manager'
# )] <- 'Top'
# hrd$Position[hrd$Position %in% c('Data Architect','Enterprise Architect','Principal Data Architect','Production Manager','Sales Manager'
# )] <- 'High'
# hrd$Position[hrd$Position %in% c('Senior BI Developer','Sr. DBA','Sr. Network Engineer','Area Sales Manager','Sr. Accountant'
# )] <- 'Middle'
# hrd$Position[hrd$Position %in% c('BI Developer','Database Administrator','Data Analyst','IT Support','Network Engineer','Production Technician I','Production Technician II','Software Engineer','Accountant I','Administrative Assistant'
# )] <- 'Low'

# hrd$Position[hrd$Position %in% c('CIO','IT Director','IT Manager - DB','IT Manager - Support','IT Manager - Infra','BI Director','Director of Operations','Director of Sales','Software Engineering Manager','President & CEO','Shared Services Manager'
# )] <- 'Top'
# hrd$Position[hrd$Position %in% c('Data Architect','Enterprise Architect','Principal Data Architect','Sr. DBA','Production Manager','Sales Manager'
# )] <- 'High'
# hrd$Position[hrd$Position %in% c('Senior BI Developer','Sr. Network Engineer','Area Sales Manager','Software Engineer','Sr. Accountant'
# )] <- 'Middle'
# hrd$Position[hrd$Position %in% c('BI Developer','Database Administrator','Data Analyst','IT Support','Network Engineer','Production Technician I','Production Technician II','Accountant I','Administrative Assistant'
# )] <- 'Low'

hrd$SpecialProjectsCount <- ifelse(hrd$SpecialProjectsCount==0,"0",">=1")
#hrd$SpecialProjectsCount <- ifelse(hrd$SpecialProjectsCount>4,">4","<=4")


hrd <- rename(hrd,c("CitizenDesc"="Citizen","RaceDesc"="Race","Position"="PositionLevel"))

write.csv(hrd,"prep_hrd.csv")