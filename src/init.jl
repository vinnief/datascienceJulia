#using DrWatson
#run when starting Julia project to set all paths and dependencies
quickactivate("D:/gits/datascienceJulia", "datascience1")
#DrWatson.greet()
#print("Don't forget to quickactivate your project")
#using OhMyREPL # is in startup.jl  check!
paste = function(a ; sep=",")
       reduce(*,map(x-> x*sep, a[1:(end-1)]))*a[end]
       end
a =  x-> paste(x, sep="")
tryusing = function(package)
    try
        @eval using package
            catch e
        @warn "error while importing " * string(package) e
    end
end  ### does not work. copied from OhMYREPL web page
#tryusing( CSV)
using   CSV, HTTP, JuMP, Plots, StatsPlots , LaTeXStrings, JLD, DataFrames, DataFramesMeta, TimeSeries, SplitApplyCombine, Statistics    #GadFly,

notebookdir = function() joinpath(projectdir(),"notebooks") end
notebookdir = function(args...)   joinpath(projectdir(),"notebooks",args...) end

#notebook(dir = notebookdir()) #starts Jupyter in that directory.

#= DataFrameMeta defines:
    Julia             dplyr            LINQ
    ---------------------------------------------
    @where            filter           Where
    @transform        mutate           Select (?)
    @by                                GroupBy
    groupby           group_by
    @based_on         summarise/do
    @orderby          arrange          OrderBy
    @select           select           Select
    where(g, d -> mean(d[:a]) > 0) and @where(g, mean(:a) > 0)
    -- Filter groups based on the given criteria. Returns a GroupedDataFrame.
    orderby(g, d -> mean(d[:a]))# and
    @orderby(g, mean(:a))
    -- Sort groups based on the given criteria. Returns a GroupedDataFrame.

    DataFrame(g)
    -- Convert groups back to a DataFrame with the same group orderings.

    @based_on(g, z = mean(:a))
    -- Summarize results within groups. Returns a DataFrame.

    transform(g, d -> y = d[:a] - mean(d[:a])) and @transform(g, y = :a - mean(:a))
    -- Transform a DataFrame based on operations within a group. Returns a DataFrame.

    You can also index on GroupedDataFrames. g[1] is the first group, returned as a SubDataFrame. g[[1,4,5]] or g[[true, false, true, false, false]] return subsets of groups as a GroupedDataFrame.
    You can also iterate over GroupedDataFrames.
    The most general split-apply-combine approach is based on map.
    map(fun, g) returns a GroupApplied object with keys and vals.
    This can be used with combine.
    combine(df, :a => sum, nrow)  sum a and count rows, drop other columns.
    combine(gd::GroupedDataFrame, args...; keepkeys::Bool=true, ungroup::Bool=true)
    Apply operations to each group in a GroupedDataFrame and return the combined result as a DataFrame if ungroup=true or GroupedDataFrame if
  ungroup=false.
 =#

 #=other useful packages
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
3. RCall: call R from Julia. JuliaCall does the reverse in R
=#
