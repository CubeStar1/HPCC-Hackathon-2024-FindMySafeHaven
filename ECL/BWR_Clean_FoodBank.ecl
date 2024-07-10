
IMPORT $, STD, Visualizer;

FoodBank := $.File_AllData.FoodBankDS;
FoodBankRecs := $.File_AllData.FoodBankRec;

Cities := $.File_AllData.City_DS;


                         
 
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
 


CleanFoodBankRec ToCleanFoodBankRec(FoodBankRecs Le) := TRANSFORM
        SELF.xcoor := Le.___x;
        SELF.ycoor := Le.y;
        SELF.food_bank_name := STD.STR.ToUpperCase(Le.food_bank_name);
        SELF.address := STD.STR.ToUpperCase(Le.address);
        SELF.city := STD.STR.ToUpperCase(Le.city);
        SELF.state := STD.STR.ToUpperCase(Le.state);
        SELF.zip_code := Le.zip_code;
        SELF.web_page := Le.web_page;
        SELF.status := Le.Status;
        SELF.primaryFIPS := 0;
END;

        

CleanFoodBankRec CleanFoodBank := PROJECT(FoodBank, ToCleanFoodBankRec(LEFT));


CleanFoodBankRec ToCleanFoodBankFIPSRec(CleanFoodBankRec Le, $.File_AllData.CitiesRec Ri) := TRANSFORM
          SELF.primaryFIPS := (UNSIGNED3) Ri.county_fips;
          SELF := Le;
END;

CleanFoodBankFIPS := JOIN(CleanFoodBank, Cities, STD.STR.ToUpperCase(LEFT.city) = STD.STR.ToUpperCase(RIGHT.city_ascii) AND
                                                STD.STR.ToUpperCase(LEFT.state) = STD.STR.ToUpperCase(RIGHT.state_id), ToCleanFoodBankFIPSRec(LEFT, RIGHT),
                                                LEFT OUTER, LOOKUP);
WriteFoodB := OUTPUT(CleanFoodBankFIPS,,'~AVI::OUT::FoodBClean', OVERWRITE);
CleanFoodBDS := DATASET('~AVI::OUT::FoodBClean', CleanFoodBankRec, FLAT);

CleanFoodBIDX := INDEX(CleanFoodBDS, {city, state}, {CleanFoodBDS}, '~AVI::IDX::FoodBClean::CityState');
CleanFoodBFIPSIDX := INDEX(CleanFoodBDS, {PrimaryFIPS}, {CleanFoodBDS}, '~AVI::IDX::FoodBClean::FIPS');
BuildFoodBIDX := BUILD(CleanFoodBIDX, OVERWRITE);
BuildFoodBFIPSIDX := BUILD(CleanFoodBFIPSIDX, OVERWRITE);
SEQUENTIAL(WriteFoodB, BuildFoodBIDX, BuildFoodBFIPSIDX);