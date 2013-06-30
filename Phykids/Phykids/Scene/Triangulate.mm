//
//  Triangulate.m
//  GameWorkshop
//
//  Created by Aditi Kamal on 2/19/11.
//  Copyright 2011 USC. All rights reserved.
//

#import "Triangulate.h"


@implementation Triangulate
static const float EPSILON=0.0000000001f;

static float Area(NSArray *points)
{
	
	int n = [points count];
	
	float A=0.0f;
	
	for(int p=n-1,q=0; q<n; p=q++)
	{
		CGPoint pointP = [[points objectAtIndex:p] CGPointValue];
		CGPoint pointQ = [[points objectAtIndex:q] CGPointValue];
		A+= pointP.x*pointQ.y - pointQ.x*pointP.y;
	}
	return A*0.5f;
}

/*
 InsideTriangle decides if a point P is Inside of the triangle
 defined by A, B, C.
 */
static bool InsideTriangle(float Ax, float Ay,
								 float Bx, float By,
								 float Cx, float Cy,
								 float Px, float Py)

{
	float ax, ay, bx, by, cx, cy, apx, apy, bpx, bpy, cpx, cpy;
	float cCROSSap, bCROSScp, aCROSSbp;
	
	ax = Cx - Bx;  ay = Cy - By;
	bx = Ax - Cx;  by = Ay - Cy;
	cx = Bx - Ax;  cy = By - Ay;
	apx= Px - Ax;  apy= Py - Ay;
	bpx= Px - Bx;  bpy= Py - By;
	cpx= Px - Cx;  cpy= Py - Cy;
	
	aCROSSbp = ax*bpy - ay*bpx;
	cCROSSap = cx*apy - cy*apx;
	bCROSScp = bx*cpy - by*cpx;
	
	return ((aCROSSbp >= 0.0f) && (bCROSScp >= 0.0f) && (cCROSSap >= 0.0f));
};

static bool Snip(NSArray *points,int u,int v,int w,int n,int *V)
{
	int p;
	float Ax, Ay, Bx, By, Cx, Cy, Px, Py;
	
	CGPoint pointU = [[points objectAtIndex:V[u]] CGPointValue];
	CGPoint pointV = [[points objectAtIndex:V[v]] CGPointValue];
	CGPoint pointW = [[points objectAtIndex:V[w]] CGPointValue];
	
	Ax = pointU.x;
	Ay = pointU.y;
	
	Bx = pointV.x;
	By = pointV.y;
	
	Cx = pointW.x;
	Cy = pointW.y;
	
	if ( EPSILON > (((Bx-Ax)*(Cy-Ay)) - ((By-Ay)*(Cx-Ax))) ) return false;
	
	for (p=0;p<n;p++)
	{
		if( (p == u) || (p == v) || (p == w) ) continue;
		CGPoint pointP = [[points objectAtIndex:V[p]] CGPointValue];
		Px = pointP.x;
		Py = pointP.y;
		if (InsideTriangle(Ax,Ay,Bx,By,Cx,Cy,Px,Py)) return false;
	}
	
	return true;
}

+(NSArray*) Process:(NSArray *)points
{
	/* allocate and initialize list of Vertices in polygon */
	
	int n = [points count];
	if ( n < 3 ) return nil;
	
    NSMutableArray *triangles = [NSMutableArray array];

	int *V = new int[n];
	
	/* we want a counter-clockwise polygon in V */
	
	if ( 0.0f < Area(points) )
		for (int v=0; v<n; v++) V[v] = v;
	else
		for(int v=0; v<n; v++) V[v] = (n-1)-v;
	
	int nv = n;
	
	/*  remove nv-2 Vertices, creating 1 triangle every time */
	int count = 2*nv;   /* error detection */
	
	for(int m=0, v=nv-1; nv>2; )
	{
		/* if we loop, it is probably a non-simple polygon */
		if (0 >= (count--))
		{
			//** Triangulate: ERROR - probable bad polygon!
			return FALSE;
		}
		
		/* three consecutive vertices in current polygon, <u,v,w> */
		int u = v  ; if (nv <= u) u = 0;     /* previous */
		v = u+1; if (nv <= v) v = 0;     /* new v    */
		int w = v+1; if (nv <= w) w = 0;     /* next     */
		
		if ( Snip(points,u,v,w,nv,V) )
		{
			int a,b,c,s,t;
			
			/* true names of the vertices */
			a = V[u]; b = V[v]; c = V[w];
			
			/* output Triangle */
            
            NSMutableArray *triangle = [NSMutableArray arrayWithCapacity:3];
            [triangle addObject:[points objectAtIndex:a]];
            [triangle addObject:[points objectAtIndex:b]];
            [triangle addObject:[points objectAtIndex:c]];

			[triangles addObject:triangle];
			
			m++;
			
			/* remove v from remaining polygon */
			for(s=v,t=v+1;t<nv;s++,t++) V[s] = V[t]; nv--;
			
			/* resest error detection counter */
			count = 2*nv;
		}
	}
	
	
	
	delete[] V;

	return [triangles count]?triangles:nil;
}

@end
