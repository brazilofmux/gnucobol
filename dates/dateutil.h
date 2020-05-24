/*! \file dateutil.h
 *
 * $Id$
 *
 * Copyright (C) 2000 Solid Vertical Domains, Ltd. and Stephen Dennis
 * Copyright (C) 2020 Stephen Dennis
 * Available under MIT License.
 *
 * Date code based on algorithms presented in "Calendrical Calculations",
 * Cambridge Press, 1998.
 */

#ifndef DATEUTIL_H
#define DATEUTIL_H

typedef struct
{
             short iYear;       // 1900 would be stored as 1900.
    unsigned short iMonth;      // January is 1. December is 12.
    unsigned short iDayOfWeek;  // 0 is Sunday, 1 is Monday, etc.
    unsigned short iDayOfMonth; // Day of Month, 1..31
    unsigned short iDayOfYear;  // January 1st is 1, etc.
} FIELDEDDATE;

bool du_fieldedtolinear(FIELDEDDATE *fd, int *pld);
bool du_lineartofielded(int ld, FIELDEDDATE *fd);
bool du_isvaliddate(int iYear, int iMonth, int iDay);
bool du_newyear(int iYear, int *pld);
bool du_yearend(int iYear, int *pld);
bool du_dayofweek(int ld, int *pdow);
bool du_kdayonorbefore(int k, int ld, int *pld);

#endif // DATEUTIL_H
