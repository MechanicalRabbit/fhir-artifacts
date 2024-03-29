## FHIR Resources

This repository contains a copy of FHIR standard resources suitable for
use though Julia's Pkg.Artifacts module. First, add the entries in the
``Artifacts.toml`` file.  Then, you could use it as follows.

    using JSON
    using Pkg.Artifacts

    fname = joinpath(artifact"fhir-r4", "fhir-r4", "patient-example.json");
    #-> …/fhir-r4/patient-example.json"

    resource = JSON.parsefile(read(fname, String))
    display(resource)
    #=>
    Dict{String,Any} with 14 entries:
      "active"               => true
      "managingOrganization" => Dict{String,Any}("reference"=>"Organizati…
      "address"              => Any[Dict{String,Any}("line"=>Any["534 Ere…
      "name"                 => Any[Dict{String,Any}("family"=>"Chalmers"…
    ⋮
    =#

This repository has the .tar.gz archive and the code that downloads the
specification from the HL7 website; and builds a compliant tarball and
the Artifacts.toml hashes.

## Synthea Artifacts

There is also a 116 patient Synthea testset included, encoded as FHIR
using R4 schema. It was created from a pre-release version on 2020-07-05
using 12345 as random seed, with a requested population of 100 (16 are
marked as dead).
