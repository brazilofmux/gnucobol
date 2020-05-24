/*! \file dateutil.c
 * \brief Date-related helper functions.
 *
 * $Id$
 *
 * Date code based on algorithms presented in "Calendrical Calculations",
 * Cambridge Press, 1998.
 *
 */

#include <stdio.h>
#include <stdbool.h>
#include <limits.h>
#include <memory.h>
#include "dateutil.h"

// The following functions provide a consistent division/modulus function
// regardless of how the platform chooses to provide this function.
//
// Confused yet? Here's an example:
//
// SMALLEST_INT_GTE_NEG_QUOTIENT indicates that this platform computes
// division and modulus like so:
//
//   -9/5 ==> -1 and -9%5 ==> -4
//   and (-9/5)*5 + (-9%5) ==> -1*5 + -4 ==> -5 + -4 ==> -9
//
// The iMod() function uses this to provide LARGEST_INT_LTE_NEG_QUOTIENT
// behavior (required by much math). This behavior computes division and
// modulus like so:
//
//   -9/5 ==> -2 and -9%5 ==> 1
//   and (-9/5)*5 + (-9%5) ==> -2*5 + 1 ==> -10 + 1 ==> -9
//

// Provide LLEQ modulus on a SGEQ platform.
//
static int iMod(int x, int y)
{
    if (y < 0)
    {
        if (x <= 0)
        {
            if (INT_MIN == x && -1 == y)
            {
                return 0;
            }
            return x % y;
        }
        else
        {
            return ((x-1) % y) + y + 1;
        }
    }
    else
    {
        if (x < 0)
        {
            return ((x+1) % y) + y - 1;
        }
        else
        {
            return x % y;
        }
    }
}

// Provide LLEQ division on a SGEQ platform.
//
static int iFloorDivision(int x, int y)
{
    if (y < 0)
    {
        if (x <= 0)
        {
            return x / y;
        }
        else
        {
            return (x - y - 1) / y;
        }
    }
    else
    {
        if (x < 0)
        {
            return (x - y + 1) / y;
        }
        else
        {
            return x / y;
        }
    }
}

static int iFloorDivisionMod(int x, int y, int *piMod)
{
    if (y < 0)
    {
        if (x <= 0)
        {
            if (INT_MIN == x && -1 == y)
            {
                *piMod = 0;
            }
            else
            {
                *piMod = x % y;
            }
            return x / y;
        }
        else
        {
            *piMod = ((x-1) % y) + y + 1;
            return (x - y - 1) / y;
        }
    }
    else
    {
        if (x < 0)
        {
            *piMod = ((x+1) % y) + y - 1;
            return (x - y + 1) / y;
        }
        else
        {
            *piMod = x % y;
            return x / y;
        }
    }
}

// This is equivalent to gregorian-leap-year() from "Calendrical Calculations".
//
static bool isLeapYear(long iYear)
{
    unsigned long wMod;
    if (iMod(iYear, 4) != 0)
    {
        // Not a leap year.
        //
        return false;
    }
    wMod = iMod(iYear, 400);
    if ((wMod == 100) || (wMod == 200) || (wMod == 300))
    {
        // Not a leap year.
        //
        return false;
    }
    return true;
}

static int MinimumYear = -27256;
static int MaximumYear = 30826;

// We limit the range of supported dates to between Jan 1 -27256 and
// Dec 31 30826, inclusively.  This is chosen so that the corresponding Windows
// FILEDATE is still contained within an INT64.  Of course, Windows itself
// doesn't support negative FILEDATE.
//
bool du_isvaliddate(int iYear, int iMonth, int iDay)
{
    const char daystab[12] =
    {
        31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    };

    if (  iYear < MinimumYear
       || MaximumYear < iYear
       || iMonth < 1
       || 12 < iMonth
       || iDay < 1
       || daystab[iMonth-1] < iDay
       || (  iMonth == 2
          && iDay == 29
          && !isLeapYear(iYear)))
    {
        return false;
    }
    else
    {
        return true;
    }
}

static const int gregorian_epoch = 1;

// This is equivalent to fixed-from-gregorian(year, month, day) from the book.
//
static int FixedFromGregorian(int iYear, int iMonth, int iDay)
{
    iYear = iYear - 1;

    int iFixedDay = gregorian_epoch - 1;
    iFixedDay += 365 * iYear;
    iFixedDay += iFloorDivision(iYear, 4);
    iFixedDay -= iFloorDivision(iYear, 100);
    iFixedDay += iFloorDivision(iYear, 400);
    iFixedDay += iFloorDivision(367 * iMonth - 362, 12);
    iFixedDay += iDay;

    if (iMonth > 2)
    {
        if (isLeapYear(iYear+1))
        {
            iFixedDay -= 1;
        }
        else
        {
            iFixedDay -= 2;
        }
    }

    // At this point, iFixedDay has an epoch of 1 R.D.
    //
    return iFixedDay;
}

static const int MaximumFixed =  10674576;  // Dec 31 30826
static const int MinimumFixed = -10539804;  // Jan 1 -27256

// Not multi-thread safe.
//
static int cache_iYear = 99999;
static int cache_iJan1st = 0;
static int cache_iMar1st = 0;

static void CachedSpecialDays(int iYear)
{
    if (iYear != cache_iYear)
    {
        cache_iYear = iYear;
        cache_iJan1st = FixedFromGregorian(iYear, 1, 1);
        cache_iMar1st = FixedFromGregorian(iYear, 3, 1);
    }
}

// This is equivalent to a combination of gregorian-year-from-fixed(fixed),
// gregorian-from-fixed(fixed), and day-number() from the book.
//
static void GregorianFromFixed(int iFixedDay, FIELDEDDATE *pfd)
{
    int d0 = iFixedDay - gregorian_epoch;
    int d1, n400 = iFloorDivisionMod(d0, 146097, &d1);
    int d2, n100 = iFloorDivisionMod(d1,  36524, &d2);
    int d3, n4   = iFloorDivisionMod(d2,   1461, &d3);
    int d4, n1   = iFloorDivisionMod(d3,    365, &d4);

    pfd->iYear = 400*n400 + 100*n100 + 4*n4 + n1;

    if (n100 != 4 && n1 != 4)
    {
        pfd->iYear = pfd->iYear + 1;
    }

    CachedSpecialDays(pfd->iYear);

    int iCorrection;
    int iPriorDays = iFixedDay - cache_iJan1st;
    if (iFixedDay < cache_iMar1st)
    {
        iCorrection = 0;
    }
    else if (isLeapYear(pfd->iYear))
    {
        iCorrection = 1;
    }
    else
    {
        iCorrection = 2;
    }

    pfd->iMonth = (12*(iPriorDays+iCorrection)+373)/367;
    pfd->iDayOfMonth = iFixedDay - FixedFromGregorian(pfd->iYear, pfd->iMonth, 1) + 1;
    pfd->iDayOfYear = iPriorDays + 1;

    // Calculate the Day of week using the linear progression of days.
    //
    pfd->iDayOfWeek = iMod(iFixedDay, 7);
}

// Epoch of iFixedDay should be 1 R.D.
//
static void OtherDaysFromGregorianAndFixed(int iFixedDay, FIELDEDDATE *pfd)
{
    int iPriorDays;
    CachedSpecialDays(pfd->iYear);
    iPriorDays = iFixedDay - cache_iJan1st;
    pfd->iDayOfYear = iPriorDays + 1;

    // Calculate the Day of week using the linear progression of days.
    //
    pfd->iDayOfWeek = iMod(iFixedDay, 7);
}

static int FixedFromGregorian_Adjusted(int iYear, int iMonth, int iDay)
{
    int iFixedDay = FixedFromGregorian(iYear, iMonth, iDay);

    // At this point, iFixedDay has an epoch of 1 R.D.
    // We need an Epoch of (00:00:00 UTC, January 1, 1601)
    //
    return iFixedDay - 584389;
}

static void GregorianFromFixed_Adjusted(int iFixedDay, FIELDEDDATE *pfd)
{
    // We need to convert the Epoch to 1 R.D. from
    // (00:00:00 UTC, January 1, 1601)
    //
    GregorianFromFixed(iFixedDay + 584389, pfd);
}

static void OtherDaysFromGregorianAndFixed_Adjusted(int iFixedDay, FIELDEDDATE *pfd)
{
    // We need to convert the Epoch to 1 R.D. from
    // (00:00:00 UTC, January 1, 1601)
    //
    OtherDaysFromGregorianAndFixed(iFixedDay + 584389, pfd);
}

bool du_fieldedtolinear(FIELDEDDATE *pfd, int *pld)
{
    int iFixedDay;
    if (!du_isvaliddate(pfd->iYear, pfd->iMonth, pfd->iDayOfMonth))
    {
        *pld = 0;
        return false;
    }

    iFixedDay = FixedFromGregorian_Adjusted(pfd->iYear, pfd->iMonth, pfd->iDayOfMonth);
    OtherDaysFromGregorianAndFixed_Adjusted(iFixedDay, pfd);

    *pld = iFixedDay;
    return true;
}

bool du_lineartofielded(int ld, FIELDEDDATE *pfd)
{
    memset(pfd, 0, sizeof(FIELDEDDATE));
    if (  ld < MinimumFixed
       || MaximumFixed < ld)
    {
        return false;
    }
    GregorianFromFixed_Adjusted(ld, pfd);
    if (!du_isvaliddate(pfd->iYear, pfd->iMonth, pfd->iDayOfMonth))
    {
        return false;
    }

    return true;
}

// This is equivalent to gregorian-new-year from the book.
//
bool du_newyear(int iYear, int *pld)
{
    if (  iYear < MinimumYear
       || MaximumYear < iYear)
    {
        return false;
    }
    *pld = FixedFromGregorian_Adjusted(iYear, 1, 1);
    return true;
}

// This is equivalent to gregorian-year-end from the book.
//
bool du_yearend(int iYear, int *pld)
{
    if (  iYear < MinimumYear
       || MaximumYear < iYear)
    {
        return false;
    }
    *pld = FixedFromGregorian_Adjusted(iYear, 12, 31);
    return true;
}

// This is equivalent to day-of-week-from-fixed(date).
//
bool du_dayofweek(int ld, int *pdow)
{
    if (  ld < MinimumFixed
       || MaximumFixed < ld)
    {
        return false;
    }

    *pdow = iMod(ld+1, 7);
    return true;
}

// This is equivalent to kday-on-or-before(k, date).
//
bool du_kdayonorbefore(int k, int ld, int *pld)
{
    if (  ld < MinimumFixed
       || MaximumFixed < ld)
    {
        return false;
    }

    *pld = ld - iMod(ld - k + 1, 7);
    return true;
}
