// Let's create a core "risk" file that the county code (FIPS) and the primary city.
// We can extra ct this data from the Cities file
#OPTION('obfuscateOutput', TRUE);
IMPORT $;
CityDS := $.File_AllData.City_DS;
Crime  := $.File_AllData.CrimeDS;


//CityDS(county_fips = 5035); Test to verify data accuracy for the crime score


// Declare our core RECORD:
RiskRec := RECORD
    STRING45  city;
    STRING2   state_id;
    STRING20  state_name;
    UNSIGNED3 county_fips;
    STRING30  county_name;
END;

BaseInfo := PROJECT(CityDS,RiskRec);
OUTPUT(BaseInfo,NAMED('BaseData'));

RiskPlusRec := RECORD
 BaseInfo;
 REAL8 EducationScore  := 0;
 REAL8 PovertyScore    := 0;
 REAL8 PopulationScore := 0;
 REAL8 CrimeScore      := 0;

END; 
 
RiskTbl := TABLE(BaseInfo,RiskPlusRec);
OUTPUT(RiskTbl,NAMED('BuildTable'));


//Let's add a Crime Score!

CrimeRec := RECORD
CrimeRate := TRUNCATE((INTEGER)Crime.crime_rate_per_100000);
Crime.fips_st;
fips_cty := (INTEGER)Crime.fips_cty;
Fips := Crime.fips_st + INTFORMAT(Crime.fips_cty,3,1);
END;

CrimeTbl := TABLE(Crime,CrimeRec);
OUTPUT(CrimeTbl,NAMED('BuildCrimeTable'));

JoinCrime := JOIN(CrimeTbl,RiskTbl,
                  LEFT.fips = (STRING5)RIGHT.county_fips,
                  TRANSFORM(RiskPlusRec,
                            SELF.CrimeScore := (LEFT.crimerate)/100,
                            SELF            := RIGHT),
                            RIGHT OUTER);
// Calculate the min and max of the dataset
mini := MIN(JoinCrime, CrimeScore);
maxi := MAX(JoinCrime, CrimeScore);

// Define a transform that adds a MinMax scaled field to each record
crime_by_county_minmax := RECORD
    JoinCrime;
    REAL8 NormCrime;
END;

crime_by_county_minmax add_minmax(JoinCrime le) := TRANSFORM
    SELF := le;
    SELF.NormCrime := (le.CrimeScore - mini) / (maxi - mini);
END;

// Use the transform to add a MinMax scaled field to each record in the dataset
Crime_by_county_Norm := PROJECT(JoinCrime, add_minmax(LEFT));
OUTPUT(Crime_by_county_Norm);
OUTPUT(Crime_by_county_Norm(NormCrime > 0.99));
OUTPUT(Crime_by_county_Norm,,'~AVI::OUT::CRIMENORM', OVERWRITE);                            
OUTPUT(SORT(JoinCrime,-CrimeScore),NAMED('AddedCrimeScore')); 
OUTPUT(COUNT(JoinCrime), NAMED('CountJoinCrime'));

//Now go out and get the others! Good like with your challenge! 
//After you complete the other scores, make sure to OUTPUT to a file and then create a DATASET so
//that you can reference and deliver it to the judges.   


// Add Education Score

EduRecs := RECORD
UNSIGNED3 FIPS_Code;
STRING50 County;
REAL8 NormEducation;
END;

Education := DATASET('~AVI::OUT::EDUNORM', EduRecs, FLAT);
OUTPUT(Education, NAMED('BuildEduTable'));

JoinEdu := JOIN(Education, Crime_by_county_Norm, 
                  LEFT.FIPS_Code = (UNSIGNED3) RIGHT.county_fips,
                  TRANSFORM(RECORDOF(Crime_by_county_Norm),
                            SELF.EducationScore := LEFT.NormEducation;
                            SELF := RIGHT),
                            RIGHT OUTER);
OUTPUT(JoinEdu, NAMED('AddedEduScore'));
OUTPUT(COUNT(JoinEdu), NAMED('CountJoinEdu'));



// Add Poverty Score

PovertyRecs := RECORD
UNSIGNED3 FIPS_Code;
STRING50 County;
REAL8 NormPoverty;
END;


Poverty := DATASET('~AVI::OUT::POVNORM', PovertyRecs, FLAT);
OUTPUT(Poverty, NAMED('BuildPovTable'));

JoinPov := JOIN(Poverty, JoinEdu, 
                  LEFT.FIPS_Code = (UNSIGNED3) RIGHT.county_fips,
                  TRANSFORM(RECORDOF(JoinEdu),
                            SELF.PovertyScore := LEFT.NormPoverty;
                            SELF := RIGHT),
                            RIGHT OUTER);
OUTPUT(JoinPov, NAMED('AddedPovScore'));
OUTPUT(COUNT(JoinPov), NAMED('CountJoinPov'));


// Add Population Score

PopulationRecs := RECORD
UNSIGNED3 FIPS_Code;
STRING50 County;
REAL8 Population;
END;



Population := DATASET('~AVI::OUT::POP', PopulationRecs, FLAT);
OUTPUT(Population, NAMED('BuildPopTable'));

JoinPop := JOIN(Population, JoinPov, 
                  LEFT.FIPS_Code = (UNSIGNED3) RIGHT.county_fips,
                  TRANSFORM(RECORDOF(JoinPov),
                            SELF.PopulationScore := LEFT.Population;
                            SELF := RIGHT),
                            RIGHT OUTER);
OUTPUT(JoinPop, NAMED('AddedPopScore'));

// Calculate total score

// final_tbl_rec := RECORD
  // Joinpop;
  // REAL8 Total
 // END;
 
// final_tbl_rec calc_total(JoinPop le) := TRANSFORM
  // SELF := le;
  // SELF.Total := (le.educationscore + le.populationscore + le.normcrime + le.povertyscore)/4;
// END;

// Final_tbl := PROJECT(JoinPop, calc_total(LEFT));
// OUTPUT(Final_tbl, NAMED('FinalRiskTable'));

// OUTPUT(SORT(Final_tbl, -total));

final_tbl_rec := RECORD
  Joinpop;
  REAL8 Total
 END;
 
 
 
 crime_weight := 0.5;
 pov_weight := 0.3;
 edu_weight := 0.2;
final_tbl_rec calc_total(JoinPop le) := TRANSFORM
  SELF := le;
  SELF.Total := (edu_weight *le.educationscore) + (crime_weight * le.normcrime) + (pov_weight * le.povertyscore);
END;

Final_tbl := PROJECT(JoinPop, calc_total(LEFT));
OUTPUT(Final_tbl, NAMED('FinalRiskTable'));

OUTPUT(SORT(Final_tbl, -total));
                        
OUTPUT(Crime(crime_rate_per_100000 = '0'));


