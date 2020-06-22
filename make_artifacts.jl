#!/usr/bin/env julia
using Pkg.Artifacts
using Tar, Inflate, SHA
using ZipFile

artifacts_toml = joinpath(@__DIR__, "Artifacts.toml")
fhir_hash = artifact_hash("fhir-r4", artifacts_toml)
if fhir_hash == nothing || !artifact_exists(fhir_hash)
    fhir_hash = create_artifact() do artifact_dir
        fpath = joinpath(artifact_dir, "fhir-r4")
	fname = download("http://hl7.org/fhir/R4/fhir-spec.zip")
	zip = ZipFile.Reader(fname);
	for f in zip.files
	    parts = split(f.name, "\\")
	    if !endswith(parts[end], ".profile.json")
	       continue
	    end
            mkpath(joinpath(fpath, parts[2:end-1]...))
	    open(joinpath(fpath, parts[2:end]...), "w") do file
	       write(file, read(f))
	    end
	end
	close(zip)
    end
    bind_artifact!(artifacts_toml, "fhir-r4", fhir_hash)
end

filename = joinpath(@__DIR__, "fhir-r4-2019-10-30.tgz")
datapath = artifact_path(fhir_hash)
if !isfile(filename)
   println("making $(filename)")
   run(`/bin/tar --directory=$(datapath) --file=$(filename) --create --gzip .`)
end

println("sha256: ", bytes2hex(open(sha256, filename)))
println("tree-sha1: ", Tar.tree_hash(IOBuffer(inflate_gzip(filename))))
