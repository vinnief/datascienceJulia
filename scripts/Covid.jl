# ECDC plots
using DrWatson
include(srcdir("init.jl")) #does not work without using Dr Watson forst!

LAGRC = 42  #max time to recovery for Covid19 apparently #:dateRep => "Date",
makeECDC = function( )
    #res = HTTP.get("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv")
    #return((res.body)  # retuns one column of Ints   #|> DataFrame )
    res = CSV.read(download("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv"),DataFrame)
    #using CSV:
        #fileEncoding  = "UTF-8-BOM"
    DataFrames.rename!(res, Dict(:countriesAndTerritories => "PSCR",
                        :countryterritoryCode    => "ISOcode",
                        :cases  => "confirmed_today",
                        :deaths => "deaths_today",
                        :popData2019 => "population",
                        :continentExp => "Region")
            )
    #res.thedate::Date
    dformat = Dates.DateFormat("dd/mm/yyyy")
    res = @transform(res, thedate = Date.(:dateRep, dformat))
    #res.thedate =  Date(res.dateRep, "dd/mm/yyyy")
    res = @orderby(res,:PSCR, :thedate)
    return(res) # a many x 12 DF
    #using urldownload
    #urldownload("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv")
end

ECDC = makeECDC()
ECDC.dateRep[1:10]
names(ECDC)
ECDC.day[1:10]
ECDC.thedate[1:10]
ECDC.thedate[length(ECDC.thedate)]
ECDC[length(ECDC.thedate),:].thedate
ECDC[length(ECDC.thedate),:PSCR]
ECDC[1,:PSCR]
ECDC.PSCR[1]
tail = function(df::DataFrame; nrrowstoprint::Int32 = 6)
    nrrows = nrow(df)
    print(df[nrrows-nrrowstoprint+1:nrrows,:])
end
tail(ECDC)
typeof(ECDC)
ECDC2 = DataFrames.groupby(ECDC,"PSCR")
#ECDC2 = @orderby(ECDC2,:PSCR, :Date)
ECDC2 =  @transform(ECDC2, confirmed = cumsum(:confirmed_today) ,
                    deaths = cumsum(:deaths_today))
ECDC2 = DataFrames.groupby(ECDC2,"PSCR")
VF_lag = function(v::Array{T,1} where T<:Any; delay::Int64 = 1)
    delay >= 0 ? [ [NaN for n in 1:delay],   vec[1:(length(vec)-delay)] ] :
                [ vec[(1 - delay) : length(vec), [NaN for n in 1:-delay] ] ]
end
#names(ECDC2)
combine(ECDC2, :confirmed => VF_lag => "recovered" ,ungroup = false)
print(ECDC2[1:400,[:confirmed_today,:confirmed,:PSCR]])
ECDC3 = TimeArray(ECDC2, timestamp = :thedate)
addvars = function(lpti::DataFrame)
    lpti = groupby(lpti,"PSCR")
    lpti = @transform(lpti, confirmed = cumsum(:confirmed_today) ,
        deaths = cumsum(:deaths_today) )#,    recovered = Int64(0) )
    #lpti = @orderby(lpti, :Date)
    #lpti.recovered = missing
    lpti[!,"recovered"] = missing
    #@transform(lpti, recovered_imputed = lag(:confirmed,LAGRC)
    lpti.recovered_imputed = lag.(lpti.confirmed,LAGRC, padding = true) #lag(cl[1:3], padding=true)
    lpti.active_imputed = lpti.confirmed - lpti.recovered_imputed - lpti.deaths
    lpti
end
ECDC3 = addvars(ECDC)
ECDC2 = @transform(ECDC2, confirmed = cumsum(:confirmed_today) ,
    deaths = cumsum(:deaths_today) )#,    recovered = Int64(0) )
names(ECDC2)
ECDC2[1].confirmed
select(ECDC2, :Date => first => :mindate)
#check earliest data per country

B = @where(ECDC2, :PSCR .== "Belgium")
scatter(B.Date, B.deaths, label = "deaths")
ylabel!("deaths")
scatter(B.Date, B.confirmed, label = "confirmed", ylabel="conf", xlabel = "Date", color = "red")
scatter(B.Date, B.confirmed, label = "confirmed", ylabel="conf", xlabel = "Date", color = "red")
ylabel!("confirmed")
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
