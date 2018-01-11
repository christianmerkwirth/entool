#include <cmath>
#include <vector>
#include <algorithm>

using namespace std;

inline double mysign(const double x)
{
	if (x > 0)
		return 1.0;
	else if (x < 0)
		return -1.0;
	else
		return 0.0;
}

struct absolute_insensitive {
	const double eps;

	absolute_insensitive(const double e) : eps(e) {};

	double operator()(const double soll, const double ist) const
	{
		const double d = fabs(soll - ist) - eps;

		if (d > 0)
			return d;
		else	
			return 0;		
	}		
};

struct squared {
	double operator()(const double soll, const double ist) const
	{
		const double d = soll - ist;
		return d*d;		
	}
};

inline double sqared_insensitive_der(const double x, const double eps)
{
	if (x > eps)
		return x-eps;
	else if (x < -eps)
		return x+eps;
	else
		return 0;
}

struct squared_insensitive {
	const double eps;

	squared_insensitive(const double e) : eps(e) {};

	double operator()(const double soll, const double ist) const
	{
		const double d = sqared_insensitive_der(soll-ist,eps);
		return d*d;	
	}		
};

// Einfacher sampleweiser Fehler
template<class LOSS>
double samplewise_error(const LOSS& lossfun, const mvector& soll, const mvector& ist) 
{
	double err = 0;	
	
	for(int i=1; i <= soll.length(); i++) {				
		err += lossfun(soll(i), ist(i));	
	}
	
	return err/soll.length();
}

// Gewichteter sampleweiser Fehler
template<class LOSS>
double samplewise_error(const LOSS& lossfun, const mvector& soll, const mvector& ist, const vector<double>& weights) 
{
	double err = 0;	
	double sum = 0;	

	for(int i=1; i <= soll.length(); i++) {				
		sum += weights[i-1];
		err += weights[i-1]*lossfun(soll(i), ist(i));	
	}
	
	return err/sum;
}

