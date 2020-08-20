#wip
lag(TimeArray(ECDC2[1][:,[:thedate,:confirmed]],timestamp= :thedate),2)
ECDC1=addVarsAllCountries(ECDC)
ECDC1=addVarsAllCountries(ECDC, ungroup = false)
using RData
objs = load(joinpath("..","..","Covid19",".RData"))
#Libz needed

by(ECDC[:,4:ncol(ECDC)], :PSCR, last)
combine(f, groupby(d, cols, sort=sort, skipmissing=skipmissing)) instead of by.
by(ECDC, :PSCR) do df
  DataFrame(maxact = max(df.active), maxgrow = max(fracsafe(df.active,VF_lag(df.active))))
end

combinedims(ECDC3)

l = @layout [    a{0.15w}    [ grid(2,2)
    c{.2h} ]
             ]
plot(
    rand(10, 14),
    layout = l, legend = false, seriestype = [:bar :scatter :path :histogram],
    title = ["graph $i" for j in 1:1, i in 1:11], titleloc = :right, titlefont = font(8)
)

graphit3D(["Belgium"], df = ECDCflat,
    yvars = [:confirmed],  seriestype = :scatter!,  xvar = :thedate)
graphit3D(["Belgium"],yvars = ["active"], plotfn=areaplot!)
graphit(["Belgium"],yvars = [:confirmed_today,:net_active], plotfn=plot!, ytrafo=identity)
graphit(["Germany","Belgium","France","Spain","United_Kingdom","Chile"],
    yvars = ["active"], xvar = "thedate")
graphit(["Belgium"],yvars = ["confirmed","recovered","active"],
    seriestype = scatter)
graphit(["Belgium"],yvars = ["active"])
graphit(["Netherlands","Belgium","Luxembourg","China","Taiwan"],
    yvars = ["active","confirmed","recovered"],facet = "country")

graphit3D(["United_Kingdom","Spain","Italy","France","Germany","Belgium"],
    yvars = ["active","confirmed"])
graphit(["Spain","United_Kingdom","Italy","France","Germany","Belgium","China",
    "Netherlands" ,   "Poland",  "Denmark",  "Luxembourg"],
    yvars = ["active"])
