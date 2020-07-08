#!/usr/bin/env julia
using Pkg.Artifacts
using Tar, Inflate, SHA
using ZipFile

artifacts_toml = joinpath(@__DIR__, "Artifacts.toml")
function build(standard="R4") 
    handle = "fhir-$(lowercase(standard))"
    fhir_hash = artifact_hash(handle, artifacts_toml)
    if fhir_hash == nothing || !artifact_exists(fhir_hash)
        fhir_hash = create_artifact() do artifact_dir
            println("Downloading...")
            fpath = joinpath(artifact_dir, handle)
            fname = download("http://hl7.org/fhir/$(standard)/fhir-spec.zip")
            zip = ZipFile.Reader(fname);
            for f in zip.files
                parts = split(f.name, "\\")
                if "v3" in parts || "v2" in parts
                    continue
                end
                is_canonical = endswith(parts[end], ".canonical.json")
                is_example = contains(parts[end], "-example") &&
                             endswith(parts[end], ".json")
                if is_example || is_canonical
                    println("Adding file... ", joinpath(parts[2:end]...))
                    mkpath(joinpath(fpath, parts[2:end-1]...))
                    open(joinpath(fpath, parts[2:end]...), "w") do file
                       write(file, read(f))
                    end
                end
            end
            close(zip)
        end
        bind_artifact!(artifacts_toml, handle, fhir_hash)
    end
end

for (standard, datetime) in (("R4", "2019-10-30"), ("STU3", "2019-10-24"))
    build(standard)
    handle = "fhir-$(lowercase(standard))"
    fhir_hash = artifact_hash(handle, artifacts_toml)
    filename = joinpath(@__DIR__, "$(handle)-$(datetime).tar.gz")
    datapath = artifact_path(fhir_hash)
    if !isfile(filename)
        println("Making $(filename)")
        run(`/bin/tar --directory=$(datapath) --file=$(filename) 
              --create --gzip $(handle)`)
    end
    println("handle: ", handle)
    println("sha256: ", bytes2hex(open(sha256, filename)))
    println("tree-sha1: ", Tar.tree_hash(IOBuffer(inflate_gzip(filename))))
end

