
#ifndef ROAMTYPES__HERE
#define ROAMTYPES__HERE 1

/*
 * roamtypes.h         typedefs/structs common to several roamstepN.c modules
 * by Mark Duchaineau (free but copyrighted, see LibGen/COPYING)
 *
 * 2002-08-07: teased out from roamstep3.c; added roam_*int64 for portability
 * 2002-08-08: corrected WIN32 to _WIN32 per Thatcher Ulrich's suggestion;
 *             modified diamonds to use parent/kid links rather than hash
 * 2002-08-11: added fields and structures for step 4 library
 *
 */


/* 64-bit signed and unsigned integers */

//#ifdef _WIN32
//typedef signed __int64 roam_int64;
//typedef unsigned __int64 roam_uint64;
//#else
//typedef signed long long int roam_int64;
//typedef unsigned long long int roam_uint64;
//#endif

/* other int types */

typedef int roam_int32;
typedef unsigned int roam_uint32;
typedef short roam_int16;
typedef unsigned short roam_uint16;
typedef signed char roam_int8;
typedef unsigned char roam_uint8;


/*
 * typedefs of various structures referenced
 * should appear before structures are defined
 */

typedef struct roamdm_structdef roamdm_struct,*roamdm;
typedef struct roam_structdef roam_struct,*roam;


#define DMSTOREN     65536 /* number of diamonds in storage pool            */
#define IQMAX         4096 /* number of buckets in priority queue           */
#define TRI_IMAX     65536 /* number of triangle-chunk slots                */
#define DMCHECKLISTN 65536 /* check list size                               */


/* frustum cull bit masks */
#define CULL_ALLIN 0x3f
#define CULL_OUT   0x40


/* misc flags bits */
#define ROAM_SPLIT    0x01
#define ROAM_TRI0     0x04
#define ROAM_TRI1     0x08
#define ROAM_CLIPPED  0x10
#define ROAM_SPLITQ   0x40
#define ROAM_MERGEQ   0x80
#define ROAM_ALLQ     0xc0
#define ROAM_UNQ      0x00


/* parent/kid split flags */
#define SPLIT_K0      0x01
#define SPLIT_K       0x0f
#define SPLIT_P0      0x10
#define SPLIT_P       0x30


/*
 * per-diamond record (carefully packed for alignment)
 */

struct roamdm_structdef {
    roam rm;               /* global record that owns this diamond          */
    roamdm p[2];           /* diamond's parents (two corners)               */
    roamdm a[2];           /* other two corners (a[0]=quadtree parent)      */
    roamdm k[4];           /* diamond's kids                                */
    roamdm q0,q1;          /* prev and next links on queue or free list     */
    float v[3];            /* vertex position                               */
    float r_bound;         /* radius of sphere bound squared (-1 if NEW)    */
    float r_error;         /* radius of pointwise error squared             */
    roam_int16 iq;         /* index in priority-queue array                 */
    roam_uint16 tri_i[2];  /* triangle output chunk indices (side p0,p1)    */
    roam_int8 i[2];        /* our kid index within each of our parents      */
    roam_int8 l;           /* level of resolution                           */
    roam_uint8 cull;       /* IN/OUT bits for frustum culling               */
    roam_uint8 flags;      /* misc. bit flags (splits etc)                  */
    roam_uint8 lockcnt;    /* number of references (0=FREE)                 */
    roam_uint8 splitflags; /* parent and kid split flags                    */
    roam_uint8 framecnt;   /* frame count of most recent priority update    */
    char padding[2];       /* filler to make 8-byte alignment               */
};


/*
 * global record per ROAM optimizer
 */

struct roam_structdef {
    int lmax;              /* maximum bintree refinement level              */
    float xc,yc,zc;        /* float copy of camera position in world space  */
    float frust_planes[6][4]; /* copy of frustum plane coefficients         */
    float level2dzsize[ROAM_LMAX+1]; /* max midpoint displacement per level */
    roamdm dmstore;        /* storage pool of diamond records               */
    int dmstoren;          /*   number of diamonds in store                 */
    roamdm dm_free0,dm_free1; /* least and most recent unlocked diamonds    */
    int dmfreecnt;         /*   number of elements on free list             */
    int framecnt;          /* current frame count                           */
    roamdm dm_b0[4][4];    /* base diamonds level 0 (b0[1][1] is domain)    */
    roamdm dm_b1[4][4];    /* base diamonds level -1,-2...                  */  
    int iqfine;            /* fine limit on priority index                  */
    roamdm splitq[IQMAX];  /* split queue buckets                           */
    int iqsmax;            /*   max occupied bucket                         */
    roamdm mergeq[IQMAX];  /* merge queue buckets                           */
    int iqmmin;            /*   min occupied bucket                         */
    int tri_imax;          /* max number of tri chunks allowed              */
    int trifreecnt;        /* number of triangles on free list              */
    int tricnt;            /* number of triangles drawn (on tri_in list)    */
    int tricntmax;         /* target triangle count                         */
    int tri_free;          /* first free tri chunk                          */
    int *tri_dmij;         /* packed diamond index and side                 */
    int fixtab[256];       /* correction to float->int conversions          */
    void *step_data;       /* data attachment specific to a library step    */
    float *heights;
    float size;
};


#endif /* ifndef ROAMTYPES__HERE */

