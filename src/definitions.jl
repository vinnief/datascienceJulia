using DrWatson
include(joinpath("..","src","init.jl"))
#include(srcdir("init.jl"))
#does not work without using Dr Watson first and setting up project dir, which happens in init.jl!!
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
    #res[!, :thedate] = map(x-> Date(x,dformat), res[:,:dateRep])
    #res.thedate =  Date(res.dateRep, "dd/mm/yyyy")
    res = @orderby(res,:PSCR, :thedate)
    return(res) # a many x 12 DF
    #using urldownload
    #urldownload("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv")
end
tail = function(df; nrrowstoprint = 6)
    nrrows = nrow(df)
    print(df[nrrows-nrrowstoprint+1:nrrows,:])
end
repeat = function(n::Number, nr::Int)
    repeat([n],nr)
end
VF_lag = function(veccy , delay = 1; padding = missing)
    if delay > length(veccy) delay = length(veccy)
    elseif -delay > length(veccy)  delay = -length(veccy)
    end
    if padding !== false
        delay >= 0 ? [ [padding for n in 1:delay] ;  veccy[1:(length(veccy)-delay)] ] :
                [ veccy[(1 - delay) : length(veccy) ;[padding for n in 1:-delay] ] ]
    else
         delay >= 0 ?   veccy[1:(length(veccy)-delay)] :
                        veccy[(1 - delay) : length(veccy)]
    end
end

# timeArrays.lag works using the dates, but we cannot convert a grouped dataframe to a timearray.
GroupedTimeArray = Array{TimeArray}
addvars = function(lpti::DataFrame)
    lpti[:,:confirmed] .= 0
    lpti[:,:deaths] .= 0
    lpti[:,:recovered].=0
    lpti[:,:active] .= 0
    lpti[:,:net_active] = 0 #
    allowmissing!(lpti, [:active,:recovered,:net_active])#
    lpti = groupby(lpti,"PSCR")
    for country = Base.OneTo(length(lpti))
        lpti[country][:,:confirmed] .= cumsum(lpti[country][:,:confirmed_today])
        lpti[country][:,:deaths]    .= cumsum(lpti[country][:,:deaths_today])
        lpti[country].recovered     .= VF_lag(lpti[country][:,:confirmed]-lpti[country][:,:deaths], LAGRC,padding = 0)
        lpti[country][:,:active]    .= lpti[country].confirmed - lpti[country].deaths - lpti[country].recovered
        lpti[country][:,:net_active].= lpti[country].active - VF_lag(lpti[country].active,1,padding=0)
    end
    lpti
end
countryIndex = function(country; gdf=ECDC2, key=:PSCR)
    index=0
    for i in 1:length(gdf)
        if (gdf[i][1,key] == country)
             index =i
        end
    end
    return index
end

graphit = function( countries= ["Belgium","Netherlands"]; gdf = ECDC2,
    yvars=[:active], xvar="thedate",plotfn::Function =plot!,
    ytrafo=false,seriestype = :path, kwargs...)
    if     ytrafo ==log10  yaxtrafo =exp10; ytrafo = ytrafo ∘ (x-> x>0 ? x : missing)
    elseif ytrafo == log   yaxtrafo =exp; ytrafo = ytrafo ∘ (x-> x>0 ? x : missing)
    elseif ytrafo == log2  yaxtrafo =exp2; ytrafo = ytrafo ∘ (x-> x>0 ? x : missing)
    elseif ytrafo == exp   yaxtrafo =log
    elseif ytrafo == false yaxtrafo = identity
    else println(ytrafo ,"s inverse not known. Y-axis may need adjusting");yaxtrafo=identity
    end
    yaxtrafo = (x -> round(x,digits=2)) ∘ yaxtrafo
    plot(minimum(gdf[countryIndex(countries[1])][xvar]),1)
    for country in countries
        data = gdf[countryIndex(country)]
        if !(xvar in names(gdf)) data[xvar] = [1:nrow(data)...] end
        print(kwargs...)
        for yvar in yvars
            if startswith(string(yvar), "confirmed") color="orange"
            elseif endswith(string(yvar),  "active") color = "red"
            elseif string(yvar)== "recovered" color = "lawngreen"
            elseif startswith(string(yvar), "deaths") color = "black"
                #confirmed_today
            else color = "blue"
            end
            plotfn(data[:,xvar], seriestype = seriestype,
                ytrafo==false ? data[:,yvar] : broadcast(ytrafo,data[:,yvar]),
                ylabel = string(yvars), yaxis = yaxtrafo , color= color,
                legend = :topleft, alpha = 0.5,
                kwargs...)
            #eval(Expr(:call, type,
            #             data[:,xvar],#(:ref, :data, :(:), :xvar),
            #             ytrafo==false ? data[:,yvar] : broadcast(ytrafo,data[:,yvar]),#(:ref, :data, :(:), :yvars)#,
            #             #(:kw, :ylabel, (:call, :string, :yvars))
            #             kwargs...
            #             ))

        end
    end
    title!(join(countries))
end
B = @where(ECDC, :PSCR .== "Belgium")


p=    plot(B.thedate, B.active, label = "active",
                    ylabel="active", xlabel = "Date", color = "orange")
yaxis!(p,log10)

#=
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
