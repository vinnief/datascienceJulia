#using DrWatson
#@quickactivate "datascience1"
DrWatson.greet()
projectdir()
datadir()
srcdir()
plotsdir()
scriptsdir()
papersdir()
notebookdir = function()
    joinpath(projectdir(),"notebooks")
end
notebookdir =function(args...)
    joinpath(projectdir(),"notebooks",args...)
end


#usage of dir functions
datadir("foo", "test.bson") # preferred
datadir() * "/foo/test.bson" # not recommended
#start Jupyter in notebook directory:
#notebook(dir = notebookdir())
