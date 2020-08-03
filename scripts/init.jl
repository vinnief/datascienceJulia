using DrWatson
#run when setting up project first time: create empty project
initialize_project("D:/gits/datascience1" , "datascience1")
#run when someone sends you this project.
quickactivate("D:/gits/datascience1", "datascience1")
using Pkg
Pkg.add("JuMP")
Pkg.add("Juliamusic") ; using JuliaMusic
Pkg.add("Plots")
Pkg.add("CSV"); Pkg.add("HTTP") #Pkg.add("Requests")  #deprecated? not needed if you have HTTP and or CSV?

Pkg.add("DataFrames")
Pkg.add("DataFramesMeta")
#=
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
    orderby(g, d -> mean(d[:a])) and @orderby(g, mean(:a))
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
using HTTP, DataFrames, CSV, JuMP, Plots, DataFramesMeta
