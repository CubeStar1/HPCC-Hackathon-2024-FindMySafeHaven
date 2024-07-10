IMPORT $,STD;
UpperIt(STRING txt) := Std.Str.ToUpperCase(txt);


Final_risk_tbl_recs := RECORD
    STRING45  city;
    STRING2   state_id;
    STRING20  state_name;
    UNSIGNED3 county_fips;
    STRING30  county_name;
    DECIMAL5_2 EducationScore; 
    DECIMAL5_2 PovertyScore; 
    DECIMAL5_2 CrimeScore; 
    DECIMAL5_2 FinalScore; 
END;

CleanCoreDS  := DATASET('~AVI::OUT::RISKTBL',Final_risk_tbl_recs,FLAT);

//Declare and Build Indexes (special datasets that can be used in the ROXIE data delivery cluster
CleanCoreIDX     := INDEX(CleanCoreDS,{city,state_id},{CleanCoreDS},'~AVI::IDX::CoreFile::CityState');
CleanCoreFIPSIDX := INDEX(CleanCoreDS,{county_fips},{CleanCoreDS},'~AVI::IDX::CoreFile::FIPS');   

EXPORT Av_CoreQuery(FipsVal,STRING22 CityVal,STRING2 StateVal) := FUNCTION
MyCore := IF(FipsVal = 0,
               OUTPUT(CleanCoreIDX(City=UpperIt(CityVal),state_id=UpperIt(StateVal))),
               OUTPUT(CleanCoreFIPSIDX(county_fips=FipsVal)));
RETURN MyCore;
END;