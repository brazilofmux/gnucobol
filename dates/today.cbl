*>*****************************************************************
*> today - What is today's date?                                  *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*>                    and Stephen Dennis                          *
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>*****************************************************************
identification division.
program-id. today.

environment division.
configuration section.
repository.
    function fielded_to_linear
    function isvaliddate
    function linear_to_fielded
    function all intrinsic.

data division.

working-storage section.

01  output-line-1.
    05  ol1-year    pic +99999.
    05  filler      pic x       value '-'.
    05  ol1-month   pic 99.
    05  filler      pic x       value '-'.
    05  ol1-dom     pic 99.
    05  filler      pic x       value ' '.
    05  ol1-doy     pic 999.
    05  filler      pic x       value ' '.
    05  ol1-dow     pic 9.
    05  filler      pic x       value ' '.
    05  ol1-linear  pic +9(8).
    05  filler      pic x       value ' '.
    05  ol1-time.
        10  ol1-hours       pic 99.
        10  filler          pic x       value ':'.
        10  ol1-minutes     pic 99.
        10  filler          pic x       value ':'.
        10  ol1-seconds     pic 99.99.
    05  filler      pic x       value ' '.
    05  ol1-timezone.
        10  ol1-tz-sign     pic x.
        10  ol1-tz-hours    pic 99.
        10  filler          pic x       value ':'.
        10  ol1-tz-minutes  pic 99.

01  output-line-2.
    05  ol2-dayname    pic x(3).
    05  filler         pic x.
    05  ol2-monthname  pic x(3).
    05  filler         pic x.
    05  ol2-dayofmonth pic 9(2).
    05  filler         pic x.
    05  ol2-time.
        10  ol2-hours       pic 99.
        10  filler          pic x       value ':'.
        10  ol2-minutes     pic 99.
        10  filler          pic x       value ':'.
        10  ol2-seconds     pic 99.99.
    05  filler      pic x       value ' '.
    05  ol2-timezone.
        10  ol2-tz-sign     pic x.
        10  ol2-tz-hours    pic 99.
        10  filler          pic x       value ':'.
        10  ol2-tz-minutes  pic 99.
    05  filler      pic x       value ' '.
    05  ol2-year    pic +99999.

*>
*> size of this structure is 8 bytes.
*>
01  fielded-date.
    05  year        pic s9(5)   comp-5.
    05  month       pic 99      comp-5.
    05  dom         pic 99      comp-5.
    05  doy         pic 999     comp-5.
    05  dow         pic 9       comp-5.

*>
*> this size of this item is 4 bytes.
*>
01  linear-date     pic s9(8)   comp-5.

01  time-stamp.
    05  ts-date.
        10  ts-year         pic 9999.
        10  ts-month        pic 99.
        10  ts-dom          pic 99.
    05  ts-time.
        10  ts-hours        pic 99.
        10  ts-minutes      pic 99.
        10  ts-seconds      pic 99v99.
    05  ts-timezone.
        10  ts-tz-sign      pic x.
            88 tz-positive  value '+'.
            88 tz-negative  value '-'.
        10  ts-tz-hours     pic 99.
        10  ts-tz-minutes   pic 99.

01  ws-dayname-def.
    05  filler pic x(3) value 'Sun'.
    05  filler pic x(3) value 'Mon'.
    05  filler pic x(3) value 'Tue'.
    05  filler pic x(3) value 'Wed'.
    05  filler pic x(3) value 'Thu'.
    05  filler pic x(3) value 'Fri'.
    05  filler pic x(3) value 'Sat'.
01  ws-dayname-table redefines ws-dayname-def.
    05  ws-dayname pic x(3) occurs 7 times.
01  ws-dayname-index  pic 9 comp-5.

01  ws-monthname-def.
    05  filler pic x(3) value 'Jan'.
    05  filler pic x(3) value 'Feb'.
    05  filler pic x(3) value 'Mar'.
    05  filler pic x(3) value 'Apr'.
    05  filler pic x(3) value 'May'.
    05  filler pic x(3) value 'Jun'.
    05  filler pic x(3) value 'Jul'.
    05  filler pic x(3) value 'Aug'.
    05  filler pic x(3) value 'Sep'.
    05  filler pic x(3) value 'Oct'.
    05  filler pic x(3) value 'Nov'.
    05  filler pic x(3) value 'Dec'.
01  ws-monthname-table redefines ws-monthname-def.
    05  ws-monthname pic x(3) occurs 12 times.

procedure division.
0000-start-here.
    move function current-date to time-stamp.
    move ts-year  to year.
    move ts-month to month.
    move ts-dom   to dom.
    if isvaliddate(year, month, dom) = 'N'
        display time-stamp
        display year ' ' month ' ' dom ' *not valid*'
        go to 9000-end
    end-if.
    move fielded_to_linear(year, month, dom) to linear-date.
    move linear_to_fielded(linear-date) to fielded-date.

    move year to ol1-year.
    move month to ol1-month.
    move doy to ol1-doy.
    move dom to ol1-dom.
    move dow to ol1-dow.
    move linear-date to ol1-linear.
    move ts-hours to ol1-hours.
    move ts-minutes to ol1-minutes.
    move ts-seconds to ol1-seconds.
    move ts-tz-sign to ol1-tz-sign.
    move ts-tz-hours to ol1-tz-hours.
    move ts-tz-minutes to ol1-tz-minutes.
    display output-line-1.

    compute ws-dayname-index = dow + 1;
    move ws-dayname(ws-dayname-index) to ol2-dayname.
    move ws-monthname(month) to ol2-monthname.
    move dom to ol2-dayofmonth.
    move ts-hours to ol2-hours.
    move ts-minutes to ol2-minutes.
    move ts-seconds to ol2-seconds.
    move ts-tz-sign to ol2-tz-sign.
    move ts-tz-hours to ol2-tz-hours.
    move ts-tz-minutes to ol2-tz-minutes.
    move year to ol2-year.
    display output-line-2.

9000-end.
    goback.

end program today.
