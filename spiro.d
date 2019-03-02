module spiro;

extern(C)
struct spiro_cp {
    double x;
    double y;
    char ty;
};

// Possible values of the "ty" field.
static const char SPIRO_CORNER   = 'v';
static const char SPIRO_G4       = 'o';
static const char SPIRO_G2       = 'c';
static const char SPIRO_LEFT     = '[';
static const char SPIRO_RIGHT    = ']';
static const char SPIRO_ANCHOR   = 'a';
static const char SPIRO_HANDLE   = 'h';
static const char SPIRO_END      = 'z'; // For a closed contour add an extra cp with a ty set to 
static const char SPIRO_OPEN_CONTOUR = '{'; // For an open contour the first cp must have a ty set to
static const char SPIRO_END_OPEN_CONTOUR = '}'; // For an open contour the last cp must have a ty set to 

//
extern(C)
struct spiro_seg {
// run_spiro() uses array of information given in the structure above and
// creates an array in this structure format to use by spiro_to_bpath for
// building bezier curves
    double x;       // SpiroCP segment_chord startX 
    double y;       // SpiroCP segment_chord startY 
    char ty;        // Spiro CodePoint Type 
    double bend_th; // bend theta between this vector and next vector 
    double[4] ks;
    double seg_ch;  // segment_chord distance from xy to next SpiroCP 
    double seg_th;  // segment_theta angle for this SpiroCP 
    double l;
};

extern(C) spiro_seg*  run_spiro (const spiro_cp *src, int n);
extern(C) void        free_spiro (spiro_seg *s);
extern(C) void        spiro_to_bpath (const spiro_seg *s, int n, bezctx *bc);
extern(C) double      get_knot_th (const spiro_seg *s, int i);

// These 2 functions are kept for backwards compatibility for older 
// programs. Please use the functions listed afterwards that return 
// success/failure replies when done.                   
extern(C) void TaggedSpiroCPsToBezier (spiro_cp *spiros, bezctx *bc);
extern(C) void SpiroCPsToBezier (spiro_cp *spiros, int n, int isclosed, bezctx *bc);



// These functions are available in libspiro-0.2.20130930 or higher 

// The two functions below return 1 upon success and 0 upon failure 

// The spiros array should indicate it's own end... So              
// Open contours must have the ty field of the first cp set to '{'  
//               and have the ty field of the last cp set to '}'    
// Closed contours must have an extra cp at the end whose ty is 'z' 
//               the x&y values of this extra cp are ignored        
extern(C) int TaggedSpiroCPsToBezier0 (spiro_cp *spiros, bezctx *bc);

// The first argument is an array of spiro control points.          
// Open contours do not need to start with '{', nor to end with '}' 
// Close contours do not need to end with 'z'                       
extern(C) int SpiroCPsToBezier0 (spiro_cp *spiros, int n, int isclosed, bezctx *bc);



// These functions are available in libspiro-0.3.20150131 or higher 

// If you can't use TaggedSpiroCPsToBezier0(), SpiroCPsToBezier0(), 
// these functions are enhanced versions of the original functions, 
// where spiro success/failure replies are passd back through *done 
extern(C) void TaggedSpiroCPsToBezier1 (spiro_cp *spiros, bezctx *bc, int *done);
extern(C) void SpiroCPsToBezier1 (spiro_cp *spiros, int n,int isclosed, bezctx *bc, int *done);

//
/*
bezctx* new_bezctx ();
void    bezctx_moveto (bezctx *bc, double x, double y, int is_open);
void    bezctx_lineto (bezctx *bc, double x, double y);
void    bezctx_quadto (bezctx *bc, double x1, double y1, double x2, double y2);
void    bezctx_curveto (bezctx *bc, double x1, double y1, double x2, double y2,
                        double x3, double y3);
void    bezctx_mark_knot (bezctx *bc, int knot_idx);
*/

//
extern(C)
struct bezctx {
    // Called by spiro to start a contour 
    void function(bezctx *bc, double x, double y, int is_open) moveto;

    // Called by spiro to move from the last point to the next one on a straight line 
    void function(bezctx *bc, double x, double y) lineto;

    // Called by spiro to move from the last point to the next along a quadratic bezier spline 
    // (x1,y1) is the quadratic bezier control point and (x2,y2) will be the new end point 
    void function(bezctx *bc, double x1, double y1, double x2, double y2) quadto;

    // Called by spiro to move from the last point to the next along a cubic bezier spline 
    // (x1,y1) and (x2,y2) are the two off-curve control point and (x3,y3) will be the new end point 
    void function(bezctx *bc, double x1, double y1, double x2, double y2, double x3, double y3) curveto;

    void function(bezctx *bc, int knot_idx) mark_knot;
};
