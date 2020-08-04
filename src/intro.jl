using DrWatson
@quickactivate "datascience1"
DrWatson.greet()
projectdir()
datadir()
srcdir()
plotsdir()
scriptsdir()
papersdir()
#usage of dir functions
datadir("foo", "test.bson") # preferred
datadir() * "/foo/test.bson" # not recommended
