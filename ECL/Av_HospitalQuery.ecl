IMPORT $,STD;
UpperIt(STRING txt) := Std.Str.ToUpperCase(txt);
//These INDEXes are created (built) in BWR_CleanChurches
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

CleanHospitals := DATASET('~AVI::OUT::HospitalClean', CleanHospitalRec, FLAT);

CleanHospitalIDX := INDEX(CleanHospitals, {city, state}, {CleanHospitals}, '~AVI::IDX::HospitalClean::CityState');
CleanHospitalFIPSIDX := INDEX(CleanHospitals, {PrimaryFIPS}, {CleanHospitals}, '~AVI::IDX::HospitalClean::FIPS');
/* To Publish your Query:
   1. Change Target to ROXIE
   2. Compile ONLY
   3. Open ECL Watch and select the Publish tab to publish your query 
   4. Test and demonstarte using: http://training.us-hpccsystems-dev.azure.lnrsg.io:8002
    
*/
EXPORT Av_HospitalQuery(FipsVal,STRING22 CityVal,STRING2 StateVal) := FUNCTION
MyHospital := IF(FipsVal = 0,
               OUTPUT(CleanHospitalIDX(City=UpperIt(CityVal),State=UpperIt(StateVal))),
               OUTPUT(CleanHospitalFIPSIDX(PrimaryFIPS=FipsVal)));
RETURN MyHospital;
END;