// 
// predict3 : predict len next points of an time-series of vector points,
//           using a mixture of local models. models are weighted according to their loo error
// 
//   input arguments :
//    ts - scalar time series 
//
//    All arguments below can be given as scalars or as vectors (all of same length)
//    Each element of the vector will be used for an individual model
//
//	  dim - embedding dimension
//	  delay - time delay in samples
//    len    - length of prediction in samples  - only scalar
//    NNR    - number of nearest neighbours to use for each prediction
//    mode (optional) - method of computing predicted values
//    exp_weighted_factor (optional) - parameter for the euclidian weighted distance calculation, may be choosen out of ]0,1] (see McNames Leuven,Belgium 1998)
// 
//  cmerk 2004
//
// mex -I. -I.. predict3.cpp -O



#include <cmath>

// C++ Standard Template Library
// this files have to be located before(!!!) the #ifdef MATLAB_MEX_FILE sequence,
// otherwise the defines will break the STL
#include <algorithm>
#include <deque>
#include <list>
#include <queue>
#include <vector>
#include <stack>

#include "mextools/mextools.h"

// this includes the code for the nearest neighbor searcher and the prediction routines
#include "NNSearcher/point_set.h"
#include "NNSearcher/nn_predictor.h"
#include "include.mex"

using namespace std;

// Access image of training vector i
template<class POINT_SET>
struct direct_prediction {
	const POINT_SET& points;
	
	direct_prediction(const POINT_SET& p) : points(p) {};
	~direct_prediction() {}

	double operator()(const long i) const {
		return *(points.point_begin(i+1));
	}
};

// Access image of training vector i
template<class POINT_SET>
struct integrated_prediction {
	const POINT_SET& points;
	
	integrated_prediction(const POINT_SET& p) : points(p) {};
	~integrated_prediction() {}

	double operator()(const long i) const {
		return *(points.point_begin(i+1)) - *(points.point_begin(i));
	}
};

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])
{	
    int verbose = 0;
	long i;
	
	/* check input args */
	
	if (nrhs < 5)
	{
		mexErrMsgTxt("Local constant prediction : Time series, dim, delay, length to predict, number of NN must be given, mode (0-3), metric factor and verbose are optional\n");
		return;
	}
	
	/* handle matrix and parameter I/O */
		
	const long N = mxGetM(prhs[0]) * mxGetN(prhs[0]);	
	double* ts = (double *)mxGetPr(prhs[0]);

	const int nr_models = mxGetM(prhs[1]) * mxGetN(prhs[1]);	
	const long length 	= (long) *((double *)mxGetPr(prhs[3]));
	
	if (nrhs > 7) verbose = (long) *((double *)mxGetPr(prhs[7])); 	// verbosity
	
	mvector dims(prhs[1]);
    mvector delays(prhs[2]);
    mvector nnrs(prhs[4]);
    
    mvector modes(nr_models);
    
    if (nrhs > 5) 
        copy((double *)mxGetPr(prhs[5]),((double *)mxGetPr(prhs[5]))+nr_models, modes.begin());
    else
        fill(modes.begin(), modes.end(), 0);
    
    mvector metric_factors(nr_models);    
        
    if (nrhs > 6) 
        copy((double *)mxGetPr(prhs[6]),((double *)mxGetPr(prhs[6]))+nr_models, metric_factors.begin());
    else
        fill(metric_factors.begin(), metric_factors.end(), 1.0);
	
	if (length < 1) {
		mexErrMsgTxt("Length must be greater zero");
		return;
	}		 

	if (verbose) 
	    mexPrintf("Length of input time series     : %d\n", N);
	if (verbose) 
	    mexPrintf("Length of prediction            : %d\n", length);
    if (verbose) 
	    mexPrintf("Number of models     : %d\n", nr_models);
		
	plhs[0] = mxCreateDoubleMatrix(N + length, 1, mxREAL);
	double* const x = (double *) mxGetPr(plhs[0]);
	
	copy(ts, ts + N, x);	// copy time series samples to output
	
	embedded_time_series_point_set<exp_weighted_euclidian_distance> ** point_sets = new (embedded_time_series_point_set<exp_weighted_euclidian_distance>*)[nr_models];
	ATRIA<embedded_time_series_point_set < exp_weighted_euclidian_distance > > ** searchers = new (ATRIA<embedded_time_series_point_set < exp_weighted_euclidian_distance > > *)[nr_models];
	nn_predictor< ATRIA<embedded_time_series_point_set < exp_weighted_euclidian_distance > > > ** predictors = new (nn_predictor< ATRIA<embedded_time_series_point_set < exp_weighted_euclidian_distance > > >*) [nr_models];
	
	mvector last_valid_sample(nr_models);
	mvector validation_errors(nr_models);
	
	for (int model=0; model < nr_models; model++) {
	    long dim =  (long) dims(model+1);
	    long delay = (long) delays(model+1);
	    long NNR = (long) nnrs(model+1);
	    long mode = (long) modes(model+1);
	    double metric_factor = metric_factors(model+1);

        if (verbose) mexPrintf("Model                           : %d\n", model+1);
	    if (verbose) mexPrintf("Reconstruction dimension        : %d\n", dim);
	    if (verbose) mexPrintf("Reconstruction delay            : %d\n", delay);
	    
	    if (verbose) mexPrintf("Number of nearest neighbors     : %d\n", NNR);
	    if (verbose) mexPrintf("Metric factor                   : %f\n", metric_factor);
	    if (verbose) mexPrintf("Mode                            : %d\n", mode);
	    
	    if (dim < 1) {
		    mexErrMsgTxt("Embedding dimension must be greater zero");
		    return;
	    }		
	    if (delay < 1) {
		    mexErrMsgTxt("Time delay must be greater zero");
		    return;
	    }		
		if (NNR < 1) {
		    mexErrMsgTxt("Number of nearest neighbors must be greater zero");
		    return;
	    }		
	    if  ((metric_factor <= 0) || (metric_factor > 1)) {
		    mexErrMsgTxt("Metric factor must be out of ]0,1]");
		    return;
	    }		
	    exp_weighted_euclidian_distance metric(metric_factor);
	
	    embedded_time_series_point_set<exp_weighted_euclidian_distance> dummy(N, dim, delay, ts, metric);
	    
	    if (verbose) mexPrintf("Number of reconstruction points : %d\n", dummy.size());	
	    
	    if (dummy.size() < 3) {
		    mexErrMsgTxt("Time series must too short for given parameters");
		    return;
	    }			
	    
	    last_valid_sample(model+1) = dummy.size();
	    
	    point_sets[model] = new embedded_time_series_point_set<exp_weighted_euclidian_distance>(N + length, dim, delay, x, metric);
	    searchers[model] = new ATRIA<embedded_time_series_point_set < exp_weighted_euclidian_distance > > (*point_sets[model], length + 1);	
	    predictors[model] = new nn_predictor< ATRIA<embedded_time_series_point_set < exp_weighted_euclidian_distance > > >(*searchers[model] );
	
	    if ((*predictors[model]).geterr()) {	
		    mexErrMsgTxt("Error preparing predictor : Inconsistent parameters given ?");
		    return;
	    }
	    
	    double err = 1e-12;
	   
	    // compute the leave-one-out-errors
	    for (long actual_sample = 0; actual_sample < dummy.size()-1; actual_sample++) {    
			const long first = actual_sample - dim*delay;
			const long last = actual_sample + dim*delay;
	   
			double xhat = 0.0;
			
	        switch(mode) {
		        case 1 :
		        {
			biquadratic_weight wg;
			direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv((*point_sets[model]));	
			local_approx< direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , biquadratic_weight> approximator(fv , wg);
				xhat = (*predictors[model]).predict(NNR + 1, (*point_sets[model]).point_begin(actual_sample), approximator, first, last);
                
			break;
		}	
		case 2 :
		{
			constant_weight wg;
			integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv((*point_sets[model]));	
			local_approx< integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , constant_weight> approximator(fv , wg);

		    xhat = *((*point_sets[model]).point_begin(actual_sample)) + (*predictors[model]).predict(NNR, (*point_sets[model]).point_begin(actual_sample), approximator, first, last);          
			break;
		}
		case 3 :
		{
			biquadratic_weight wg;
			integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv((*point_sets[model]));	
			local_approx< integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , biquadratic_weight> approximator(fv , wg);
		    xhat = *((*point_sets[model]).point_begin(actual_sample)) + (*predictors[model]).predict(NNR + 1, (*point_sets[model]).point_begin(actual_sample), approximator, first, last);			
			break;
		}		
		default : 
		{
			constant_weight wg;
			direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv((*point_sets[model]));	
			local_approx< direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , constant_weight> approximator(fv , wg);

			xhat = (*predictors[model]).predict(NNR, (*point_sets[model]).point_begin(actual_sample), approximator, first, last);			
			break;
		            }	
	        }
	        
	        err += (*((*point_sets[model]).point_begin(actual_sample+1)) - xhat)*(*((*point_sets[model]).point_begin(actual_sample+1)) - xhat); 
	    }
	    
	    err /= (dummy.size()-1);
	    err = sqrt(err);
        validation_errors(model+1) = err;
        
	    if (verbose) mexPrintf("LOO-error                       : %f\n", err);
	}
	
	
	// compute the prediction
	for (long t = 0; t < length; t++) {
	    x[N + t] = 0;
	    
	    double modelweight = 0.0;
	    
	    for (int model=0; model < nr_models; model++) {
	        long dim =  (long) dims(model+1);
	        long delay = (long) delays(model+1);
	        long NNR = (long) nnrs(model+1);
	        long mode = (long) modes(model+1);
	        double metric_factor = metric_factors(model+1);
	        
	        const long actual_sample = t + long(last_valid_sample(model+1))-1;
			const long first = actual_sample - dim*delay;
			const long last = (*point_sets[model]).size();
	        
			//mexPrintf("First, last, actual  %d %d %d\n", first, last, actual_sample);	
			
			double a = 0.0;
			
	        switch(mode) {
		        case 1 :
		        {
			biquadratic_weight wg;
			direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv((*point_sets[model]));	
			local_approx< direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , biquadratic_weight> approximator(fv , wg);
		

				a = (*predictors[model]).predict(NNR + 1, (*point_sets[model]).point_begin(actual_sample), approximator, first, last);
                
			break;
		}	
		case 2 :
		{
			constant_weight wg;
			integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv((*point_sets[model]));	
			local_approx< integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , constant_weight> approximator(fv , wg);

				a = x[N + t - 1] + (*predictors[model]).predict(NNR, (*point_sets[model]).point_begin(actual_sample), approximator, first, last);
                
			break;
		}
		case 3 :
		{
			biquadratic_weight wg;
			integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv((*point_sets[model]));	
			local_approx< integrated_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , biquadratic_weight> approximator(fv , wg);

				a = x[N + t - 1] + (*predictors[model]).predict(NNR + 1, (*point_sets[model]).point_begin(actual_sample), approximator, first, last);			
			break;
		}		
		default : 
		{
			constant_weight wg;
			direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > fv((*point_sets[model]));	
			local_approx< direct_prediction<embedded_time_series_point_set < exp_weighted_euclidian_distance > > , constant_weight> approximator(fv , wg);

				a = (*predictors[model]).predict(NNR, (*point_sets[model]).point_begin(actual_sample), approximator, first, last);			
			break;
		            }	
	        }
	        x[N + t] += a  / validation_errors(model+1);
	        modelweight += 1.0 / validation_errors(model+1);
	    }
	    
	    x[N + t] /= modelweight;
	}
	
	for (int model=0; model < nr_models; model++) {
	    delete point_sets[model];
	    delete searchers[model];
	    delete predictors[model];
	}
	
	delete[] point_sets;
	delete[] searchers;
	delete[] predictors;
}	




