*>*****************************************************************
*> isvaliddate                                                    *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*>                    and Stephen Dennis                          *
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>                                                                *
*> The following code determines whether a given date is a valid  *
*> one or not. This test guarantees that the given date will be   *
*> convertible to a 'linear' day number without the overhead of   *
*> actually calculating it.                                       *
*>*****************************************************************
identification division.
function-id. isvaliddate.
environment division.
configuration section.
repository.
    function isleapyear
    function all intrinsic.
data division.
working-storage section.
01  ivd-days-in-month-values.
    05  filler          pic 99 comp-5 value 31.
    05  filler          pic 99 comp-5 value 29.
    05  filler          pic 99 comp-5 value 31.
    05  filler          pic 99 comp-5 value 30.
    05  filler          pic 99 comp-5 value 31.
    05  filler          pic 99 comp-5 value 30.
    05  filler          pic 99 comp-5 value 31.
    05  filler          pic 99 comp-5 value 31.
    05  filler          pic 99 comp-5 value 30.
    05  filler          pic 99 comp-5 value 31.
    05  filler          pic 99 comp-5 value 30.
    05  filler          pic 99 comp-5 value 31.
01  ivd-days-in-month-table redefines ivd-days-in-month-values.
    05  ivd-days-in-month   occurs 12 times pic 99 comp-5.

linkage section.
01  ivd-year            pic s9(5) comp-5.
01  ivd-month           pic 99    comp-5.
01  ivd-day-of-month    pic 99    comp-5.
01  ivd-valid           pic x.
    88  ivd-is-valid-date       value 'Y'.
    88  ivd-is-not-valid-date   value 'N'.

procedure division using ivd-year ivd-month ivd-day-of-month returning ivd-valid.
0100-main.
    move 'N' to ivd-valid.
    if (   -27256 <= ivd-year) and (ivd-year <= 30826)
       and (1 <= ivd-month) and (ivd-month <= 12)
       and (1 <= ivd-day-of-month)
       and (ivd-day-of-month <= ivd-days-in-month(ivd-month))

        if (ivd-month not equal 2) or (ivd-day-of-month not equal 29) or (isleapyear(ivd-year) = 'Y')
            move 'Y' to ivd-valid
        end-if
    end-if.
    goback.
end function isvaliddate.
