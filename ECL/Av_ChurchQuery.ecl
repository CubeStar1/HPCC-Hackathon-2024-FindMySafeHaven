﻿IMPORT $,STD;
UpperIt(STRING txt) := Std.Str.ToUpperCase(txt);
//These INDEXes are created (built) in BWR_CleanChurches
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
CleanChurchFIPSIDX := INDEX(CleanChurchesDS,{PrimaryFIPS},{CleanChurchesDS},'~AVI::IDX::ChurchClean::FIPS');
/* To Publish your Query:
   1. Change Target to ROXIE
   2. Compile ONLY
   3. Open ECL Watch and select the Publish tab to publish your query 
   4. Test and demonstarte using: http://training.us-hpccsystems-dev.azure.lnrsg.io:8002
    
*/
EXPORT Av_ChurchQuery(FipsVal,STRING22 CityVal,STRING2 StateVal) := FUNCTION
MyChurch := IF(FipsVal = 0,
               OUTPUT(CleanChurchIDX(City=UpperIt(CityVal),State=UpperIt(StateVal))),
               OUTPUT(CleanChurchFIPSIDX(PrimaryFIPS=FipsVal)));
RETURN MyChurch;
END;


