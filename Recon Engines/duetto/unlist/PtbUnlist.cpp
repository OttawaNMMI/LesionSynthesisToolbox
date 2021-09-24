/*
* PtbUnlist.cpp
*
* Usage:
* PtbUnlist(inputFile, doTOF, doSSRB, startMsecVec, endMsecVec, acqTotalCounts,
*              bytesPerCell, waitForTrigger, pSinoBuff, highEnergyLim, lowEnergyLim)
*
* Unlists and histograms PET events in an uncompressed RDFv9 List RDF
* to a native geometry sinogram. Both TOF and Non-TOF output sinograms
* are supported.
*
* Inputs:
*     inputFile      - list file path
*     doTOF          - 0 or 1 (flag to unlist to TOF/Non-TOF sinograms)
*     doSSRB         - 0 or 1 (flag to perform single-slice rebinning)
*     startMsecVec   - vector of start msec, relative to start of scan
*     endMsecVec     - vector of end msec, relative to start of scan
*     acqTotalCounts - value of expected total counts if count-based unlisting;
*                      set to 0 to not use (default)
*     bytesPerCell   - 1 or 2
*     waitForTrigger - use for gated scans, ignores events until it sees a trigger
*                      0 -> do not wait, 1 -> wait for PHYS1 (cardiac), 2 -> wait for PHYS2 (respiratory)
*     pSinoBuff      - pointer to sino buffer (e.g. pSinoBuff = zeros(1, sinoBytes))
*     highEnergyLim  - high photon energy limit
*     lowEnergyLim  - low photon energy limit
*
* Outputs:
*      endMsecVecNew - modified end of scan time if doing count-based unlisting
*                      (return 0 if not performing count-based unlisting)
*
* Example calls for Static unlist:
*      Consider a 5 minute long (300000 ms) scan.
*
*      -To unlist the first 2 minutes to a 2D Non-TOF sinogram:
*          endMsecVecNew = PtbUnlist('inputFilename', 0, 1, 0, 120000, 0, 2, 0, pSinoBuff);
*
*      -To unlist the last minute to a 3D TOF sinogram:
*          endMsecVecNew = PtbUnlist('inputFilename', 1, 0, 240000, 300000, 0, 2, 0, pSinoBuff);
*
*      -To unlist from 1 minute to 2M counts to a 3D TOF sinogram:
*          endMsecVecNew = PtbUnlist('inputFilename', 1, 0, 60000, 300000, 2000000, 2, 0, pSinoBuff);
*
* Copyright (c) 2020 General Electric Company. All rights reserved.
*
*
* ---------------------------------------------------------
* MATLAB MEX NOTE: This needs to compile AND link with HDF5
* ---------------------------------------------------------
* When mexing, compile with the version of the HDF5 libraries since that is included
* with MATLAB (1.8.6 as of R2014b).  If this is done, then no runtime library path needs
* to be set before running the mex'ed function. See initUnlister.m for details.
*/

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>
#include <string.h>
#include <mex.h>
#include <algorithm>
#include <limits>
#include "hdf5.h"
//#include <fstream>
//#include <iostream>
//using namespace std;


#define MIN(X,Y) ((X) < (Y) ? (X) : (Y))

#define INIT_GTOD_TIMER \
struct timeval startTime, endTime, elapsedTime

#define START_GTOD_TIMER \
gettimeofday(&startTime, NULL)

#define STOP_GTOD_TIMER \
gettimeofday(&endTime, NULL)

#define REPORT_GTOD_TIME(sname) \
timersub(&endTime, &startTime, &elapsedTime); \
printf(sname " completed. Time = %f secs\n", \
        (elapsedTime.tv_sec + elapsedTime.tv_usec*1e-6 ))


// added timersub for compiling in both 32-bit and 64-bit Windows
#ifdef _WIN32
        void timersub(struct timeval *endPre, struct timeval *beginPre, struct timeval *result)
{
    do
    {
        (result)->tv_sec = (endPre)->tv_sec - (beginPre)->tv_sec;
        (result)->tv_usec = (endPre)->tv_usec - (beginPre)->tv_usec;
        if ((result)->tv_usec < 0)
        {
            --(result)->tv_sec;
            (result)->tv_usec += 1000000;
        }
    }
    while (0);
}
#endif

enum PhysType_Gal
{
    PHYS2_TRIG_GAL_EVT          = 0x0, /* Trig 0 => Respiratory (pet_acq -> PHYS2) */
    PHYS1_TRIG_GAL_EVT          = 0x1, /* Trig 1 => Cardiac (pet_acq -> PHYS1) */
    MR_EXTERNAL_TRIG_GAL_EVT    = 0x2, /* Trig 2 => MR External Event */
    MR_ACTIVE_TRIG_GAL_EVT      = 0x3  /* Trig 3 => MR Active Event */
};

/***********************************
 * Supported Event Length Modes
 ***********************************/
enum EventLength
{
    /* RESERVED         = 0x0, */
    LENGTH_6_EVT        = 0x1,
    LENGTH_8_EVT        = 0x2,
    LENGTH_16_EVT       = 0x3
};

/***********************************
 * Supported Event Types
 ***********************************/
enum EventType
{
    EXTENDED_EVT    = 0x0,
    COINC_EVT       = 0x1
};

/***********************************
 * Supported Extended Event Types
 ***********************************/
enum ExtendedEvtType
{
    TIME_MARKER_EVT = 0x0,
    COINC_COUNT_EVT = 0x1,
    EXTERN_TRIG_EVT = 0x2,
    TABLE_POS_EVT   = 0x3,
    /* RESERVED     = 0x4 to 0xE */
    /* 0xE is temporary taken here to mark end of it. */
    END_LIST_EVT    = 0xE,
    SINGLE_EVT      = 0xF
};

/***********************************
 * Nominal (Clinical) Coinc Event = 6-bytes
 ***********************************/
typedef struct PetLinkEvtNomCoinc
{
    uint16_t eventLength:2;       /* Event Length : Enum for the number of bytes in the event */
    uint16_t eventType:1;         /* Event Type : Coin or Extended types */
    uint16_t hiXtalShortInteg:1;  /* High Crystal Short Integration on / off */
    uint16_t loXtalShortInteg:1;  /* Low Crystal Short Integration on / off */
    uint16_t hiXtalScatterRec:1;  /* High Crystal Scatter Recovered on / off */
    uint16_t loXtalScatterRec:1;  /* Low Crystal Scatter Recovered on / off */
    int16_t  deltaTime:9;         /* TOF 'signed' delta time (units defined by electronics */
    uint16_t hiXtalAxialID:6;     /* High Crystal Axial Id */
    uint16_t hiXtalTransAxID:10;  /* High Crystal Trans-Axial Id */
    uint16_t loXtalAxialID:6;     /* Low Crystal Axial Id */
    uint16_t loXtalTransAxID:10;  /* Low Crystal Trans-Axial Id */
} PET_LINK_EVT_NOM_COINC;

/***********************************
 * Energy Coinc Event = 8-bytes
 ************************************/
typedef struct PetLinkEvtEnergyCoinc
{
    PET_LINK_EVT_NOM_COINC nomCoincPart; /* Part that is common with Nominal Coinc Event */
    uint16_t hiXtalEnergy:8;             /* High Crystal Electronics Anger Math Energy component */
    uint16_t loXtalEnergy:8;             /* Low Crystal Electronics Anger Math Energy component */
} PET_LINK_EVT_ENERGY_COINC;

/*************************************
 * Calibration Coinc Event = 16-bytes
 **************************************/
typedef struct PetLinkEvtCalibCoinc
{
    uint16_t eventLength:2;       /* Event Length : Enum for the number of bytes in the event */
    uint16_t eventType:1;         /* Event Type : Coin or Extended types */
    uint16_t hiXtalShortInteg:1;  /* High Crystal Short Integration on / off */
    uint16_t loXtalShortInteg:1;  /* Low Crystal Short Integration on / off */
    uint16_t hiXtalScatterRec:1;  /* High Crystal Scatter Recovered on / off */
    uint16_t loXtalScatterRec:1;  /* Low Crystal Scatter Recovered on / off */
    uint16_t unused1:9;           /* Unused */
    uint16_t hiXtalAxialID:6;     /* High Crystal Axial Id */
    uint16_t hiXtalTransAxID:10;  /* High Crystal Trans-Axial Id */
    uint16_t loXtalAxialID:6;     /* Low Crystal Axial Id */
    uint16_t loXtalTransAxID:10;  /* Low Crystal Trans-Axial Id */
    uint16_t unused2:7;           /* Unused */
    uint16_t hiXtalEnergy:9;      /* High Crystal Electronics Anger Math Energy component */
    uint16_t unused3:7;           /* Unused */
    uint16_t loXtalEnergy:9;      /* Low Crystal Electronics Anger Math Energy component */
    uint16_t unused4:4;           /* Unused */
    int16_t  deltaTime:12;        /* TOF 'signed' delta time (units defined by electronics) */
    uint16_t hiXtalAngerX:8;      /* High Crystal Electronics Anger Math X component (E normalized) */
    uint16_t hiXtalAngerZ:8;      /* High Crystal Electronics Anger Math Z component (E normalized) */
    uint16_t loXtalAngerX:8;      /* Low Crystal Electronics Anger Math X component (E normalized) */
    uint16_t loXtalAngerZ:8;      /* Low Crystal Electronics Anger Math Z component (E normalized) */
} PET_LINK_EVT_CALIB_COINC;

/*************************************
 * Time Marker Event = 6-bytes
 *************************************/
typedef struct PetLinkEvtTimeMarker
{
    uint16_t eventLength:2;     /* Event Length : Enum for the number of bytes in the event */
    uint16_t eventType:1;       /* Event Type : Coin or Extended types */
    uint16_t eventTypeExt:4;    /* Extended Event Type : Time Marker, Trigger, Single..etc */
    uint16_t unused1:5;         /* Unused */
    uint16_t externEvt3:1;	    /* External Event Input 3 Level */
    uint16_t externEvt2:1;	    /* External Event Input 2 Level */
    uint16_t externEvt1:1;	    /* External Event Input 1 Level */
    uint16_t externEvt0:1;	    /* External Event Input 0 Level */
    uint16_t timeMarkerLS:16;   /* Least Significant 16 bits of 32-bit Time Marker */
    uint16_t timeMarkerMS:16;   /* Most Significant 16 bits of 32-bitTime Marker */
} PET_LINK_EVT_TIME_MARKER;

/*************************************
 * Coinc Count Event = 4-bytes
 *************************************/
typedef struct PetLinkEvtCoincCount
{
    uint16_t eventLength:2;     /* Event Length : Enum for the number of bytes in the event */
    uint16_t eventType:1;       /* Event Type : Coin or Extended types */
    uint16_t eventTypeExt:4;    /* Extended Event Type : Time Marker, Trigger, Single..etc */
    uint16_t unused1:5;         /* Unused */
    uint32_t coincCount:20;     /* Coinc Count */
} PET_LINK_EVT_COINC_COUNT;

/*************************************
 * External Trigger Event = 4-bytes
 *************************************/
typedef struct PetLinkEvtExternTrig
{
    uint16_t eventLength:2;         /* Event Length : Enum for the number of bytes in the event */
    uint16_t eventType:1;           /* Event Type : Coin or Extended types */
    uint16_t eventTypeExt:4;        /* Extended Event Type : Time Marker, Trigger, Single..etc */
    uint16_t unused1:1;             /* Unused */
    uint16_t externTrigEdgeType:1;  /* External Trigger Edge Type : Rising / Falling */
    uint16_t unused2:5;             /* Unused */
    uint16_t externTrigInput:2;     /* External Trigger Input */
    uint16_t extEvtCountPerTrig;    /* External Event Count per Trigger */
} PET_LINK_EVT_EXTERN_TRIG;


struct UnlistRx
{
    uint32_t    doTOF;
    uint32_t    doSSRB;
    uint32_t    waitForFirstCardiacTrigger;
    uint32_t    waitForFirstRespTrigger;
    uint32_t    numTimeRanges;
    uint32_t *  startMsecsAfterScan;
    uint32_t *  endMsecsAfterScan;
    uint64_t    acqTotalCounts;
    uint32_t    highEnergyLim;
    uint32_t    lowEnergyLim;
    
    UnlistRx() :
    doTOF(0), doSSRB(0), numTimeRanges(0),
            startMsecsAfterScan(NULL), endMsecsAfterScan(NULL),
            acqTotalCounts(0), highEnergyLim(0), lowEnergyLim(0)
    {
    }

void InitUnlistTimes(uint32_t numRanges)
{
    if(numTimeRanges != numRanges)
    {
        ClearUnlistTimes();
        numTimeRanges = numRanges;
        startMsecsAfterScan = new uint32_t[numTimeRanges];
        endMsecsAfterScan = new uint32_t[numTimeRanges];
    }
    else
    {
        memset(startMsecsAfterScan, 0, numTimeRanges*sizeof(startMsecsAfterScan[0]));
        memset(endMsecsAfterScan, 0, numTimeRanges*sizeof(endMsecsAfterScan[0]));
    }
}

~UnlistRx()
{
    ClearUnlistTimes();
}

void ClearUnlistTimes()
{
    if(startMsecsAfterScan != NULL)
    {
        delete[] startMsecsAfterScan;
        startMsecsAfterScan = NULL;
    }
    if(endMsecsAfterScan != NULL)
    {
        delete[] endMsecsAfterScan;
        endMsecsAfterScan = NULL;
    }
    numTimeRanges = 0;
}
};






/* ReadDataset (HDF5 wrapper function)
 * Reads entire dataset into ptrForData
 * Useful for single-item datasets like header data
 * Returns number of bytes read (0 for error)
 */
uint64_t ReadDataset( hid_t h5file, const char* pathAndName, void* ptrForData )
{
    if ( h5file < 0 )
    {
        printf("Error: HDF5 file invalid");
        return 0;
    }

    hid_t dset = H5Dopen2( h5file, pathAndName, H5P_DEFAULT );
    if ( dset < 0 )
    {
        printf("Error: Unable to open dataset with name %s", pathAndName);
        return 0;
    }

    hid_t dspace = H5Dget_space( dset );
    if ( dspace < 0 )
    {
        H5Dclose( dset );
        printf("Error: Unable to get dataspace for dataset with name %s", pathAndName);
        return 0;
    }

    hid_t dtype = H5Dget_type( dset );
    if ( dtype < 0 )
    {
        H5Sclose( dspace );
        H5Dclose( dset );
        printf("Error: Unable to query dataset with name %s", pathAndName);
        return 0;
    }

    herr_t readStatus = H5Dread( dset, dtype, H5S_ALL, H5S_ALL, H5P_DEFAULT, ptrForData );
    if ( readStatus < 0 )
    {
        H5Tclose( dtype );
        H5Sclose( dspace );
        H5Dclose( dset );
        printf("Error: Unable to perform read from dataset with name %s", pathAndName);
        return 0;
    }

    hsize_t bytesRead = (H5Tget_size(dtype)) * (H5Sget_simple_extent_npoints(dspace));

    H5Tclose( dtype );
    H5Sclose( dspace );
    H5Dclose( dset );

    return (uint64_t)bytesRead;
}






/* ReadDatasetSlab (HDF5 wrapper function)
 * Reads hyperslab of HDF5 dataset to memory at ptrForData.
 * Returns number of bytes read.
 */
uint64_t ReadDatasetSlab( hid_t h5file, const char* pathAndName, void* ptrForData, uint64_t startPoint[], uint64_t elemCount[] )
{
    if ( h5file < 0 )
    {
        printf("Error: No open HDF5 file associated with this H5Wrap object!\n");
        return 0;
    }

    hid_t dset = H5Dopen2( h5file, pathAndName, H5P_DEFAULT );
    if ( dset < 0 )
    {
        printf("Error: Unable to open dataset with name %s\n", pathAndName);
        return 0;
    }

    hid_t dtype = H5Dget_type( dset );
    if ( dtype < 0 )
    {
        H5Dclose( dset );
        printf("Error: Unable to query dataset with name %s for its datatype\n", pathAndName);
        return 0;
    }

    hid_t dspace = H5Dget_space( dset );
    if ( dspace < 0 )
    {
        H5Tclose( dtype );
        H5Dclose( dset );
        printf("Error: Unable to get dataspace for dataset with name %s\n", pathAndName);
        return 0;
    }

    int rank = H5Sget_simple_extent_ndims( dspace );

    if ( rank < 0 )
    {
        H5Sclose( dspace );
        H5Tclose( dtype );
        H5Dclose( dset );
        printf("Error: Unable to determine dimensionality of dataset with name %s\n", pathAndName);
        return 0;
    }

    hsize_t dims[ rank ];
    hsize_t maxDims[ rank ];

    rank = H5Sget_simple_extent_dims( dspace, &dims[0], &maxDims[0] ); /* this function also returns the rank */
    if ( rank < 0 )
    {
        H5Sclose( dspace );
        H5Tclose( dtype );
        H5Dclose( dset );
        printf("Error: Unable to get dimension sizes of dataset with name %s\n", pathAndName);
        return 0;
    }

    /* Hard-code stride to be 1 */
    hsize_t stride[ rank ];
    hsize_t start[ rank ];
    hsize_t count[ rank ];
    int i;
    for ( i = 0; i < rank; i++ )
    {
        stride[i] = 1;
        start[i] = (hsize_t) startPoint[i];
        count[i] = (hsize_t) elemCount[i];

        /* check that we don't exceed dims */
        if ( (start[i]+count[i]) > dims[i] )
        {
            H5Sclose( dspace );
            H5Tclose( dtype );
            H5Dclose( dset );
            printf("Error: Slab selection exceeds dataset dimensions!\n");
            return 0;
        }
    }

    herr_t slabStatus = H5Sselect_hyperslab( dspace, H5S_SELECT_SET, &start[0], &stride[0], &count[0], NULL );
    if ( slabStatus < 0 )
    {
        H5Sclose( dspace );
        H5Tclose( dtype );
        H5Dclose( dset );
        printf("Error: Unable to make hyperslab selection in dataspace for dataset with name %s\n", pathAndName);
        return 0;
    }

    hid_t memspace = H5Screate_simple( rank, &count[0], NULL );
    if ( memspace < 0 )
    {
        H5Sclose( dspace );
        H5Tclose( dtype );
        H5Dclose( dset );
        printf("Error: Unable to create memory space for read from dataset with name %s\n", pathAndName);
        return 0;
    }
    herr_t readStatus = H5Dread( dset, dtype, memspace, dspace, H5P_DEFAULT, ptrForData );

    if ( readStatus < 0 )
    {
        H5Sclose( memspace );
        H5Sclose( dspace );
        H5Tclose( dtype );
        H5Dclose( dset );
        printf("Error: Unable to perform read from dataset with name %s\n", pathAndName);
        return 0;
    }

    hssize_t elementsRead = H5Sget_select_npoints( dspace );
    if ( elementsRead < 0 )
    {
        H5Sclose( memspace );
        H5Sclose( dspace );
        H5Tclose( dtype );
        H5Dclose( dset );
        printf("Error: Unable to query datapace for number of elements in selection\n!");
        return 0;
    }

    hsize_t bytesRead = elementsRead * ((hsize_t)H5Tget_size(dtype));

    H5Sclose( memspace );
    H5Sclose( dspace );
    H5Tclose( dtype );
    H5Dclose( dset );

    return (uint64_t)bytesRead;
}





/*  GetCrystalsInFan (copied from CUtils::GetCrystalsInFan())
 *  This function will generate the number of crystals in the SFOV fan for
 *  the current detector geometry.
 */
uint32_t GetCrystalsInFan( float effRingDia, float sfovInCM, uint32_t extraRadialLORs, uint32_t radialXtalsPerBlock, uint32_t radialBlocksPerUnit, uint32_t radialUnitsPerModule, uint32_t radialModulesPerSystem, float interCrystalPitch )
{
    uint32_t numUnits = radialUnitsPerModule * radialModulesPerSystem;
    uint32_t radCrysPerUnit = radialXtalsPerBlock * radialBlocksPerUnit;
    float sysCryPitch = interCrystalPitch;

    uint32_t minValue = (uint32_t) ceil (2* (asin( (sfovInCM * 10.0) / effRingDia ) - floor (numUnits * asin( (sfovInCM * 10.0) / effRingDia ) / M_PI) * M_PI / numUnits ) /sysCryPitch );

    if ( radCrysPerUnit < minValue)
        minValue = radCrysPerUnit;

    uint32_t halfFanLORs = (uint32_t) floor(numUnits * asin( (sfovInCM * 10.0) / effRingDia ) / M_PI) * radCrysPerUnit + minValue;

    /* Round up half fan 'r's to nearest integer, add extra LOR's for recon radial repositioning,
     * x2 for full fan and add one LOR to force odd number
     */
    uint32_t radialLORs = ( halfFanLORs * 2)  + ( extraRadialLORs * 2) + 1;

    uint32_t transAxialDetectorElements = radialXtalsPerBlock * radialBlocksPerUnit * radialUnitsPerModule * radialModulesPerSystem;

    if ( radialLORs > transAxialDetectorElements )
        radialLORs = transAxialDetectorElements;

    return radialLORs;
}






/*  Get3DRingIndex (modified from CSortTables::gen3DRingLut())
 *  This function returns a 'vTheta' index based on the axial IDs of two LORs
 *  The implementation is based on ASL Tech Note 92-58
 */
int32_t Get3DRingIndex(int32_t z1, int32_t z2, int32_t numRings, int32_t rxRingDiff, uint32_t doSSRB)
{
    // If single-slice rebinning, return 2D slice
    if ( doSSRB != 0 ) { return z1 + z2; }

    /* maxAngle is the absolute value of the maximum axial angle
     * e.g. five 3D angles, i.e. {-2, -1, 0, +1, +2} equates to a maxAngle of 2
     */
    int32_t maxAngle = rxRingDiff / 2;

    int32_t ringDiff = z1 - z2;
    int32_t ringSum = z1 + z2;

    if ( ringDiff > 1 )
    {
        int32_t angle = ringDiff / 2;
        if ( angle <= maxAngle )
            return ringSum + (4*angle - 2) * numRings - (4*angle*angle - 1);
    }
    else if ( ringDiff < -1 )
    {
        int32_t angle = (z2 - z1) / 2;
        if ( angle <= maxAngle )
            return ringSum + (4*angle) * numRings - ((angle+1) * (4*angle));
    }
    else
    {
        return ringSum;
    }

    printf("Error: Invalid angle calculated in Get3DRingIndex\n");
    return -1;
}




/*  ComputeUOsinoIndex (modified from GEcomputeUOVAsinoIndex.c in motiontoolbox)
 *  This function converts the crystal indices to 2D projection plane indices (U,O)
 *  The (U,O) correspond exactly to (R,phi) or (R.T) from 2D sinograms
 *  X1, X2 are the transaxial indices from the coincidence event
 *  If the projplane index is outside of the SFOV defined in binParams an error is
 *  printed to the console and the values are deemed invalid.
 *
 *  The implementation is based on ASL Tech Notes 92-09 and 92-58
 */
void ComputeUOsinoIndex(uint16_t X1, uint16_t X2, uint32_t numBlocksPerRing, uint32_t numRadBlockXtals, uint64_t nPhi, uint64_t nU, uint64_t *U, uint64_t *O)
{
    uint16_t N = numBlocksPerRing * numRadBlockXtals; /*--- Number of crystal per ring ---*/
    int16_t mashFactor = N/2 / nPhi;
    uint16_t H = (nU-1)/2; /*--- Half width ---*/

    int16_t flip;

    if (((N/2)<= (X1+X2)) && ((X1+X2) < (3*N/2)))
    {
        flip =  1;
    }
    else
    {
        flip = -1;
    }

    int16_t R = H + flip*(abs(X1-X2)-N/2);
    *O = ((X1+X2 + N/2)%N)/2/mashFactor;

    if ((R >= 0) && (R <= (nU-1)))
    {
        *U = (uint16_t) R;
    }
    else
    {
        // The projplane index is outside of the SFOV defined in binParams
        printf("X1 = %d  \tX2 = %d  \tR = %d  \tO = %d\n",X1,X2,R,*O);
    }
}





/* This function returns the TOF bin from the deltaT of a coin event
 *  Inputs:
 *  uint_8*      pEvent - pointer to a coin event
 *  int          negCoincWindow - most negative deltaT to expect in Electronic timing LSBs
 *  int          posCoincWindow - most positive deltaT to expect in Electronic timing LSBs
 *  unsigned int tofMashFactor - TOF Mash (a.k.a. 'collapse' or 'compression') factor
 *
 *  Returns:
 *  Time bin (in range 0 to nT-1) if success; -1 if error
 */
int32_t GetTOFBin( uint8_t* pEvent, int32_t negCoincWindow, int32_t posCoincWindow, uint32_t tofMashFactor, bool bTranspose)
{
    PET_LINK_EVT_NOM_COINC* pCoin = (PET_LINK_EVT_NOM_COINC*) pEvent; /* assume it's a coin event to start */
    if ( pCoin->eventType != COINC_EVT ) /* if it's not, return error */
    {
        printf("Error: tried to get time bin for non-coin event\n");
        return -1;
    }

    /* the deltaTime field is in different spots for different events of different lengths */
    int32_t deltaT;
    if ( pCoin->eventLength == LENGTH_6_EVT )
    {
        deltaT = pCoin->deltaTime;
    }
    else if ( pCoin->eventLength == LENGTH_8_EVT )
    {
        PET_LINK_EVT_ENERGY_COINC* pEnergyCoin = (PET_LINK_EVT_ENERGY_COINC*)pEvent;
        deltaT = pEnergyCoin->nomCoincPart.deltaTime;
    }
    else if ( pCoin->eventLength == LENGTH_16_EVT )
    {
        PET_LINK_EVT_CALIB_COINC* pCalibCoin = (PET_LINK_EVT_CALIB_COINC*)pEvent;
        deltaT = pCalibCoin->deltaTime;
    }
    else
    {
        printf("Error: unrecognized event length\n");
        return -1;
    }
    if (bTranspose)
    {
        deltaT *= -1;
    }

    /* make sure deltaT is within bounds */
    if ( (deltaT > posCoincWindow) || (abs(deltaT) > negCoincWindow) )
    {
        printf("Error: invalid deltaT  %f\n",deltaT);
        return -1;
    }
    else
    {
        return (negCoincWindow + deltaT)/tofMashFactor;
    }
}




/* This function returns the frame duration in milliseconds
 *  Inputs:
 *  hid_t       h5file - HDF5 file identifier for OPEN HDF5 file
 *
 *  Returns:
 *  Non-zero frame duration for success; 0 for error
 */
uint32_t GetMsecFrameDuration(hid_t h5file)
{
    if ( h5file < 0 )
    {
        printf("Error: No open HDF5 file associated with this HDF5 file identifier\n");
        return 0;
    }

    if ( H5Iget_type(h5file) != H5I_FILE )
    {
        printf("Error: Invalid HDF5 file identifier\n");
        return 0;
    }

    uint32_t frameDuration;
    if ( ReadDataset(h5file, "/HeaderData/AcqStats/frameDuration", &frameDuration) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 0;
    }

    return frameDuration;
}





/* This function writes the sinogram dimensions to the pointers specified by the caller
 *  Inputs:
 *  hid_t       h5file - HDF5 file identifier for OPEN HDF5 file
 *  uint32_t    doSSRB - 0 = fully 3D, 1 = single-slice rebinning (SSRB)
 *  uint32_t*   nPhi_ptr - pointer to nPhi variable
 *  uint32_t*   nU_ptr - pointer to nU variable
 *  uint32_t*   nVtheta_ptr - pointer to nVtheta variable
 *  uint32_t*   nT_ptr - point to nT (numTimebins) variable
 *
 *  Returns:
 *  0 for success; 1 for error
 */
int SetSinogramDimensions(hid_t h5file, uint32_t doSSRB, uint64_t* nPhi_ptr, uint64_t* nU_ptr, uint64_t* nVtheta_ptr, uint64_t* nT_ptr)
{
    if ( h5file < 0 )
    {
        printf("Error: No open HDF5 file associated with this HDF5 file identifier\n");
        return 1;
    }

    if ( H5Iget_type(h5file) != H5I_FILE )
    {
        printf("Error: Invalid HDF5 file identifier\n");
        return 1;
    }

    uint32_t radialCrystalsPerBlock;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/radialCrystalsPerBlock", &radialCrystalsPerBlock) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t radialBlocksPerUnit;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/radialBlocksPerUnit", &radialBlocksPerUnit) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t radialUnitsPerModule;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/radialUnitsPerModule", &radialUnitsPerModule) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t radialModulesPerSystem;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/radialModulesPerSystem", &radialModulesPerSystem) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t axialCrystalsPerBlock;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/axialCrystalsPerBlock", &axialCrystalsPerBlock) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t axialBlocksPerUnit;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/axialBlocksPerUnit", &axialBlocksPerUnit) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t axialUnitsPerModule;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/axialUnitsPerModule", &axialUnitsPerModule) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t axialModulesPerSystem;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/axialModulesPerSystem", &axialModulesPerSystem) != sizeof(axialModulesPerSystem) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    float effRingDia;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/effectiveRingDiameter", &effRingDia) != sizeof(float) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t transAxialFOV;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/EDCATParameters/transAxialFOV", &transAxialFOV) != sizeof(float) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }
    float sfovInCM = (float) transAxialFOV;

    float interCrystalPitch;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/interCrystalPitch", &interCrystalPitch) != sizeof(float) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t extraRadialLORs;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/RxScanParameters/extraRsForTFOV", &extraRadialLORs) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    int32_t posCoincidenceWindow;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/EDCATParameters/posCoincidenceWindow", &posCoincidenceWindow) != sizeof(int32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    int32_t negCoincidenceWindow;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/EDCATParameters/negCoincidenceWindow", &negCoincidenceWindow) != sizeof(int32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t tofCompressionFactor;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/RxScanParameters/tofCompressionFactor", &tofCompressionFactor) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t transAxialDetectorElements = radialCrystalsPerBlock * radialBlocksPerUnit * radialUnitsPerModule * radialModulesPerSystem;
    uint32_t numRings = axialCrystalsPerBlock * axialBlocksPerUnit * axialUnitsPerModule * axialModulesPerSystem;
    uint32_t numTimebins = (posCoincidenceWindow + negCoincidenceWindow + 1) / tofCompressionFactor;

    // Write sinogram dimensions to input ptrs
    // nU should agree with /HeaderData/AcqParameters/EDCATParameters/crystalsInTFOV dataset
    *nPhi_ptr = transAxialDetectorElements / 2;
    *nU_ptr = GetCrystalsInFan( effRingDia, sfovInCM, extraRadialLORs, radialCrystalsPerBlock, radialBlocksPerUnit, radialUnitsPerModule, radialModulesPerSystem, interCrystalPitch );
    *nT_ptr = numTimebins;

    if ( doSSRB == 0 )
    {
        *nVtheta_ptr = numRings * numRings - (numRings - 1);
    }
    else
    {
        *nVtheta_ptr = numRings + numRings - 1;
    }

    return 0;
}





/* This function histograms the events in an RDFv9 list file based on an Unlist prescription
 *
 *  Inputs:
 *  hid_t        h5file   - HDF5 file identifier for OPEN HDF5 file
 *  void*        pSinoArg - pointer to output sinogram (cast to a uint8_t* or uint16_t* later)
 *  UnlistRx&    unlistRx - unlist prescription object (See class definition above)
 *
 *  Returns:
 *  0 for success; 1 for error
 *
 * template function can be called with 'uint8_t *' or 'uint16 *' pSino pointer.
 */
template<typename T> int PtbUnlist(hid_t h5file, T *pSino, const UnlistRx & unlistRx)
{
    uint16_t maxCellCnt = std::numeric_limits<T>::max();
    if ( h5file < 0 )
    {
        printf("Error: No open HDF5 file associated with this HDF5 file identifier\n");
        return 1;
    }

    if ( H5Iget_type(h5file) != H5I_FILE )
    {
        printf("Error: Invalid HDF5 file identifier\n");
        return 1;
    }

    if(unlistRx.numTimeRanges <= 0)
    {
        printf("Error: Invalid Unlist Start/End time range\n");
        return 1;
    }

    uint64_t sizeOfList;
    if ( ReadDataset(h5file, "/HeaderData/ListHeader/sizeOfList", &sizeOfList) != sizeof(uint64_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t isListCompressed;
    if ( ReadDataset(h5file, "/HeaderData/ListHeader/isListCompressed", &isListCompressed) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    int32_t coinOutputMode;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/EDCATParameters/coinOutputMode", &coinOutputMode) != sizeof(int32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    if ( sizeOfList == 0 )
    {
        printf("Invalid List RDF");
        return 1;
    }

    if ( isListCompressed != 0 )
    {
        printf("Unlist only works on uncompressed lists!\n");
        printf("Uncompress with the 'unglepl' program on the scanner and retry.");
        return 1;
    }

    uint32_t bytesPerEvent;
    if ( coinOutputMode == 802 )
    {
        bytesPerEvent = 6; 	// nominal coin (6 bytes per event)
        
        // Check if the user is trying to do energy-mode unlisting
        if (unlistRx.highEnergyLim < 1000 || unlistRx.lowEnergyLim > 0)
        {
            printf("\Error: LIST data is 6-byte mode, which does not include energy information.\n");
            printf("Turn off energy-mode unlisting and retry.\n");
            return 1;
        }   
    }
    else if ( coinOutputMode == 803 )
    {
        bytesPerEvent = 16;	// cal coin (16 bytes per event)
    }
    else if ( coinOutputMode == 805 ||  coinOutputMode == 806 )
    {
        bytesPerEvent = 8;	// energy coin (8 bytes per event)
    }
    else
    {
        printf("Unsupported Coin Output Mode (%d)\n", coinOutputMode);
        return 1;
    }

    printf("List Info:\n");
    printf("\tisListCompressed: %d\n", isListCompressed);
    printf("\tcoinOutputMode: %d ", coinOutputMode);
    switch ( coinOutputMode )
    {
        case 802: printf("(6-byte nominal coincidence events)\n"); break;
        case 803: printf("(16-byte calibration coincidence events)\n"); break;
        case 805: printf("(8-byte energy coincidence events)\n"); break;
        default:  printf("\n"); break;
    }
    
    printf("\tsizeOfList: %lu\n", sizeOfList);
    printf("\tevents in list: %lu\n", (sizeOfList/bytesPerEvent) );
    printf("\n");

    // Acquire system geometry parameter from header datasets
    float effRingDia;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/effectiveRingDiameter", &effRingDia) != sizeof(float) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t transAxialFOV;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/EDCATParameters/transAxialFOV", &transAxialFOV) != sizeof(float) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }
    float sfovInCM = (float) transAxialFOV;

    float interCrystalPitch;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/interCrystalPitch", &interCrystalPitch) != sizeof(float) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    float interBlockPitch;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/interBlockPitch", &interBlockPitch) != sizeof(float) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t extraRadialLORs;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/RxScanParameters/extraRsForTFOV", &extraRadialLORs) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t axialCrystalsPerBlock;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/axialCrystalsPerBlock", &axialCrystalsPerBlock) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t axialBlocksPerUnit;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/axialBlocksPerUnit", &axialBlocksPerUnit) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t axialUnitsPerModule;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/axialUnitsPerModule", &axialUnitsPerModule) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t axialModulesPerSystem;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/axialModulesPerSystem", &axialModulesPerSystem) != sizeof(axialModulesPerSystem) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t radialCrystalsPerBlock;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/radialCrystalsPerBlock", &radialCrystalsPerBlock) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t radialBlocksPerUnit;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/radialBlocksPerUnit", &radialBlocksPerUnit) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }
    
    uint32_t radialUnitsPerModule;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/radialUnitsPerModule", &radialUnitsPerModule) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t radialModulesPerSystem;
    if ( ReadDataset(h5file, "/HeaderData/SystemGeometry/radialModulesPerSystem", &radialModulesPerSystem) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t radialBlocksPerSystem = radialBlocksPerUnit * radialUnitsPerModule * radialModulesPerSystem;

    uint32_t transAxialDetectorElements = radialCrystalsPerBlock * radialBlocksPerUnit * radialUnitsPerModule * radialModulesPerSystem;

    uint32_t acceptRingDiff;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/BackEndAcqFilters/maxRingDiff", &acceptRingDiff) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t numRings = axialCrystalsPerBlock * axialBlocksPerUnit * axialUnitsPerModule * axialModulesPerSystem;

    int32_t posCoincidenceWindow;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/EDCATParameters/posCoincidenceWindow", &posCoincidenceWindow) != sizeof(int32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    int32_t negCoincidenceWindow;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/EDCATParameters/negCoincidenceWindow", &negCoincidenceWindow) != sizeof(int32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t tofCompressionFactor;
    if ( ReadDataset(h5file, "/HeaderData/AcqParameters/RxScanParameters/tofCompressionFactor", &tofCompressionFactor) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    uint32_t scanStartTimemarker;
    // Note that "/HeaderData/AcqStats/frameStartCoincTStamp" is not always the same as "/HeaderData/ListHeader/firstTmAbsTimeStamp"
    if ( ReadDataset(h5file, "/HeaderData/ListHeader/firstTmAbsTimeStamp", &scanStartTimemarker) != sizeof(uint32_t) )
    {
        printf("Error: Unable to read dataset\n");
        return 1;
    }

    // Get sinogram dimensions
    uint64_t nPhi = 0;
    uint64_t nU = 0;
    uint64_t nVtheta = 0;
    uint64_t nT = 0;
    SetSinogramDimensions(h5file, unlistRx.doSSRB, &nPhi, &nU, &nVtheta, &nT);

    printf("3D %s Sinogram Dimensions (each cell is a uint16):\n", (unlistRx.doTOF ? "TOF" : "Non-TOF"));
    if ( unlistRx.doTOF )
    {
        printf("\tnT: %d (fastest-changing)\n", nT);
        printf("\tnU: %d\n", nU);
    }
    else
    {
        printf("\tnU: %d (fastest-changing)\n", nU);
    }
    printf("\tnVtheta: %d\n", nVtheta);
    printf("\tnPhi: %d (slowest-changing)\n", nPhi);
    printf("\n");

    // Only display if unlisting in energy mode
    if (!((unlistRx.lowEnergyLim == 0) && (unlistRx.highEnergyLim == 1000)))
    {
        printf("Sinogram binned using energy limits:\n");
        printf("\tLow energy limit:  %d keV\n", unlistRx.lowEnergyLim);
        printf("\tHigh energy limit: %d keV\n", unlistRx.highEnergyLim);
        printf("\n");
    }
    
    const uint64_t coinsPerBuffer = 8000000;
    
    uint64_t listBufferSize = bytesPerEvent * coinsPerBuffer;
    
    uint8_t* pListBuffer = (uint8_t*) malloc( listBufferSize );
    if ( pListBuffer == NULL )
    {
        printf("Error: Unable to allocate memory for list buffer\n");
        return 1;
    }
    
    uint64_t totalEvents = 0;
    uint64_t totalPromptsHistogrammed = 0;
    uint64_t totalTimemarkers = 0;
    uint64_t totalCoinCounts = 0;

    uint64_t totalTriggers = 0;
    uint64_t totalCardiacTriggers = 0;
    uint64_t totalRespiratoryTriggers = 0;
    uint64_t totalMRActiveTriggers = 0;
    uint64_t totalMRExtTriggers = 0;

    uint32_t firstTimemarker = 0;
    uint32_t currTimemarker = scanStartTimemarker;
    uint32_t lastTimemarker = 0;
    uint64_t missingTimemarkers = 0;

    bool firstTimeStampSeen = false;
    bool firstCardiacTriggerSeen = false;
    bool firstRespTriggerSeen = false;

    INIT_GTOD_TIMER;
    START_GTOD_TIMER;

    uint64_t offset = 0; // current list offset (pointer to our spot in the list)
    uint64_t startTimeAbsolute = scanStartTimemarker + unlistRx.startMsecsAfterScan[0];
    uint64_t endTimeAbsolute = scanStartTimemarker + unlistRx.endMsecsAfterScan[0];
    uint32_t numRangeDone = 0;

    FILE *myFile;
    if ( bytesPerEvent == 8 )
    {
        myFile = fopen("energyEventInfo.bin", "wb"); // write events out, read in MATLAB
     }

    // To maximize efficiency, read as many elements in list buffer as possible, then process from buffer.
    T *pCell;  // pointer to histogram cell
    while ( offset < sizeOfList )
    {
        uint64_t startPoint[1] = {offset};
        uint64_t elemCount[1] = { MIN( (coinsPerBuffer*bytesPerEvent), (sizeOfList - offset) ) };
        uint64_t bytesRead = ReadDatasetSlab( h5file, "/ListData/listData", (void*)pListBuffer, startPoint, elemCount );
        uint64_t eventsRead = bytesRead / bytesPerEvent;

        totalEvents += eventsRead;

        // Loop over events in list buffer and process coins
        uint64_t e;
        for ( e = 0; e < eventsRead; e++ )
        {
            uint8_t* pEvent = (uint8_t*) (pListBuffer + e*bytesPerEvent); // will point to current event within list buffer
            
            // before anything else, update our current timemarker if the event is a timemarker event
            PET_LINK_EVT_TIME_MARKER* pTimemarker = (PET_LINK_EVT_TIME_MARKER*) pEvent;
            if ( (pTimemarker->eventType == EXTENDED_EVT) && (pTimemarker->eventTypeExt == TIME_MARKER_EVT) )
            {
                firstTimeStampSeen = true;
                currTimemarker = (pTimemarker->timeMarkerMS << 16) + pTimemarker->timeMarkerLS;
                //printf("currTimemarker = %d\n",currTimemarker);
            }

            // when we hit the user-defined end point, stop unlisting
            if ( currTimemarker >= endTimeAbsolute )
            {
                printf("Unlist Time Range %lu to %lu processed, Remaining %u\n",
                        unlistRx.startMsecsAfterScan[numRangeDone], unlistRx.endMsecsAfterScan[numRangeDone],
                        (unlistRx.numTimeRanges - numRangeDone - 1));
                lastTimemarker = currTimemarker; // do we need this?
                ++numRangeDone;
                
                if(numRangeDone < unlistRx.numTimeRanges)
                {
                    startTimeAbsolute = scanStartTimemarker + unlistRx.startMsecsAfterScan[numRangeDone];
                    endTimeAbsolute = scanStartTimemarker + unlistRx.endMsecsAfterScan[numRangeDone];

                    firstRespTriggerSeen = false;
                    firstCardiacTriggerSeen = false;

                    continue;
                }
                else
                {
                    goto DoneUnlisting;
                }
            }
            /* otherwise, process the event IF it occurs AFTER the user-defined
             * start point AND IF we have already seen a timestamp. the product
             * seems to only histogram list events after it sees the first
             * timestamp, so we are trying to replicate that behavior.
             */
            else if ( (currTimemarker >= startTimeAbsolute) && firstTimeStampSeen )
            {
                PET_LINK_EVT_NOM_COINC* pCoin = (PET_LINK_EVT_NOM_COINC*) pEvent; // assume coin event
                if ( pCoin->eventType == COINC_EVT ) // it actually is a coin event 
                {
                    // In the list files, the triggers are timestamped with the most recent timestamp.
                    // That means that there will be prompts after the timestamp and before the trigger.
                    // For gated scans, during the first bin of every cycle, we do NOT want to histogram
                    // prompts until we see that trigger.
                    if ( (unlistRx.waitForFirstRespTrigger && !firstRespTriggerSeen) || (unlistRx.waitForFirstCardiacTrigger && !firstCardiacTriggerSeen) )
                    {
                        continue;
                    }

                    // 3D sinogram coordinates
                    uint64_t vTheta;
                    uint64_t phi;
                    uint64_t u;

                    // Energy information from detectors
                    uint16_t hiXtalEnergyBin = 0;
                    uint16_t loXtalEnergyBin = 0;
                    
                    /* If the list contains 'long' events (8-byte or 16-byte),
                     * we can extract additional information from the event.
                     * If the events are nominal events (6-byte), then we don't
                     * have access to energy bin data.
                     *
                     * This info is not currently used for anything, but exists
                     * for instructional purposes.
                     */
                    if ( pCoin->eventLength == LENGTH_8_EVT )
                    {
                        PET_LINK_EVT_ENERGY_COINC* pEnergyCoin = (PET_LINK_EVT_ENERGY_COINC*) pEvent;

                        hiXtalEnergyBin = pEnergyCoin->hiXtalEnergy * 2 + 240;
                        loXtalEnergyBin = pEnergyCoin->loXtalEnergy * 2 + 240;
                    }
                    else if ( pCoin->eventLength == LENGTH_16_EVT )
                    {
                        PET_LINK_EVT_CALIB_COINC* pCalibCoin = (PET_LINK_EVT_CALIB_COINC*) pEvent;

                        hiXtalEnergyBin = pCalibCoin->hiXtalEnergy;
                        loXtalEnergyBin = pCalibCoin->loXtalEnergy;
                    }
                        
                    /* Note that 'xs' represents the sum of the crystal (or block) transaxial IDs of the
                     * coincidence event.
                     *
                     * Determine which R LUT to use. Need 'r' reflection if < PI/2 or > 3/2PI views.
                     * Reference ASL Tech Note 90-51.
                     *
                     * If we need to used transposed r, we flip the hi and lo for the 3D Ring calculation.
                     * The (U, O) or (u, phi) calculation will take care of its own transposing.
                     */
                    uint32_t xs = pCoin->hiXtalTransAxID + pCoin->loXtalTransAxID;
                    int32_t bTranspose;
                    if ( (xs >= (transAxialDetectorElements/2)) && (xs < (3 * (transAxialDetectorElements/2))) )
                    {
                        bTranspose = false;
                        vTheta = Get3DRingIndex(pCoin->loXtalAxialID, pCoin->hiXtalAxialID, (int32_t) numRings, (int32_t) acceptRingDiff, unlistRx.doSSRB);
                    }
                    else
                    {
                        bTranspose = true;
                        vTheta = Get3DRingIndex(pCoin->hiXtalAxialID, pCoin->loXtalAxialID, (int32_t) numRings, (int32_t) acceptRingDiff, unlistRx.doSSRB);
                    }
                    
                    int32_t timeBin = GetTOFBin(pEvent, negCoincidenceWindow, posCoincidenceWindow, tofCompressionFactor, bTranspose);

                    // Same function calculates both u and phi, pointers to each are provided as input args
                    ComputeUOsinoIndex(pCoin->hiXtalTransAxID, pCoin->loXtalTransAxID, radialBlocksPerSystem, radialCrystalsPerBlock, nPhi, nU, &u, &phi);

                    // Increment the sinogram cell by 1 for the current LOR
                    // Check that photon energies are between energy cutoff limits
                    if ( (hiXtalEnergyBin <= unlistRx.highEnergyLim && hiXtalEnergyBin >= unlistRx.lowEnergyLim) && (loXtalEnergyBin <= unlistRx.highEnergyLim && loXtalEnergyBin >= unlistRx.lowEnergyLim) )
                    {
                        if ( (phi < nPhi) && (u < nU) && (vTheta < nVtheta) && (vTheta >= 0) )
                        {
                            // Write sino info and energy to file
                            if ( bytesPerEvent == 8 )
                            {
                                fwrite(&vTheta, sizeof(uint16_t), 1, myFile);
                                fwrite(&phi, sizeof(uint16_t), 1, myFile);
                                fwrite(&u, sizeof(uint16_t), 1, myFile);
                                fwrite(&hiXtalEnergyBin, sizeof(uint16_t), 1, myFile);
                                fwrite(&loXtalEnergyBin, sizeof(uint16_t), 1, myFile);
                            }
                            /*printf("\nhiXtalTransAxID: %d\n",pCoin->hiXtalTransAxID);
                             * printf("hiXtalAxialID: %d\n",pCoin->hiXtalAxialID);
                             * printf("loXtalTransAxID: %d\n",pCoin->loXtalTransAxID);
                             * printf("loXtalAxialID: %d\n",pCoin->loXtalAxialID);
                             * printf("deltaTime: %d\n",pCoin->deltaTime); */

                            if(unlistRx.doTOF)
                            {
                                if(timeBin >= nT) {
                                    printf("Error: Invalid time bin %d! phi=%d, u=%d, vTheta=%d\n", timeBin, phi, u, vTheta);
                                    return 1;
                                }
                                /* dimensions are [nVtheta (fastest changing), nT, nU, nPhi (slowest changing)] */

                                pCell = pSino + vTheta + timeBin*nVtheta + u*nT*nVtheta + phi*nVtheta*nU*nT;
                                if (*pCell >= maxCellCnt) {     // check for overflow before incrementing
                                    printf("Error: TOF cell overflow, timeBin=%d phi=%d, u=%d, vTheta=%d\n", timeBin, phi, u, vTheta);
                                    return 1;
                                }
                                *pCell += 1;
                                totalPromptsHistogrammed++;
                                //printf("totalPromptsHistogrammed = %d\n", totalPromptsHistogrammed);
                            }
                            else
                            {
                                // dimensions are [u, (fastest changing), vTheta, phi (slowest changing)]
                                pCell = pSino + u + vTheta*nU + phi*nU*nVtheta;
                                if (*pCell >= maxCellCnt) {    // check for overflow before incrementing
                                    printf("Error: nonTOF cell overflow, phi=%d, u=%d, vTheta=%d\n", phi, u, vTheta);
                                    return 1;
                                }
                                *pCell += 1;
                                totalPromptsHistogrammed++;
                                //printf("totalPromptsHistogrammed = %d\n", totalPromptsHistogrammed);
                            }

                            // Stop unlisting if the totalPromptsHistogrammed reaches user input
                            if (unlistRx.acqTotalCounts != 0)
                            {
                                if (totalPromptsHistogrammed == unlistRx.acqTotalCounts)
                                {
                                    // Modify the endTime
                                    unlistRx.endMsecsAfterScan[numRangeDone] = lastTimemarker - firstTimemarker;
                                    goto DoneUnlisting;
                                }
                            }

                        }
                        else
                        {
                            printf("Error: Invalid sino index! phi=%d, u=%d, vTheta=%d\n", phi, u, vTheta);
                        }
                    }
                }
                else /* it was not a coin event */
                {
                    /* assume it's a timemarker at first in order to figure out what it really is */
                    PET_LINK_EVT_TIME_MARKER* pTmark = (PET_LINK_EVT_TIME_MARKER*) pEvent;

                    if ( pTmark->eventTypeExt == TIME_MARKER_EVT ) /* it's a timemarker */
                    {
                        //printf("Processing at currTimemarker=%u  startTimeAbsolute=%u  endTimeAbsolute=%u\n",
                        //currTimemarker, startTimeAbsolute, endTimeAbsolute);

                        if (totalTimemarkers == 0)
                        {
                            firstTimemarker = currTimemarker;
                        }
                        else
                        {
                            if (currTimemarker - lastTimemarker != 1) { missingTimemarkers += 1; }
                        }

                        lastTimemarker = currTimemarker;

                        totalTimemarkers++; /* need to actually count timemarkers-- they may not all be present for high count rate lists */
                    }
                    else if ( pTmark->eventTypeExt == COINC_COUNT_EVT ) /* it's a coin count event */
                    {
                        PET_LINK_EVT_COINC_COUNT* pCoincount = (PET_LINK_EVT_COINC_COUNT*) pEvent;

                        totalCoinCounts++;
                    }
                    else if ( pTmark->eventTypeExt == EXTERN_TRIG_EVT ) /* it's a trigger event */
                    {
                        PET_LINK_EVT_EXTERN_TRIG* pTrigger = (PET_LINK_EVT_EXTERN_TRIG*) pEvent;

                        totalTriggers++;

                        if ( pTrigger->externTrigInput == PHYS1_TRIG_GAL_EVT )
                        {
                            firstCardiacTriggerSeen = true;
                            totalCardiacTriggers++;
                        }
                        else if ( pTrigger->externTrigInput == PHYS2_TRIG_GAL_EVT )
                        {
                            firstRespTriggerSeen = true;
                            totalRespiratoryTriggers++;
                        }
                        else if ( pTrigger->externTrigInput == MR_ACTIVE_TRIG_GAL_EVT )
                        {
                            totalMRActiveTriggers++;
                        }
                        else if ( pTrigger->externTrigInput == MR_EXTERNAL_TRIG_GAL_EVT )
                        {
                            totalMRExtTriggers++;
                        }
                    }
                    else
                    {
                        printf("Unsupported event! Event Type Ext = %d\n", pTmark->eventTypeExt);
                    }

                } /* end if statement for event not being a coin event */

            } /* end else if statement for event being after start point */

        } /* end for loop over events */

        offset += bytesRead;

    } /* end while loop over list data */

    if ( bytesPerEvent == 8 )
    {
        fclose(myFile);
    }
    
    DoneUnlisting:
        STOP_GTOD_TIMER;
        REPORT_GTOD_TIME("Unlisting");

        uint64_t timemarkerDiff = lastTimemarker - firstTimemarker;
        printf("\n");
        printf("--- Event statistics --- \n");
        printf("First Time Mark: %lu   Last Time Mark: %lu   Delta Time: %lu\n", firstTimemarker, lastTimemarker, timemarkerDiff);
        printf("Time Markers: %lu   Missing Time Marks: %lu   Coin Count Events: %lu\n", totalTimemarkers, missingTimemarkers, totalCoinCounts);
        printf("Prompts: %lu   Cardiac Triggers: %lu   Respiratory Triggers: %lu   \nMR Active Triggers: %lu   MR External Triggers: %lu\n", totalPromptsHistogrammed, totalCardiacTriggers, totalRespiratoryTriggers, totalMRActiveTriggers, totalMRExtTriggers);
        printf("\n");

        // Cleanup
        free( pListBuffer );

        return 0;
}


bool SetUnlistTimeRange(hid_t h5file,
        const mxArray * startTimeIn,
        const mxArray * endTimeIn,
        uint32_t numTimeRanges,
        UnlistRx & unlistRx)
{
    if(startTimeIn == NULL)
    {
        printf("No Start time for Unlist specified. Starting at time 0\n");
        numTimeRanges = 1;
        unlistRx.InitUnlistTimes(numTimeRanges);
        unlistRx.startMsecsAfterScan[0] = 0;
    }
    else
    {
        unlistRx.InitUnlistTimes(numTimeRanges);
        if ( !mxIsNumeric(startTimeIn) )
        {
            mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:InvalidUnlistTime", "Invalid Unlisting Start times specified!");
        }
        double * startOffsets = (double *) mxGetPr(startTimeIn);

        //printf("unlistRx.startMsecsAfterScan : ");
        for(uint32_t i = 0; i < numTimeRanges; ++i)
        {
            unlistRx.startMsecsAfterScan[i] = (uint64_t)startOffsets[i];
            //printf("%lu ", unlistRx.startMsecsAfterScan[i]);
        }

#if 0
        // Sort to reorder the unlist times ...
        std::sort(unlistRx.startMsecsAfterScan, unlistRx.startMsecsAfterScan + numTimeRanges);
        /***
         * printf("\n");
         * printf("unlistRx.startMsecsAfterScan (Sorted) : ");
         * for(uint32_t i = 0; i < numTimeRanges; ++i)
         * {
         * printf("%lu ", unlistRx.startMsecsAfterScan[i]);
         * }
         * printf("\n");
         ***/

        uint32_t * beginIter = unlistRx.startMsecsAfterScan;
        uint32_t * endIter = unlistRx.startMsecsAfterScan + numTimeRanges;

        // ... And make sure there are no duplicates
        if(std::adjacent_find(beginIter, endIter) == endIter)
        {
            //printf("unlistRx.startMsecsAfterScan : No duplicates found\n");
        }
        else
        {
            // printf("unlistRx.startMsecsAfterScan : Duplicates found!\n");
            // return false;
        }
#endif
    }

    if(endTimeIn == NULL)
    {
        uint64_t frameDuration = GetMsecFrameDuration(h5file);
        if ( frameDuration <= 0 )
        {
            mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:frameDuration", "frameDuration from input list file is invalid.");
        }
        unlistRx.endMsecsAfterScan[0] = frameDuration;

        printf("No End time for Unlist specified. Entire file will be unlisted (duration %lu msecs)\n", unlistRx.endMsecsAfterScan[0]);
    }
    else
    {
        if ( !mxIsNumeric(endTimeIn) )
        {
            mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:InvalidUnlistTime", "Invalid Unlisting End times specified!");
        }
        double * endOffsets = (double *) mxGetPr(endTimeIn);

        //printf("unlistRx.endMsecsAfterScan : ");
        for(uint32_t i = 0; i < numTimeRanges; ++i)
        {
            unlistRx.endMsecsAfterScan[i] = (uint64_t)endOffsets[i];
            //printf("%lu ", unlistRx.endMsecsAfterScan[i]);
        }
    }

    // Finally make sure there are no overlapping ranges
    for(uint32_t i = 0; i < numTimeRanges; ++i)
    {
        // Any end time must be higher than corresponding start time,
        // and lower than the next start time
        if(unlistRx.endMsecsAfterScan[i] > unlistRx.startMsecsAfterScan[i])
        {
            if((i+1) < numTimeRanges)
            {
                if(unlistRx.endMsecsAfterScan[i] > unlistRx.startMsecsAfterScan[i+1])
                {
                    printf("Overlap detected. Unlist End time %u (index %u) cannot exceed Start time %u (index %u)\n",
                            unlistRx.endMsecsAfterScan[i], i, unlistRx.startMsecsAfterScan[i+1], (i+1));
                    return false;
                }
            }
        }
        else
        {
            // ignore if start and end msecs are equal
            if(unlistRx.endMsecsAfterScan[i] < unlistRx.startMsecsAfterScan[i])
            {
                printf("Overlap detected. Unlist End time %u (index %u) should be greater than corresponding Start time %u (index %u)\n",
                        unlistRx.endMsecsAfterScan[i], i, unlistRx.startMsecsAfterScan[i], i);
                return false;
            }
        }
    }

    return true;
}




/*
 * Input args:
 *   prhs[0] - list file path
 *   prhs[1] - doTOF          - 0 or 1 (flag to unlist to TOF/Non-TOF sinograms)
 *   prhs[2] - doSSRB         - 0 or 1 (flag to perform single-slice rebinning)
 *   prhs[3] - startMsecVec   - vector of start msec
 *   prhs[4] - endMsecVec     - vector of end msec
 *   prhs[5] - acqTotalCounts - number of counts to unlist (for count-based unlisting)
 *   prhs[6] - bytesPerCell   - 1 or 2 (redundant since pSinoBuff class is uint16 or uint8)
 *   prhs[7] - waitForTrigger - 0 -> do not wait, 1 -> wait for PHYS1 (cardiac), 2 -> wait for PHYS2 (respiratory)
 *   prhs[8] - pSinoBuff      - pointer to sino buffer (e.g. pSinoBuff = zeros(1, sinoBytes))
 *   prhs[9] - highEnergyLim  - high photon energy cutoff
 *   prhs[10] - lowEnergyLim   - low photon energy cutoff
 *
 * Output args:
 *   None
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // check the number of args: right side has 11 args, left side must have one arg (for sinogram)
    if (nrhs != 11)
    {
        mexErrMsgTxt("syntax error:\n\t endMsecVecNew = PtbUnlist(inputFilename, doTOF, doSSRB, startMsecVec, endMsecVec, acqTotalCounts, bytesPerCell, waitForTrigger, sinoBuff, highEnergyLim, loEnergyLim)");
    }
    
    /* filename inputs must be strings */
    if (mxIsChar(prhs[0]) != 1)
    {
        mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:inputNotString", "First input must be a string.");
    }
    
    /* input strings must be row vectors */
    if (mxGetM(prhs[0])!=1)
    {
        mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:inputNotVector", "Input string must be a row vector.");
    }
    
    /* get the length of the input strings */
    size_t buflen0 = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
    
    /* copy the string data from prhs[0] into a C string input_ buf.    */
    char* inputFilename = mxArrayToString(prhs[0]);
    
    if (inputFilename == NULL)
    {
        mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:conversionFailed", "Could not convert input to string.");
    }
    
    /*
     *  Open HDF5 file
     *  We need to open the file to read out parameters used to derive the
     *  sinogram dimensions before we create the MATLAB array for the output.
     *  We also need to read the frame duration so we can make sure the input
     *  times are valid.
     */
    hid_t h5file;
    
    printf("\n\n*****************************************************\n", inputFilename);
    printf("Opening input HDF5 List file %s\n", inputFilename);
    
    h5file = H5Fopen( inputFilename, H5F_ACC_RDONLY, H5P_DEFAULT );
    if (h5file < 0)
    {
        mexErrMsgIdAndTxt("MATLAB:PtbUnlist:failedFileOpen", "Error: Unable to open input HDF5 List file %s\n", inputFilename);
    }
    
    //  process rhs args (need HDF5 opened to get frame duration)
    UnlistRx unlistRx;
    
    unlistRx.doTOF = ( ((uint32_t) mxGetScalar(prhs[1])) > 0 ) ? 1 : 0;
    
    uint32_t numTimeRanges = 1;
    
    unlistRx.doSSRB = (uint32_t) mxGetScalar(prhs[2]);
    
    unlistRx.highEnergyLim = (uint32_t) mxGetScalar(prhs[9]);
    unlistRx.lowEnergyLim = (uint32_t) mxGetScalar(prhs[10]);
    
    unlistRx.waitForFirstCardiacTrigger = ( ((uint32_t) mxGetScalar(prhs[7])) == 1 ) ? 1 : 0;
    unlistRx.waitForFirstRespTrigger = ( ((uint32_t) mxGetScalar(prhs[7])) == 2 ) ? 1 : 0;
    
    uint32_t numStartTimes = mxGetNumberOfElements(prhs[3]);
    uint32_t numEndTimes = mxGetNumberOfElements(prhs[4]);
    
    numTimeRanges = (numStartTimes < numEndTimes) ? numStartTimes : numEndTimes;
    
    if(numStartTimes != numEndTimes)
    {
        mexWarnMsgIdAndTxt("MATLAB:PtbUnlist:unlistTimeRange", "Mismatch between Unlist Start and End time ranges. Only first %u time ranges will be used.", numTimeRanges);
    }
    
    if( !SetUnlistTimeRange(h5file, prhs[3], prhs[4], numTimeRanges, unlistRx) )
    {
        mexErrMsgIdAndTxt("MATLAB:PtbUnlist:UnlistTimes", "Ensure that the Unlist Start/End times are valid, and have distinct ranges with no overlap");
    }
    
    printf("\nBegin %s Unlisting of HDF5 List %s \n",(unlistRx.doTOF ? "TOF" : "Non-TOF"), inputFilename);
    printf("\n");
    
    // Get sinogram dimensions
    uint64_t nPhi = 0;
    uint64_t nu = 0;
    uint64_t nv = 0;
    uint64_t nt = 0;
    SetSinogramDimensions(h5file, unlistRx.doSSRB, &nPhi, &nu, &nv, &nt);
    
    if (unlistRx.doTOF == 0) { nt = 1; }
    
    unlistRx.acqTotalCounts = (uint64_t) mxGetScalar(prhs[5]);
    uint64_t bytesPerCell = (uint64_t) mxGetScalar(prhs[6]);
    if (bytesPerCell == 1) {
        if (strcmp(mxGetClassName(prhs[8]), "uint8") != 0)
        {
            H5Fclose(h5file);
            mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:sinoType", "sinogram buffer must be uint8 when bytesPerCell=1");
        }
    }
    else if (bytesPerCell == 2)
    {
        if (strcmp(mxGetClassName(prhs[8]), "uint16") != 0)
        {
            H5Fclose(h5file);
            mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:sinoType", "sinogram buffer must be uint16 when bytesPerCell=2");
        }
    }
    else
    {
        H5Fclose(h5file);
        mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:sinoType", "bytesPerCell must be 1 or 2");
    }
    
    uint64_t sinoBuffBytes = mxGetNumberOfElements(prhs[8]) * bytesPerCell;
    uint64_t sinoBytesReqd = nPhi * nu * nv * nt * bytesPerCell;
    
    printf("Sinogram dimensions: nv=%u nt=%u nu=%u nPhi=%u bytesPerCell=%u\n", nv, nt, nu, nPhi, bytesPerCell);
    printf("Sinogram buffer: sinoBuffBytes=%lu sinoBuffType=%s sinoBytesReqd=%lu\n",
            sinoBuffBytes, mxGetClassName(prhs[8]), sinoBytesReqd);
    
    if (unlistRx.acqTotalCounts != 0)
    {
        printf("Total number of prompt counts to unlist: %u\n", unlistRx.acqTotalCounts);
    }
    
    if (sinoBuffBytes < sinoBytesReqd) {
        printf("sinoBuffBytes=%lu sinoBytesReqd=%lu\n", sinoBuffBytes, sinoBytesReqd);
        H5Fclose(h5file);
        mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:sinoBuff", "sinogram buffer is not large enough");
    }
    
    void *pSinoBuff = mxGetData(prhs[8]);
    memset(pSinoBuff, 0, sinoBytesReqd);
    
    int retVal = 0;
    if (bytesPerCell == 1)
    {
        retVal = PtbUnlist(h5file, static_cast<uint8_t *>(pSinoBuff), unlistRx);
    }
    else
    {
        retVal = PtbUnlist(h5file, static_cast<uint16_t *>(pSinoBuff), unlistRx);
    }
    
    if (retVal != 0)
    {
        H5Fclose(h5file);
        mexErrMsgIdAndTxt( "MATLAB:PtbUnlist:histogram", "histogram error");
    }
    
    // Determine endMsec output value
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);   // initialize the output
    if (numEndTimes == 1)   // count-based unlisted only for static data
    {
        uint32_t endMsecsAfterScanOrg = static_cast<uint32_t>(mxGetScalar(prhs[4]));
        if (unlistRx.endMsecsAfterScan[0] != endMsecsAfterScanOrg)
        {
            printf("The end of scan time is adjusted from %u to %u (count-based unlisting)\n", endMsecsAfterScanOrg, unlistRx.endMsecsAfterScan[0]);
            double *endMsecsAfterScan = mxGetPr(plhs[0]);
            endMsecsAfterScan[0] = unlistRx.endMsecsAfterScan[0];
        }
    }
    
    printf("Closing HDF5 file %s\n", inputFilename);
    printf("\n");
    H5Fclose( h5file );
}

