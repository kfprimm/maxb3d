
#ifndef ROAM__HERE
#define ROAM__HERE 1

/*
 * roam.h                common header file for roamstepN.c library examples
 * by Mark Duchaineau (free but copyrighted, see LibGen/COPYING)
 *
 * 2002-08-03: wrote
 * 2002-08-13: added _set_tricntmax()
 * 2002-08-17: added _set_iqfine()
 *
 */


//#include "fly.h"

/* maximum bintree level for which index-to-float conversions work */
#define ROAM_LMAX 45


/*
 * opaque handle to the roam view-dependent mesh returned from roam_create()
 */

typedef void *roamhandle;


float getHeight(roamhandle rmh, float x, float z);


/*
 * make a roam view-dependent mesh
 */

roamhandle roam_create(float *heightdata, int size);

void roam_free(roamhandle rmh);

/*
 * set the frustum used to cull and optimize the mesh
 */

void roam_set_frustum(roamhandle rmh, float cx, float cy, float cz, float* frust_planes);

void roam_set_displacement(roamhandle rmh, int index, float displacement);

/*
 * set heightdata to make the terrain
 */
void roam_set_heightdata(roamhandle rmh, float *heightdata, int size);
void roam_update_heightdata(roamhandle rmh);

/*
 * set the target triangle count
 */

void roam_set_tricntmax(roamhandle rmh,int tricntmax);


/*
 * set the maximum bintree refinement level
 */

void roam_set_lmax(roamhandle rmh,int lmax);


/*
 * set the maximum projected accuracy as a priority-queue index
 */

void roam_set_iqfine(roamhandle rmh,int iqfine);


/*
 * optimize the roam mesh for the current frustum and draw it
 *
 * NOTE: roam does not look at what the actual view transform is.
 * So, for debugging you can look at the roam mesh from a
 * different point of view than was used for optimization
 * and culling.
 */

void roam_draw(roamhandle rmh);

void roam_optimize(roamhandle rmh);

float *roam_getdata(roamhandle rmh, int* count);


#endif /* ifndef ROAM__HERE */

