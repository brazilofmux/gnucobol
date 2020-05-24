*>*****************************************************************
*> fielded_to_linear                                              *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*> All rights reserved.                                           *
*>                                                                *
*> This function returns a linear count of days with an Epoch of  *
*> 1601-JAN-01 by calling gregorian_to_linear which returns a     *
*> linear date with an Epoch of 1 R.D.                            *
*>                                                                *
*> The date is assumed valid (see isvaliddate).                   *
*>*****************************************************************
identification division.
program-id. fielded_to_linear.
data division.
linkage section.
01  year         pic s9(5) comp-5.
01  month        pic 99    comp-5.
01  dom          pic 99    comp-5.
01  linear       pic s9(8) comp-5.
procedure division using year month dom linear.
0100-main.
    call 'gregorian_to_linear' using year month dom linear.
    subtract 584389 from linear.
    goback.
end program fielded_to_linear.

*>*****************************************************************
*> gregorian_to_linear                                            *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*> All rights reserved.                                           *
*>                                                                *
*> The following date conversion routine takes a Gregorian        *
*> Calendar date and calculates a linear numbering of days from   *
*> the Epoch of 0001-JAN-01 R.D.                                  *
*>                                                                *
*> This is equivalent to fixed-from-gregorian(year, month, day)   *
*> from "Calendrical Calculations".                               *
*>                                                                *
*> The date is assumed valid (see isvaliddate).                   *
*>*****************************************************************
identification division.
program-id. gregorian_to_linear.
data division.
working-storage section.
*>*****************************************************************
*> floor-divmod, floor-div                                        *
*>*****************************************************************
01  fdm-x   pic s9(8) comp-5.
01  fdm-y   pic s9(8) comp-5.
01  fdm-div pic s9(8) comp-5.
01  fdm-mod pic s9(8) comp-5.

*>*****************************************************************
*> isleapyear                                                     *
*>*****************************************************************
01  ily-leap    pic x.
    88  ily-is-leap-year    value 'Y'.
    88  ily-not-leap-year   value 'N'.

01  gtl-year-less-1  pic s9(5) comp-5.
01  gtl-temp-days    pic 9999  comp-5.

linkage section.
01  gtl-year         pic s9(5) comp-5.
01  gtl-month        pic 99    comp-5.
01  gtl-day-of-month pic 99    comp-5.
01  gtl-linear       pic s9(8) comp-5.

procedure division using gtl-year gtl-month gtl-day-of-month
                         gtl-linear.
0100-main.
    subtract 1 from gtl-year giving gtl-year-less-1.
    multiply gtl-year-less-1 by 365 giving gtl-linear.

    move gtl-year-less-1 to fdm-x.
    move 4 to fdm-y.
    call 'floor-div' using fdm-x fdm-y fdm-div
    add fdm-div to gtl-linear.

    move 100 to fdm-y.
    call 'floor-div' using fdm-x fdm-y fdm-div.
    subtract fdm-div from gtl-linear.

    move 400 to fdm-y.
    call 'floor-div' using fdm-x fdm-y fdm-div.
    add fdm-div to gtl-linear.

    multiply 367 by gtl-month giving gtl-temp-days.
    subtract 362 from gtl-temp-days giving fdm-x.
    move 12 to fdm-y.
    call 'floor-div' using fdm-x fdm-y fdm-div.
    add fdm-div to gtl-linear.

    add gtl-day-of-month to gtl-linear.

    if gtl-month > 2
        call 'isleapyear' using gtl-year ily-leap
        if ily-is-leap-year
            subtract 1 from gtl-linear
        else
            subtract 2 from gtl-linear
        end-if
    end-if.
    goback.
end program gregorian_to_linear.
