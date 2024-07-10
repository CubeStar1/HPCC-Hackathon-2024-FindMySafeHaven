IMPORT $,STD;
UpperIt(STRING txt) := Std.Str.ToUpperCase(txt);
//These INDEXes are created (built) in BWR_CleanChurches
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

CleanFireDS := DATASET('~AVI::OUT::FireClean', CleanFireRec, FLAT);

CleanFireIDX := INDEX(CleanFireDS, {city, state}, {CleanFireDS}, '~AVI::IDX::FireClean::CityState');
CleanFireFIPSIDX := INDEX(CleanFireDS, {PrimaryFIPS}, {CleanFireDS}, '~AVI::IDX::FireClean::FIPS');
/* To Publish your Query:
   1. Change Target to ROXIE
   2. Compile ONLY
   3. Open ECL Watch and select the Publish tab to publish your query 
   4. Test and demonstarte using: http://training.us-hpccsystems-dev.azure.lnrsg.io:8002
    
*/
EXPORT Av_FireQuery(FipsVal,STRING22 CityVal,STRING2 StateVal) := FUNCTION
MyFire := IF(FipsVal = 0,
               OUTPUT(CleanFireIDX(City=UpperIt(CityVal),State=UpperIt(StateVal))),
               OUTPUT(CleanFireFIPSIDX(PrimaryFIPS=FipsVal)));
RETURN MyFire;
END;