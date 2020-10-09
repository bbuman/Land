# test the gain_risk_map
println("\nTesting the gain_risk_map Function...")
@testset "SoilPlantAirContinuum --- gain_risk_map" begin
    for FT in [Float32, Float64]
        node   = SPACSimple{FT}();
        photo  = C3CLM(FT);
        zenith = FT(30);
        r_all  = FT(1000);

        big_leaf_partition!(node, zenith, r_all);
        mat = gain_risk_map(node, photo);
        recursive_FT_test(mat, FT);
        recursive_NaN_test(mat);
    end
end




# test and benchmark the leaf_gas_exchange_nonopt!
println("\nTesting the leaf_gas_exchange_nonopt! Functions...")
@testset "SoilPlantAirContinuum --- leaf_gas_exchange_nonopt!" begin
    for FT in [Float32, Float64]
        node   = SPACSimple{FT}();
        photo  = C3CLM(FT);
        zenith = FT(30);
        r_all  = FT(1000);
        flow   = FT(4);
        f_sl   = FT(2.5);
        f_sh   = FT(1.5);

        big_leaf_partition!(node, zenith, r_all);
        leaf_gas_exchange_nonopt!(node, photo, flow);
        recursive_FT_test(node, FT);
        recursive_NaN_test(node);
        leaf_gas_exchange_nonopt!(node, photo, f_sl, f_sh);
        recursive_FT_test(node, FT);
        recursive_NaN_test(node);

        if benchmarking
            @btime leaf_gas_exchange_nonopt!($node, $photo, $flow);
            @btime leaf_gas_exchange_nonopt!($node, $photo, $f_sl, $f_sh);
        end
    end
end




# test and benchmark the leaf_gas_exchange!
println("\nTesting the leaf_gas_exchange! Functions...")
@testset "SoilPlantAirContinuum --- leaf_gas_exchange!" begin
    for FT in [Float32, Float64]
        node   = SPACSimple{FT}();
        photo  = C3CLM(FT);
        zenith = FT(30);
        r_all  = FT(1000);
        flow   = FT(4);
        f_sl   = FT(2.5);
        f_sh   = FT(1.5);

        big_leaf_partition!(node, zenith, r_all);
        leaf_gas_exchange!(node, photo, flow);
        recursive_FT_test(node, FT);
        recursive_NaN_test(node);
        leaf_gas_exchange!(node, photo, f_sl, f_sh);
        recursive_FT_test(node, FT);
        recursive_NaN_test(node);

        if benchmarking
            @btime leaf_gas_exchange!($node, $photo, $flow);
            @btime leaf_gas_exchange!($node, $photo, $f_sl, $f_sh);
        end
    end
end




# test and benchmark the leaf_temperature*
println("\nTesting the leaf_temperature* Functions...")
@testset "SoilPlantAirContinuum --- leaf_temperature*" begin
    for FT in [Float32, Float64]
        node = SPACSimple{FT}();
        rad  = FT(300);
        flow = FT(4);

        for result in [ leaf_temperature(node, rad, flow),
                        leaf_temperature_shaded(node, rad, flow),
                        leaf_temperature_sunlit(node, rad, flow) ]
            recursive_FT_test(result, FT);
            recursive_NaN_test(result);
        end

        if benchmarking
            @btime leaf_temperature($node, $rad, $flow);
            @btime leaf_temperature_shaded($node, $rad, $flow);
            @btime leaf_temperature_sunlit($node, $rad, $flow);
        end
    end
end




# test and benchmark the optimize_flows!
println("\nTesting the optimize_flows! Functions...")
@testset "SoilPlantAirContinuum --- optimize_flows!" begin
    for FT in [Float32, Float64]
        node   = SPACSimple{FT}();
        photo  = C3CLM(FT);
        zenith = FT(30);
        r_all  = FT(1000);

        big_leaf_partition!(node, zenith, r_all);
        optimize_flows!(node, photo);
        recursive_FT_test(node, FT);
        recursive_NaN_test(node);

        if benchmarking
            # reset the node before benchmarking
            node = SPACSimple{FT}();
            @btime optimize_flows!($node, $photo);
        end
    end
end




# test and benchmark the atmosheric* functions
println("\nTesting the atmosheric* Functions...")
@testset "SoilPlantAirContinuum --- atmosheric*" begin
    for FT in [Float32, Float64]
        h = FT(1000);

        for result in [ atmospheric_pressure(h),
                        atmospheric_pressure_ratio(h),
                        ppm_to_Pa(h) ]
            recursive_FT_test(result, FT);
            recursive_NaN_test(result);
        end

        if benchmarking
            @btime atmospheric_pressure($h);
            @btime atmospheric_pressure_ratio($h);
            @btime ppm_to_Pa($h);
        end
    end
end




# test and benchmark the zenith_angle
println("\nTesting the zenith_angle Functions...")
@testset "SoilPlantAirContinuum --- zenith_angle" begin
    for FT in [Float32, Float64]
        latd = FT(10);
        decd = FT(10);
        lhad = FT(10);
        day  = FT(100)
        hour = FT(13)
        minu = FT(30)

        for result in [ zenith_angle(latd, decd, lhad),
                        zenith_angle(latd, day, hour),
                        zenith_angle(latd, day, hour, minu) ]
            recursive_FT_test(result, FT);
            recursive_NaN_test(result);
        end

        if benchmarking
            @btime zenith_angle($latd, $decd, $lhad);
            @btime zenith_angle($latd, $day, $hour);
            @btime zenith_angle($latd, $day, $hour, $minu);
        end
    end
end




# test and benchmark the annual_profit
println("\nTesting the annual_profit Functions...")
@testset "SoilPlantAirContinuum --- annual_profit" begin
    weat = DataFrame!(CSV.File("../data/gs_sample.csv"));
    for FT in [Float32, Float64]
        node    = SPACSimple{FT}();
        photo   = C3CLM(FT);
        weatmat = Matrix{FT}(weat);

        gscp = annual_profit(node, photo, weatmat);
        recursive_FT_test(gscp, FT);
        recursive_NaN_test(gscp);

        if benchmarking
            # reset the node before benchmarking
            node = SPACSimple{FT}();
            @btime annual_profit($node, $photo, $weatmat);
        end
    end
end




# test and benchmark the annual_simulation!
println("\nTesting annual_simulation! Functions...")
@testset "SoilPlantAirContinuum --- annual_simulation!" begin
    weat = DataFrame!(CSV.File("../data/gs_sample.csv"));
    for FT in [Float32, Float64]
        node  = SPACSimple{FT}();
        photo = C3CLM(FT);
        df    = create_dataframe(FT, weat);

        annual_simulation!(node, photo, weat, df);
        recursive_FT_test(node, FT);
        recursive_NaN_test(node);
    end
end




# test and benchmark the leaf_allocation!
println("\nTesting the leaf_allocation! Functions...")
@testset "SoilPlantAirContinuum --- leaf_allocation!" begin
    for FT in [Float32, Float64]
        node  = SPACSimple{FT}();
        photo = C3CLM(FT);
        laba  = FT(1000);
        vmax  = FT(80);

        leaf_allocation!(node, laba);
        recursive_FT_test(node, FT);
        recursive_NaN_test(node);
        leaf_allocation!(node, photo, vmax);
        recursive_FT_test(node, FT);
        recursive_NaN_test(node);
        leaf_allocation!(node, photo, laba, vmax);
        recursive_FT_test(node, FT);
        recursive_NaN_test(node);

        if benchmarking
            @btime leaf_allocation!($node, $laba);
            @btime leaf_allocation!($node, $photo, $vmax);
            @btime leaf_allocation!($node, $photo, $laba, $vmax);
        end
    end
end




# test and benchmark the optimize_leaf
println("\nTesting the optimize_leaf! Functions...")
@testset "SoilPlantAirContinuum --- optimize_leaf!" begin
    weat = DataFrame!(CSV.File("../data/gs_sample.csv"));
    for FT in [Float32, Float64]
        node    = SPACSimple{FT}();
        photo   = C3CLM(FT);
        weatmat = Matrix{FT}(weat);

        optimize_leaf!(node, photo, weatmat);
        recursive_FT_test(node, FT);
        recursive_NaN_test(node);

        if benchmarking
            # reset the node before benchmarking
            node = SPACSimple{FT}();
            @btime optimize_leaf!($node, $photo, $weatmat);
        end
    end
end




# test the function to vary SPACSimple
println("\nTesting the vary_spac! Functions...")
@testset "SoilPlantAirContinuum --- vary_spac!" begin
    weat = DataFrame!(CSV.File("../data/gs_sample.csv"));
    facs = ["kl", "kw", "wb", "wc", "wk",
            "cc", "cv", "gm",
            "ga", "sd",
            "ta", "rh", "ca"];
    for FT in [Float32, Float64]
        node = SPACSimple{FT}();
        for _fac in facs
            vary_spac!(node, weat, _fac, FT(1.5));
            @test true;
        end
    end
end
