// intensity.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include "math.h"
#include "stdio.h"
extern "C" __declspec(dllexport) void __stdcall inten(
					 int N,
					 double T00,
					 double P[],
					 int NQ,
					 double B1[],
					 double B2[],
					 double Xorg[],
					 int pointNumber,
					 int Jmax,
					 double SP0[],
					 double SQ0[],
					 double SR0[],
					 double Q12[],
					 int Ishape,
					 double Ysub[]); 
extern "C" __declspec(dllexport) void __stdcall gauss(double AA[][50],int parameterNumber);
const double Ve=29671.03;
const double KB = 1.38062E-23;
const double h0 = 6.6262E-34;
const double PI = 3.14159265;
const double C0 = 299792500.0;
const double E0 = 1.602192E-19;
BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
	switch( ul_reason_for_call ) 

{ 

case DLL_PROCESS_ATTACH: 

case DLL_THREAD_ATTACH: 

case DLL_THREAD_DETACH: 

case DLL_PROCESS_DETACH: 

break; 

} 
    return TRUE;
}
//我的函数 

void __stdcall gauss(double AA[][50],int parameterNumber)
{
    int k,Imax;
    double Amax;
	double T;
	int i;
    for(k = 1;k<=parameterNumber;k++)
       {
        Amax = 0.0;
        Imax = 1;        

        
        for(i = k;i<=parameterNumber;i++)
           {
            if(fabs(AA[i][k]) > Amax)
               {
                Amax = fabs(AA[i][k]);
                Imax = i;
               }
           }
        if(fabs(Amax) < 1.0E-32)
           {
           // Debug.Print k, k, Amax
            //printf("%d,%d,%f",k,k,Amax);
            AA[Imax][k] = 1.0;
           }
        int j;
        for( j = k;j<=parameterNumber + 1;j++)
           {

            T = AA[k][j];
            AA[k][j] = AA[Imax][j];
            AA[Imax][j] = T;
           }
        Amax = AA[k][k];
        for(j = k;j<=parameterNumber + 1;j++)
           {
            AA[k][j] = AA[k][j] / Amax;
           }
        for(i = k + 1;i<=parameterNumber;i++)
           {
            T = AA[i][k];
            for(j = k;j<=parameterNumber + 1;j++)
               {
                AA[i][j] = AA[i][j] - T * AA[k][j];
               }
           }
          }
    for(k = parameterNumber;k>=1;k--)
        {
        T = AA[k][parameterNumber + 1];
        for(i = k - 1;i>=1;i--)
           {
            AA[i][parameterNumber + 1] = AA[i][parameterNumber + 1] - T * AA[i][k];
           }
        }
}



void __stdcall inten(
					 int N,
					 double T00,
					 double P[],
					 int NQ,
					 double B1[],
					 double B2[],
					 double Xorg[],
					 int pointNumber,
					 int Jmax,
					 double SP0[],
					 double SQ0[],
					 double SR0[],
					 double Q12[],
					 int Ishape,
					 double Ysub[])
{
    double Tvib;
    Tvib = P[1];
    double Trot;
    Trot = P[2];
    double Whalf;
    Whalf = P[3];
    double G12;
    G12 = 10000000 / P[N - 1 + NQ] - Ve;
    double W;
    W = 2 * PI * C0 * G12;
    double D1, D2, DStep, Nrange;
   // D1 = 4 * B1[N] ^ 3 / W ^ 2;
   // D2 = 4 * B2[N] ^ 3 / W ^ 2;
     D1 = 4 * pow(B1[N],3.0) /pow(W, 2.0);
    D2 = 4 * pow(B2[N],3.0) / pow(W, 2.0);
    DStep = (Xorg[pointNumber] - Xorg[1])/ double(pointNumber - 1);    //数据步长估计
    Nrange = 1 / DStep;                               //发光峰数据点范围
    int i,j;
    for(j = 0;j<= Jmax;j++)
       {
        double Fup, Tup, FP, FQ, FR, SP, SQ, SR, FP12, FQ12, FR12;
        Fup = j * (j + 1) * (B1[N] - D1 * j * (j + 1));    //上能级转动能(波数单位)
        Tup = Fup * h0 * C0 * 100 / KB ;              //计算转动能(温度单位)
        FP = (j + 2) * (j + 1) * (B2[N] - D2 * (j + 2) * (j + 1));    //下能级转动能(波数单位)
        FQ = j * (j + 1) * (B2[N] - D2 * j * (j + 1)) ;   //下能级转动能(波数单位)
        FR = j * (j - 1) * (B2[N] - D2 * j * (j - 1));    //下能级转动能(波数单位)
        SP = SP0[j + 1];
        SQ = SQ0[j + 1];
        SR = SR0[j + 1];
        FP12 = Fup - FP;                               //上下能级转动能量差
        FQ12 = Fup - FQ;                              //上下能级转动能量差
        FR12 = Fup - FR;                               //上下能级转动能量差
        double WP, WQ, WR, WLP, WLQ, WLR;
        WP = 10000000 / P[N - 1 + NQ] + FP12;         //计算发射光谱波数
        WQ = 10000000 / P[N - 1 + NQ] + FQ12;
        WR = 10000000 / P[N - 1 + NQ] + FR12;
        WLP = 10000000 / WP ;                         //计算发射光谱波长(单位nm)
        WLQ = 10000000/ WQ;                          //计算发射光谱波长(单位nm)
        WLR = 10000000 / WR ;                         //计算发射光谱波长(单位nm)
        WP = 0.0001 * WP;
        WQ = 0.0001 * WQ;
        WR = 0.0001 * WR;
        double PP, PQ, PR, NWL,Imax;;
			int Imin;
        PP = pow(WP,4) * Q12[N] * exp(-T00 / Tvib) * SP * exp(-Tup / Trot);    //计算发射强度
        PQ = pow(WQ,4) * Q12[N] * exp(-T00 / Tvib) * SQ * exp(-Tup / Trot);    //计算发射强度
        PR = pow(WR,4) * Q12[N] * exp(-T00 / Tvib) * SR * exp(-Tup / Trot);    //计算发射强度
        NWL = int((WLQ - Xorg[1]) / DStep + 0.5) + 1;  //wlqP(N - 1 + NQ);
        Imin =int( NWL - Nrange);
        Imax = NWL + Nrange;
        if(Imin < 1)  Imin = 1;
        if(Imax > pointNumber) Imax = pointNumber;
 double Wgauss;
	 		double XX, DXP, DXQ, DXR; 
 double WLorentz;
        if(Ishape == 1)
           {
            //^^^^^^^^^* Gauss Function for Peak ^^^^^^^^^
           
            Wgauss = 1 / sqrt(PI / 2) / Whalf;        //Gauss函数系数
            int i;
            for(i = int(Imin);i<=Imax;i++)
               {
                XX = Xorg[i];
                DXP = -2.0 * pow(((XX - WLP) / Whalf),2);
                DXQ = -2.0 * pow(((XX - WLQ) / Whalf),2);
                DXR = -2.0 * pow(((XX - WLR) / Whalf),2);
                Ysub[i] = Ysub[i] + Wgauss * (PP * exp(DXP) + PQ * exp(DXQ) + PR * exp(DXR));
               }
        }
            //^^^^^^^^^* Lorentz Function for Peak ^^^^^^^^^
			else{
				if(Ishape == 0) {
              
                WLorentz = 2 * Whalf / PI;             //Lorentz函数系数
                for(i =int(Imin);i<= Imax;i++)
                   {
			
                    XX = Xorg[i];
                    DXP = 4 * pow((XX - WLP), 2) + pow(Whalf,2);
                    DXQ = 4 * pow((XX - WLQ), 2) + pow(Whalf,2);
                    DXR = 4 * pow((XX - WLR), 2) + pow(Whalf, 2);
                    Ysub[i] = Ysub[i] + WLorentz * (PP / DXP + PQ / DXQ + PR / DXR);
                   }
				}
			
            else{
                //^^^^^^^^^* Voigt Function for Peak ^^^^^^^^^
                double Ratio, Para;
                Ratio = 0.5;
                Para = log(4);
                Wgauss = Ratio * Para / sqrt(PI / 2) / Whalf;    //Gauss函数系数
                for(i =int( Imin);i<= Imax;i++)
                   {
                    XX = Xorg[i];
                    DXP = -2 * Para * pow(((XX - WLP) / Whalf),2);
                    DXQ = -2 * Para * pow(((XX - WLQ) / Whalf),2);
                    DXR = -2 * Para * pow(((XX - WLR) / Whalf),2);
                    Ysub[i] = Ysub[i] + Wgauss * (PP * exp(DXP) + PQ * exp(DXQ) + PR * exp(DXR));
                   }
                WLorentz = (1 - Ratio) * 2 * Whalf / PI;    //Lorentz函数系数
                for( i =int( Imin);i<= Imax;i++)
                   {
                    XX = Xorg[i];
                    DXP = 4 * pow((XX - WLP),2) + pow(Whalf,2);
                    DXQ = 4 * pow((XX - WLQ),2) + pow(Whalf,2);
                    DXR = 4 * pow((XX - WLR),2) + pow(Whalf,2);
                    Ysub[i] = Ysub[i] + WLorentz * (PP / DXP + PQ / DXQ + PR / DXR);
                    }
              }
       }
     }
}