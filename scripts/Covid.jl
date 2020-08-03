# ECDC plots
makeECDC = function( )
    #res = HTTP.get("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv")
    #return((res.body)  # retuns one column of Ints   #|> DataFrame )
    #using CSV:
    res=CSV.read(download("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv"),DataFrame)
        #fileEncoding  = "UTF-8-BOM"
        #CSV.read returns a DataFrame
    #using Requests
    return(res) # a many x 12 DF
    #get("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv")
    #then like http.get need to exttract the body
    #using urldownload
    #urldownload("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv")

end

ECDC = makeECDC()
ECDC1 = rename(ECDC, Dict(:countriesAndTerritories => "PSCR",
                :countryterritoryCode    => "ISOcode",
                :cases  => "confirmed_today",
                :deaths => "deaths_today",
                :dateRep => "Date",
                :popData2019 => "population",
                :continentExp => "Region")
                ) #|> groupby(:PSCR)
names(ECDC1)
ECDC.dateRep[1]
ECDC1.day
ECDC1.Date[1]
ECDC2 = groupby(ECDC1,"PSCR")
ECDC2 = @transform(ECDC2, confirmed = cumsum(:confirmed_today) ,
    deaths = cumsum(:deaths_today) )#,    recovered = Int64(0) )
names(ECDC2)
ECDC2[1].confirmed
select(ECDC2, :Date => first => :mindate)
#check earliest data per country

B = @where(ECDC2, :PSCR .== "Belgium")
scatter(B.Date, B.deaths, label = "deaths")
scatter(B.Date, B.confirmed, label = "confirmed")
p = scatter(B.Date, B.deaths, label = "deaths")
log
yaxis!(p,log2)

combine(ECDC2, :Date => last => :mindate, nrow)
names(ECDC2)
=======
## Date  = as.Date(dateRep, format = "%d/%m/%Y"),
 # select(-popData2019, geoId, -day, -month, -year, -cases , -countriesAndTerritories,#
#      -dateRep, -continentExp, -countryterritoryCode)  %>%
 # arrange(PSCR, Date)  %>%  group_by(PSCR)  %>%
 # mutate(confirmed  = cumsum(confirmed_today),
#      deaths  = cumsum(deaths_today),
#      recovered = as.numeric(NA))  %>%
 # select(-confirmed_today, -deaths_today)
 if (verbose > 0) {a = as.numeric(max(lpti$Date) - min(lpti$Date) + 1)
  print('ECDC' %: % a % % "dates" %, % length(unique(lpti$PSCR)) % % "regions, last date:" % %
     max(lpti$Date) %, % "with"  % %
     sum(is.na(lpti[lpti$Date >= "2020-02-02", ]))  % %
     "missing values after 2020-02-01")}
 lpti
}

correctMissingLastDay <- function(lpti = ECDC0){
  maxDate <- max(lpti$Date)
  lpti <- lpti %>% group_by(PSCR)
  missingPSCR <- setdiff( unique(lpti$PSCR) ,
                          lpti %>% filter(Date == maxDate) %>% pull(PSCR) )
  for (myPSCR in missingPSCR) {
    countryData <- filter(lpti, PSCR == myPSCR )
    lastDate <- max(countryData$Date)
    missingRows <- countryData %>% filter( Date == lastDate)
    lastDate <- as.Date(lastDate, format = '%Y-%m-%d')
    missingRows <- missingRows[rep(1, as.Date(maxDate, format = '%Y-%m-%d') - lastDate) ,]
    missingRows <- missingRows %>% mutate(Date = as.Date(lastDate + row_number(),  origin = '1970-01-01'))
      if (verbose >= 2) print(missingRows)
      lpti <- rbind(lpti,missingRows)
    }
  lpti
}
