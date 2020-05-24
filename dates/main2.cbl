*>*****************************************************************
*> main2 - Driver for date routines.                              *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*>                    and Stephen Dennis                          *
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>*****************************************************************
identification division.
program-id. main2.

environment division.
configuration section.
repository.
    function c_dayofweek
    function c_fieldedtolinear
    function c_isvaliddate
    function c_lineartofielded
    function c_newyear
    function c_yearend
    function all intrinsic.

input-output section.
file-control.

    select output-file assign to 'dates2.txt'
        organization is line sequential
        access is sequential.

data division.

file section.
fd  output-file
    block contains 50 records.

01  output-record.
    05  or-year     pic +99999.
    05  filler      pic x.
    05  or-month    pic 99.
    05  filler      pic x.
    05  or-dom      pic 99.
    05  filler      pic x.
    05  or-doy      pic 999.
    05  filler      pic x.
    05  or-dow      pic 9.
    05  filler      pic x.
    05  or-linear   pic +9(8).

working-storage section.

01  working-record.
    05  wr-year     pic +99999.
    05  filler      pic x       value '-'.
    05  wr-month    pic 99.
    05  filler      pic x       value '-'.
    05  wr-dom      pic 99.
    05  filler      pic x       value ' '.
    05  wr-doy      pic 999.
    05  filler      pic x       value ' '.
    05  wr-dow      pic 9.
    05  filler      pic x       value ' '.
    05  wr-linear   pic +9(8).

01  ltf-result.
    05  fieldeddate.
        10 year         sync usage   signed-short.
        10 month        sync usage unsigned-short.
        10 dow          sync usage unsigned-short.
        10 dom          sync usage unsigned-short.
        10 doy          sync usage unsigned-short.

    05  ltf-success     pic x.

01  ftl-result.
    05  ftl-ld          signed-int.
    05  ftl-success     pic x.

01  dow-result.
    05  dow2            unsigned-short.
    05  dow-success     pic x.

01  ye-result.
    05  ld-yearend      signed-int.
    05  ye-success      pic x.

01  ny-result.
    05  ld-newyear      signed-int.
    05  ny-success      pic x.

01  ld              usage   signed-int.
01  cld             usage   signed-int.
01  ld_today        usage   signed-int.
01  cld_today       usage   signed-int.
01  ld_lower        usage   signed-int.
01  ld_upper        usage   signed-int.

01  time-stamp.
    05  ts-date.
        10  ts-year         pic 9999.
        10  ts-month        pic 99.
        10  ts-dom          pic 99.
    05  ts-date-3 redefines ts-date pic 9(8).
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

01  ts-date-2.
    05  ts-year-2         pic 9999.
    05  ts-month-2        pic 99.
    05  ts-dom-2          pic 99.

01  julian_date.
    05  jd_year           pic 9999.
    05  jd_doy            pic 999.

procedure division.
0000-start-here.
    open output output-file.
    move function current-date to time-stamp.
    move ts-year  to year.
    move ts-month to month.
    move ts-dom   to dom.
    if c_isvaliddate(year, month, dom) = 0
        display time-stamp
        display year ' ' month ' ' dom ' *not valid*'
        go to 9000-end
    end-if.
    move c_fieldedtolinear(fieldeddate) to ftl-result.
    if ftl-success = 'N'
        display year ' ' month ' ' dom ' ' '*not valid*'
        go to 9000-end
    end-if.
    move ftl-ld to ld_today.

    move function integer-of-date(ts-date-3) to cld_today.

    if ld_today <> cld_today - 1
        display 'Does not agree with function integer-of-date'
        display ld_today
        display ts-date-3
        display cld_today
    end-if.

    move function day-of-integer(cld_today) to julian_date.
    if jd_doy <> doy
        display 'Does not agree with function day-of-integer'
        display ld_today
        display ts-date-3
        display cld_today
        display jd_doy
        display doy
    end-if.

    subtract 200000 from ld_today giving ld_lower.
    add 200000 to ld_today giving ld_upper.

    perform varying ld from ld_lower by 1 until ld > ld_upper

        move c_lineartofielded(ld) to ltf-result
        if ltf-success = 'N'
            display ld ' *not valid*'
            go to 9000-end
        end-if

        move year to wr-year
        move month to wr-month
        move doy to wr-doy
        move dom to wr-dom
        move dow to wr-dow
        move ld to wr-linear
        write output-record from working-record

        if 0 < ld
            add 1 to ld giving cld
            move function date-of-integer(cld) to ts-date-2
            move year to ts-year
            move month to ts-month
            move dom to ts-dom
            if ts-year-2 <> ts-year or ts-month-2 <> ts-month or ts-dom-2 <> ts-dom
                display 'Does not agree with function date-of-integer'
                display cld
                display ts-date-2
                display ts-date
            end-if

            move function day-of-integer(cld) to julian_date
            if jd_doy <> doy
                display 'Does not agree with function day-of-integer'
                display ld_today
                display ts-date-3
                display cld_today
                display jd_doy
                display doy
            end-if
        end-if

        move c_dayofweek(ld) to dow-result
        if dow-success = 'N'
            display 'Day of week: ', ld, dow2, ' *not valid*'
            go to 9000-end
        end-if
        if dow not equal dow2
            display 'Day of week: ', ld, ' ', dow, ' ', dow2, ' does not agree'
            go to 9000-end
        end-if

        if month = 1 and dom = 1
            move c_newyear(year) to ny-result
            if ny-success = 'N'
                display year ' *not valid*'
                go to 9000-end
            end-if
            if ld-newyear not equal ld
                display 'New year: ', year, ' does not agree with ', ld-newyear
                go to 9000-end
            end-if
        end-if

        if month = 12 and dom = 31
            move c_yearend(year) to ye-result
            if ye-success = 'N'
                display year ' *not valid*'
                go to 9000-end
            end-if
            if ld-yearend not equal ld
                display 'Year end: ', year, ' does not agree with ', ld-yearend
                go to 9000-end
            end-if
        end-if

    end-perform.

9000-end.
    close output-file.
    goback.

end program main2.
