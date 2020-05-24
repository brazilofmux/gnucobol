*>*****************************************************************
*> linear_to_fielded                                              *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*>                    and Stephen Dennis                          *
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>                                                                *
*> LINEAR_TO_GREGORIAN uses an Epoch of 1 R.D. We make an         *
*> adjustment now so that we may accept linear dates with an      *
*> Epoch of 1601-JAN-01.                                          *
*>*****************************************************************
identification division.
program-id. linear_to_fielded.
data division.
working-storage section.
01  linear1          pic s9(8) comp-5.

linkage section.
01  linear           pic s9(8) comp-5.
01  year             pic s9(5) comp-5.
01  month            pic 99    comp-5.
01  dom              pic 99    comp-5.
01  doy              pic 999   comp-5.
01  dow              pic 9     comp-5.
procedure division using linear year month dom doy dow.
0100-main.
    add 584389 to linear giving linear1.
    call 'linear_to_gregorian' using linear1 year month dom doy
                                     dow.
    goback.
end program linear_to_fielded.

*>*****************************************************************
*> linear_to_gregorian                                            *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*> All rights reserved.                                           *
*>                                                                *
*> The following date conversion routine takes a linear numbering *
*> of days from the Epoch of 1601 January 1st and calculates the  *
*> corresponding date in the Gregorian Calendar.                  *
*>                                                                *
*> This is equivalent to a combination of                         *
*> gregorian-year-from-fixed(fixed), gregorian-from-fixed(fixed), *
*> and day-number() from the book.                                *
*>                                                                *
*>*****************************************************************
identification division.
program-id. linear_to_gregorian.
data division.
working-storage section.
*>*****************************************************************
*> floor-divmod, floor-div                                        *
*>*****************************************************************
01  fdm-div pic s9(8) comp-5.
01  fdm-mod pic s9(8) comp-5.

*>*****************************************************************
*> isleapyear                                                     *
*>*****************************************************************
01  ily-leap    pic x.
    88  ily-is-leap-year    value 'Y'.
    88  ily-not-leap-year   value 'N'.

01  ltg-d0            pic s9(8) comp-5.
01  ltg-d1            pic s9(8) comp-5.
01  ltg-d2            pic s9(8) comp-5.
01  ltg-d3            pic s9(8) comp-5.
01  ltg-d4            pic s9(8) comp-5.
01  ltg-n1            pic s9(8) comp-5.
01  ltg-n4            pic s9(8) comp-5.
01  ltg-n100          pic s9(8) comp-5.
01  ltg-n400          pic s9(8) comp-5.
01  ltg-jan01         pic s9(8) comp-5.
01  ltg-mar01         pic s9(8) comp-5.
01  ltg-correction    pic 9     comp-5.
01  ltg-prior-days    pic s9(8) comp-5.
01  ltg-temp          pic s9(8) comp-5.
01  ltg-1st           pic s9(8) comp-5.
01  ltg-cache-year    pic s9(5) comp-5  value -27257.
01  ltg-cache-jan01   pic s9(8) comp-5.
01  ltg-cache-mar01   pic s9(8) comp-5.

01  c146097      pic s9(8) comp-5 value 146097.
01  c36524       pic s9(8) comp-5 value 36524.
01  c1461        pic s9(8) comp-5 value 1461.
01  c365         pic s9(8) comp-5 value 365.
01  c7           pic s9(8) comp-5 value 7.

linkage section.
01  ltg-linear        pic s9(8) comp-5.
01  ltg-year          pic s9(5) comp-5.
01  ltg-month         pic 99    comp-5.
01  ltg-day-of-month  pic 99    comp-5.
01  ltg-day-of-year   pic 999   comp-5.
01  ltg-day-of-week   pic 9     comp-5.

procedure division using ltg-linear ltg-year ltg-month
                         ltg-day-of-month ltg-day-of-year
                         ltg-day-of-week.
0100-main.
    subtract 1 from ltg-linear giving ltg-d0.
    call 'floor-divmod' using ltg-d0 c146097 ltg-n400 ltg-d1.
    call 'floor-divmod' using ltg-d1 c36524 ltg-n100 ltg-d2.
    call 'floor-divmod' using ltg-d2 c1461 ltg-n4 ltg-d3.
    call 'floor-divmod' using ltg-d3 c365 ltg-n1 ltg-d4.

    compute ltg-year = 400 * ltg-n400 + 100 * ltg-n100
                     + 4 * ltg-n4 + ltg-n1.

    if (ltg-n100 is not equal 4) and (ltg-n1 is not equal 4)
        add 1 to ltg-year
    end-if.

*> we need to find the linear day for {ltg-year, jan, 01} and
*> {ltg-year, mar, 01}. first, check the cache.

    move 1 to ltg-day-of-month.
    if ltg-year is equal to ltg-cache-year
        move ltg-cache-jan01 to ltg-jan01
        move ltg-cache-mar01 to ltg-mar01
    else
*>        january 1, ltg-year

        move 1 to ltg-month
        call 'gregorian_to_linear' using ltg-year ltg-month
             ltg-day-of-month ltg-jan01

*>        march 1, ltg-year

        move 3 to ltg-month
        call 'gregorian_to_linear' using ltg-year ltg-month
             ltg-day-of-month ltg-mar01

*>        update cache

        move ltg-year  to ltg-cache-year
        move ltg-jan01 to ltg-cache-jan01
        move ltg-mar01 to ltg-cache-mar01
    end-if.

    if (ltg-linear  < ltg-mar01)
        move 0 to ltg-correction
    else
        call 'isleapyear' using ltg-year ily-leap
        if ily-is-leap-year
            move 1 to ltg-correction
        else
            move 2 to ltg-correction
        end-if
    end-if.

    subtract ltg-jan01 from ltg-linear giving ltg-prior-days.
    add 1 to ltg-prior-days giving ltg-day-of-year.
    compute ltg-temp =
        (12 * (ltg-prior-days + ltg-correction) + 373) / 367.
    move ltg-temp to ltg-month.

    call 'gregorian_to_linear' using ltg-year ltg-month
         ltg-day-of-month ltg-1st.

    compute ltg-day-of-month = ltg-linear - ltg-1st + 1.

    call 'floor-divmod' using ltg-linear c7 fdm-div fdm-mod.
    move fdm-mod to ltg-day-of-week.
    goback.
end program linear_to_gregorian.
