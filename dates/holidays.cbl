*>*****************************************************************
*> newyear                                                        *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*>                    and Stephen Dennis                          *
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>                                                                *
*> Returns the linear date for the first day of the given year.   *
*>                                                                *
*>*****************************************************************
identification division.
program-id. newyear.

data division.
working-storage section.
01  isvalid               usage   signed-int.
    88  notvalid value 0.

01  month           pic 99      comp-5 value 1.
01  dom             pic 99      comp-5 value 1.

linkage section.
*>  Input
*>
*>  The valid range of year is -27256 to 30826, inclusively.
*>
01  ny-year              pic s9(5)   comp-5.

*>  Output
*>
*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ny-lineardate        pic s9(8)   comp-5.

*>  Success/Failure
*>
01  ny-bool              pic x.
    88  is-valid       value 'Y'.
    88  is-not-valid   value 'N'.

procedure division using ny-year ny-lineardate ny-bool.
0100-main.
    move 'N' to ny-bool.
    if (-27256 <= ny-year) and (ny-year <= 30826)
        call 'fielded_to_linear' using ny-year month dom ny-lineardate
        move 'Y' to ny-bool
    end-if.
    goback.
end program newyear.

*>*****************************************************************
*> yearend                                                        *
*> Copyright (C) 2020 Stephen Vincent Dennis                      *
*> All rights reserved.                                           *
*>                                                                *
*> Returns the linear date for the first day of the given year.   *
*>                                                                *
*>*****************************************************************
identification division.
program-id. yearend.

data division.
working-storage section.
01  isvalid               usage   signed-int.
    88  notvalid value 0.

01  month           pic 99      comp-5 value 12.
01  dom             pic 99      comp-5 value 31.

linkage section.
*>  Input
*>
*>  The valid range of year is -27256 to 30826, inclusively.
*>
01  ye-year              pic s9(5)   comp-5.

*>  Output
*>
*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ye-lineardate        pic s9(8)   comp-5.

*>  Success/Failure
*>
01  ye-bool              pic x.
    88  is_valid       value 'Y'.
    88  is_not_valid   value 'N'.

procedure division using ye-year ye-lineardate ye-bool.
0100-main.
    move 'N' to ye-bool.
    if (-27256 <= ye-year) and (ye-year <= 30826)
        call 'fielded_to_linear' using ye-year month dom ye-lineardate
        move 'Y' to ye-bool
    end-if.
    goback.
end program yearend.

*>*****************************************************************
*> dayofweek                                                      *
*> Copyright (C) 2020 Stephen Vincent Dennis                      *
*> All rights reserved.                                           *
*>                                                                *
*> Returns the day of week for the given fixed date.              *
*>                                                                *
*>*****************************************************************
identification division.
program-id. dayofweek.

data division.
working-storage section.
01  isvalid               usage   signed-int.
    88  notvalid value 0.

01  ld2                    signed-int.
01  c7           pic s9(8) comp-5 value 7.
01  n            pic s9(8) comp-5.
01  d            pic s9(8) comp-5.

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
    add 1 to ld giving ld2.
    call 'floor-divmod' using ld2 c7 n d.
    move d to dayofweek.
    move 'Y' to bool
    goback.
end program dayofweek.

*>*****************************************************************
*> kdayonorbefore                                                 *
*> Copyright (C) 2020 Stephen Vincent Dennis                      *
*> All rights reserved.                                           *
*>                                                                *
*> Returns a requested day of the week where the week ends on a   *
*> certain date.                                                  *
*>                                                                *
*>*****************************************************************
identification division.
program-id. kdayonorbefore.

data division.
working-storage section.
01  isvalid               usage   signed-int.
    88  notvalid value 0.

01  ld2-max                signed-int.
01  c7           pic s9(8) comp-5 value 7.
01  n            pic s9(8) comp-5.
01  d            pic s9(8) comp-5.

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
*>  ld = ld-max - mod(ld-max - k + 1, 7);
*>
    compute ld2-max = ld-max - k + 1.
    call 'floor-divmod' using ld2-max c7 n d.
    subtract d from ld-max giving ld.
    move 'Y' to bool.
    goback.
end program kdayonorbefore.
