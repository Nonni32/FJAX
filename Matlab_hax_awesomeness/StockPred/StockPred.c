// Stock Prediction using Geometric Brownian Motion
// Authors: Karan Mendiratta, Vinay C Patil, April 2010
// Dependent Libraries/Files: koolplot (C++ application for plotting), stockprediction.m (GARCH model to get sigma and mu)

#include <iostream>
#include <fstream>
#include <math.h>
#include <stdio.h>
#include "koolplot.h"
#include <iomanip>

using namespace std;

#define IA 16807
#define IM 2147483647
#define AM (1.0/IM)
#define IQ 127773
#define IR 2836
#define NTAB 32
#define NDIV (1+(IM-1)/NTAB)
#define EPS 1.2e-7
#define RNMX (1.0-EPS)


//---------Called by gasdev() to generate random numbers normally distributed (0,1)-------//

float ran1(long idum) {
    int j;
    long k;
    static long iy = 0;
    static long iv[NTAB];
    float temp;

    if (idum <= 0 || !iy) {
        if (-idum < 1) idum=1;
        else idum = -idum;
        for (j = NTAB+7;j >= 0;j--) {
            k = idum/IQ;
            idum=IA*(idum-k*IQ)-IR*k;
            if (idum < 0) idum += IM;
            if (j < NTAB) iv[j] = idum;
        }
        iy=iv[0];
    }
    k = idum/IQ;
    idum = IA*(idum-k*IQ)-IR*k;
    if (idum < 0) idum += IM;
    j=iy/NDIV;
    iy=iv[j];
    iv[j] = idum;
    temp=(float)AM*iy;
    if (temp > RNMX) return (float)RNMX;
    else return temp;
}

#undef IA
#undef IM
#undef AM
#undef IQ
#undef IR
#undef NTAB
#undef NDIV
#undef EPS
#undef RNMX

//---------------Quasi-Normal Random number generator:: Numerical Recepies---------------------//

float gasdev(long idum)
{
    float ran1(long idum);
    static int iset=0;
    static double gset;
    double fac,rsq,v1,v2;

    if (iset == 0) {
        do {
            v1=2.0*ran1(idum)-1.0;
            v2=2.0*ran1(idum)-1.0;
            rsq=v1*v1+v2*v2;
        } while (rsq >= 1.0 || rsq == 0.0);
        fac=sqrt(-2.0*log(rsq)/rsq);
        gset=v1*fac;
        iset=1;
        return (float)(v2*fac);
    } else {
        iset=0;
        return (float)gset;
    }
}
class CGBMotion
{
public:

    long IDUM; // used by Numerical Recepies::gasdev
    double Initial; // initial security value
    double Drift; //------  drift
    double Sigma; //------ volatility
    double CurrentTime; //-------- current elapsed time
    double CurrentDiffusion; //------- how much the process has diffused
public:
//------------------------ constructor----------------------------//
CGBMotion(double nSInitial,long seed)
{
    Initial = nSInitial;
    CurrentTime = 0;
    CurrentDiffusion = 0;
    IDUM = seed;
}
void step(double nTime)
{
   double nDeltaT = nTime - CurrentTime; //----------- calculates the time elapsed
   if (nDeltaT > 0)
   {

//--------------------- add to our diffusion relative to sqrt of elapsed time and update the current time----------------//

       CurrentDiffusion += sqrt(nDeltaT) * gasdev(IDUM);


    CurrentTime = nTime;
   }
}

//--------------Using GEOMETRIC BROWNIAN MOTION formula to calculate current value of stock based on different parameters...........//

double getCurrentValue(double nDrift,double nSigma)
{

 Drift = nDrift;
 Sigma = nSigma;

    return Initial * exp(Drift*CurrentTime- .5* Sigma * Sigma*CurrentTime + Sigma*CurrentDiffusion);
}

//-------------------------Reset time and diffusion -----------------------//
void reset()
{
    CurrentTime = 0;
    CurrentDiffusion = 0;
}

};

//-------------------------Main()-----------------------------//

int main()
{
//--------------Reading volatility values obtained from the MATLAB garch(1,1)-------------//

fstream rdfile("H:/quincy/work/forcastge.txt", ios::in);

int j;
double temp[30],init;
double sig[10],mean[10],newv[10];

rdfile >> init;
printf("%f\n",init);

for(int i=0;!rdfile.eof();i++)
{
rdfile >> temp[i];
}

for(int i=0;i<10;i++)
{
sig[i]=temp[i];
mean[i]=temp[i+10];
newv[i]=temp[i+20];
printf("%f \t %f \n",sig[i],mean[i]);
}
newv[9]=newv[8];
rdfile.close();


GBMotion oGBM(init,-5); //------ Geometric Brownian Motion Object with initial value
			//-------of stock being read from the file with seed as -5 -------//

//-----------C++ plotting application initialization-------------//
plotdata x(-1.0, 1.0),y = x;

clear(x);
clear(y);

fstream File;

double t = 0;
x << 0;
y << init;

File.open("Data2.xls", ios::out);

if (File.is_open ())
{

   File << 0 << "\t";
   File << init << "\t";
   File << newv[0] << "\n";

//----------------Predicting the stock price for the future 10 days (1st day above) and writing results to an excel file for plotting using Origin----------//
   for (int i = 0; i < 9; i++)
   {

      oGBM.reset();

//--------------- 10 time steps----------------//

      for (int j = 0; j < 10; j++)
      {
         t = t + .00001;
         oGBM.step(t);
      }

      File<< i+1<<"\t";
      File<< oGBM.getCurrentValue(mean[i],sig[i])+b[i] <<"\t";
      File << newv[i+1] << "\n";
      cout<<endl;

        double y_value = oGBM.getCurrentValue(mean[i],sig[i])+b[i];
        x << i+1;
        y << y_value;

      printf("%02d: Simulated value %lf \n", i, oGBM.getCurrentValue(mean[i],sig[i])+b[i]);
      init = y_value;
      }

}
File.close();
//----------------Plotting the Forecasted values(RED) vs Actual values(BLUE)-----------------//

setColor(x,y,BLUE);
for(int i=0;i<10;i++)
{
x << i;
y << newv[i];
}
plot(x,y,RED);

return 0;
}
