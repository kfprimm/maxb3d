/*
 
  ------------------------Thanks to Mark A. Duchaineau--------------------------

  Starting Novermber 22, 2007, the License has been changed to the Open Source
  certified MIT License, reproduced below, with <data> and <copyright holders>
  updated, from

   http://www.opensource.org/licenses/mit-license.html

  ------------------ The cognigraph.com/LibGen License -------------------------
  Copyright (c) 1991-2008 cognigraph.com, Mark A. Duchaineau

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  ------------------------------------------------------------------------------

*/

/*
 * roamstep4.c     ROAM example 4: diamond split/merge, priority queues
 * by Mark Duchaineau (free but copyrighted, see LibGen/COPYING)
 *
 * At this step the split and merge optimization is added.
 * During each frame the viewpoint change is taken into account
 * via _set_frustum(), and used to drive a number of split
 * and merge operations each frame.  This starts with the previous frame's
 * mesh and updates the level of detail incrementally until either
 * the mesh is completely optimal for this viewpoint, or until
 * the number of splits or merges reaches some application-supplied
 * limit.  This split-merge step limit, combined with the ability to
 * set the target number of displayed triangles, allows the application to
 * provide strict control of frame rate in cases where the bottleneck is
 * a combination of CPU work and per-triangle GPU work.  So far we do not
 * take into account any fill-rate limitations on performance.  In tests on
 * one machine, the default flight loop ran 1.7 times as fast as with
 * the step 3 library.
 *
 * 2002-08-13: wrote based on roamstep3.c and LibGen/Roam code
 * 2002-08-17: debugged and tested
 * 2002-08-18: more debugging; added framecnt for better OUT->IN priority
 *             response; got working under Win32
 *
 */


#include <string.h>    /* for memcpy()                                     */
//#include "randtab.h"   /* randomizer hashing tables                        */
#include "roam.h"      /* our own defs                                     */
#include "roamtypes.h" /* typedefs for internal use of roamstepN.c         */

/*
 * functions used only internally in this module
 */


//static float getHeight(roamhandle rmh, float x, float z);

/* update the display mesh for the new viewpoint */
//static void rm_optimize(roam rm);

/* allocate a triangle for diamond dm side j */
static void dm_grabtri(roamdm dm,int j);

/* deallocate the triangle for diamond dm side j */
static void dm_freetri(roamdm dm,int j);

/* put triangle i on draw list */
void dm_set_in_tri(roamdm dm,int j);

/* take triangle i off of draw list */
void dm_set_out_tri(roamdm dm,int j);

/* per-frame recursive update of the cull flags (quadtree recursion) */
static void dm_cull_updatesub(roamdm dm);

/* force-split a diamond (ignores call if already split) */
static void dm_split(roamdm dm);

/* merge a diamond (must be a mergable diamond--does not force merge) */
static void dm_merge(roamdm dm);

/* get diamond from free list, returns null if out of mem */
/* does not set up the data structure in any way (see fetchkid) */
static roamdm dm_create(roam rm);

/* fetch child i of diamond dm (locks it, creates as needed) */
static roamdm dm_fetchkid(roamdm c,int i);

/* increment reference count, lockcnt!=0 means not FREE to recycle */
static void dm_lock(roamdm dm);

/* decrement reference count, lockcnt==0 means FREE to recycle */
static void dm_unlock(roamdm dm);

/* update the cull flags of a single diamond (looks at its quadtree parent) */
static void dm_cull_update(roamdm dm);

/* update diamond's priority queue index for the current viewpoint */
static void dm_priority_update(roamdm dm);

/* update the queue state of the diamond as specified */
static void dm_enqueue(roamdm dm,int qflags,int iq_new);

/* perform sanity check on all data structures, abort if error */
void rm_checkit(roam rm,char *msg);

/* */
void roam_transformPoint(roamhandle rmh, float *x, float *y, float *z);

/*
 * implementations of publicly-supplied roam.h API functions
 */

float getHeight(roamhandle rmh, float x, float z) {
	roam rm;
	rm = (roam)rmh;
	
	int px, py;

	px = (int)((x+1)*rm->size/2.0f);
	py = (int)((z+1)*rm->size/2.0f);
	if (px < 0) px=0;//return 0.0f;
	if (py < 0) py=0;//return 0.0f;
	if (px >= (int)rm->size) px=(int)rm->size-1;//return 0.0f;
	if (py >= (int)rm->size) py=(int)rm->size-1;//return 0.0f;
	
	return rm->heights[px*(int)rm->size+py];
}

void roam_set_heightdata(roamhandle rmh, float *heightdata, int size) {
	roam rm;
	rm = (roam)rmh;
	
	if (rm->size != size)
	  if (rm->heights != NULL) {
		rm->heights = NULL;
		free(rm->heights);
	  }
	
	rm->size = size;	
     rm->heights = (float *)malloc(sizeof(float)*size*size);

	int i, j;
	for (i=0; i<size; i++)
	for (j=0; j<size; j++)
	    rm->heights[i*size+j] = heightdata[i*size+j];
}

void roam_update_heightdata(roamhandle rmh) {
	roam rm=(roam)rmh;
	int i,j, k;
	for (k=0;k<16+16;k++) {	
		j=k/4; i=k%4;
		roamdm dm=rm->dm_b0[j][i];
		if (dm != NULL) dm->v[1]=getHeight(rm, dm->v[0],dm->v[2]);
	}
}

void roam_set_displacement(roamhandle rmh, int index, float displacement) {
	if (index < 0) return;
	if (index > ROAM_LMAX) return;
	roam rm;
	rm=(roam)rmh;
     rm->level2dzsize[index]=displacement;
}


roamhandle roam_create(float *heightdata, int size)
{
    roam rm;

    rm->size=0;
    rm->heights=NULL;

    rm=(roam)malloc(sizeof(roam_struct));

    roam_set_heightdata(rm, heightdata, size);
    
    rm->lmax=ROAM_LMAX;
    rm->iqfine=1990/4.0;
    rm->framecnt=0;
    /* note: eyepoint and frustum are indeterminate until set_frustum called */

    /* generate table of displacement sizes versus level */
    {
        int l;

        for (l=0;l<=ROAM_LMAX;l++)
            rm->level2dzsize[l]=0.3f/sqrt(((float)((int)1<<l)));
            //rm->level2dzsize[l]=0.3f/sqrt(((float)((int)1<<l)));
    }

    /* create diamond store, free list, other arrays */
    {
        int i;
        roamdm dm0,dm1;

        /* allocate diamond storage pool and other arrays */
        rm->dmstoren=DMSTOREN;
        rm->dmstore=(roamdm)malloc(rm->dmstoren*sizeof(roamdm_struct));
        rm->tri_imax=TRI_IMAX;
        rm->tri_dmij=(int *)malloc(rm->tri_imax*sizeof(int));
        /* coords */
        rm->step_data=(void *)malloc(rm->tri_imax*15*sizeof(float));

        /* start all diamonds on free list */
        for (i=0;i+1<rm->dmstoren;i++) {
            dm0=rm->dmstore+i; dm1=rm->dmstore+(i+1);
            dm0->q1=dm1; dm1->q0=dm0;
        }
        rm->dm_free0=rm->dmstore; rm->dm_free1=rm->dmstore+(rm->dmstoren-1);
        rm->dm_free0->q0=(roamdm)0; rm->dm_free1->q1=(roamdm)0;
        rm->dmfreecnt=rm->dmstoren;

        /* set diamonds initially to be NEW and FREE */
        for (i=0;i<rm->dmstoren;i++) {
            dm0=rm->dmstore+i;
            dm0->rm=rm;
            dm0->r_bound= -1; /* indicates NEW */
            dm0->lockcnt=0;
            dm0->flags=0;
            dm0->framecnt=255;
            dm0->a[0]=dm0->a[1]=(roamdm)0;
            dm0->cull=0;
            dm0->i[0]=dm0->i[1]=0;
            dm0->iq=IQMAX/2;
            dm0->k[0]=dm0->k[1]=dm0->k[2]=dm0->k[3]=(roamdm)0;
            dm0->l= -100;
            dm0->p[0]=dm0->p[1]=(roamdm)0;
            dm0->r_error=10.0f;
        }

        /* clear queues */
        for (i=0;i<IQMAX;i++) { rm->splitq[i]=rm->mergeq[i]=(roamdm)0; }
        rm->iqsmax= -1; rm->iqmmin=IQMAX;

        /* clear tri-chunk output list */
        for (i=0;i<rm->tri_imax;i++) rm->tri_dmij[i]= -1;
        rm->tri_free=1;
        rm->tricnt=0;
        rm->trifreecnt=rm->tri_imax-1;
        rm->tricntmax=30000; /* default value..use _set_tricntmax() */
    }

    /* generate correction table for float->int conversions */
    {
        int i,*ip;
        float f;

        ip=(int *)(&f);
        for (i=0;i<256;i++) {
            *ip=0x3f800000+(i<<15);
            rm->fixtab[i]=
                (int)floor(2048.0*(log(f)/log(2.0)-(float)i/256.0)+0.5f)<<12;
        }
    }

    /* allocate, position and hook up base-mesh diamonds */
    /* --> see DIAMONDS.txt for detailed notes on how this works */
    {
        int i,j,k,di,dj,ix,jx;
        roamdm dm;

        /* allocate all base diamonds, setting everything but the links */
        for (k=0;k<16+16;k++) {
            if (k<16) {
                j=k/4; i=k%4; rm->dm_b0[j][i]=dm=dm_create(rm);
                dm->v[0]=2.0f*(float)(i-1);
                dm->v[2]=2.0f*(float)(j-1);
            }else{
                j=(k-16)/4; i=(k-16)%4; rm->dm_b1[j][i]=dm=dm_create(rm);
                dm->v[0]=2.0f*(float)i-3.0f;
                dm->v[2]=2.0f*(float)j-3.0f;
            }
		
            dm->tri_i[0]=dm->tri_i[1]=0;
            dm->v[1]=getHeight(rm, dm->v[0],dm->v[2]);
            dm->r_bound=5.0f;
            dm->r_error=5.0f;
            dm->p[0]=dm->p[1]=dm->a[0]=dm->a[1]=(roamdm)0;
            dm->k[0]=dm->k[1]=dm->k[2]=dm->k[3]=(roamdm)0;
            dm->l=(k<16?0:(((i^j)&1)?-1:-2));
            dm->cull=0; dm->flags=0; dm->splitflags=0; dm->iq=IQMAX-1;
            if (k<16 && k!=5) dm->flags|=ROAM_CLIPPED;
            if (dm->l<0) dm->flags|=ROAM_SPLIT;
        }

        /* now that they all exist, set the links */
        for (k=0;k<16;k++) {
            j=k/4; i=k%4; dm=rm->dm_b0[j][i];
            di=(((i^j)&1)?1:-1); dj=1;
            ix=((2*i+1-di)>>1)%4; jx=((2*j+1-dj)>>1)%4;
            dm->p[0]=rm->dm_b1[jx][ix];
            ix=((2*i+1+di)>>1)%4; jx=((2*j+1+dj)>>1)%4;
            dm->p[1]=rm->dm_b1[jx][ix];
            ix=((2*i+1-dj)>>1)%4; jx=((2*j+1+di)>>1)%4;
            dm->a[0]=rm->dm_b1[jx][ix];
            ix=((2*i+1+dj)>>1)%4; jx=((2*j+1-di)>>1)%4;
            dm->a[1]=rm->dm_b1[jx][ix];
            ix=(di<0?0:3); dm->p[0]->k[ix]=dm; dm->i[0]=ix;
            ix=(di<0?2:1); dm->p[1]->k[ix]=dm; dm->i[1]=ix;
        }
        for (k=0;k<16;k++) {
            j=k/4; i=k%4; dm=rm->dm_b1[j][i];
            dm->a[1]=rm->dm_b1[(j+3)%4][i];
            dm->a[0]=rm->dm_b1[(j+1)%4][i];
            dm->p[0]=rm->dm_b1[j][(i+3)%4];
            dm->p[1]=rm->dm_b1[j][(i+1)%4];
        }

        /* fixup top-level z to agree with steps 1-2 */
        //rm->dm_b0[1][1]->v[1]=getHeight(rm, rm->dm_b0[1][1]->v[0],rm->dm_b0[1][1]->v[2]);
    }

    /* put top-level diamond on split queue, grab tris, */
    {
        roamdm dm;

        dm=rm->dm_b0[1][1];
        dm_enqueue(dm,ROAM_SPLITQ,IQMAX-1);
        dm_grabtri(dm,0);
        dm_grabtri(dm,1);
    }
    
    /* do sanity check on startup */
    //rm_checkit(rm,"roam_create");

    return (roamhandle)rm;
}

void roam_set_frustum(roamhandle rmh, float cx, float cy, float cz, float* frust_planes)
{
    int i,j;
    roam rm;

    rm=(roam)rmh;

    rm->xc=cz / rm->size;
    rm->yc=cx / rm->size;
    rm->zc=cy;

    for (i=0;i<6;i++) {
    for (j=0;j<4;j++) {
        rm->frust_planes[i][j]=frust_planes[i, j];
    }}

}


void roam_set_tricntmax(roamhandle rmh,int tricntmax)
{
    roam rm;

    rm=(roam)rmh;
    rm->tricntmax=tricntmax;
}


void roam_set_lmax(roamhandle rmh,int lmax)
{
    roam rm;

    rm=(roam)rmh;
    rm->lmax=lmax;
}


void roam_set_iqfine(roamhandle rmh,int iqfine)
{
    roam rm;

    rm=(roam)rmh;
    rm->iqfine=iqfine;
}

float *roam_getdata(roamhandle rmh, int* count) {
	roam rm;
	rm=(roam)rmh;
	count[0]=rm->tri_free-1;
	float *v;
	v=(float *)rm->step_data+15;
	return v;
}

/*
 * ========== internal routines ==========
 */


#define U 10 /* compute 1/U of the priority updates each frame */

void roam_optimize(roamhandle rmh)
{
	roam rm=(roam)rmh;
	
    static int i0=0;
    int i,i1;
    roamdm dm;

    /* quadtree-recursive update cull for all active diamonds */
    dm=rm->dm_b0[1][1];
    dm_cull_updatesub(dm);
    for (i=0;i<4;i++) { if (dm->k[i]) dm_cull_updatesub(dm->k[i]); }

    /* update priority for all queued diamonds */
    i1=i0+(rm->dmstoren+(U-1))/U;
    if (i1>=rm->dmstoren) i1=rm->dmstoren-1;
    for (i=i0;i<=i1;i++) {
        dm=rm->dmstore+i;
        if (dm->flags&ROAM_ALLQ) dm_priority_update(dm);
    }
    i0=(i1+1)%rm->dmstoren; 

    /*
     * keep splitting/merging until either
     *  (a) no split/merge priority overlap and:
     *      target tri count reached or accuracy target reached
     * or
     *  (b) time is up (limit optimization-loop iterations)
     * or
     *  (c) not enough free (unlocked) diamonds in cache
     *
     * Note: this implementation handles non-monotonic priorities,
     * i.e. where a child can have a higher priority than its parent.
     * Also, we are careful to be just one force-split away from being
     * beyond the target triangle/accuracy count.  As a side effect, this
     * eliminates one kind of oscillation that might occur if using
     * the suggested pseudocode from the original ROAM paper (see Vis 1997).
     *
     */
    {
        int side,overlap,overlap0,optcnt,optcntmax;

        optcntmax=2000; /* split/merge limit */
        optcnt=0;
        #define TOO_COARSE \
            (rm->tricnt<=rm->tricntmax && rm->iqsmax>=rm->iqfine && \
             rm->dmfreecnt>128 && rm->trifreecnt>128)
        if (TOO_COARSE) side= -1; else side=1;
        overlap=overlap0=rm->iqsmax-rm->iqmmin;

        while ((side!=0 || overlap0>1) && optcnt<optcntmax) {

            if (side<=0) {
                if (rm->iqsmax>0) {
                    dm_split(rm->splitq[rm->iqsmax]);
                    if (!TOO_COARSE) side=1;
                }else side=0;
            }else{
                dm_merge(rm->mergeq[rm->iqmmin]);
                if (TOO_COARSE) side=0;
            }

            overlap=rm->iqsmax-rm->iqmmin;
            if (overlap<overlap0) overlap0=overlap;
            optcnt++;
        }

    }

    rm->framecnt=(rm->framecnt+1)&255;
}


static void dm_grabtri(roamdm dm,int j)
{
    int pflags;

    /* CLIPPED diamonds never have triangles */
    if (dm->flags&ROAM_CLIPPED) return;

    pflags=dm->p[j]->flags;

    /* CLIPPED parent j means no triangle on side j */
    if (pflags&ROAM_CLIPPED) return;

    /* indicate that tri on side j is active */
    dm->flags|=ROAM_TRI0<<j;

    /* put tri on IN list if not OUT */
    if (!(dm->cull&CULL_OUT)) dm_set_in_tri(dm,j);
}


static void dm_freetri(roamdm dm,int j)
{
    int pflags;

    /* CLIPPED diamonds never have triangles */
    if (dm->flags&ROAM_CLIPPED) return;

    pflags=dm->p[j]->flags;

    /* CLIPPED parent j means no triangle on side j */
    if (pflags&ROAM_CLIPPED) return;

    /* indicate that tri on side j is not active */
    dm->flags&= ~(ROAM_TRI0<<j);

    /* take tri off IN list if not OUT */
    if (!(dm->cull&CULL_OUT)) dm_set_out_tri(dm,j);
}


void dm_set_in_tri(roamdm dm,int j)
{
    int i;
    roam rm;

    rm=dm->rm;

    /* grab free tri and fill in */
    i=rm->tri_free++;
    if (i>=rm->tri_imax) {
        /* should deal with this more gracefully... */
        exit(1);
    }
    rm->trifreecnt--;
    dm->tri_i[j]=i;
    rm->tri_dmij[i]=((dm-rm->dmstore)<<1)|j;

    /* copy data for tri */
    {
        int vi;
        float *v;
        roamdm dmtab[3];

        dmtab[1]=dm->p[j];
        if (j) { dmtab[0]=dm->a[1]; dmtab[2]=dm->a[0]; }
        else   { dmtab[0]=dm->a[0]; dmtab[2]=dm->a[1]; }
        v=(float *)rm->step_data+15*i;
        for (vi=0;vi<3;vi++,v+=5) {
//		  if (vi==0) { v[0]=0.0; v[1]=0.0; }
//		  if (vi==1) { v[0]=1.0; v[1]=0.0; }
//		  if (vi==2) { v[0]=1.0; v[1]=1.0; }
		  v[0]=dmtab[vi]->v[0]*100.0;
		  v[1]=dmtab[vi]->v[2]*100.0;
            v[2]=dmtab[vi]->v[2]*rm->size;
            v[3]=dmtab[vi]->v[1];
            v[4]=dmtab[vi]->v[0]*rm->size;
        }
    }

    rm->tricnt++;
}


void dm_set_out_tri(roamdm dm,int j)
{
    int i;
    roam rm;

    rm=dm->rm;

    i=dm->tri_i[j];

    /* put tri back on free list */
    dm->tri_i[j]=0;
    rm->tri_free--;
    rm->trifreecnt++;
    { /* copy last non-free tri to freed tri */
        int ix,dmij,jx;
        roamdm dmx;
        float *v,*vx;

        ix=rm->tri_free;
        dmij=rm->tri_dmij[ix];
        jx=dmij&1;
        dmx=rm->dmstore+(dmij>>1);
        dmx->tri_i[jx]=i;
        rm->tri_dmij[i]=dmij;
        v=(float *)rm->step_data;
        vx=v+15*ix; v+=15*i;
        memcpy((void *)v,(void *)vx,15*sizeof(float));
    }

    rm->tricnt--;
}


static void dm_cull_updatesub(roamdm dm)
{
    int cull,i;
    roamdm k;

    /* CLIPPED diamonds have no interest in cull bits */
    if (dm->flags&ROAM_CLIPPED) return;

    cull=dm->cull; /* save old cull flags for comparison */

    /* update dm's cull flags via it's quadtree parent */
    dm_cull_update(dm);

    /* skip subtree if it will be the same as last time */
    if (cull==dm->cull && (cull==CULL_OUT || cull==CULL_ALLIN)) return;

    /* if the OUT status has changed, then update the priority */
    if ((cull^dm->cull)&CULL_OUT) { dm_priority_update(dm); }

    /* if diamond is split, recurse on four quadtree kids (if they exist) */
    if (dm->flags&ROAM_SPLIT) {
        for (i=0;i<4;i+=2) {
            if (k=dm->k[i]) {
                if (k->p[0]==dm) {
                    if (k->k[0]) dm_cull_updatesub(k->k[0]);
                    if (k->k[1]) dm_cull_updatesub(k->k[1]);
                }else{
                    if (k->k[2]) dm_cull_updatesub(k->k[2]);
                    if (k->k[3]) dm_cull_updatesub(k->k[3]);
                }
            }
        }
    }
}


static void dm_split(roamdm dm)
{
    int i,s;
    roamdm k,p;

    /* if already split, then skip */
    if (dm->flags&ROAM_SPLIT) return;

    /* split parents as needed recursively */
    for (i=0;i<2;i++) {
        p=dm->p[i];
        dm_split(p);
        /* if dm is p's first split kid, take p off of mergeq */
        if (!(p->splitflags&SPLIT_K)) dm_enqueue(p,ROAM_UNQ,p->iq);
        p->splitflags|=SPLIT_K0<<dm->i[i];
    }

    /* fetch kids, update cull/priority, and put on split queue */
    for (i=0;i<4;i++) {
        k=dm_fetchkid(dm,i);
        dm_cull_update(k);
        dm_priority_update(k);
        /* kids of a freshly-split diamond go on splitq */
        dm_enqueue(k,ROAM_SPLITQ,k->iq);
        s=(k->p[1]==dm?1:0);
        k->splitflags|=SPLIT_P0<<s;
        dm_unlock(k);
        dm_grabtri(k,s); /* put kid tris on draw list */
    }

    /* indicate diamond is split, update queueing, add to check list */
    dm->flags|=ROAM_SPLIT;
    dm_enqueue(dm,ROAM_MERGEQ,dm->iq); /* freshly-split dm goes on mergeq */

    /* put any triangles back on free list */
    dm_freetri(dm,0); dm_freetri(dm,1);
}


static void dm_merge(roamdm dm)
{
    int i,s;
    roamdm k,p;

    /* if already merged, then skip */
    if (!(dm->flags&ROAM_SPLIT)) return;

    /* kids off split queue if their other parent is not split */
    for (i=0;i<4;i++) {
        k=dm->k[i];
        s=(k->p[1]==dm?1:0);
        k->splitflags&= ~(SPLIT_P0<<s);
        if (!(k->splitflags&SPLIT_P)) dm_enqueue(k,ROAM_UNQ,k->iq);
        dm_freetri(k,s); /* put kid tris back on free list */
    }

    /* indicate diamond is not split, update queueing, add to check list */
    dm->flags&= ~ROAM_SPLIT;
    dm_enqueue(dm,ROAM_SPLITQ,dm->iq);

    /* update parents as needed */
    for (i=0;i<2;i++) {
        p=dm->p[i];
        p->splitflags&= ~(SPLIT_K0<<dm->i[i]);
        if (!(p->splitflags&SPLIT_K)) {
            dm_priority_update(p);
            dm_enqueue(p,ROAM_MERGEQ,p->iq);
        }
    }

    /* put parent tris on draw list */
    dm_grabtri(dm,0); dm_grabtri(dm,1);
}


static roamdm dm_create(roam rm)
{
    roamdm dm;

    /* recycle least recently used diamond from free list */
    dm=rm->dm_free0;
    if (!dm) {
        /* to do: get all calling code to deal with out-of-mem failure */
        /* return (roamdm)0; */
        exit(1);
    }

    /* if not NEW, unlink from parents, otherwise set to not NEW */
    if (dm->r_bound>=0.0f) {
        dm->p[0]->k[dm->i[0]]=(roamdm)0; dm_unlock(dm->p[0]);
        dm->p[1]->k[dm->i[1]]=(roamdm)0; dm_unlock(dm->p[1]);
        dm->iq=IQMAX>>1;
    }else dm->r_bound=0.0f;

    /* make sure the framecnt is old */
    dm->framecnt=(rm->framecnt-1)&255;

    /* lock and return it */
    dm_lock(dm);
    return dm;
}


static roamdm dm_fetchkid(roamdm c,int i)
{
    int ix;
    roamdm k,px,cx;
    float *vc;

    /* return right away if already there */
    if ((k=c->k[i])) { dm_lock(k); return k; }

    /* need to create kid */

    /* lock center diamond early to avoid recycling it on dm_create */
    dm_lock(c);

    /* recursively create other parent to kid i */
    if (i<2) { px=c->p[0]; ix=(c->i[0]+(i==0?1:-1))&3; }
    else     { px=c->p[1]; ix=(c->i[1]+(i==2?1:-1))&3; }
    cx=dm_fetchkid(px,ix); /* locks other parent */

    /* allocate new kid */
    k=dm_create(c->rm); /* locks new kid */

    /* set all the links */
    c->k[i]=k; ix=(i&1)^1; if (cx->p[1]==px) ix|=2; cx->k[ix]=k;
    if (i&1) { k->p[0]=cx; k->i[0]=ix; k->p[1]=c; k->i[1]=i; }
    else     { k->p[0]=c; k->i[0]=i; k->p[1]=cx; k->i[1]=ix; }
    k->a[0]=c->p[i>>1];
    k->a[1]=c->a[((i+1)&2)>>1];
    k->k[0]=k->k[1]=k->k[2]=k->k[3]=(roamdm)0;

    /* set kid level, cull, flags, vertex position, etc */
    k->cull=0; k->flags=0; k->splitflags=0;
    if ((k->a[0]->flags&ROAM_CLIPPED) ||
        ((c->flags&ROAM_CLIPPED) && (cx->flags&ROAM_CLIPPED)))
        k->flags|=ROAM_CLIPPED;
    k->tri_i[0]=k->tri_i[1]=0;
    k->iq= -10; k->l=c->l+1; vc=k->v;
    {
        float *v0,*v1,dz,ds;

        v0=k->a[0]->v; v1=k->a[1]->v;
        vc[0]=0.5f*(v0[0]+v1[0]);
        vc[2]=0.5f*(v0[2]+v1[2]);
        
        ds=c->rm->level2dzsize[k->l];

        //vc[2]=0.5f*(v0[2]+v1[2])+dz*ds;
	   vc[1]=getHeight(c->rm, vc[2],vc[0]);


        k->r_error=ds*ds;
    }

    /* compute radius of diamond bounding sphere (squared) */
    {
        float rd,rc,dx,dy,dz,*v;

        v=k->p[0]->v; dx=v[0]-vc[0]; dy=v[1]-vc[1]; dz=v[2]-vc[2];
        rd=dx*dx+dy*dy+dz*dz;
        v=k->p[1]->v; dx=v[0]-vc[0]; dy=v[1]-vc[1]; dz=v[2]-vc[2];
        rc=dx*dx+dy*dy+dz*dz; if (rc>rd) rd=rc;
        v=k->a[0]->v; dx=v[0]-vc[0]; dy=v[1]-vc[1]; dz=v[2]-vc[2];
        rc=dx*dx+dy*dy+dz*dz; if (rc>rd) rd=rc;
        v=k->a[1]->v; dx=v[0]-vc[0]; dy=v[1]-vc[1]; dz=v[2]-vc[2];
        rc=dx*dx+dy*dy+dz*dz; if (rc>rd) rd=rc;
        k->r_bound=rd;
    }

    return k;
}


static void dm_lock(roamdm dm)
{
    roamdm dm0,dm1;

    /* remove from free list if first reference */
    if (dm->lockcnt==0) {
        dm0=dm->q0; dm1=dm->q1;
        if (dm0) dm0->q1=dm1; else dm->rm->dm_free0=dm1;
        if (dm1) dm1->q0=dm0; else dm->rm->dm_free1=dm0;
        dm->rm->dmfreecnt--;
    }
    dm->lockcnt++;
}


static void dm_unlock(roamdm dm)
{
    roamdm dm0;

    dm->lockcnt--;
    /* add to free list if no references left */
    if (dm->lockcnt==0) {
        dm0=dm->rm->dm_free1;
        dm->q0=dm0; dm->q1=(roamdm)0;
        if (dm0) dm0->q1=dm; else dm->rm->dm_free0=dm;
        dm->rm->dm_free1=dm;
        dm->rm->dmfreecnt++;
    }
}


static void dm_cull_update(roamdm dm)
{
		
    int cull,j,m;
    float *vc,rb,r;

    /* get quadtree parent's cull flag */
    cull=dm->a[0]->cull;

    /* get diamond center and bound radius */
    vc=dm->v; rb=dm->r_bound;

    /* if needed, update for all non-IN halfspaces */
    if (cull!=CULL_ALLIN && cull!=CULL_OUT) {
        float (*frust_planes)[4];

        frust_planes=dm->rm->frust_planes;
	
        for (j=0,m=1;j<6;j++,m<<=1) {
            if (!(cull&m)) {
			 float px= vc[2];
			 float py= vc[1];
			 float pz= vc[0];
			
			 //roam_transformPoint(dm->rm, &px, &py, &pz);
			
  			 r=frust_planes[j][0]*px + frust_planes[j][1]*py + frust_planes[j][2]*pz + frust_planes[j][3]/(float)dm->rm->size;
                if (r*r>=rb) {
                    if (r<=0.0f) cull=CULL_OUT;
                    else cull|=m; /* IN */ //hiero
                } /* else still overlaps this frustum plane */
            }
        } 
//		cull|=m;
    }

    /* if OUT state changes, update in/out listing on any draw tris */
    if ((dm->cull^cull)&CULL_OUT) {
        for (j=0;j<2;j++) {
            if (dm->flags&(ROAM_TRI0<<j)) {
                if (cull&CULL_OUT) dm_set_out_tri(dm,j);
                else dm_set_in_tri(dm,j);
            }
        }
    }

    /* store the updated cull flags */
    dm->cull=cull;
}


static void dm_priority_update(roamdm dm)
{
    int j,k,*ip;
    roam rm;
    float d,dx,dy,dz,*vc;

    rm=dm->rm;

    /* skip update if already done this frame */
    if (rm->framecnt==dm->framecnt) return;
    dm->framecnt=rm->framecnt;

    if ((dm->flags&ROAM_CLIPPED) || dm->l>=rm->lmax) k=0;
    else{
        ip=(int *)(&d); /* needed for IEEE float->int tricks */

        d=dm->r_error;

        /* compute k = fixed-point log_2(r_error) (IEEE float tricks) */
        k= *ip; k+=rm->fixtab[(k>>15)&0xff];

        /* compute distance from split point to camera (squared) */
        vc=dm->v; dx=vc[0]-rm->xc; dy=vc[2]-rm->yc; dz=(vc[1]-rm->zc)/100.0f; //zc*35/512
        d=dx*dx+dy*dy+dz*dz+1e-10;

        /* compute j = fixed-point log_2(dist_to_eye) (IEEE float tricks) */
        j= *ip; j+=rm->fixtab[(j>>15)&0xff];

        /* compute k = fixed-point log_2(r_error/dist_to_eye) (more tricks) */
        k=(k-j)+0x10000000;

        /* scale and clamp priority index to [1..IQMAX-1] */
        if (k<0) k=0; k=(k>>16)+1; if (k>=IQMAX) k=IQMAX-1;

        /* for OUT diamonds, reduce the priority but leave them ordered */
        if (dm->cull&CULL_OUT) { if (k>2048) k-=1024; else k=(k+1)>>1; }
    }

    /* update the queue index now that it is computed */
    dm_enqueue(dm,dm->flags&ROAM_ALLQ,k);
}


static void dm_enqueue(roamdm dm,int qflags,int iq_new)
{
    int i,dlock;
    roamdm *q,dmx;
    roam rm;

    /* quit early if already queued properly */
    if ((dm->flags&ROAM_ALLQ)==qflags && dm->iq==iq_new) return;

    rm=dm->rm;

    /* determine net change in lock count */
    dlock=0;
    if (dm->flags&ROAM_ALLQ) dlock--;
    if (qflags&ROAM_ALLQ) dlock++;

    /* remove from old queue if any */
    if (dm->flags&ROAM_ALLQ) {
        q=((dm->flags&ROAM_SPLITQ)?rm->splitq:rm->mergeq);
        if (dm->q0) dm->q0->q1=dm->q1;
        else{
            q[dm->iq]=dm->q1;
            if (!dm->q1) {
                if (dm->flags&ROAM_SPLITQ) {
                    if (dm->iq==rm->iqsmax) {
                        dmx=q[0]; q[0]=(roamdm)1;
                        for (i=dm->iq;!q[i];i--) ;
                        if (!(q[0]=dmx) && i==0) i--;
                        rm->iqsmax=i;
                    }
                }else{
                    if (dm->iq==rm->iqmmin) {
                        dmx=q[IQMAX-1]; q[IQMAX-1]=(roamdm)1;
                        for (i=dm->iq;!q[i];i++) ;
                        if (!(q[IQMAX-1]=dmx) && i==IQMAX-1) i++;
                        rm->iqmmin=i;
                    }
                }
            }
        }
        if (dm->q1) dm->q1->q0=dm->q0;
        dm->flags&= ~ROAM_ALLQ;
    }

    /* update priority queue index as specified */
    dm->iq=iq_new;

    /* insert into new queue if requested */
    if (qflags&ROAM_ALLQ) {

        /* insert into bucket on selected queue */
        q=((qflags&ROAM_SPLITQ)?rm->splitq:rm->mergeq);
        dm->q0=(roamdm)0; dm->q1=q[dm->iq];
        q[dm->iq]=dm;
        if (dm->q1) dm->q1->q0=dm;
        else{
            if (qflags&ROAM_SPLITQ) {
                if (dm->iq>rm->iqsmax) rm->iqsmax=dm->iq;
            }else{
                if (dm->iq<rm->iqmmin) rm->iqmmin=dm->iq;
            }
        }

        /* indicate which queue the diamond is in */
        dm->flags|=qflags;
    }

    /* perform any required locking/unlocking */
    if (dlock!=0) { if (dlock<0) dm_unlock(dm); else dm_lock(dm); }
}


void rm_checkit(roam rm,char *msg)
{

return;
    int i,j;
    roamdm dm,k,p;

    /* verify that queue links are not outside the diamond storage pool */
    for (i=0;i<rm->dmstoren;i++) {
        dm=rm->dmstore+i;
        if (dm->q0 && (dm->q0-rm->dmstore<0 || dm->q0-rm->dmstore>=DMSTOREN)) {
            printf("%s: bad ->q0=%d\n",msg,dm->q0-rm->dmstore); exit(1);
        }
        if (dm->q1 && (dm->q1-rm->dmstore<0 || dm->q1-rm->dmstore>=DMSTOREN)) {
            printf("%s: bad ->q1=%d\n",msg,dm->q1-rm->dmstore); exit(1);
        }
    }

    /* make sure diamond links reciprocate */
    for (i=0;i<rm->dmstoren;i++) {
        dm=rm->dmstore+i;
        if (dm->r_bound>=0) {
            for (j=0;j<4;j++) {
                if (k=dm->k[j]) {
                    if (k->p[0]!=dm && k->p[1]!=dm) {
                        printf("%s: non-reciprocating kid\n",msg);
                        exit(1);
                    }
                }
            }
            if (dm->l>=0) {
                for (j=0;j<2;j++) {
                    if (p=dm->p[j]) {
                        if (p->k[dm->i[j]]!=dm) {
                            printf("%s: non-reciprocating parent\n",
                                msg);
                            exit(1);
                        }
                    }
                }
            }
        }
    }
}


/* ----nakijken op gebruik van FREE()----*/
void roam_free(roamhandle rmh)
{
    roam rm;
    rm=(roam)rmh;

    free(rm->heights);
    free(rm->dmstore);
    free(rm->tri_dmij);
    free(rm->step_data);
    free(rmh);
}
