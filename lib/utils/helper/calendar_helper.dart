import 'dart:math';

class CalendarHelper {
  List<int> convertSolar2Lunar(int dd, int mm, int yy, {int timeZone = 7}) {
    int dayNumber = _jdFromDate(dd, mm, yy);
    int k = _mathFloor((dayNumber - 2415021.076998695) / 29.530588853);
    int monthStart = _getNewMoonDay(k + 1, timeZone);
    if (monthStart > dayNumber) {
      monthStart = _getNewMoonDay(k, timeZone);
    }
    int a11 = _getLunarMonth11(yy, timeZone);
    int b11 = a11;
    int lunarYear;
    if (a11 >= monthStart) {
      lunarYear = yy;
      a11 = _getLunarMonth11(yy - 1, timeZone);
    } else {
      lunarYear = yy + 1;
      b11 = _getLunarMonth11(yy + 1, timeZone);
    }
    int lunarDay = dayNumber - monthStart + 1;
    int diff = _mathFloor((monthStart - a11) / 29);
    int lunarLeap = 0;
    int lunarMonth = diff + 11;
    if (b11 - a11 > 365) {
      int leapMonthDiff = _getLeapMonthOffset(a11, timeZone);
      if (diff >= leapMonthDiff) {
        lunarMonth = diff + 10;
        if (diff == leapMonthDiff) {
          lunarLeap = 1;
        }
      }
    }
    if (lunarMonth > 12) {
      lunarMonth = lunarMonth - 12;
    }
    if (lunarMonth >= 11 && diff < 4) {
      lunarYear -= 1;
    }
    return [lunarDay, lunarMonth, lunarYear];
  }

  int _mathFloor(double d) {
    return d.floor();
  }

  int _jdFromDate(int dd, int mm, int yy) {
    int a = _mathFloor((14 - mm) / 12);
    int y = yy + 4800 - a;
    int m = mm + 12 * a - 3;
    int jd = dd +
        _mathFloor((153 * m + 2) / 5) +
        365 * y +
        _mathFloor(y / 4) -
        _mathFloor(y / 100) +
        _mathFloor(y / 400) -
        32045;
    if (jd < 2299161) {
      jd = dd + _mathFloor((153 * m + 2) / 5) + 365 * y + _mathFloor(y / 4) - 32083;
    }
    return jd;
  }

  int _getNewMoonDay(int k, int timeZone) {
    double T = k / 1236.85; // Time in Julian centuries from 1900 January 0.5
    double T2 = T * T;
    double T3 = T2 * T;
    double dr = pi / 180;
    double Jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3;
    Jd1 = Jd1 + 0.00033 * sin((166.56 + 132.87 * T - 0.009173 * T2) * dr); // Mean new moon
    double M = 359.2242 + 29.10535608 * k - 0.0000333 * T2 - 0.00000347 * T3; // Sun's mean anomaly
    double Mpr = 306.0253 + 385.81691806 * k + 0.0107306 * T2 + 0.00001236 * T3; // Moon's mean anomaly
    double F = 21.2964 + 390.67050646 * k - 0.0016528 * T2 - 0.00000239 * T3; // Moon's argument of latitude
    double C1 = (0.1734 - 0.000393 * T) * sin(M * dr) + 0.0021 * sin(2 * dr * M);
    C1 = C1 - 0.4068 * sin(Mpr * dr) + 0.0161 * sin(dr * 2 * Mpr);
    C1 = C1 - 0.0004 * sin(dr * 3 * Mpr);
    C1 = C1 + 0.0104 * sin(dr * 2 * F) - 0.0051 * sin(dr * (M + Mpr));
    C1 = C1 - 0.0074 * sin(dr * (M - Mpr)) + 0.0004 * sin(dr * (2 * F + M));
    C1 = C1 - 0.0004 * sin(dr * (2 * F - M)) - 0.0006 * sin(dr * (2 * F + Mpr));
    C1 = C1 + 0.0010 * sin(dr * (2 * F - Mpr)) + 0.0005 * sin(dr * (2 * Mpr + M));
    double deltat = 0;
    if (T < -11) {
      deltat = 0.001 + 0.000839 * T + 0.0002261 * T2 - 0.00000845 * T3 - 0.000000081 * T * T3;
    } else {
      deltat = -0.000278 + 0.000265 * T + 0.000262 * T2;
    }
    ;
    double JdNew = Jd1 + C1 - deltat;
    return _mathFloor(JdNew + 0.5 + (timeZone / 24));
  }

  int _getSunLongitude(int jdn, int timeZone) {
    double T = (jdn - 2451545.5 - timeZone / 24) / 36525; // Time in Julian centuries from 2000-01-01 12:00:00 GMT
    double T2 = T * T;
    double dr = pi / 180; // degree to radian
    double M = 357.52910 + 35999.05030 * T - 0.0001559 * T2 - 0.00000048 * T * T2; // mean anomaly, degree
    double L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2; // mean longitude, degree
    double DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * sin(dr * M);
    DL = DL + (0.019993 - 0.000101 * T) * sin(dr * 2 * M) + 0.000290 * sin(dr * 3 * M);
    double L = L0 + DL; // true longitude, degree
    // obtain apparent longitude by correcting for nutation and aberration
    double omega = 125.04 - 1934.136 * T;
    L = L - 0.00569 - 0.00478 * sin(omega * dr);
    L = L * dr;
    L = L - pi * 2 * (_mathFloor(L / (pi * 2))); // Normalize to (0, 2*PI)
    return _mathFloor(L / pi * 6);
  }

  int _getLunarMonth11(int yy, int timeZone) {
    int off = _jdFromDate(31, 12, yy) - 2415021;
    int k = _mathFloor(off / 29.530588853);
    int nm = _getNewMoonDay(k, timeZone);
    int sunLong = _getSunLongitude(nm, timeZone); // sun longitude at local midnight
    if (sunLong >= 9) {
      nm = _getNewMoonDay(k - 1, timeZone);
    }
    return nm;
  }

  int _getLeapMonthOffset(int a11, int timeZone) {
    int k = _mathFloor((a11 - 2415021.076998695) / 29.530588853 + 0.5);
    int last = 0;
    int i = 1; // We start with the month following lunar month 11
    int arc = _getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone);
    do {
      last = arc;
      i = i + 1;
      arc = _getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone);
    } while (arc != last && i < 14);
    return i - 1;
  }
}
