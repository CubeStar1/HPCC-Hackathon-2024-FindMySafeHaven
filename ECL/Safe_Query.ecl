IMPORT $,STD;
UpperIt(STRING txt) := Std.Str.ToUpperCase(txt);


// Church
CleanChurchRec := RECORD
    REAL8 xcoor;
    REAL8 ycoor;
    STRING70  name;
    STRING35  street;
    STRING22  city;
    STRING2   state;
    UNSIGNED3 zip;
    UNSIGNED1 affiliation; 
    UNSIGNED3 PrimaryFIPS; //New - will be added from Cities DS
END;
CleanChurchesDS    := DATASET('~AVI::OUT::ChurchesClean',CleanChurchRec,FLAT);
CleanChurchIDX     := INDEX(CleanChurchesDS,{city,state},{CleanChurchesDS},'~AVI::IDX::ChurchClean::CityState');
CleanChurchFIPSIDX := INDEX(CleanChurchesDS,{PrimaryFIPS},{CleanChurchesDS},'~SAFE::IDX::ChurchClean::FIPS');

// FoodBank
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


// Fire
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



// Hospital
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



// Police
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
EXPORT Safe_Query(FipsVal,STRING22 CityVal,STRING2 StateVal) := FUNCTION
MyChurch := IF(FipsVal = 0,
               OUTPUT(CleanChurchIDX(City=UpperIt(CityVal),State=UpperIt(StateVal))),
               OUTPUT(CleanChurchFIPSIDX(PrimaryFIPS=FipsVal)));
MyFoodBank := IF(FipsVal = 0,
               OUTPUT(CleanFoodBIDX (City=UpperIt(CityVal),State=UpperIt(StateVal))),
               OUTPUT(CleanFoodBFIPSIDX (PrimaryFIPS=FipsVal)));
MyFire := IF(FipsVal = 0,
               OUTPUT(CleanFireIDX (City=UpperIt(CityVal),State=UpperIt(StateVal))),
               OUTPUT(CleanFireFIPSIDX (PrimaryFIPS=FipsVal)));
MyHospital := IF(FipsVal = 0,
               OUTPUT(CleanHospitalIDX (City=UpperIt(CityVal),State=UpperIt(StateVal))),
               OUTPUT(CleanHospitalFIPSIDX (PrimaryFIPS=FipsVal)));
MyPolice := IF(FipsVal = 0,
               OUTPUT(CleanPoliceIDX (City=UpperIt(CityVal),State=UpperIt(StateVal))),
               OUTPUT(CleanPoliceFIPSIDX (PrimaryFIPS=FipsVal)));
RETURN MyChurch + MyFoodBank + MyFire + MyHospital + MyPolice;
END;
