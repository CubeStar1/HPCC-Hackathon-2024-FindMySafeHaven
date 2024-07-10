IMPORT $,STD;
UpperIt(STRING txt) := Std.Str.ToUpperCase(txt);
//These INDEXes are created (built) in BWR_CleanChurches
CleanFoodBankRec := RECORD
  REAL8 xcoor;
  REAL8 ycoor;
  STRING70 food_bank_name;
  STRING42 address;
  STRING16 city;
  STRING2 state;
  STRING10 zip_code;
  STRING60 web_page;
  STRING11 status;
  UNSIGNED3 primaryFIPS;
 END;

CleanFoodBDS := DATASET('~AVI::OUT::FoodBClean', CleanFoodBankRec, FLAT);

CleanFoodBIDX := INDEX(CleanFoodBDS, {city, state}, {CleanFoodBDS}, '~AVI::IDX::FoodBClean::CityState');
CleanFoodBFIPSIDX := INDEX(CleanFoodBDS, {PrimaryFIPS}, {CleanFoodBDS}, '~AVI::IDX::FoodBClean::FIPS');
/* To Publish your Query:
   1. Change Target to ROXIE
   2. Compile ONLY
   3. Open ECL Watch and select the Publish tab to publish your query 
   4. Test and demonstarte using: http://training.us-hpccsystems-dev.azure.lnrsg.io:8002
    
*/
EXPORT Av_FoodBankQuery(FipsVal,STRING22 CityVal,STRING2 StateVal) := FUNCTION
MyFoodB := IF(FipsVal = 0,
               OUTPUT(CleanFoodBIDX(City=UpperIt(CityVal),State=UpperIt(StateVal))),
               OUTPUT(CleanFoodBFIPSIDX(PrimaryFIPS=FipsVal)));
RETURN MyFoodB;
END;