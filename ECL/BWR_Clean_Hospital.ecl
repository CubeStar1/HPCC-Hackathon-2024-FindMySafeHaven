
IMPORT $, STD, Visualizer;

HospitalData := $.File_AllData.HospitalDS;
HospitalRecs := $.File_AllData.HospitalRec;

Cities := $.File_AllData.City_DS;


                         
 
CleanHospitalRec := RECORD
  REAL8 xcoor;
  REAL8 ycoor;
  STRING100 hospital_name;
  STRING42 address;
  STRING35  city;
  STRING2 state;
  STRING10 zip_code;
  STRING15  telephone;
  STRING206 website;
  UNSIGNED3 primaryFIPS;
 END;
 


CleanHospitalRec ToCleanHospitalRec(HospitalRecs Le) := TRANSFORM
        SELF.xcoor := Le.xCoor;
        SELF.ycoor := Le.yCoor;
        SELF.hospital_name := STD.STR.ToUpperCase(Le.name);
        SELF.address := STD.STR.ToUpperCase(Le.address);
        SELF.city := STD.STR.ToUpperCase(Le.city);
        SELF.state := STD.STR.ToUpperCase(Le.state);
        SELF.zip_code := Le.zip;
        SELF.telephone := Le.telephone;
        SELF.website := Le.website;
        SELF.primaryFIPS := (UNSIGNED3) Le.countyfips
END;

        

CleanHospitalRec CleanHospital:= PROJECT(HospitalData, ToCleanHospitalRec(LEFT));


OUTPUT(SORT(CleanHospital, primaryFIPS));

WriteHospital := OUTPUT(CleanHospital,,'~AVI::OUT::HospitalClean', OVERWRITE);
CleanHospitals := DATASET('~AVI::OUT::HospitalClean', CleanHospitalRec, FLAT);

CleanHospitalIDX := INDEX(CleanHospitals, {city, state}, {CleanHospitals}, '~AVI::IDX::HospitalClean::CityState');
CleanHospitalFIPSIDX := INDEX(CleanHospitals, {PrimaryFIPS}, {CleanHospitals}, '~AVI::IDX::HospitalClean::FIPS');
BuildHospitalIDX := BUILD(CleanHospitalIDX, OVERWRITE);
BuildHospitalFIPSIDX := BUILD(CleanHospitalFIPSIDX, OVERWRITE);
SEQUENTIAL(WriteHospital, BuildHospitalIDX, BuildHospitalFIPSIDX);