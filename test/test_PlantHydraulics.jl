# FT and NaN test
println("\nTesting the structures...")
@testset "Hydraulics --- structures" begin
    for FT in [Float32, Float64]
        leaf  = LeafHydraulics{FT}();
        root  = RootHydraulics{FT}();
        stem  = StemHydraulics{FT}();
        grass = create_grass_like_hs(FT(-2.1), FT(0.5), FT[0,-1,-2,-3], collect(FT,0:1:20));
        palm  = create_palm_like_hs(FT(-2.1), FT(5.5), FT(6), FT[0,-1,-2,-3], collect(FT,0:1:20));
        tree  = create_tree_like_hs(FT(-2.1), FT(5.5), FT(6), FT[0,-1,-2,-3], collect(FT,0:1:20));
        treet = TreeSimple{FT}();
        _vc1  = WeibullSingle{FT}();
        _vc2  = WeibullDual{FT}();
        _sh1  = BrooksCorey{FT}();
        _sh2  = VanGenuchten{FT}();

        # Test the struct
        for data_set in [ leaf, root, stem, grass, palm, tree, treet, _vc1, _vc2, _sh1, _sh2,
                          VGClay(FT),
                          VGClayLoam(FT),
                          VGLoamySand(FT),
                          VGLoamySand2(FT),
                          VGSand(FT),
                          VGSandyClayLoam(FT),
                          VGSandyClayLoam2(FT),
                          VGSandyLoam(FT),
                          VGSilt(FT),
                          VGSiltyClay(FT),
                          VGSiltyClayLoam(FT),
                          VGSiltyLoam(FT) ]
            @test FT_test(data_set, FT)
            @test NaN_test(data_set)
        end
    end
end



# FT and NaN test
println("\nTesting and benchmarking the soil VC functions...")
@testset "Hydraulics --- soil VC" begin
    for FT in [Float32, Float64]
        _sh1  = BrooksCorey{FT}();
        _sh2  = VanGenuchten{FT}();

        # test soil functions
        _rwc = FT(0.5);
        _p   = FT(-0.5);
        for result in [ soil_rwc(_sh1, _p),
                        soil_rwc(_sh2, _p),
                        soil_k_ratio_rwc(_sh1, _rwc),
                        soil_k_ratio_rwc(_sh2, _rwc),
                        soil_k_ratio_swc(_sh1, _rwc*_sh1.Θs),
                        soil_k_ratio_swc(_sh2, _rwc*_sh2.Θs),
                        soil_k_ratio_p25(_sh1, _p),
                        soil_k_ratio_p25(_sh2, _p),
                        soil_p_25_rwc(_sh1, _rwc),
                        soil_p_25_rwc(_sh2, _rwc),
                        soil_p_25_swc(_sh1, _rwc*_sh1.Θs),
                        soil_p_25_swc(_sh2, _rwc*_sh2.Θs) ]
            @test FT_test(result, FT);
            @test NaN_test(result);
        end

        # test if the soil_p_25 and soil_rwc converge
        _p_giv = FT(-2);
        _r_m_1 = soil_erwc(_sh1, _p_giv);
        _r_m_2 = soil_erwc(_sh2, _p_giv);
        _p_m_1 = soil_p_25_erwc(_sh1, _r_m_1);
        _p_m_2 = soil_p_25_erwc(_sh2, _r_m_2);
        @test _p_giv ≈ _p_m_1 ≈ _p_m_2;

        _r_m_1 = soil_rwc(_sh1, _p_giv);
        _r_m_2 = soil_rwc(_sh2, _p_giv);
        _p_m_1 = soil_p_25_rwc(_sh1, _r_m_1);
        _p_m_2 = soil_p_25_rwc(_sh2, _r_m_2);
        @test _p_giv ≈ _p_m_1 ≈ _p_m_2;

        _r_m_1 = soil_swc(_sh1, _p_giv);
        _r_m_2 = soil_swc(_sh2, _p_giv);
        _p_m_1 = soil_p_25_swc(_sh1, _r_m_1);
        _p_m_2 = soil_p_25_swc(_sh2, _r_m_2);
        @test _p_giv ≈ _p_m_1 ≈ _p_m_2;
    end
end



# FT and NaN test
println("\nTesting and benchmarking the xylem VC functions...")
@testset "Hydraulics --- xylem VC" begin
    for FT in [Float32, Float64]
        _vc1 = WeibullSingle{FT}();
        _vc2 = WeibullDual{FT}();
        _sh1 = BrooksCorey{FT}();
        _sh2 = VanGenuchten{FT}();
        _p   = FT(-0.5);
        _v   = FT(0.9);

        # Test xylem_p_crit
        f_st = FT(1)
        for result in [ xylem_p_crit(_vc1, f_st),
                        xylem_p_crit(_vc2, f_st) ]
            @test FT_test(result, FT);
            @test NaN_test(result);
        end

        # test the xylem_k_ratio
        for result in [ xylem_k_ratio(_vc1, _p, _v),
                        xylem_k_ratio(_vc2, _p, _v) ]
            @test FT_test(result, FT);
            @test NaN_test(result);
        end
    end
end



# FT and NaN test
println("\nTesting and benchmarking the leaf functions...")
@testset "Hydraulics --- leaf" begin
    for FT in [Float32, Float64]
        leaf  = LeafHydraulics{FT}();
        _f    = FT(0.01);

        # Test the struct
        _lr = leaf_xylem_risk(leaf, _f);
        _ec = leaf_e_crit(leaf);

        for result in [_lr, _ec]
            @test FT_test(result, FT);
            @test NaN_test(result);
        end
    end
end



# FT and NaN test
println("\nTesting and benchmarking the legacy functions...")
@testset "Hydraulics --- legacy" begin
    for FT in [Float32, Float64]
        _ps   = FT(-0.1);
        _ft   = FT(1);
        _fsl  = FT(0.8);
        _fsh  = FT(0.2);
        _rsl  = FT(0.5);

        # Test the struct
        treet = TreeSimple{FT}();
        hydraulic_p_profile!(treet, _ps, _ft);
        @test FT_test(treet, FT);
        @test NaN_test(treet);

        treet = TreeSimple{FT}();
        hydraulic_p_profile!(treet, _ps, _fsl, _fsh, _rsl);
        @test FT_test(treet, FT);
        @test NaN_test(treet);

        inititialize_legacy!(treet);
        @test FT_test(treet, FT);
        @test NaN_test(treet);
    end
end



# FT and NaN test
println("\nTesting and benchmarking the temperature functions...")
@testset "Hydraulics --- temperature functions" begin
    for FT in [Float32, Float64]
        leaf  = LeafHydraulics{FT}();
        root  = RootHydraulics{FT}();
        treet = TreeSimple{FT}();
        T     = rand(FT) + 298;

        # test the temperature functions
        vc_temperature_effects!(treet);
        vc_temperature_effects!(leaf, T);
        vc_temperature_effects!(root, T);

        for dataset in [leaf, root, treet]
            @test FT_test(dataset, FT);
            @test NaN_test(dataset);
        end
    end
end



# FT and NaN test
println("\nTesting and benchmarking the root-related functions...")
@testset "Hydraulics --- root-related functions" begin
    for FT in [Float32, Float64]
        root  = RootHydraulics{FT}();
        grass = create_grass_like_hs(FT(-2.1), FT(0.5), collect(FT,0:-0.5:-3.0), collect(FT,0:1:20));

        # test the root q functions
        _p1 = FT(0)
        _p2 = FT(-0.5)
        _p3 = FT(-1.0)
        for result in [ root_q_from_pressure(root, _p1),
                        root_q_from_pressure(root, _p2),
                        root_q_from_pressure(root, _p3) ]
            @test FT_test(result, FT);
            @test NaN_test(result);
        end

        # test the root qs from q functions
        _f0 = FT(0);
        _f1 = FT(0.1);
        _f2 = FT(0.5);
        _ks = zeros(FT, 5);
        _ps = zeros(FT, 5);
        _qs = zeros(FT, 5);
        for _f in [_f0, _f1, _f2]
            roots_flow!(grass.roots, _ks, _ps, _qs, _f);
            @test FT_test(grass, FT);
            @test NaN_test(grass);
        end

        # test the recalculate_roots_flow function
        _ks = zeros(FT, 5);
        _ps = zeros(FT, 5);
        _qs = zeros(FT, 5);
        recalculate_roots_flow!(grass.roots, _ks, _ps, _qs, FT(0.5));
        @test NaN_test(grass);
    end
end



# FT and NaN test
println("\nTesting and benchmarking the pressure functions...")
@testset "Hydraulics --- pressure functions" begin
    for FT in [Float32, Float64]
        leaf  = LeafHydraulics{FT}();
        root  = RootHydraulics{FT}();
        stem  = StemHydraulics{FT}();
        grass = create_grass_like_hs(FT(-2.1), FT(0.5), FT[0,-1,-2,-3], collect(FT,0:1:20));
        palm  = create_palm_like_hs(FT(-2.1), FT(5.5), FT(6), FT[0,-1,-2,-3], collect(FT,0:1:20));
        tree  = create_tree_like_hs(FT(-2.1), FT(5.5), FT(6), FT[0,-1,-2,-3], collect(FT,0:1:20));
        treet = TreeSimple{FT}();

        # test the xylem_p_from_flow function
        _f_1 = FT(0.001)
        _f_2 = FT(1)
        for result in [ xylem_p_from_flow(leaf, _f_1),
                        xylem_p_from_flow(leaf, _f_2),
                        xylem_p_from_flow(root, _f_1),
                        xylem_p_from_flow(root, _f_2),
                        xylem_p_from_flow(stem, _f_1),
                        xylem_p_from_flow(stem, _f_2) ]
            @test FT_test(result, FT);
            @test NaN_test(result);
        end

        # test the xylem_p_from_flow function for plants
        for result in [ xylem_p_from_flow(grass, _f_1),
                        xylem_p_from_flow(grass, _f_2),
                        xylem_p_from_flow(palm, _f_1),
                        xylem_p_from_flow(palm, _f_2),
                        xylem_p_from_flow(tree, _f_1),
                        xylem_p_from_flow(tree, _f_2),
                        xylem_p_from_flow(treet, _f_1),
                        xylem_p_from_flow(treet, _f_2) ]
            @test FT_test(result, FT);
            @test NaN_test(result);
        end
    end
end



# FT and NaN test
println("\nTesting and benchmarking the plant-level functions...")
@testset "Hydraulics --- plant-level" begin
    for FT in [Float32, Float64]
        grass = create_grass_like_hs(FT(-2.1), FT(0.5), FT[0,-1,-2,-3], collect(FT,0:1:20));
        palm  = create_palm_like_hs(FT(-2.1), FT(5.5), FT(6), FT[0,-1,-2,-3], collect(FT,0:1:20));
        tree  = create_tree_like_hs(FT(-2.1), FT(5.5), FT(6), FT[0,-1,-2,-3], collect(FT,0:1:20));
        treet = TreeSimple{FT}();

        # test the tree_e_crit function
        for result in [ tree_e_crit(grass),
                        tree_e_crit(palm),
                        tree_e_crit(tree),
                        tree_e_crit(treet) ]
            @test FT_test(result, FT);
            @test NaN_test(result);
        end
    end
end
