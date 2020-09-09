# ECDC plots
include(joinpath("..", "src", "definitions.jl"))
@time ECDC = makeECDC()
#ECDC = ECDC[:,5:ncol(ECDC)]
ECDC = ECDC[:, [5:7; 10:ncol(ECDC)]]
names(ECDC)
@time ECDC2 = addvars(ECDC)
@time ECDCflat = addVarsAllCountries(ECDC)
ECDC1 = addVarsAllCountries(ECDC, ungroup = false)
#ECDC3 = combinedims(ECDCflat)
@time save(datadir("ECDCdata.jld"), "ECDC", ECDC, "ECDC2", ECDC2, "ECDC1", ECDC1)
CSV.write(datadir("ECDCdata.csv"), ECDC)
CSV.write(datadir("ECDC2data.csv"), DataFrame(ECDC2))
CSV.write(datadir("ECDC1data.csv"), DataFrame(ECDC1))


B = @where(ECDC, :PSCR .== "Belgium")
p = plot(
    B.thedate,
    B.active,
    label = "active",
    ylabel = "active",
    xlabel = "Date",
    color = "orange",
)
p
Be = countryIndex("Belgium", gdf = ECDC2, key = :PSCR)
F = countryIndex("France", gdf = ECDC2, key = :PSCR)
Nl = countryIndex("Netherlands")
D = countryIndex("Germany")
#print(ECDC2[Be][1:(LAGRC+1),[:thedate,:confirmed,:recovered,:deaths,:active,:net_active,
#    :deaths_today,:confirmed_today,:PSCR]])

tail(ECDC1[Be][  :,    [  :thedate,   :confirmed,
        :recovered,  :deaths,   :active,   :net_active,
        :deaths_today,  :confirmed_today,      :PSCR,   ],])
#map(transform)
tail(ECDC2[D][ :,  [ :thedate, :confirmed, :recovered,
        :deaths,   :active,  :net_active,  :deaths_today,
        :confirmed_today,   :PSCR,    ],])
tail(ECDC2[F][    :,[:thedate,:confirmed,:recovered,:deaths,
        :active,:net_active,:deaths_today,:confirmed_today,
        :PSCR,    ],])
tail(ECDC2[Nl][    :,[:thedate,:confirmed,:recovered,:deaths,
        :active,:net_active,:deaths_today,:confirmed_today,
        :PSCR,],])

graphit(["Belgium", "Netherlands"], gdf = ECDC2, yvars = [:confirmed],
#seriestype = :scatter!,
    xvar = :thedate)
graphit(["Belgium", "Netherlands"], yvars = ["active"])
graphit(["Belgium"], yvars = ["active"], plotfn = areaplot!)
graphit(["Belgium"],  yvars = [:confirmed_today, :net_active], plotfn = plot!, ytrafo = identity, seriestype = :line)# xvar = :confirmed_today,
graphit(
    ["Germany", "Belgium", "France", "Spain", "United_Kingdom", "Chile"],
    yvars = ["active"],
    xvar = "thedate",
)
graphit(["Belgium"], yvars = ["confirmed", "recovered", "active"], seriestype = scatter)
graphit(
    ["Netherlands", "Belgium", "Luxembourg", "China", "Taiwan"],
    yvars = ["active", "confirmed", "recovered"],
    facet = "country",
)

graphit(
    ["United_Kingdom", "Spain", "Italy", "France", "Germany", "Belgium"],
    yvars = ["active", "confirmed"],
)
graphit(
    [
        "Spain",
        "United_Kingdom",
        "Italy",
        "France",
        "Germany",
        "Belgium",
        "China",
        "Netherlands",
        "Poland",
        "Denmark",
        "Luxembourg",
    ],
    yvars = ["active"],
)

graphit(
    [
        "Spain",
        "United_Kingdom",
        "Italy",
        "France",
        "Germany",
        "Belgium",
        "China",
        "Netherlands",
        "Poland",
        "Denmark",
        "Luxembourg",
    ],
    yvars = ["recovered"],
)
