# create the Dict for datas, but without any calculations

# site energy data
function data_djEs_sketch(at::Atoms, h::Float64, cutoffs::Array{Float64,1})

    atd = deepcopy(at);
    # neighbour lists for different cutoffs
    rcut1, rcut2, rcut3 = cutoffs[:];
    nlist_d1 = neighbourlist(at, rcut1);
    nlist_d2 = neighbourlist(at, rcut2);
    nlist_d3 = neighbourlist(at, rcut3);

    # data
    D = Dict{String, Any}();
    D["species"] = JuLIP.Chemistry.chemical_symbol(at.Z[1]);
    D["at"] = Dict(atd);
    D["Info"] = "djEs type training set";
    D["cutoff_d"] = rcut1
    D["cutoff_d2"] = rcut2;
    D["cutoff_d3"] = rcut3;
    data = Dict[]
    D["data"] = data;

    l0 = 1;

    # 0. Es
    dat = Dict{String, Any}();
    dat["Info"] = "Es of the origin site";
    dat["datatype"] = "Es"
    push!(data, dat);

    # 1. dEs
    dat = Dict{String, Any}();
    dat["Info"] = "dEs of the origin site";
    dat["datatype"] = "dEs"
    push!(data, dat);

    # 2. d2Es
    index_rcut2_0 = [];
    for (n, neigs, R) in sites(nlist_d2)
        if n == l0
            index_rcut2_0 = neigs;
        end
    end
    index_rcut2_0 = unique(index_rcut2_0)
    N₂ = length(index_rcut2_0);
    d2Esh = zeros(3, N₂, 3, length(atd));
    for i = 1 : 3
        for j = 1 : N₂
            ℓ = index_rcut2_0[j];
            # store d2Esh
            dat = Dict{String, Any}();
            dat["Info"] = "perturb the origin atom in direction i and store
                    d2Esh = 1/2h * ( E_{ℓ,n}(y+h*e₀) - E_{ℓ,n}(y-h*e₀) )";
            dat["h"] = h;
            dat["i"] = i;
            dat["l"] = ℓ;
            dat["datatype"] = "d2Esh";
            push!(data, dat);
        end
    end

    # 3. d3Es
    index_rcut3_0 = [];
    for (n, neigs, R) in sites(nlist_d3)
        if n == l0
            index_rcut3_0 = neigs
        end
    end
    N₃ = length(index_rcut3_0)
    # d3Esh = zeros(3, N₃, 3, )

    return D
end



# force data
function data_djF_sketch(at::Atoms, h::Float64, cutoffs::Array{Float64,1};
                         nconfig_F = 100, rndF = 0.2 * rnn(at.Z[1]),
                         nconfig_V = 100, rndV = 0.2)

    atd = deepcopy(at);
    # neighbour lists for different cutoffs
    rcut1, rcut2, rcut3 = cutoffs[:];
    nlist_d1 = neighbourlist(at, rcut1);
    nlist_d2 = neighbourlist(at, rcut2);
    nlist_d3 = neighbourlist(at, rcut3);

    # data
    D = Dict{String, Any}();
    D["species"] = JuLIP.Chemistry.chemical_symbol(at.Z[1]);
    D["at"] = Dict(atd);
    D["Info"] = "djF type training set";
    D["cutoff_d"] = rcut1
    D["cutoff_d2"] = rcut2;
    D["cutoff_d3"] = rcut3;
    data = Dict[]
    D["data"] = data;

    # 1. F
    dat = Dict{String, Any}();
    dat["Info"] = "forces";
    dat["datatype"] = "F"
    push!(data, dat);

    # 2. FC
    for i = 1 : 3
        # store force-constants
        dat = Dict{String, Any}()
        dat["Info"] = "perturb the origin atom in direction i and store
                      dFh = 1/2h * ( F_{,n}(y+h*e₀) - F_{,n}(y-h*e₀) )"
        dat["l0"] = 1;
        dat["i"] = i;
        dat["h"] = h;
        dat["datatype"] = "FC";
        push!(data, dat);
    end

    # # 3. d2F
    # for i = 1 : 3, j = 1 : 3
    #     for k = 1 : length()
    #     # store force-constants
    #     dat = Dict{String, Any}()
    #     dat["Info"] = "perturb the origin atom in direction i
    #             perturb the k-th atom in direction j
    #             and store dFh = 1/2h * ( F_{,n}(y+h*e₀) - F_{,n}(y-h*e₀) )"
    #     dat["i0"] = 1;
    #     dat["h"] = h;
    #     dat["i"] = i;
    #     dat["datatype"] = "d2F";
    #     push!(data, dat);
    # end

    # # 4. random forces
    # for n = 1:nconfig_F
    #     at1 = deepcopy(at)
    #     r = rndF * rand()
    #     rattle!(at1, r)
    #     dat = Dict{String, Any}(
    #             "Info" => "Forces on Random Configuration",
    #             "r" => r,
    #             "at" => Dict(at1),
    #             "datatype" => "EF")
    #     push!(data, dat)
    # end
    #
    # # 5. random cells
    # s = chemical_symbol(at.Z[1])
    # for n = 1:nconfig_V
    #     at1 = bulk(s)  # correcrt equilibrium distance???!!!???
    #     r = rndV * rand()
    #     F = I + r * 2 * (rand(3,3) .- 0.5)
    #     apply_defm!(at1, F)
    #     dat = Dict{String, Any}(
    #             "Info" => "Virials on Random Cell Shapes",
    #             "r" => r,
    #             "at" => Dict(at1),
    #             "datatype" => "EFV")
    # end

    return D
end
