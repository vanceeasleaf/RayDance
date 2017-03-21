package 
{
	import flash.display.MovieClip;
	
	public class SpectraFit extends MovieClip
	{
		
		//***************** the second positive band of N2 ****************
		//DATA Q12/0.1330,0.2536,0.3367,0.0,0.0/      //2-0 Franck-Confor(n因子
		//DATA Q12/0.3949,0.3413,0.2117,0.126,0.0///1-0 Franck-Confor(n因子
		private var Q12:Array = [null,0.4527,0.02157,0.02348,0.08817,0.1075];//0-0 Franck-Confor(n因子
		//DATA Q12/0.3291,0.2033,0.06345,0.004811,0.003908///0-1 Franck-Confor(n因子
		//DATA Q12/0.1462,0.1990,0.1605,0.09426,0.04242///0-2 Franck-Confor(n因子
		//DATA Xcal/297.50,296.00,295.02,0.0,0.0,0.0,0.0,0.0,0.0,0.0///2-0
		//DATA Xcal/315.6,313.4,311.5,310.0,0.0,0.0,0.0,0.0,0.0,0.0/  //1-0
		private var Xcal:Array = [null,337.0,333.6,330.5,328.6,326.6,0.0,0.0,0.0,0.0,0.0];//0-0
		//   DATA Xcal/357.6,353.6,349.9,346.8,344.5,0.0,0.0,0.0,0.0,0.0///0-1
		//DATA Xcal/380.0,375.2,370.5,367.0,364.0,0.0,0.0,0.0,0.0,0.0///0-2
		//N2第二正带的(V1,V2)振动带振动峰峰位
		private var Lvib:Array = [null,0,1,2,3,4,5,6,7,8,9];//上能级振动量子数
		private var paraNumber:int;     //拟合参数个数
		private var pointsNumber:int;   //点个数
		private var Tstep:Number = 0.5;//收敛步长
		private var Err:Number = 1.0E-3;//拟合误差限制
		private var Nmax:int = 30;//迭代次数限制
		private var peaksNumber:int = 5;//振动峰数量
		private var Ratio=0.5//发光峰线性选择0-Lorentz,1-Gauss,(0,1)-Voigt
		private var PRange = 3.0;//发光峰范围(nm)
		private var jmax = 85;//最大转动能级量子数
		private var NQ = 5;
		/*数据存储*/
		private var Xorg:Array = [];
		private var Yorg:Array = [];
		private var Ycal:Array = [];
		private var Ysub:Array = [];
		private var F10:Array = [];
		private var F11:Array = [];
		private var F12:Array = [];
		private var F20:Array = [];
		private var F21:Array = [];
		private var F22:Array = [];
		private var SP1:Array = [];
		private var SQ1:Array = [];
		private var SR1:Array = [];
		private var SP2:Array = [];
		private var SQ2:Array = [];
		private var SR2:Array = [];
		private var SP3:Array = [];
		private var SQ3:Array = [];
		private var SR3:Array = [];
		private const h0 = 6.6262E-34;
		private const C0 = 2.997925E8;
		private const E0 = 1.602192E-19;
		private const KB = 1.38062E-23;
		private const Pi = 3.14159265;
		private const Be1 = 1.82473;
		private const Ae1 = 0.018683;
		private const Ge1 = -2.275e-3;
		private const A1 = 39.51;
		private const Be2 = 1.63745;
		private const Ae2 = 0.017906;
		private const Ge2 = -7.71e-5;
		private const A2 = 42.2564;
		private var P:Array = [];
		private var N0:int = 0;           //第二正带振动峰带头量子数
		private var Nd:int = 0;           //第二正带振动峰量子数差值
		/*转动常数*/
		private var G1:Array = [null,2047.178,-28.445,2.0883,-0.535];
		private var G2:Array = [null,1733.391,-14.1221,-0.05688,0.003612];
		private var AA:Array = [];//1.82473
		private var LM12:int = 1;//与第二正带有关的控制参数
		private var Ldt:int = 0;//与第二正带有关的控制参数
		/* 初始化 */
		public function SpectraFit()
		{
			Txt.read('H00.txt',Xorg,Yorg,init);
		}
		//导入数据，完成后执行init;
		//};
		function init():void
		{
			
			//var LM12:int = 1;//与第二正带有关的控制参数
			//var Ldt:int = 0;//与第二正带有关的控制参数
			HONLLONDON(4,8);
			Rotation(4,8,1.0,1.0);
			pointsNumber=Xorg.length -1;//数据点数量
			//***************** initializing ******************************
			P[1] = 4550.0;//振动温度初值
			P[2] = 450.0;//转动温度初值
			P[3] = 2.0e-4;//谱仪分辨率初值
			P[4] = 800;//背景噪声初值
			P[5] = 0.1;//比例因子
			for (var i:int =1; i<=peaksNumber; i++)
			{
				trace('Peak'+i+'='+Xcal[i]);
				P[i + NQ] = Xcal[i];//将振动峰峰位设置为拟合参数
			}
			paraNumber = NQ + peaksNumber;//拟合参数个数
			//*****************************************************************
			Pfit(1);
			trace('标准方差 Error='+Err);
			//标准方差;
			for (i=1; i<=paraNumber; i++)
			{
				trace( 'Parameter'+i+'='+P[i]);
			}
			for (i=1; i<=pointsNumber; i++)
			{
			trace( Xorg[i]+' '+Yorg[i]+' '+Ycal[1][i]);
			}
			/*var ifine:int=0 //精细光谱输出控制
			if (ifine==0) return;
			//************ Fine result simulation ************
			trace('输入精细光谱分辨率=')
			read (*,*) P(3)  //谱仪分辨率设置
			XRange=Xorg(pointsNumber)-Xorg(1)
			Xmin=Xorg(1)
			pointsNumber=int(10.0*XRange/P(3))
			if (pointsNumber>20000) pointsNumber=20000
			var XStep:Number=XRange/(pointsNumber-1)
			for(i=1;i<=pointsNumber;i++){
			Xorg(i)=Xmin+XStep*Number(i-1)
			}
			spectra()
			for( i=1;i<=pointsNumber;i++){
			Yorg(i)=Ysub(i)
			write(30,2000) Xorg(i),Yorg(i)
			}*/
			
		}

		//************** Fitting Parameters Optimizing ****************
		function Pfit(NFit:int):void
		{
			if (NFit==1)
			{
				var Y0sum:Number = 0.0;
				for (var j:int=1; j<=pointsNumber; j++)
				{
					Y0sum +=  Yorg[j] * Yorg[j];
				}
				for (var Niter:int=0; Niter<=Nmax; Niter++)
				{
					PFun();
					var DYsum:Number = 0.0;
					for (j=1; j<=pointsNumber; j++)
					{
						//trace(" "+Xorg[j]+"  "+Ycal[1][j]);                //可能光强计算函数出了问题
						Ycal[1][j] -=  Yorg[j];
						DYsum +=  Ycal[1][j] * Ycal[1][j];
					}
					var Error:Number = DYsum / Y0sum;
					//trace("Y0sum="+Y0sum+"\n"+" DYsum="+ DYsum);
					Error=Math.sqrt(Error/Number(pointsNumber));
					//trace("Error="+Error);
					if ((Error)<Err)
					{
						break;
					}
					trace('iteration='+Niter+'            Sigma='+Error);
					//********************** 构造高斯矩阵 *******************
					for (var i:int=1; i<=paraNumber; i++)
					{
						AA[i] = [];
						for (j=1; j<=paraNumber; j++)
						{
							AA[i][j] = 0.0;
							for (var k:int=1; k<=pointsNumber; k++)
							{
								AA[i][j] +=  Ycal[i + 1][k] * Ycal[j + 1][k];
							}
						}
						AA[i][paraNumber + 1] = 0.0;
						for (k=1; k<=pointsNumber; k++)
						{
							AA[i][paraNumber+1]+=Ycal[i+1][k]*Ycal[1][k];
						}
					}		
			/*		for(j=1;j<=11;j++){
					for(i=1;i<=10;i++){
						
						trace(i+' '+j+' '+AA[i][j]);
					}
					}*/
					Gauss();
					
					for (j=1; j<=paraNumber; j++)
					{
						var DPj:Number = Tstep * AA[j][paraNumber + 1];
						P[j] = P[j] - DPj;
					}
					trace(111);
				}
				Err = Error;
			}
			
			for (j=1; j<=pointsNumber; j++)
			{
				Ycal[1][j] +=  Yorg[j];
			}
		}
		//************** Optimizing Function ****************
		function PFun():void
		{
			var DP0 = 0.0001;
			var Porg:Array = [];
			for (var i:int=1; i<=paraNumber; i++)
			{
				Porg[i] = P[i];//存储拟合参数
			}
			Spectra();//计算发射光谱强度
			Ycal[1] = [];
			for (i=1; i<=pointsNumber; i++)
			{
				Ycal[1][i] = Ysub[i];//存储计算的发射光谱强度
			}
			for (var  j:int=1; j<=paraNumber; j++)
			{
				//拟合参数微分对光谱强度的影响
				Ycal[j + 1] = [];
				var DP = Porg[j] * DP0;
				P[j] = Porg[j] - DP;
				Spectra();
				var Y1:Array = [];
				for (i=1; i<=pointsNumber; i++)
				{
					Y1[i] = Ysub[i];
				}
				P[j] = Porg[j] + DP;
				Spectra();
				var Y2:Array = [];
				for (i=1; i<=pointsNumber; i++)
				{
					Y2[i] = Ysub[i];
				}
				for (i=1; i<=pointsNumber; i++)
				{
					var DY12=0.5*(Y2[i]-Y1[i])/DP;
					Ycal[j + 1][i] = DY12;
					
				}
				P[j] = Porg[j];
			}
			
		}
		
		//***************** Calculation of the fitting spectra ****************
		function Spectra():void
		{
			
			for (var i:int =1; i<=pointsNumber; i++)
			{
				Ysub[i] = 0.0;
			}
			var Dstep=(Xorg[pointsNumber]-Xorg[1])/Number(pointsNumber-1);//数据步长估计
			var NRange:int = int(PRange / Dstep);   //发光峰数据点范围
			var const1:Number = h0 * C0 * 100.0 / KB;
			var Tvib = P[1];
			var Trot = P[2];
			var Doppl=7.2e-7*Math.sqrt(Trot/28.0);  //Doppler展宽因子
			var Resol = P[3];
			var Qvib = 0.0;
			var P0 = 1e-12;//光谱强度控制
			for (i=0; i<=5; i++)
			{
				var V1 = Number(i) + 0.5;
				var Gup = G1[1] * V1 + G1[2] * V1 * V1 + G1[3] * V1 * V1 * V1 + G1[4] * V1 * V1 * V1 * V1;
				var T00 = Gup * const1;   //振动量子数为V1的理论振动能(温度单位)
				Qvib = Qvib + Math.exp( -  T00 / Tvib);
			
			}
			for (i=1; i<=peaksNumber; i++)
			{
				var N1:int = Lvib[N0 + i] + 1; //上能级振动量子数+1
				jmax = 85;
				if (N1==2)
				{
					jmax = 65;
				}//Predissociation
				if (N1==3)
				{
					jmax = 55;
				}//Predissociation
				if (N1==4)
				{
					jmax = 43;
				}//Predissociation
				if (N1==5)
				{
					jmax = 28;
				}//Predissociation
			
				var N2:int = N1 - Nd + 1;   //下能级振动量子数+1
				V1=Number(N1-1)+0.5;
				var V2 = V1 - Number(Nd);
				Gup = G1[1] * V1 + G1[2] * V1 * V1 + G1[3] * V1 * V1 * V1 + G1[4] * V1 * V1 * V1 * V1;
				T00 = Gup * const1;        //振动量子数为V1的理论振动能(温度单位)
				//****************** 发射强度计算基于麦克斯韦分布假设 *****************
				for (var j:int=0; j<=jmax; j++)
				{
					var Fup = F10[N1][j + 1];//上能级转动能(波数单位)
					var Tup = Fup * const1;//上能级转动能(温度单位)
					var PD = P0 * Q12[i] * Math.exp( -  T00 / Tvib) * Math.exp( -  Tup / Trot) / Qvib / Trot;
					//****************** Pi0支P支发射强度计算 *****************
					var jP:int = j + 1;
					var SP = SP1[N1][N2][j + 1];
					
					var FP = F20[N2][jP + 1];//下能级P转动能(波数单位)
					var FP12 = Fup - FP;//上下能级转动能量差
					var WP = 1.0E7 / P[i + NQ] + FP12;//计算P支发射光谱波数
					var WLP = 1.0E7 / WP;//计算P支发射光谱波长(单位nm)
					var PP = WP * WP * WP * WP * PD * SP;//计算发射强度
					var NWL=int((WLP-Xorg[1])/Dstep+0.5)+1;//计算发射光谱中心波长位置
					var imin = NWL - NRange;
					var imax = NWL + NRange;
					if (imin<1)
					{
						imin = 1;
					}
					if (imax>pointsNumber)
					{
						imax = pointsNumber;
					}
					FPeak(Resol,WLP,imin,imax,PP,Doppl);
					//****************** Pi0支R支发射强度计算 *****************
					var jR:int = j - 1;
					if (jR>=0)
					{
						var SR = SR1[N1][N2][j + 1];
						var FR = F20[N2][jR + 1];//下能级R转动能(波数单位)
						var FR12 = Fup - FR;//上下能级转动能量差
						var WR = 1.0E7 / P[i + NQ] + FR12;//计算R支发射光谱波数
						var WLR = 1.0E7 / WR;//计算R支发射光谱波长(单位nm)
						var PR = WR * WR * WR * WR * PD * SR;//计算发射强度
						NWL=int((WLR-Xorg[1])/Dstep+0.5)+1;//计算发射光谱中心波长位置
						imin = NWL - NRange;
						imax = NWL + NRange;
						if (imin<1)
						{
							imin = 1;
						}
						if (imax>pointsNumber)
						{
							imax = pointsNumber;
						}
						FPeak(Resol,WLR,imin,imax,PR,Doppl);
					}
				}
				for (j=1; j<=jmax; j++)
				{
					Fup = F11[N1][j + 1];//上能级转动能(波数单位)
					Tup = Fup * const1;//上能级转动能(温度单位)
					PD = P0 * Q12[i] * Math.exp( -  T00 / Tvib) * Math.exp( -  Tup / Trot) / Qvib / Trot;
					//****************** Pi1支P支发射强度计算 *****************
					jP = j + 1;
					SP = SP2[N1][N2][j + 1];
					FP = F21[N2][jP + 1];  //下能级P转动能(波数单位)
					FP12 = Fup - FP;        //上下能级转动能量差
					WP = 1.0E7 / P[i + NQ] + FP12;//计算P支发射光谱波数
					WLP = 1.0E7 / WP;//计算P支发射光谱波长(单位nm)
					PP = WP * WP * WP * WP * PD * SP;//计算发射强度
					NWL=int((WLP-Xorg[1])/Dstep+0.5)+1;//计算发射光谱中心波长位置
					imin = NWL - NRange;
					imax = NWL + NRange;
					if (imin<1)
					{
						imin = 1;
					}
					if (imax>pointsNumber)
					{
						imax = pointsNumber;
					}
					FPeak(Resol,WLP,imin,imax,PP,Doppl);
					//****************** Pi1支Q支发射强度计算 *****************
					var jQ:int = j;
					var SQ = SQ2[N1][N2][j + 1];
					var FQ = F21[N2][jQ + 1];                 //下能级Q转动能(波数单位)
					var FQ12 = Fup - FQ;                      //上下能级转动能量差
					var WQ = 1.0E7 / P[i + NQ] + FQ12;        //计算Q支发射光谱波数
					var WLQ = 1.0E7 / WQ;                     //计算Q支发射光谱波长(单位nm)
					var PQ = WP * WP * WP * WP * PD * SQ;         //计算发射强度
					NWL=int((WLQ-Xorg[1])/Dstep+0.5)+1;       //计算发射光谱中心波长位置
					imin = NWL - NRange;
					imax = NWL + NRange;
					if (imin<1)
					{
						imin = 1;
					}
					if (imax>pointsNumber)
					{
						imax = pointsNumber;
					}
					FPeak(Resol,WLQ,imin,imax,PQ,Doppl);
					//****************** Pi1支R支发射强度计算 *****************
					jR = j - 1;
					if (jR>=1)
					{
						SR = SR2[N1][N2][j + 1];
						FR = F21[N2][jR + 1];//下能级R转动能(波数单位)
						FR12 = Fup - FR;//上下能级转动能量差
						WR = 1.0E7 / P[i + NQ] + FR12;//计算R支发射光谱波数
						WLR = 1.0E7 / WR;//计算R支发射光谱波长(单位nm)
						PR = WR * WR * WR * WR * PD * SR;//计算发射强度
						NWL=int((WLR-Xorg[1])/Dstep+0.5)+1;//计算发射光谱中心波长位置
						imin = NWL - NRange;
						imax = NWL + NRange;
						if (imin<1)
						{
							imin = 1;
						}
						if (imax>pointsNumber)
						{
							imax = pointsNumber;
						}
						FPeak(Resol,WLR,imin,imax,PR,Doppl);
					}
				}
				for (j=2; j<=jmax; j++)
				{
					Fup = F12[N1][j + 1];             //上能级转动能(波数单位)
					Tup = Fup * const1;               //上能级转动能(温度单位)
					PD = P0 * Q12[i] * Math.exp( -  T00 / Tvib) * Math.exp( -  Tup / Trot) / Qvib / Trot;
					//****************** Pi2支P支发射强度计算 *****************
					jP = j + 1;
					SP = SP3[N1][N2][j + 1];
					FP = F22[N2][jP + 1];               //下能级P转动能(波数单位)
					FP12 = Fup - FP;                    //上下能级转动能量差
					WP = 1.0E7 / P[i + NQ] + FP12;      //计算P支发射光谱波数
					WLP = 1.0E7 / WP;                   //计算P支发射光谱波长(单位nm)
					PP = WP * WP * WP * WP * PD * SP;   //计算发射强度
					NWL=int((WLP-Xorg[1])/Dstep+0.5)+1; //计算发射光谱中心波长位置
					imin = NWL - NRange;
					imax = NWL + NRange;
					if (imin<1)
					{
						imin = 1;
					}
					if (imax>pointsNumber)
					{
						imax = pointsNumber;
					}
					FPeak(Resol,WLP,imin,imax,PP,Doppl);
					//****************** Pi2支Q支发射强度计算 *****************
					jQ = j;
					SQ = SQ3[N1][N2][j + 1];
					FQ = F22[N2][jQ + 1];//下能级Q转动能(波数单位)
					FQ12 = Fup - FQ;//上下能级转动能量差
					WQ = 1.0E7 / P[i + NQ] + FQ12;//计算Q支发射光谱波数
					WLQ = 1.0E7 / WQ;//计算Q支发射光谱波长(单位nm)
					PQ = WP * WP * WP * WP * PD * SQ;//计算发射强度
					NWL=int((WLQ-Xorg[1])/Dstep+0.5)+1;//计算发射光谱中心波长位置
					imin = NWL - NRange;
					imax = NWL + NRange;
					if (imin<1)
					{
						imin = 1;
					}
					if (imax>pointsNumber)
					{
						imax = pointsNumber;
					}
					FPeak(Resol,WLQ,imin,imax,PQ,Doppl);
					//****************** Pi2支R支发射强度计算 *****************
					jR = j - 1;
					if (jR>=2)
					{
						SR = SR3[N1][N2][j + 1];
						FR = F22[N2][jR + 1];//下能级R转动能(波数单位)
						FR12 = Fup - FR;//上下能级转动能量差
						WR = 1.0E7 / P[i + NQ] + FR12;//计算R支发射光谱波数
						WLR = 1.0E7 / WR;//计算R支发射光谱波长(单位nm)
						PR = WR * WR * WR * WR * PD * SR;//计算发射强度
						NWL=int((WLR-Xorg[1])/Dstep+0.5)+1;//计算发射光谱中心波长位置
						imin = NWL - NRange;
						imax = NWL + NRange;
						if (imin<1)
						{
							imin = 1;
						}
						if (imax>pointsNumber)
						{
							imax = pointsNumber;
						}
						FPeak(Resol,WLR,imin,imax,PR,Doppl);
					}
				}
			}
			for (i=1; i<=pointsNumber; i++)
			{
				Ysub[i] = Ysub[i] * P[5] + P[4];
			}
		}
		//******************* Voigt Function for Peak ******************
		function FPeak(Resol,WL,imin,imax,PT,Doppl):void
		{
			var Para:Number = Math.log(16.0);
			var Wdopp:Number = Doppl * WL;
			var Whalf = Resol * WL + Wdopp;
			var Ratio = Wdopp / Whalf;
			var Wgauss=Ratio*Math.sqrt(Para/Pi)/Whalf;  //Gauss函数系数
			for (var i:int=imin; i<=imax; i++)
			{
				var XX = Xorg[i];
				DX =  -  Para * ((XX - WL) / Whalf) * ((XX - WL) / Whalf);
				Ysub[i] +=  Wgauss * PT * Math.exp(DX);
			}
			var WLorentz = (1.0 - Ratio) * 2.0 * Whalf / Pi;//Lorentz函数系数
			for (i=imin; i<=imax; i++)
			{
				XX = Xorg[i];
				var DX = 4.0 * (XX - WL) * (XX - WL) + Whalf * Whalf;
				Ysub[i] +=  WLorentz * PT / DX;
			}
		}
		//***************** Calculation of rotational energy ****************
		function Rotation(Lvib1,Lvib2,Rl1,Rl2):void
		{
			//Rl1,Rl2 上下能级 电子角动量沿轴向分量量子数
			var W01 = G1[1];
			var W02 = G2[1];
			/*上能级*/
			for (var i:int=0; i<=Lvib1; i++)
			{
				F10[i + 1] = [];//注意数组编号比量子数+1
				F11[i + 1] = [];//注意数组编号比量子数+1
				F12[i + 1] = [];
				var V1 = Number(i) + 0.5;
				var B1 = Be1 - Ae1 * V1 + Ge1 * V1 * V1;//Bv
				var D1=(0.5112+0.222*V1-0.139*V1*V1+0.024*V1*V1*V1)*1e-5;
				var Y1=(A1-0.692*V1+0.111*V1*V1-0.041*V1*V1*V1)/B1;          //A随振动能级增加而减小
				for (var j:int=0; j<=99; j++)
				{
					var Rj = Number(j);
					var Fj=Number(j*(j+1));
					var ZA1 = Rl1 * Rl1 * Y1 * (Y1 - 4.0) + 4.0 / 3.0 + 4.0 * Fj;
					var ZB1=(Rl1*Rl1*Y1*(Y1-1.0)-4.0/9.0-2.0*Fj)/3.0/ZA1;
					var F1=B1*(Fj-Math.sqrt(ZA1)-2.0*ZB1)-D1*(Rj-0.5)*(Rj-0.5)*(Rj-0.5)*(Rj-0.5);//上0转动能(波数单位)
					var F2 = B1 * (Fj + 4.0 * ZB1) - D1 * (Rj + 0.5) * (Rj + 0.5) * (Rj + 0.5) * (Rj + 0.5);//上1转动能(波数单位)
					var F3=B1*(Fj+Math.sqrt(ZA1)-2.0*ZB1)-D1*(Rj+1.5)*(Rj+1.5)*(Rj+1.5)*(Rj+1.5);//上2转动能(波数单位)
					F10[i + 1][j + 1] = F1;//注意数组编号比量子数+1
					F11[i + 1][j + 1] = F2;//注意数组编号比量子数+1
					F12[i + 1][j + 1] = F3;//注意数组编号比量子数+1
				}
			}
			/*下能级*/
			for (i=0; i<=Lvib2; i++)
			{
				F20[i + 1] = [];//注意数组编号比量子数+1
				F21[i + 1] = [];//注意数组编号比量子数+1
				F22[i + 1] = [];
				var V2 = Number(i) + 0.5;
				var B2 = Be2 - Ae2 * V2 + Ge2 * V2 * V2;
				var D2 = (0.5888 + 0.001312 * V2) * 1e-5;
				var Y2=(A2-0.0453*V2-0.00107*V2*V2-1.34e-4)/B2;//A随振动能级增加而减小
				for (j=0; j<=99; j++)
				{
					Rj = Number(j);
					Fj=Number(j*(j+1));
					var ZA2 = Rl2 * Rl2 * Y2 * (Y2 - 4.0) + 4.0 / 3.0 + 4.0 * Fj;
					var ZB2=(Rl2*Rl2*Y2*(Y2-1.0)-4.0/9.0-2.0*Fj)/3.0/ZA2;
					F1=B2*(Fj-Math.sqrt(ZA2)-2.0*ZB2)-D2*(Rj-0.5)*(Rj-0.5)*(Rj-0.5)*(Rj-0.5);           //下0转动能
					F2 = B2 * (Fj + 4.0 * ZB2) - D2 * (Rj + 0.5) * (Rj + 0.5) * (Rj + 0.5) * (Rj + 0.5);//下1转动能
					F3=B2*(Fj+Math.sqrt(ZA2)-2.0*ZB2)-D2*(Rj+1.5)*(Rj+1.5)*(Rj+1.5)*(Rj+1.5);           //下2转动能
					F20[i + 1][j + 1] = F1;
					F21[i + 1][j + 1] = F2;
					F22[i + 1][j + 1] = F3;
				}
			}
		}
		//************  Calculation of Honl-Lonfor(n Parameters ***********
		function HONLLONDON(Lvib1:int,Lvib2:int):void
		{
			//COMMON/Hon1/SP1(5,9,100),SQ1(5,9,100),SR1(5,9,100)
			//COMMON/Hon2/SP2(5,9,100),SQ2(5,9,100),SR2(5,9,100)
			//COMMON/Hon3/SP3(5,9,100),SQ3(5,9,100),SR3(5,9,100)
			var C11:Array = [],C12:Array = [],C13:Array = [],C21:Array = [],C22:Array = [],C23:Array = [];
			var Up1:Array = [],Uq1:Array = [],Up2:Array = [],Uq2:Array = [];
			var Wp1:Array = [],Wq1:Array = [],Wp2:Array = [],Wq2:Array = [];
			for (var i1:int=0; i1<=Lvib1; i1++)
			{
				SP1[i1 + 1] = [];
				SQ1[i1 + 1] = [];
				SR1[i1 + 1] = [];
				SP2[i1 + 1] = [];
				SQ2[i1 + 1] = [];
				SR2[i1 + 1] = [];
				SP3[i1 + 1] = [];
				SQ3[i1 + 1] = [];
				SR3[i1 + 1] = [];
				var V1 = Number(i1) + 0.5;
				var B1 = Be1 - Ae1 * V1 + Ge1 * V1 * V1;
				var Y1 = A1 / B1;
				for (var  i2:int=0; i2<=Lvib2; i2++)
				{
					SP1[i1 + 1][i2 + 1] = [];
					SQ1[i1 + 1][i2 + 1] = [];
					SR1[i1 + 1][i2 + 1] = [];
					SP2[i1 + 1][i2 + 1] = [];
					SQ2[i1 + 1][i2 + 1] = [];
					SR2[i1 + 1][i2 + 1] = [];
					SP3[i1 + 1][i2 + 1] = [];
					SQ3[i1 + 1][i2 + 1] = [];
					SR3[i1 + 1][i2 + 1] = [];
					var V2 = Number(i2) + 0.5;
					var B2 = Be2 - Ae2 * V2 + Ge2 * V2 * V2;
					var Y2 = A2 / B2;
					for (var j:int=0; j<=96; j++)
					{
						var G = Number(j);
						var u01=Math.sqrt(Y1*(Y1-4.0)+4.0*G*G);
						var u02=Math.sqrt(Y2*(Y2-4.0)+4.0*G*G);
						var w01=Math.sqrt(Y1*(Y1-4.0)+4.0*(G+1)*(G+1));
						var w02=Math.sqrt(Y2*(Y2-4.0)+4.0*(G+1)*(G+1));
						Up1[j + 1] = u01 + (Y1 - 2.0);
						Uq1[j + 1] = u01 - (Y1 - 2.0);
						Up2[j + 1] = u02 + (Y2 - 2.0);
						Uq2[j + 1] = u02 - (Y2 - 2.0);
						Wp1[j + 1] = w01 + (Y1 - 2.0);
						Wq1[j + 1] = w01 - (Y1 - 2.0);
						Wp2[j + 1] = w02 + (Y2 - 2.0);
						Wq2[j + 1] = w02 - (Y2 - 2.0);
						C11[j+1]=Y1*(Y1-4)+2*(G+G+1)*(G-1);
						C12[j+1] = Y1 * (Y1 - 4) + 4 * G * (G + 1);
						C13[j+1]=Y1*(Y1-4)*(G-1)*(G+2)+2*(G+G+1)*G*(G+1)*(G+2);
						C21[j+1]=Y2*(Y2-4)+2*(G+G+1)*(G-1);
						C22[j+1] = Y2 * (Y2 - 4) + 4 * G * (G + 1);
						C23[j+1]=Y2*(Y2-4)*(G-1)*(G+2)+2*(G+G+1)*G*(G+1)*(G+2);
						//C系列 输出正确
						/*if(i1==0 &&i2==0)
						{
						trace("C23["+(j+1)+"]="+C23[j+1]);
						}*/
					}
					for (j=0; j<=90; j++)
					{
						var H = Number(j);
						//************  Calculation of Pi0 ********************
						G = H + 1.0;         //j2=j1+1
						var i:int = j + 1;   //j2=j1+1
						var A = 8.0 * (G - 2) * (G - 1) * G * (G + 1);
						var B = (G - 2) * (G + 2) * Uq1[i] * Uq2[i + 1];
						var C = G * G * Up1[i] * Up2[i + 1];
						if (j>=0)
						{
							var D = 1.0 / 16.0 /( G * G * G) / C11[i] / C21[i + 1];
							SP1[i1+1][i2+1][j+1]=(A+B+C)*(A+B+C)*D;
						}
						else
						{
							SP1[i1 + 1][i2 + 1][j + 1] = 0.0;
						}
						G = H - 1.0;   //j2=j1-1
						i = j - 1;     //j2=j1-1
						A = 8.0 * (G - 1) * G * (G + 1) * (G + 2);
						B = (G - 1) * (G + 3) * Uq1[i + 2] * Uq2[i + 1];
						C = (G + 1) * (G + 1) * Up1[i + 2] * Up2[i + 1];
						if (j>=1)
						{
							D = 1.0 / 16.0 / ((G + 1) * (G + 1) * (G + 1)) / C11[i + 2] / C21[i + 1];
							SR1[i1+1][i2+1][j+1]=(A+B+C)*(A+B+C)*D;
						
						}
						else
						{
							SR1[i1 + 1][i2 + 1][j + 1] = 0.0;
						}
						//************  Calculation of Pi1 ********************
						G = H + 1.0;    //j2=j1+1
						i = j + 1;      //j2=j1+1
						A = (Y1 - 2) * (Y2 - 2);
						B = 2.0 * (G - 2) * (G + 2);
						C = 2.0 * G * G;
						if (j>=1)
						{
							D = (G - 1) * (G + 1) / G / C12[i] / C22[i + 1];
							SP2[i1+1][i2+1][j+1]=(A+B+C)*(A+B+C)*D;
						}
						else
						{
							SP2[i1 + 1][i2 + 1][j + 1] = 0.0;
						}
						G = H;     //j2=j1+1
						i = j;     //j2=j1+1
						A = (Y1 - 2) * (Y2 - 2);
						B = 4.0 * (G - 1) * (G + 2);
						C = 0.0;
						if (j>=1)
						{
							D=(G+G+1)/G/(G+1)/C12[j+1]/C22[j+1];
							SQ2[i1+1][i2+1][j+1]=(A+B+C)*(A+B+C)*D;
						}
						else
						{
							SQ2[i1 + 1][i2 + 1][j + 1] = 0.0;
						}
						G = H - 1.0;   //j2=j1-1
						i = j - 1;     //j2=j1-1
						A = (Y1 - 2) * (Y2 - 2);
						B = 2.0 * (G - 1) * (G + 3);
						C = 2.0 * (G + 1) * (G + 1);
						if (j>=2)
						{
							D = G * (G + 2) / (G + 1) / C12[i + 2] / C22[i + 1];
							SR2[i1+1][i2+1][j+1]=(A+B+C)*(A+B+C)*D;
						}
						else
						{
							SR2[i1 + 1][i2 + 1][j + 1] = 0.0;
						}
						//************  Calculation of Pi2 ********************
						G = H + 1.0;   //j2=j1+1
						i = j + 1;     //j2=j1+1
						A = 8.0 * (G - 1) * G * (G + 1) * (G + 2);
						B = (G - 2) * (G + 2) * Wp1[i] * Wp2[i + 1];
						C = G * G * Wq1[i] * Wq2[i + 1];
						if (j>=2)
						{
							D = (G - 1) * (G + 1) / 16.0 / G / C13[i] / C23[i + 1];
							SP3[i1+1][i2+1][j+1]=(A+B+C)*(A+B+C)*D;
						}
						else
						{
							SP3[i1 + 1][i2 + 1][j + 1] = 0.0;
						}
						G = H;//j2=j1+1
						i = j;//j2=j1+1
						A = 4.0 * G * G * (G + 2);
						B = (G - 1) * Wp1[j + 1] * Wp2[j + 1];
						C = 0.0;
						if (j>=2)
						{
							D=(G+2)*(G+2)*(G+G+1)/4.0/G/(G+1)/C13[j+1]/C23[j+1];
							SQ3[i1+1][i2+1][j+1]=(A+B+C)*(A+B+C)*D;
						}
						else
						{
							SQ3[i1 + 1][i2 + 1][j + 1] = 0.0;
						}
						G = H - 1.0;//j2=j1-1
						i = j - 1;//j2=j1-1
						A = 8.0 * G * (G + 1) * (G + 2) * (G + 3);
						B = (G - 1) * (G + 3) * Wp1[i + 2] * Wp2[i + 1];
						C = (G + 1) * (G + 1) * Wq1[i + 2] * Wq2[i + 1];
						if (j>=3)
						{
							D = G * (G + 2) / 16.0 / (G + 1) / C13[i + 2] / C23[i + 1];
							SR3[i1+1][i2+1][j+1]=(A+B+C)*(A+B+C)*D;
						}
						else
						{
							SR3[i1 + 1][i2 + 1][j + 1] = 0.0;
						}
						//trace("SP1["+(i1+1)+"]["+(i2+1)+"]["+(j+1)+"]="+SP1[i1+1][i2+1][j+1]);
					}
				}
			}
		}
		//************** Gauss Equation Soluting ****************
		function Gauss():void
		{
			for (var k:int=1; k<=paraNumber; k++)
			{
				var Amax = 0.0;
				var imax:int = 0;
				for (var  i:int=k; i<=paraNumber; i++)
				{
					if (Math.abs(AA[i][k]) > Amax)
					{
						Amax = Math.abs(AA[i][k]);
						imax = i;
					}
				}
				if (Math.abs(Amax) < 1.0e-32)
				{
					trace( '拟合参数初值设置问题');
					trace( k+' '+k+' '+Amax);
					return;
				}
				for (var  j:int=k; j<=paraNumber+1; j++)
				{
					var T = AA[k][j];
					AA[k][j] = AA[imax][j];
					AA[imax][j] = T;
				}
				Amax = AA[k][k];
				//trace(Amax+'Amax');
				for (j=k; j<=paraNumber+1; j++)
				{
					AA[k][j] = AA[k][j] / Amax;
				}
				for (i=k+1; i<=paraNumber; i++)
				{
					T = AA[i][k];
					for (j=k; j<=paraNumber+1; j++)
					{
						AA[i][j] = AA[i][j] - T * AA[k][j];
					}
				}
			}
			for (k=paraNumber; k>=1; k--)
			{
				T = AA[k][paraNumber + 1];
				for (i=k-1; i>=1; i--)
				{
					AA[i][paraNumber+1]-=T*AA[i][k];
				}
			}
		}
	}
}
