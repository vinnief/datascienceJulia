#InitJulia1sttimeonly
using Pkg
Pkg.add("JuMP")
#Pkg.add("Juliamusic") ; using JuliaMusic
Pkg.add("Plots") # can use several backends, unifies syntax.
Pkg.add("StatsPlots")
Pkg.add("Colors")
#Pkg.add("GadFly")  #ggplot like plots, different syntax
Pkg.add("CSV");
Pkg.add("HTTP") #Pkg.add("Requests")  #deprecated? not needed if you have HTTP and or CSV?
Pkg.add("Pluto") #interactive notebook.
Pkg.add("OhMyREPL")
Pkg.add("JLD") #Juia data format for saving
Pkg.add("RData")
Pkg.add("Statistics")
Pkg.add("TimeSeries")
Pkg.add("Interact") #interactive webpage with sliders and buttons bound to variables.
Pkg.add("Knockout")
Pkg.build("Knockout") # builds Knockout.js that was missing.
Pkg.add("DataFrames")

Pkg.add("DataFramesMeta")
#getpackage = function(packagename)
#    try using (packagename)
#    catch
#        Pkg.add(packagename)
#        using(packagename  )
#    end
#end
try using(LaTeXStrings)
catch
    Pkg.add("LaTeXStrings")
    using LaTeXStrings
end
#= ======= useful packages
QuantEcon : Quantitative Economics functions for Julia.
2. Plots : easy plots.
3. PyPlot : plotting for Julia based on matplotlib.pyplot.
4. Gadfly : another plotting package; it follows Hadley Wickhams’s ggplot2 for R and the
ideas of Wilkinson (2005).
5. Distributions : probability distributions and associated functions.
6. DataFrames : to work with tabular data.
7. Pandas : a front-end to work with Python’s Pandas.
8. TensorFlow : a Julia wrapper for TensorFlow.
Several packages facilitate the interaction of Julia with other common programming
languages. Among those, we can highlight:
1. Pycall : call Python functions.
2. JavaCall : call Java from Julia.
3. RCall: call R from Julia.
=#
