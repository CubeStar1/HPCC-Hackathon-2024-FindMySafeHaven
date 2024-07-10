
IMPORT $, STD, Visualizer;

FireData := $.File_AllData.FireDS;
FireRecs := $.File_AllData.FireRec;

Cities := $.File_AllData.City_DS;


                         
 
CleanFireRec := RECORD
  REAL8 xcoor;
  REAL8 ycoor;
  STRING100 fire_name;
  STRING42 address;
  STRING35  city;
  STRING2 state;
  STRING10 zip_code;
  UNSIGNED3 primaryFIPS;
 END;
 


CleanFireRec ToCleanFireRec(FireRecs Le) := TRANSFORM
        SELF.xcoor := Le.xcoor;
        SELF.ycoor := Le.ycoor;
        SELF.fire_name := STD.STR.ToUpperCase(Le.name);
        SELF.address := STD.STR.ToUpperCase(Le.address);
        SELF.city := STD.STR.ToUpperCase(Le.city);
        SELF.state := STD.STR.ToUpperCase(Le.state);
        SELF.zip_code := Le.zipcode;
        SELF.primaryFIPS := 0;
END;

        

CleanFireRec CleanFire:= PROJECT(FireData, ToCleanFireRec(LEFT));
CleanFire_with_addr := CleanFire(address <> '' AND city <> '' AND state <> '');


CleanFireRec ToCleanFireFIPSRec(CleanFireRec Le, $.File_AllData.CitiesRec Ri) := TRANSFORM
          SELF.primaryFIPS := (UNSIGNED3) Ri.county_fips;
          SELF := Le;
END;

CleanFireFIPS := JOIN(CleanFire_with_addr, Cities, STD.STR.ToUpperCase(LEFT.city) = STD.STR.ToUpperCase(RIGHT.city_ascii) AND
                                                STD.STR.ToUpperCase(LEFT.state) = STD.STR.ToUpperCase(RIGHT.state_id), ToCleanFireFIPSRec(LEFT, RIGHT),
                                                LEFT OUTER, LOOKUP);
WriteFire := OUTPUT(CleanFireFIPS,,'~AVI::OUT::FireClean', OVERWRITE);
CleanFireDS := DATASET('~AVI::OUT::FireClean', CleanFireRec, FLAT);

CleanFireIDX := INDEX(CleanFireDS, {city, state}, {CleanFireDS}, '~AVI::IDX::FireClean::CityState');
CleanFireFIPSIDX := INDEX(CleanFireDS, {PrimaryFIPS}, {CleanFireDS}, '~AVI::IDX::FireClean::FIPS');
BuildFireIDX := BUILD(CleanFireIDX, OVERWRITE);
BuildFireFIPSIDX := BUILD(CleanFireFIPSIDX, OVERWRITE);
SEQUENTIAL(WriteFire, BuildFireIDX, BuildFireFIPSIDX);