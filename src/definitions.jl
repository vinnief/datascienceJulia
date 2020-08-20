#using DrWatson # in startup.jl
include(joinpath("..","src","init.jl"))

LAGRC = 42  #max time to recovery for Covid19 apparently #:dateRep => "Date",
makeECDC = function( )
    #res = HTTP.get("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv")
    #return((res.body)  # retuns one column of Ints   #|> DataFrame )
    res = CSV.read(download("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv"),DataFrame)
    DataFrames.rename!(res, Dict(:countriesAndTerritories => "PSCR",
                        :countryterritoryCode    => "ISOcode",
                        :cases  => "confirmed_today",
                        :deaths => "deaths_today",
                        :popData2019 => "population",
                        :continentExp => "Region")
            )
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
#repeat = function(n::Number, nr::Integer=1)
    ### """repeat a number and make a vector """
#    repeat([n],nr)
#end
VF_lag = function(veccy::Array{T,1} where T<: Any, delay = 1; padding = missing)
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
fracsafe = function(a,b)
    b == 0 ? missing : a/b
end
# timeArrays.lag works using the dates, but we cannot convert a grouped dataframe to a timearray.
GroupedTimeArray = Array{TimeArray}
addvars = function(lpti::DataFrame)
    lpti[:,:confirmed] .= 0
    lpti[:,:deaths] .= 0
    lpti[:,:recovered].=0
    lpti[:,:active] .= 0
    lpti[!,:net_active] .= 0 #
    lpti[!,:confirmed_rate] .= 0.0
    allowmissing!(lpti, [:active,:recovered,:net_active, :confirmed_rate])#
    lpti = groupby(lpti,"PSCR")
    for country = Base.OneTo(length(lpti))
        lpti[country][:,:confirmed] .= cumsum(lpti[country][:,:confirmed_today])
        lpti[country][:,:deaths]    .= cumsum(lpti[country][:,:deaths_today])
        lpti[country][:,:recovered]     .= VF_lag(lpti[country][:,:confirmed]-lpti[country][:,:deaths], LAGRC,padding = 0)
        lpti[country][:,:active]    .= lpti[country][:,:confirmed] .- lpti[country].deaths .- lpti[country].recovered
        lpti[country][:,:net_active].= lpti[country][:,:active] .- VF_lag(lpti[country][:,:active],1,padding=0)
        lpti[country][:,:confirmed_rate].= fracsafe.(lpti[country][:,:confirmed_today] , lpti[country][:,:active])
    end
    lpti
end
addVars1Country = function(df)
    df[:,:confirmed] .= cumsum(df[:,:confirmed_today])
    df[:,:deaths]    .= cumsum(df[:,:deaths_today])
    df[:,:recovered] .= VF_lag(df[:,:confirmed]-df[:,:deaths], LAGRC,padding = 0)
    df[:,:active]    = df[:,:confirmed] - df.deaths - df.recovered
    df[:,:net_active].= df[:,:active] - VF_lag(df[:,:active],1,padding=0)
    df[:,:confirmed_rate].= fracsafe.(df[:,:confirmed_today] , df[:,:active])
    df
end
addVarsAllCountries = function(lpdf::DataFrame; ungroup = true)
    lpdf[:,:confirmed] .= 0
    lpdf[:,:deaths] .= 0
    lpdf[:,:recovered].=0
    lpdf[:,:active] .= 0
    lpdf[!,:net_active] .= 0 #
    lpdf[!,:confirmed_rate] .= 0.0#
    allowmissing!(lpdf, [:active,:recovered,:net_active,:confirmed_rate])#
    gdf = groupby(lpdf,"PSCR")
    res = combine(addVars1Country, gdf,ungroup = ungroup)
    res
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

makeColor= function(yvar)
    if startswith(string(yvar), "confirmed") color="orange"
    elseif endswith(string(yvar),  "active") color = "red"
    elseif string(yvar)== "recovered" color = "lawngreen"
    elseif startswith(string(yvar), "deaths") color = "black"
        #confirmed_today
    else color = "blue"
    end
end

makeInvTrafo = function(trafo)
    if    (trafo == false || trafo == identity)   axtrafo = identity
    elseif trafo == log10 axtrafo =exp10; trafo = trafo ∘ (x-> x>0 ? x : missing)
    elseif trafo == log   axtrafo =exp ;  trafo = trafo ∘ (x-> x>0 ? x : missing)
    elseif trafo == log2  axtrafo =exp2;  trafo = trafo ∘ (x-> x>0 ? x : missing)
    elseif trafo == exp   axtrafo =log
    elseif trafo == sqrt  axtrafo = x-> x*x
    else println(trafo ,"'s inverse unknown. Y-axis may need adjusting");axtrafo=identity
    end
end
graphit = function( countries= ["Belgium","Netherlands"]; gdf = ECDC2,
    yvars=[:active, :deaths], xvar="thedate",plotfn::Function =plot!,
    ytrafo = false, seriestype = :scatter, facet = false, kwargs...)
    yaxtrafo = makeInvTrafo(ytrafo)
    shapes = [:octagon,:heptagon,:hexagon ,:pentagon, :square,:diamond,:circ,
        :star,:star6,:star7,:star8]
    strokecolors = [:red,:blue,:cyan,:darkgreen,:lawngreen,:pink,:purple,
            :magenta,:darkblue,:orange, :yellow]
    length(countries)<= min(length(shapes),length(strokecolors))  ||
                print("Cannot plot so many countries")
    #length(yvars)<= length(markercolors) || print("Cannot plot so many variables at once")
    yaxtrafo = (x -> round(x,digits=2)) ∘ yaxtrafo

    plot(layout = (facet == "country") ? length(countries) : 1)
    #(gdf[countryIndex(countries[1])][!, xvar]),
    #    [1/LAGRC for n in 1:nrow(gdf[countryIndex(countries[1])]) ] ,
    #    label = :none)
    for country in countries
        data = gdf[countryIndex(country)]
        if !(string(xvar) in names(gdf)) data[xvar] = [1:nrow(data)...] end
        print(kwargs...)
        for yvar in yvars
            color = makeColor(yvar)
            plotfn(data[:,xvar], seriestype = seriestype,
                ytrafo==false ? data[:,yvar] : broadcast(ytrafo,data[:,yvar]),
                ylabel = string(yvars), yaxis = yaxtrafo ,
                label = (country* "-" *string.(yvar)),
                markercolor= strokecolors[indexin([country], countries)],
                markerstrokecolor = color,
                legend = :topleft, alpha = 0.5,
                #size = 3,
                shape = shapes[indexin([country], countries)],
                kwargs...)
        end
    end
    title!(join(countries, " "))
end
graphit3D = function( countries= ["Belgium","Netherlands"]; lpdf = ECDCflat,
    yvars=[:active, :deaths], xvar="thedate",plotfn::Function =plot!,
    ytrafo = false,seriestype = :scatter, facet = :country, kwargs...)
    yaxtrafo = makeInvTrafo(ytrafo)
    shapes = [:octagon,:heptagon,:hexagon ,:pentagon, :square,:diamond,:circ,
        :star,:star6,:star7,:star8]
    strokecolors = [:red,:blue,:cyan,:darkgreen,:lawngreen,:pink,:purple,
            :magenta,:darkblue,:orange, :yellow]
    length(countries)<= min(length(shapes),length(strokecolors))     ||
                begin print("Cannot plot so many countries");return("no plot") end
    #length(yvars)<= length(markercolors) || print("Cannot plot so many variables at once")
    yaxtrafo = (x -> round(x,digits=2)) ∘ yaxtrafo
    plot(layout = (facet == "country") ? length(countries) : 1)
    cols = [:PSCR;xvar;yvars]
    data = lpdf[in(countries).(lpdf.PSCR),cols]
    println(names(data))
    #    data = lpdf[countryIndex(country)]
    #    if !(xvar in names(gdf)) data[xvar] = [1:nrow(data)...] end
    #    print(kwargs...)
    ro= Int64(floor(sqrt(length(countries)+1)))
    co= Int64(floor(length(countries) /ro ))
    rest = length(countries) - ro*co
    if facet == :country
        if rest>0 l =  @layout [   grid(ro,co)
            grid(1,rest) ] #{.2h}
        elseif rest==0      @layout   grid(ro,co)
        end
    end
    for yvar in yvars
        color = makeColor(yvar)
        for country in countries
            plotfn(data[data.PSCR .== :country,xvar],
                ytrafo==false ? data[data.PSCR .== :country,yvar] : broadcast(ytrafo,data[data.PSCR .== :country,yvar]),
                ylabel = string(yvars), yaxis = yaxtrafo , seriestype = seriestype,
                label = (country* "-" *string(yvar)),
                markercolor= strokecolors[indexin([country], countries)],
                markerstrokecolor = color,
                legend = :topleft, alpha = 0.5,
                #size = 3,
                shape = shapes[indexin([country], countries)],
                kwargs...)
        end
    title!(country)
    end
end

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
=#
