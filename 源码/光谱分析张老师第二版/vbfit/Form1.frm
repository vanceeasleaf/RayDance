VERSION 5.00
Begin VB.Form Form1 
   AutoRedraw      =   -1  'True
   Caption         =   "Form1"
   ClientHeight    =   3030
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   4560
   LinkTopic       =   "Form1"
   ScaleHeight     =   3030
   ScaleWidth      =   4560
   StartUpPosition =   3  '窗口缺省
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Option Base 1
'^^^^^^^^^    Main Program of OES-Dfit  ^^^^^^^^^*
'         This program is used to fit the emission spectrum of     *
'         molecular with foruble atoms                            *
'^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
Dim Xorg(20000) As Double, Yorg(20000) As Double, Ycal(50, 20000) As Double, Ysub(20000) As Double, P(50) As Double
Dim Jmax%, Npeak%, NQ%
Attribute Npeak.VB_VarUserMemId = 1073938437
Attribute NQ.VB_VarUserMemId = 1073938437
Dim SP0(100) As Double, SQ0(100) As Double, SR0(100) As Double
Attribute SP0.VB_VarUserMemId = 1073938440
Dim AA(50, 50) As Double
Attribute AA.VB_VarUserMemId = 1073938443
'^^^^^^^^* This is the parameters used in fitting ^^^^^^^^
Dim Xcal, Lvib, G1, G2, B1, B2, Q12
Const Ve = 29671.03
Const KB = 1.38062E-23
Const h0 = 6.6262E-34
Const PI = 3.14159265
Const C0 = 299792500#
Const E0 = 1.602192E-19


Private Sub Form_Load()
    fit
End Sub

'^^^^^^  Calculation of Honl-Lonforn Parameters ^^^^^*
Sub fit()
    Xcal = Array(315.65, 313.44, 311.52, 310.07, 0#, 0#, 0#, 0#, 0#, 0#)    'N2第二正带的(i,i-1)振动带振动峰峰位
    Lvib = Array(1, 2, 3, 4, 0, 0, 0, 0, 0, 0)        '上能级振动量子数
    G1 = Array(2047.178, -28.445, 2.0883, -0.535)
    G2 = Array(1733.391, -14.1221, -0.05688, 0.003612)
    B1 = Array(1.8154, 1.7933, 1.7694, 1.7404, 1.6999)
    B2 = Array(1.6285, 1.6285, 1.6105, 1.5922, 1.5737)
    Q12 = Array(0.4527, 0.3949, 0.3413, 0.2117, 0.126)
    Debug.Print "Please input file name="
    Debug.Print "输入实验数据文件名="
    Dim FLNAME As String
    FLNAME = App.Path & "/T23Hz.txt"
    Npeak = 4                                         '振动峰数量
    Open FLNAME For Input As #3
    Dim Npoint As Integer
    Input #3, Npoint                                  '数据点数量
    Dim i%
    For i = 1 To Npoint
        Input #3, Xorg(i), Yorg(i)
    Next i
    Close (3)
    '^^^^^^^^* Initializing ^^^^^^^^^^^^^^^
    Dim Ishape%
    Ishape = 2                                      '发光峰线性选择0-Lorentz,1-Gauss,2-Voigt
    Jmax = 30                                         '最大转动能级量子数
    Dim Tstep!
    Tstep = 0.3                                       '收敛步长
    Dim Err#
    Err = 0.001                                       '拟合误差限制
    Dim Nmax%
    Nmax = 50                                         '迭代次数限制
    P(1) = 4550#                                      '振动温度初值
    P(2) = 450#                                       '转动温度初值
    P(3) = 0.09                                       '谱仪分辨率初值
    P(4) = 600                                        '背景噪声初值
    P(5) = 2#                                         '比例因子

    NQ = 5
    For i = 1 To Npeak
        Debug.Print "Peak" & i & "=" & Xcal(i)
        P(i + NQ) = Xcal(i)                           '将振动峰峰位设置为拟合参数
    Next i
    Dim Np%
    Np = NQ + Npeak                                   '拟合参数个数
    '^^^^^^^^* the second positive band of N2 ^^^^^^^^
    Dim LM12%
    Dim Ldt%
    LM12 = 1
    Ldt = 0
    Call HONLLONDON(LM12, Ldt)
    '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
    Call Pfit(1, Np, Npoint, Tstep, Err, Nmax, Ishape)
    Debug.Print "标准方差 Error=" & Err                         '标准方差
    Debug.Print "输入拟合结果文件名="
    Dim Fitname$
    Fitname = App.Path & "/fit.txt"
    Open Fitname For Output As #20
    Print #20, "Standard Error=" & Err
    For i = 1 To Np
        Debug.Print "Parameter" & i & "=" & P(i)
        Print #20, "Parameter" & i & "=" & P(i)
    Next i
    '^^^^^^ Fine result simulation ^^^^^^
    For i = 1 To Npoint
        Print #20, Xorg(i), Yorg(i), Ycal(1, i)
    Next i
    '300 continue
    'P(3) = 0.01
    'XRange = Xorg(Npoint) - Xorg(1)
    'Xmin = Xorg(1)
    'Npoint = 20000
    'XStep = XRange / CDbl(Npoint - 1)
    'For i = 1 To Npoint
    '    Xorg(i) = Xmin + XStep * CDbl(i - 1)
    'Next i
    'Call Spectra(Npoint, Ishape)
    'For i = 1 To Npoint
    '    Yorg(i) = Ysub(i)
    '    '     write(30,2000) Xorg(i),Yorg(i)
    '
    'Next i
    'pause
    'Stop

End Sub
'^^^^^^^ Fitting Parameters Optimizing ^^^^^^^^
Sub Pfit(ByVal Nfit As Integer, ByVal Np As Integer, ByVal NZ As Integer, ByVal Tstep!, Err#, ByVal Nmax%, ByVal Ishape%)
'
'      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
'    COMMON/CON3/Jmax,Xcal(10),LVib(10) to Npeak,NQ,P(50)
'    COMMON/Gau/AA(50,50)
'    foruble precision AA,Ysub
    If Nfit = 1 Then
        Dim Y0sum#
        Y0sum = 0#
        Dim j%
        For j = 1 To NZ
            Y0sum = Y0sum + Yorg(j) * Yorg(j)
        Next j
        Dim Niter%
        Niter = 0
        While (True)
            Niter = Niter + 1
            Call PFun(Np, NZ, Ishape)
            Dim DYsum#
            DYsum = 0#
            For j = 1 To NZ
                Ycal(1, j) = Ycal(1, j) - Yorg(j)
                DYsum = DYsum + Ycal(1, j) * Ycal(1, j)
            Next j
            Dim Error#
            Error = DYsum / Y0sum
            Error = Sqr(Error / CDbl(NZ))
            If (Error < Err) Then GoTo 300
            Debug.Print "Iteration=" & Niter & "            Sigma=" & Error
            If (Niter = Nmax) Then GoTo 300
            '^^^^^^^^^^^ 构造高斯矩阵 ^^^^^^^^^*
            Dim i%
            For i = 1 To Np
                For j = 1 To Np
                    AA(i, j) = 0#
                    Dim k%
                    For k = 1 To NZ
                        AA(i, j) = AA(i, j) + Ycal(i + 1, k) * Ycal(j + 1, k)
                        
                    Next k
                Next j
                AA(i, Np + 1) = 0#
                For k = 1 To NZ
                    AA(i, Np + 1) = AA(i, Np + 1) + Ycal(i + 1, k) * Ycal(1, k)
                    
                Next k
            Next i
            
            Call Gauss(Np)
            For j = 1 To Np
                Dim DPJ#
                DPJ = Tstep * AA(j, Np + 1)
                P(j) = P(j) - DPJ
            Next j
        Wend
    End If
300 Err = Error
    For j = 1 To NZ
        Ycal(1, j) = Ycal(1, j) + Yorg(j)
    Next j
End Sub
'^^^^^^^ Optimizing Function ^^^^^^^^
Sub PFun(ByVal NFun As Integer, ByVal NZ As Integer, ByVal Ishape As Integer)
'
'
'      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
'    COMMON/CON1/h0,C0,E0,KB,PI
'      COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
'    COMMON/CON3/Jmax,Xcal(10),LVib(10) to Npeak,NQ,P(50)
    Dim Porg(50) As Double, Y1(20000) As Double, Y2(20000) As Double
    '    foruble precision Ysub
    Dim DP0
    DP0 = 0.0001
    Dim i%
    For i = 1 To NFun
        Porg(i) = P(i)                                '存储拟合参数
    Next i
    Call Spectra(NZ, Ishape)                          '计算发射光谱强度
    For i = 1 To NZ
        Ycal(1, i) = Ysub(i)                          '存储计算的发射光谱强度
    Next i
    Dim j%
    For j = 1 To NFun                                 '拟合参数微分对光谱强度的影响
        Dim DP#
        DP = Porg(j) * DP0
        P(j) = Porg(j) - DP
        Call Spectra(NZ, Ishape)
        For i = 1 To NZ
            Y1(i) = Ysub(i)
        Next i
        P(j) = Porg(j) + DP
        Call Spectra(NZ, Ishape)
        For i = 1 To NZ
            Y2(i) = Ysub(i)
        Next i
        For i = 1 To NZ
            Dim DY12#
            DY12 = 0.5 * (Y2(i) - Y1(i)) / DP
            Ycal(j + 1, i) = DY12
        Next i
        P(j) = Porg(j)
    Next j
End Sub
'^^^^^^^^* Calculation of the fitting spectra ^^^^^^^^
Private Sub Spectra(NZ As Integer, Ishape As Integer)
'      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
'    COMMON/CON1/h0,C0,E0,KB,PI
'      COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
'    COMMON/CON3/Jmax,Xcal(10),LVib(10) to Npeak,NQ,P(50)
'    foruble precision Ysub
'Real KB
    Dim i%
    For i = 1 To NZ
        Ysub(i) = 0#
    Next i
    For i = 1 To Npeak
        Dim V1#
        V1 = CDbl(Lvib(i)) + 0.5
        Dim Gup#
        Gup = G1(1) * V1 + G1(2) * V1 ^ 2 + G1(3) * V1 ^ 3 + G1(4) * V1 ^ 4
        Dim Tup#
        Tup = (Gup * h0 * C0 * 100#) / KB             '振动量子数为V1的理论振动能(温度单位)
        Call INTEN(i + 1, Tup, NZ, Ishape)            '光谱强度计算,i+1用于指定振动峰系数
    Next i
    For i = 1 To NZ
        Ysub(i) = Ysub(i) * P(5) + P(4)
    Next i
End Sub

Private Sub HONLLONDON(LM12 As Integer, Ldt As Integer)
'COMMON/Honl/SP0(100),SQ0(100),SR0(100)
    Dim j%
    Dim SP#, SQ#, SR#
    For j = 0 To 99
        If (Ldt = 0) Then
            SP = CDbl((j + 1 + LM12) * (j + 1 - LM12) / (j + 1))
            If (j > 0) Then
                SR = CDbl((j + LM12) * (j - LM12) / j)
            Else
                SR = 0#
            End If
            If (LM12 > 0) Then
                If (j > 0) Then
                    SQ = CDbl((2 * j + 1) * LM12 * LM12 / (j * (j + 1)))
                Else
                    SQ = 0#
                End If
            Else
                SQ = 0#
            End If
        End If
        If (Ldt = 1) Then
            SP = CDbl((j + 1 - LM12) * (j + 2 - LM12) / (j + 1) / 4)
            If (j > 0) Then
                SR = CDbl((j + LM12) * (j - 1 + LM12) / j / 4)
                SQ = CDbl((2 * j + 1) * (j + LM12) * (j + 1 - LM12) / (4 * j * (j + 1)))
            Else
                SR = 0#
                SQ = 0#
            End If
        End If
        If (Ldt = -1) Then
            SP = CDbl((j + 1 + LM12) * (j + 2 + LM12) / (j + 1) / 4)
            If (j > 0) Then
                SR = CDbl((j - LM12) * (j - 1 - LM12) / j / 4)
                SQ = CDbl((2 * j + 1) * (j - LM12) * (j + 1 + LM12) / (4 * j * (j + 1)))
            Else
                SR = 0#
                SQ = 0#
            End If
        End If
        SP0(j + 1) = SP
        SQ0(j + 1) = SQ
        SR0(j + 1) = SR
    Next j
End Sub
'^^^^^^^^^^ Intensity calculation ^^^^^^^^^^
Sub INTEN(N As Integer, T00 As Double, Npoint As Integer, Ishape As Integer)
'      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
'    COMMON/CON1/h0,C0,E0,KB,PI
'      COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
'    COMMON/CON3/Jmax,Xcal(10),LVib(10) to Npeak,NQ,P(50)
'    COMMON/Honl/SP0(100),SQ0(100),SR0(100)
'    foruble precision Ysub
'    Real KB
    Dim Tvib#
    Tvib = P(1)
    Dim Trot#
    Trot = P(2)
    Dim Whalf#
    Whalf = P(3)
    Dim G12#
    G12 = 10000000# / P(N - 1 + NQ) - Ve
    Dim W#
    W = 2# * PI * C0 * G12
    Dim D1#, D2#, DStep#, Nrange#
    D1 = 4# * B1(N) ^ 3 / W ^ 2
    D2 = 4# * B2(N) ^ 3 / W ^ 2
    DStep = (Xorg(Npoint) - Xorg(1)) / CDbl(Npoint - 1)    '数据步长估计
    Nrange = 1# / DStep                               '发光峰数据点范围
    Dim j%
    For j = 0 To Jmax
        Dim Fup#, Tup#, FP#, FQ#, FR#, SP#, SQ#, SR#, FP12#, FQ12#, FR12#
        Fup = j * (j + 1) * (B1(N) - D1 * j * (j + 1))    '上能级转动能(波数单位)
        Tup = Fup * h0 * C0 * 100# / KB               '计算转动能(温度单位)
        FP = (j + 2) * (j + 1) * (B2(N) - D2 * (j + 2) * (j + 1))    '下能级转动能(波数单位)
        FQ = j * (j + 1) * (B2(N) - D2 * j * (j + 1))    '下能级转动能(波数单位)
        FR = j * (j - 1) * (B2(N) - D2 * j * (j - 1))    '下能级转动能(波数单位)
        SP = SP0(j + 1)
        SQ = SQ0(j + 1)
        SR = SR0(j + 1)
        FP12 = Fup - FP                               '上下能级转动能量差
        FQ12 = Fup - FQ                               '上下能级转动能量差
        FR12 = Fup - FR                               '上下能级转动能量差
        Dim WP#, WQ#, WR#, WLP#, WLQ#, WLR#
        WP = 10000000# / P(N - 1 + NQ) + FP12         '计算发射光谱波数
        WQ = 10000000# / P(N - 1 + NQ) + FQ12
        WR = 10000000# / P(N - 1 + NQ) + FR12
        WLP = 10000000# / WP                          '计算发射光谱波长(单位nm)
        WLQ = 10000000# / WQ                          '计算发射光谱波长(单位nm)
    
        WLR = 10000000# / WR                          '计算发射光谱波长(单位nm)
        WP = 0.0001 * WP
        WQ = 0.0001 * WQ
        WR = 0.0001 * WR
        Dim PP#, PQ#, PR#, NWL#, Imin#, Imax#
        PP = WP ^ 4 * Q12(N) * Exp(-T00 / Tvib) * SP * Exp(-Tup / Trot)  '计算发射强度
        PQ = WQ ^ 4 * Q12(N) * Exp(-T00 / Tvib) * SQ * Exp(-Tup / Trot)    '计算发射强度
        PR = WR ^ 4 * Q12(N) * Exp(-T00 / Tvib) * SR * Exp(-Tup / Trot)    '计算发射强度
        NWL = Int((WLQ - Xorg(1)) / DStep + 0.5) + 1 'wlqP(N - 1 + NQ)
        Imin = NWL - Nrange
        Imax = NWL + Nrange
        If Imin < 1 Then Imin = 1
        If Imax > Npoint Then Imax = Npoint
        
        If Ishape = 1 Then
            '^^^^^^^^^* Gauss Function for Peak ^^^^^^^^^
            Dim Wgauss#, XX#, DXP#, DXQ#, DXR#
            Wgauss = 1# / Sqr(PI / 2#) / Whalf        'Gauss函数系数
            Dim i%
            For i = Imin To Imax
                XX = Xorg(i)
                DXP = -2# * ((XX - WLP) / Whalf) ^ 2
                DXQ = -2# * ((XX - WLQ) / Whalf) ^ 2
                DXR = -2# * ((XX - WLR) / Whalf) ^ 2
                Ysub(i) = Ysub(i) + Wgauss * (PP * Exp(DXP) + PQ * Exp(DXQ) + PR * Exp(DXR))
            Next i
        Else
            '^^^^^^^^^* Lorentz Function for Peak ^^^^^^^^^
            If (Ishape = 0) Then
                Dim WLorentz#
                WLorentz = 2 * Whalf / PI            'Lorentz函数系数
                For i = Imin To Imax
                    XX = Xorg(i)
                    DXP = 4 * (XX - WLP) ^ 2 + Whalf ^ 2
                    DXQ = 4 * (XX - WLQ) ^ 2 + Whalf ^ 2
                    DXR = 4 * (XX - WLR) ^ 2 + Whalf ^ 2
                    Ysub(i) = Ysub(i) + WLorentz * (PP / DXP + PQ / DXQ + PR / DXR)
                Next i
            Else
                '^^^^^^^^^* Voigt Function for Peak ^^^^^^^^^
                Dim Ratio#, Para#
                Ratio = 0.5
                Para = Log(4)
                Wgauss = Ratio * Para / Sqr(PI / 2) / Whalf    'Gauss函数系数
                For i = Imin To Imax
                    XX = Xorg(i)
                    DXP = -2 * Para * ((XX - WLP) / Whalf) ^ 2
                    DXQ = -2 * Para * ((XX - WLQ) / Whalf) ^ 2
                    DXR = -2 * Para * ((XX - WLR) / Whalf) ^ 2
                    Ysub(i) = Ysub(i) + Wgauss * (PP * Exp(DXP) + PQ * Exp(DXQ) + PR * Exp(DXR))
                Next i
                WLorentz = (1 - Ratio) * 2# * Whalf / PI    'Lorentz函数系数
                For i = Imin To Imax
                    XX = Xorg(i)
                    DXP = 4 * (XX - WLP) ^ 2 + Whalf ^ 2
                    DXQ = 4 * (XX - WLQ) ^ 2 + Whalf ^ 2
                    DXR = 4 * (XX - WLR) ^ 2 + Whalf ^ 2
                    Ysub(i) = Ysub(i) + WLorentz * (PP / DXP + PQ / DXQ + PR / DXR)
                Next i
            End If
        End If
    Next j
End Sub
'^^^^^^^ Gauss Eqution Soluting ^^^^^^^^
Private Sub Gauss(Np)
'    COMMON/Gau/AA(50,50)
'    foruble precision A
    Dim k%, Amax#, Imax#
    For k = 1 To Np
        Amax = 0#
        Imax = 1
        Dim i%
        For i = k To Np
            If (Abs(AA(i, k)) > Amax) Then
                Amax = Abs(AA(i, k))
                Imax = i
            End If
        Next i
        If (Abs(Amax) < 1E-32) Then
            Debug.Print k, k, Amax
            AA(Imax, k) = 1#
        End If
        Dim j%
        For j = k To Np + 1
            Dim T#
            T = AA(k, j)
            AA(k, j) = AA(Imax, j)
            AA(Imax, j) = T
        Next j
        Amax = AA(k, k)
        For j = k To Np + 1
            AA(k, j) = AA(k, j) / Amax
        Next j
        For i = k + 1 To Np
            T = AA(i, k)
            For j = k To Np + 1
                AA(i, j) = AA(i, j) - T * AA(k, j)
            Next j
        Next i
    Next k
    For k = Np To 1 Step -1
        T = AA(k, Np + 1)
        For i = k - 1 To 1 Step -1
            AA(i, Np + 1) = AA(i, Np + 1) - T * AA(i, k)
        Next i
    Next k
End Sub

