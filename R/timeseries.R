hc_vec <- as.vector(hc_slice)
length(hc_vec)

# save a numeric vector containing 72 monthly observations
# from Jan 2009 to Dec 2014 as a time series object
hcts <- ts(hc_vec, start=c(1979, 1), end=c(2021, 9), frequency=12)

# subset the time series (June 2014 to December 2014)
hcts2 <- window(hcts, start=c(2014, 6), end=c(2014, 12))
hcts3 <- window(hcts, start=c(2006, 6), end=c(2010, 12))
# plot series
plot(hcts)

plot(hcts3) #Why is there this gap in information?
