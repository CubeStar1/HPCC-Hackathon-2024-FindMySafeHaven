#OPTION('obfuscateOutput', TRUE);
IMPORT $;
CityDS := $.File_AllData.City_DS;
Population := $.File_AllData.pop_estimatesDS;

Pop_by_county := Population(attribute = 'POP_ESTIMATE_2020')[2..];


OUTPUT(Pop_by_county, NAMED('Pop_by_county'));


// ZSCORE(DATASET(T) ds, T val) := FUNCTION
  // Calculate the mean
  // mean := AVE(ds);

  // Calculate the standard deviation
  // stddev := SQRT(VARIANCE(ds));

  // Calculate the Z score
  // zscore := (val - mean) / stddev;

  // RETURN zscore;
// END;



// Calculate the mean and standard deviation of the dataset
total_cnt := COUNT(Pop_by_county);
mean := AVE(Pop_by_county, Pop_by_county.value);
stddev := SQRT(VARIANCE(Pop_by_county, Pop_by_county.value));


OUTPUT(total_cnt, NAMED('Total_counties'));
OUTPUT(mean, NAMED('Mean_pop_by_county'));
OUTPUT(stddev, NAMED('Stddev_pop_by_county'));


a1 := 0.319381530; 
a2 := -0.356563782; 
a3 := 1.781477937;
a4 := -1.821255978; 
a5 := 1.330274429;


pop_by_county_z_rec := RECORD
  Pop_by_county;
  REAL percentile;
END;

pop_by_county_z_rec add_percentile(Pop_by_county le) := TRANSFORM
  SELF := le;
  REAL z := (le.value - mean) / stddev;
  // Abramowitz and Stegun approximation for the CDF of the standard normal distribution
  REAL t := 1 / (1 + 0.2316419 * ABS(z));
  //REAL a1 := 0.319381530, a2 := -0.356563782, a3 := 1.781477937, a4 := -1.821255978, a5 := 1.330274429;
  REAL cdf_approx := 1 - (a1*t + a2*POWER(t,2) + a3*POWER(t,3) + a4*POWER(t,4) + a5*POWER(t,5)) * EXP(-0.5 * POWER(z, 2));
  SELF.percentile := IF(z < 0, 1 - cdf_approx, cdf_approx);
END;

pop_by_county_zscore := PROJECT(pop_by_county, add_percentile(LEFT));


// Define a transform that adds a Z score field to each record
// pop_by_county_z_rec := RECORD
  // Pop_by_county;
  // REAL zscore;
// END;

// pop_by_county_z_rec add_zscore(Pop_by_county le) := TRANSFORM
  // SELF := le;
  // SELF.zscore :=  ((le.value - mean) / stddev) *100;
// END;

// Use the transform to add a Z score field to each record in the dataset
// pop_by_county_zscore := PROJECT(pop_by_county, add_zscore(LEFT));

OUTPUT(pop_by_county_zscore, NAMED('Population_Z_Scores'));




