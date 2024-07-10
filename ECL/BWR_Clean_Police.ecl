
IMPORT $, STD, Visualizer;

PoliceData := $.File_AllData.PoliceDS;
PoliceRecs := $.File_AllData.PoliceRec;

Cities := $.File_AllData.City_DS;


                         
 
CleanPoliceRec := RECORD
  REAL8 xcoor;
  REAL8 ycoor;
  STRING135 police_name;
  STRING80 address;
  STRING30  city;
  STRING2 state;
  STRING5 zip_code;
  STRING15  telephone;
  STRING155 website;
  UNSIGNED3 primaryFIPS;
 END;
 


CleanPoliceRec ToCleanPoliceRec(PoliceRecs Le) := TRANSFORM
        SELF.xcoor := Le.longitude;
        SELF.ycoor := Le.latitude;
        SELF.police_name := STD.STR.ToUpperCase(Le.name);
        SELF.address := STD.STR.ToUpperCase(Le.address);
        SELF.city := STD.STR.ToUpperCase(Le.city);
        SELF.state := STD.STR.ToUpperCase(Le.state);
        SELF.zip_code := Le.zip;
        SELF.telephone := Le.telephone;
        SELF.website := Le.website;
        SELF.primaryFIPS := (UNSIGNED3) Le.countyfips
END;

        

CleanPoliceRec CleanPolice:= PROJECT(PoliceData, ToCleanPoliceRec(LEFT));


OUTPUT(SORT(CleanPolice, primaryFIPS));

WritePolice := OUTPUT(CleanPolice,,'~AVI::OUT::PoliceClean', OVERWRITE);
CleanPolices := DATASET('~AVI::OUT::PoliceClean', CleanPoliceRec, FLAT);

CleanPoliceIDX := INDEX(CleanPolices, {city, state}, {CleanPolices}, '~AVI::IDX::PoliceClean::CityState');
CleanPoliceFIPSIDX := INDEX(CleanPolices, {PrimaryFIPS}, {CleanPolices}, '~AVI::IDX::PoliceClean::FIPS');
BuildPoliceIDX := BUILD(CleanPoliceIDX, OVERWRITE);
BuildPoliceFIPSIDX := BUILD(CleanPoliceFIPSIDX, OVERWRITE);
SEQUENTIAL(WritePolice, BuildPoliceIDX, BuildPoliceFIPSIDX);