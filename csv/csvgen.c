/*
 * Copyright (C) 2000 Solid Vertical Domains, Ltd. and Stephen Dennis
 * Copyright (C) 2020 Stephen Dennis
 * Available under MIT License.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define FALSE 0
#define TRUE (!FALSE)

#define LBUF_SIZE 8000

typedef struct
{
    FILE *m_fp;
    int   m_nFields;
    int   m_iField;

#define AS_BEGIN       1  // Waiting for BeginRow
#define AS_FIELD       2  // Waiting for PutField
#define AS_END         3  // Waiting for EndRow
    int m_iAPIState;
} CSVGEN_STATE;

typedef struct NODE
{
    CSVGEN_STATE *m_pHandle;
    struct NODE *m_next;
} NODE;

static NODE *g_list = NULL;

static int addnode(CSVGEN_STATE *p)
{
    NODE *pNode = (NODE *)malloc(sizeof(NODE));
    if (NULL != pNode)
    {
        pNode->m_pHandle = p;
        pNode->m_next = g_list;
        g_list = pNode;
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

static int isournode(CSVGEN_STATE *p)
{
    NODE *pNode = g_list;
    while (NULL != pNode)
    {
        if (pNode->m_pHandle == p)
        {
            return TRUE;
        }
        pNode = pNode->m_next;
    }
    return FALSE;
}

static int removenode(CSVGEN_STATE *p)
{
    NODE *pNode = g_list;
    NODE *pPrev = NULL;
    while (NULL != pNode)
    {
        if (pNode->m_pHandle == p)
        {
            if (NULL == pPrev)
            {
                g_list = pNode->m_next;
            }
            else
            {
                pPrev->m_next  = pNode->m_next;
            }
            free(pNode);
            return TRUE;
        }
        pPrev = pNode;
        pNode = pNode->m_next;
    }
    return FALSE;
}

static void method_CloseFile(CSVGEN_STATE *p)
{
    if (NULL != p->m_fp)
    {
        fclose(p->m_fp);
        p->m_fp = NULL;
    }
}

static void method_Clear(CSVGEN_STATE *p)
{
    p->m_fp = NULL;
    p->m_nFields = 0;
    p->m_iField = 0;
    p->m_iAPIState = AS_BEGIN;
}

int csvgen_createfile(CSVGEN_STATE **pHandle, const char *filename, int nFields)
{
    if (0 < nFields)
    {
        CSVGEN_STATE *p = (CSVGEN_STATE *)malloc(sizeof(CSVGEN_STATE));
        if (NULL != p)
        {
            method_Clear(p);
            p->m_fp = fopen(filename, "wb");
            setvbuf(p->m_fp, NULL, _IOFBF, 16384);
            p->m_nFields = nFields;
            if (  NULL != p->m_fp
               && addnode(p))
            {
                p->m_iAPIState = AS_BEGIN;
                *pHandle = p;
                return 0;
            }
            method_CloseFile(p);
            free(p);
        }
    }
    return -1;
}

static void method_EncodeField(CSVGEN_STATE *p, const char *v)
{
    int fUseQuoted = FALSE;
    if (  NULL != strchr(v, '"')
       || NULL != strchr (v, ','))
    {
        fUseQuoted = TRUE;
    }

    if (fUseQuoted)
    {
        int ch;
        fputc('"', p->m_fp);
        for (ch = *v++; '\0' != ch; ch = *v++)
        {
            if (0x20 <= ch && ch <= 0x7F)
            {
                if ('"' == ch)
                {
                    fputc('"', p->m_fp);
                }
                fputc(ch, p->m_fp);
            }
        }
        fputc('"', p->m_fp);
    }
    else
    {
        fputs(v, p->m_fp);
    }
}

int csvgen_closefile(CSVGEN_STATE *p)
{
    if (isournode(p))
    {
        method_CloseFile(p);
        removenode(p);
        return 0;
    }
    return -1;
}

int csvgen_beginrow(CSVGEN_STATE *p)
{
    if (  isournode(p)
       && AS_BEGIN == p->m_iAPIState)
    {
        p->m_iAPIState = AS_FIELD;
        p->m_iField = 0;
        return 0;
    }
    return -1;
}

int csvgen_endrow(CSVGEN_STATE *p)
{
    if (  isournode(p)
       && AS_END == p->m_iAPIState)
    {
        fputc('\n', p->m_fp);
        p->m_iAPIState = AS_BEGIN;
        return 0;
    }
    return -1;
}

int csvgen_putfield(CSVGEN_STATE *p, char *pField)
{
    if (  isournode(p)
       && AS_FIELD == p->m_iAPIState)
    {
        if (0 != p->m_iField)
        {
            fputc(',', p->m_fp);
        }

        // Output pField
        //
        method_EncodeField(p, pField);

        p->m_iField++;
        if (p->m_iField == p->m_nFields)
        {
            p->m_iAPIState = AS_END;
        }
        return 0;
    }
    return -1;
}
