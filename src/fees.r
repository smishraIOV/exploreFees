# Initial look at block fees aggregated over 20160 blocks 
# collected in batches of 2520 blocks, i.e 1/8th
# even the batches are approx since not all RPC calls returned on time
# about 85% block coverage (96% of batches have 85% block coverage)
# TX counts do not inculde the default remasc in every block
# almost 93% of all 4.93M blocks

setwd("/home/pete/work/samp/explore")

data <- read.csv("./fees.csv")
data <- data.frame(data)

#make sure the blocks are ordered
data <- data[order(-data$RefBlock),]

dim(data)

head(data)

diff = data[1:dim(data)[1]-1,1] - data[2:dim(data)[1],1]

length((unique(diff)))==1 
#if not, take a look
table(diff)


#check for duplicate blocknumbers. Then sort the data by blocknumber.
unique(data[,1])
#should be true
dim(data)[1] == length(unique(data[,1]))

#If not (duplicate will be TRUE)
which(duplicated(data$RefBlock) == T)

# after cleanup and fixing any missing values
# reorder and check for duplicates again
write.csv(df, './feedata.csv', row.names=F)


#max rows in reduced data frame (to combine and create weekly aggregate)

# create new frame to hold aggregated values
df <- data.frame()
# 1/8 becuse we collected 2520 blocks, but there are 20160 per week
max_rows = floor(dim(data)[1]/8)

agg_values <- c("BlockCount","TxCount","GasUsed")
for (i in 1:max_rows){
    df[i,c("RefBlock", "Timestamp")] = data[(8*i -7),c("RefBlock", "Timestamp")]
    df[i, agg_values] <- colSums(data[(8*i-7):(8*i),agg_values])
}

# normalize row names
row.names(df) <- 1:dim(df)[1]


## Sanity check, aggregates must match up
colSums(data[,agg_values])
#  BlockCount      TxCount      GasUsed 
#     4565761      4923704 665089240603 
colSums(df[,agg_values])
#  BlockCount      TxCount      GasUsed 
#     4565761      4923704 665089240603 

# block coverage is almost 93%
colSums(df[,agg_values])[1]/df[1,1]
# BlockCount 
# 0.9261028

## in what follows, "data" (2520 blocks) and "df" (weekly, 20160 blocks) are different. Change, use as per context


# fraction that have 90% data
length(which(df[,"BlockCount"] < 0.9*20160))/(dim(df)[1]) #should be computed over weekly aggregates
#[1] 0.2254098
length(which(df[,"BlockCount"] < 0.85*20160))/(dim(df)[1])
#[1] 0.03688525 # this is pretty good. 96% pf rows have a sample more than 85% of blocks

# none of the rows are missing more than 20% blocks
length(which(df[,"BlockCount"] < 0.8*20160))/(dim(df)[1])
[1] 0

# sum(data$BlockCount)/TotalBlocks ~ 0.93 
# about 42BTC

data$NormFeesBTC = with(data, 2520*0.06*(10^-9)*GasUsed/BlockCount)
data$NormTXs = with(data, 2520*TxCount/BlockCount)


df$NormWeekFeesBTC = with(df, 20160*0.06*(10^-9)*GasUsed/BlockCount)
df$NormWeekTXs = with(df, 20160*TxCount/BlockCount)

## Total fees using gasprice of 0.06 gwei 
sum(data$NormFeesBTC) # this is in BTC
#[1] 41.46374 BTC
sum(df$NormWeekFeesBTC)
#[1] 41.51098 BTC

## After cleanup.. save
write.csv(df, './weekly.csv', row.names=F)


names(df)
[1] "RefBlock"        "BlockCount"      "TxCount"         "GasUsed"        
[5] "Timestamp"       "NormWeekFeesBTC" "NormWeekTXs" 

## Dates
as.POSIXct(1666900516, origin="1970-01-01")


## charting (weekly)
par(mfrow=c(1,2))

plot(as.POSIXct(df$Timestamp, origin="1970-01-01"), df$NormWeekTXs, xlab="", ylab="Avg. Weekly TX count (no remasc)", col="blue", type="l")
plot(as.POSIXct(df$Timestamp, origin="1970-01-01"), df$NormWeekFeesBTC, xlab="", ylab="Avg. Weekly Fees (BTC)", col="red", type="l")

dev.print(pdf,'./weeklyPlot.pdf')
dev.off()

# charting 2520 blocks (1/8th of a week, a bit higher than daily frequency)
plot(as.POSIXct(data$Timestamp, origin="1970-01-01"), data$NormTXs, xlab="", ylab="Avg. TX count", col="blue", type="l")
plot(as.POSIXct(data$Timestamp, origin="1970-01-01"), data$NormFeesBTC, xlab="", ylab="Avg. Fees (BTC)", col="red", type="l")