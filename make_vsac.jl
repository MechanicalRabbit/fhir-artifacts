#!/usr/bin/env julia
using Pkg.Artifacts
using Tar, Inflate, SHA
using ZipFile

# This script creates a fair-use extraction of ValueSet terminology
# membership necessary for computing CMS mandated eCQMs; this
# extraction does not contain coding descriptions or relationships.
# https://vsac.nlm.nih.gov/download/ecqm?rel=20200507&
#     res=ep_ec_eh.unique_vs.20200507.txt

folder = joinpath(@__DIR__, "vsac-2020")
mkpath(folder)
codes = Dict{String, Any}()
for line in readlines("value-set-codes.txt")[2:end]
    (oid,_,_,code,_,system,_,_,_) = split(line, "|")
    if !haskey(codes, oid)
        bucket = codes[oid] = Tuple{String, String}[]
    else
        bucket = codes[oid]
    end
    push!(bucket, (system, code))
end
for (oid, items) in codes
    open(joinpath(folder, oid), "w") do f
        for (system, code) in items
            write(f, "$(system),$(code)\n")
        end
    end
end
filename = "vsac-20200507.tar.gz"
run(`/bin/tar cfz vsac-20200507.tar.gz vsac-2020`)
println("sha256: ", bytes2hex(open(sha256, filename)))
println("tree-sha1: ", Tar.tree_hash(IOBuffer(inflate_gzip(filename))))
