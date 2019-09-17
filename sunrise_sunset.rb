#1. first calculate the day of the year

def day_of_year(day, month, year)
  n1 = (275 * month / 9).floor
  n2 = ((month + 9) / 12).floor
  n3 = (1 + ((year - 4 * (year / 4).floor + 2) / 3).floor)
  n = n1 - (n2 * n3) + day - 30
  return n
end

def rising_or_setting_time(day, month, year, latitude, longitude, is_rising)

  #2. convert the longitude to hour value and calculate an approximate time

  lngHour = longitude / 15

  if is_rising
    approximate_time = day_of_year(day, month, year) + ((6 - lngHour) / 24)
  else # implicitly is_setting thus we are calculating the setting time instead
    approximate_time = day_of_year(day, month, year) + ((18 - lngHour) / 24)
  end

  #3. calculate the Sun's mean anomaly
  sun_mean_anomaly = (0.9856 * approximate_time) - 3.289

  #4. calculate the Sun's true longitude

  sun_true_longitude = sun_mean_anomaly + (1.916 * Math.sin(sun_mean_anomaly)) + (0.020 * Math.sin(2 * sun_mean_anomaly)) + 282.634

  #NOTE: sun_true_longitude potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
  sun_true_longitude = sun_true_longitude % 360

  #5a. calculate the Sun's right ascension

  sun_right_ascension = Math.atan(0.91764 * Math.tan(sun_true_longitude))

  #NOTE: sun_right_ascension potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
  sun_right_ascension = sun_right_ascension % 360

  #5b. right ascension value needs to be in the same quadrant as L

  l_quadrant  = ((sun_true_longitude/90).floor) * 90
  ra_quadrant = ((sun_right_ascension/90).floor) * 90
  sun_right_ascension = sun_right_ascension + (l_quadrant - ra_quadrant)

  #5c. right ascension value needs to be converted into hours

  sun_right_ascension = sun_right_ascension / 15

  #6. calculate the Sun's declination

  sinDec = 0.39782 * Math.sin(sun_true_longitude)
  cosDec = Math.cos(Math.asin(sinDec))

  #7a. calculate the Sun's local hour angle

  zenith = 90.8333 # "official" zenith
  cosH = (Math.cos(zenith) - (sinDec * Math.sin(latitude))) / (cosDec * Math.cos(latitude))

  if (cosH > 1) 
    # the sun never rises on this location (on the specified date)
    return nil
  end

  if (cosH < -1)
    # the sun never sets on this location (on the specified date)
    return nil
  end

  #7b. finish calculating H and convert into hours

  if is_rising
    sun_local_hour_angle = 360 - Math.acos(cosH)
  else
    sun_local_hour_angle = Math.acos(cosH)
  end

  sun_local_hour_angle = sun_local_hour_angle / 15

  #8. calculate local mean time of rising/setting

  local_mean_time_of_rising_or_setting = sun_local_hour_angle + sun_right_ascension - (0.06571 * approximate_time) - 6.622

  #9. adjust back to UTC

  utc_mean_time_of_rising_or_setting = local_mean_time_of_rising_or_setting - lngHour
  #NOTE: UT potentially needs to be adjusted into the range [0,24) by adding/subtracting 24

  #10. convert UT value to local time zone of latitude/longitude

  return utc_mean_time_of_rising_or_setting + localOffset
end

puts rising_or_setting_time(17, 9, 2019, 39.9603, -83.0093, false)
