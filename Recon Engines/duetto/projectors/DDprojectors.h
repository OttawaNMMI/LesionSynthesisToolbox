/*
 * Copyright (c) 2005-2010 General Electric Company. All rights reserved.
 * This code is only made available outside the General Electric Company
 * pursuant to a signed agreement between the Company and the institution to
 * which the code is made available.  This code and all derivative works
 * thereof are subject to the non-disclosure terms of that agreement.
 */

#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <mex.h>

#define max(A,B)        (((A)>=(B)) ? (A) : (B))
#define min(A,B)        (((A)<=(B)) ? (A) : (B))
#ifndef M_PI
#define M_PI  3.14159265358979323846264338327950288419716939937510
#endif
#define MAX_RECON_DIAMETER  714.0
#define SPEED_OF_LIGHT  3e11

#if (defined(_WIN32) || defined(WIN32) || defined(_WINDOWS) || defined(_DOS)) && !defined(__MINGW32__) && !defined(__CYGWIN__)
/* Windows (and others?) do not have the round() function.
 * Below is a (not very nice) definition. It has platform-specific behaviour for
 * negative numbers, but we're not using that here.
 */
static int round(const double x)
{ return (int)(x+0.5); }
#endif

#define printf mexPrintf

void reorderDims213(int n1, int n2, int n3, float *pOrig, float *pReorder);
void reorderDims231(int n1, int n2, int n3, float *pOrig, float *pReorder);
void reorderDims312(int n1, int n2, int n3, float *pOrig, float *pReorder);
void reorderDims2143(int n1, int n2, int n3, int n4, float *pOrig, float *pReorder);
void reorderDims2413(int n1, int n2, int n3, int n4, float *pOrig, float *pReorder);
void reorderDims3142(int n1, int n2, int n3, int n4, float *pOrig, float *pReorder);
void DD3Transpose(int nx, int ny, int nz, float *pOrig, float *pTrans);
void DD3AddTranspose(int nx, int ny, int nz, float *pOrig, float *pTrans);
void radBoundaries(int nu, float su, float *uDetBounds, float *uScaleFactors);
void radGeoBoundaries(short nU, short nPhi, float ringDiameter, 
        short nBlocks, short nXtals, float blkSize, float *uMap, 
        float *uScaleFactors, float *uMidMap);
void initTOFWeights(short nt,int nDist,float tRes, float tLSB,
        float wtStep,short sigmas,float *tofWeights);
