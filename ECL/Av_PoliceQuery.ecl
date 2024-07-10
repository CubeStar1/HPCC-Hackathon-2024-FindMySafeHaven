IMPORT $,STD;
UpperIt(STRING txt) := Std.Str.ToUpperCase(txt);
//These INDEXes are created (built) in BWR_CleanChurches
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

CleanPolices := DATASET('~AVI::OUT::PoliceClean', CleanPoliceRec, FLAT);

CleanPoliceIDX := INDEX(CleanPolices, {city, state}, {CleanPolices}, '~AVI::IDX::PoliceClean::CityState');
CleanPoliceFIPSIDX := INDEX(CleanPolices, {PrimaryFIPS}, {CleanPolices}, '~AVI::IDX::PoliceClean::FIPS');
/* To Publish your Query:
   1. Change Target to ROXIE
   2. Compile ONLY
   3. Open ECL Watch and select the Publish tab to publish your query 
   4. Test and demonstarte using: http://training.us-hpccsystems-dev.azure.lnrsg.io:8002
    
*/
EXPORT Av_PoliceQuery(FipsVal,STRING22 CityVal,STRING2 StateVal) := FUNCTION
MyPolice := IF(FipsVal = 0,
               OUTPUT(CleanPoliceIDX(City=UpperIt(CityVal),State=UpperIt(StateVal))),
               OUTPUT(CleanPoliceFIPSIDX(PrimaryFIPS=FipsVal)));
RETURN MyPolice;
END;