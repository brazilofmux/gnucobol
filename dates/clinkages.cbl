*>*****************************************************************
*> c_isvaliddate                                                  *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*> All rights reserved.                                           *
*>*****************************************************************
identification division.
program-id. c_isvaliddate.
data division.
working-storage section.
01  ft_year            usage   signed-short.
01  ft_month           usage unsigned-short.
01  ft_day             usage unsigned-short.
01  isvalid            usage   signed-int.
    88  notvalid value 0.

linkage section.
01  ivd_year            usage   signed-short.
01  ivd_month           usage unsigned-short.
01  ivd_day_of_month    usage unsigned-short.
01  ivd_valid           pic x.
    88  ivd_is_valid_date       value 'Y'.
    88  ivd_is_not_valid_date   value 'N'.

procedure division using ivd_year ivd_month ivd_day_of_month ivd_valid.
0100-main.
    move ivd_year to ft_year.
    move ivd_month to ft_month.
    move ivd_day_of_month to ft_day.
    call 'du_isvaliddate' using by value ft_year by value ft_month by value ft_day returning isvalid.
    if notvalid
        move 'N' to ivd_valid
    else
        move 'Y' to ivd_valid
    end-if.
    goback.
end program c_isvaliddate.

*>*****************************************************************
*> c_fieldedtolinear                                              *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*> All rights reserved.                                           *
*>                                                                *
*> This function returns a linear count of days with an epoch of  *
*> 1601-JAN-01                                                    *
*>*****************************************************************
identification division.
program-id. c_fieldedtolinear.

data division.
working-storage section.
01  isvalid               usage   signed-int.
    88  notvalid value 0.

linkage section.
*>  Inputs
*>
*>  The valid range of ltf_year is -27256 to 30826, inclusively.  Every month
*>  and day within those years is supported.
*>
*>  Day of Week and Day of Year are changed based on the given Year, Month, and Day.
*>
01  ftl_fieldeddate.
    05 year       sync usage   signed-short.
    05 month      sync usage unsigned-short.
    05 dayofweek  sync usage unsigned-short.
    05 dayofmonth sync usage unsigned-short.
    05 dayofyear  sync usage unsigned-short.

*>  Output
*>
*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ftl_lineardate       usage   signed-int.

*>  Success/Failure
*>
01  ftl_bool             pic x.
    88  is_valid       value 'Y'.
    88  is_not_valid   value 'N'.

procedure division using ftl_fieldeddate ftl_lineardate ftl_bool.
0100-main.

*>  FieldedToLinear also fills in the day of week and day of year, but we don't use it.
*>
    call 'du_fieldedtolinear' using by reference ftl_fieldeddate by reference ftl_lineardate returning isvalid.
    if not notvalid
        move 'Y' to ftl_bool
    else
        move 'N' to ftl_bool
    end-if
    goback.
end program c_fieldedtolinear.

*>*****************************************************************
*> c_lineartofielded                                              *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*> All rights reserved.                                           *
*>                                                                *
*> This function takes a linear count of days with an epoch of    *
*> 1601-JAN-01                                                    *
*>*****************************************************************
identification division.
program-id. c_lineartofielded.

data division.
working-storage section.
01  isvalid               usage   signed-int.
    88  notvalid value 0.

linkage section.
*>  Input
*>
*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ltf_lineardate       usage   signed-int.

*>  Outputs
*>
*>  The valid range of year is -27256 to 30826, inclusively.  Every month
*>  and day within those years is supported.
*>
01  ltf_fieldeddate.
    05 year       sync usage   signed-short.
    05 month      sync usage unsigned-short.
    05 dayofweek  sync usage unsigned-short.
    05 dayofmonth sync usage unsigned-short.
    05 dayofyear  sync usage unsigned-short.

*>  Success/Failure
*>
01  ltf_bool             pic x.
    88  is_valid       value 'Y'.
    88  is_not_valid   value 'N'.

procedure division using ltf_lineardate ltf_fieldeddate ltf_bool.
0100-main.
    call 'du_lineartofielded' using by value ltf_lineardate by reference ltf_fieldeddate returning isvalid.
    if not notvalid
        move 'Y' to ltf_bool
    else
        move 'N' to ltf_bool
    end-if.
    goback.
end program c_lineartofielded.

*>*****************************************************************
*> c_newyear                                                      *
*> Copyright (C) 2020 Stephen Vincent Dennis                      *
*> All rights reserved.                                           *
*>                                                                *
*> Returns the linear date for the first day of the given year.   *
*>                                                                *
*>*****************************************************************
identification division.
program-id. c_newyear.

data division.
working-storage section.
01  isvalid               usage   signed-int.
    88  notvalid value 0.

linkage section.
*>  Input
*>
*>  The valid range of year is -27256 to 30826, inclusively.
*>
01  ny_year             usage   signed-short.

*>  Output
*>
*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ny_lineardate       usage   signed-int.

*>  Success/Failure
*>
01  ny_bool              pic x.
    88  is_valid       value 'Y'.
    88  is_not_valid   value 'N'.

procedure division using ny_year ny_lineardate ny_bool.
0100-main.
    call 'du_newyear' using by value ny_year by reference ny_lineardate returning isvalid.
    if not notvalid
        move 'Y' to ny_bool
    else
        move 'N' to ny_bool
    end-if.
    goback.
end program c_newyear.

*>*****************************************************************
*> c_yearend                                                      *
*> Copyright (C) 2020 Stephen Vincent Dennis                      *
*> All rights reserved.                                           *
*>                                                                *
*> Returns the linear date for the first day of the given year.   *
*>                                                                *
*>*****************************************************************
identification division.
program-id. c_yearend.

data division.
working-storage section.
01  isvalid               usage   signed-int.
    88  notvalid value 0.

linkage section.
*>  Input
*>
*>  The valid range of year is -27256 to 30826, inclusively.
*>
01  ye_year             usage   signed-short.

*>  Output
*>
*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ye_lineardate       usage   signed-int.

*>  Success/Failure
*>
01  ye_bool              pic x.
    88  is_valid       value 'Y'.
    88  is_not_valid   value 'N'.

procedure division using ye_year ye_lineardate ye_bool.
0100-main.
    call 'du_yearend' using by value ye_year by reference ye_lineardate returning isvalid.
    if not notvalid
        move 'Y' to ye_bool
    else
        move 'N' to ye_bool
    end-if.
    goback.
end program c_yearend.

*>*****************************************************************
*> c_dayofweek                                                    *
*> Copyright (C) 2020 Stephen Vincent Dennis                      *
*> All rights reserved.                                           *
*>                                                                *
*> Returns the day of week for the given fixed date.              *
*>                                                                *
*>*****************************************************************
identification division.
program-id. c_dayofweek.

data division.
working-storage section.
01  isvalid               usage   signed-int.
    88  notvalid value 0.

linkage section.
*>  Input
*>
*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ld                  usage   signed-int.

*>  Output
*>
*>  The valid range is 0 (Sunday) to 6 (Saturday), inclusively.
*>
01  dayofweek           usage   unsigned-short.

*>  Success/Failure
*>
01  bool              pic x.
    88  is_valid       value 'Y'.
    88  is_not_valid   value 'N'.

procedure division using ld dayofweek bool.
0100-main.
    call 'du_dayofweek' using by value ld by reference dayofweek returning isvalid.
    if not notvalid
        move 'Y' to bool
    else
        move 'N' to bool
    end-if.
    goback.
end program c_dayofweek.

*>*****************************************************************
*> c_kdayonorbefore                                               *
*> Copyright (C) 2020 Stephen Vincent Dennis                      *
*> All rights reserved.                                           *
*>                                                                *
*> Returns a requested day of the week where the week ends on a   *
*> certain date.                                                  *
*>                                                                *
*>*****************************************************************
identification division.
program-id. c_kdayonorbefore.

data division.
working-storage section.
01  isvalid               usage   signed-int.
    88  notvalid value 0.

linkage section.
*>  Input
*>
*>  The valid range is 0 (Sunday) to 6 (Saturday), inclusively.
*>
01  k                   usage   unsigned-short.

*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ld-max              usage   signed-int.

*>  Output
*>
*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ld                  usage   signed-int.

*>  Success/Failure
*>
01  bool              pic x.
    88  is_valid       value 'Y'.
    88  is_not_valid   value 'N'.

procedure division using k ld-max ld bool.
0100-main.
    call 'du_kdayonorbefore' using by value k ld-max by reference ld returning isvalid.
    if not notvalid
        move 'Y' to bool
    else
        move 'N' to bool
    end-if.
    goback.
end program c_kdayonorbefore.
