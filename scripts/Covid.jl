# ECDC plots
include(joinpath("..","src","definitions.jl"))
lag(TimeArray(ECDC2[1][:,[:thedate,:confirmed]],timestamp= :thedate),2)
ECDC = makeECDC()
#ECDC = ECDC[:,5:ncol(ECDC)]
names(ECDC)
ECDC2= addvars(ECDC)

Be = findCountry("Belgium",ECDC2, :PSCR)
F = findCountry("France",ECDC2, :PSCR)
Nl = findCountry("Netherlands")
D = findCountry("Germany")
print(ECDC2[Be][1:(LAGRC+1),[:thedate,:confirmed,:recovered,:deaths,:active,:net_active,
    :deaths_today,:confirmed_today,:PSCR]])

tail(ECDC2[Be][:,[:thedate,:confirmed,:recovered,:deaths,:active,:net_active,
    :deaths_today,:confirmed_today,:PSCR]])
#map(transform)
tail(ECDC2[D][:,[:thedate,:confirmed,:recovered,:deaths,:active,:net_active,
    :deaths_today,:confirmed_today,:PSCR]])
tail(ECDC2[F][:,[:thedate,:confirmed,:recovered,:deaths,:active,:net_active,
        :deaths_today,:confirmed_today,:PSCR]])
tail(ECDC2[Nl][:,[:thedate,:confirmed,:recovered,:deaths,:active,:net_active,
                :deaths_today,:confirmed_today,:PSCR]])

graphit(["Belgium"],yvars = [:confirmed], plotfn=plot!, seriestype = :sticks,  xvar = "day")#, yaxis=:log)
graphit(["Belgium"],yvars = ["active"], plotfn=areaplot!)
graphit(["Belgium"],yvars = [:confirmed_today,:net_active], plotfn=plot!, ytrafo=identity)
graphit(["Germany","Belgium","France","Spain","United_Kingdom","Chile"],
    yvars = ["confirmed","active"], xvar = "day")
graphit(["Belgium"],yvars = ["confirmed","recovered","active"],plotfn=plot!)
graphit(["Belgium"],yvars = ["active"], seriestype = :steppost)
graphit(["Netherlands","Taiwan"], yvars = ["active"], ytrafo = log2, =[8,32,1024,2048,32768])
