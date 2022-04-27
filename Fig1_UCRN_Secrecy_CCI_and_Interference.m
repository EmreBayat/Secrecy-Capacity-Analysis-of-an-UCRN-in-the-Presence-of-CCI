
clear all;clc ;close all;

N = 1e6; %iterasyon

Pmax_dB = 1; %maximum transmission limit
Pmax = 10.^(0.1*Pmax_dB);

p=10.^(0.1*1);%Secrecy Treshold.

I = 10.^(0.1*2); %Imax interference limit
%I = 1;

LD = 2;
LR = 2;

var_sr = 2; var_rd = 2; % Beta Variance
var_re = 1; var_se = 1; % Epsilon variance
var_sp = 2; var_rp = 2; % Alpha Variance
var_r  = 1; var_d  = 1; %Lambda Variance
var_pr = 1; var_pd = 1;

hsr = sqrt(var_sr/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hsr
hrd = sqrt(var_rd/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hrd
hre = sqrt(var_re/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hre
hse = sqrt(var_se/2)*(randn(1,N) + 1i*randn(1,N));% Channel Gain of hse
hsp = sqrt(var_sp/2)*(randn(1,N) + 1i*randn(1,N));% Channel Gain of hsp
hrp = sqrt(var_rp/2)*(randn(1,N) + 1i*randn(1,N));% Channel Gain of hrp
hr  = sqrt(var_r/2) *(randn(1,N) + 1i*randn(1,N));% Channel Gain of hr - CCI
hd  = sqrt(var_d/2) *(randn(1,N) + 1i*randn(1,N));% Channel Gain of hd - CCI
hpr = sqrt(var_pr/2) *(randn(1,N) + 1i*randn(1,N)); % hpr primary interference -->r c ve r eþit olmalý
hpd = sqrt(var_pd/2) *(randn(1,N) + 1i*randn(1,N)); %
        


hsr_square = abs(hsr).^2; % Channel Coefficient hsr
hrd_square = abs(hrd).^2; % Channel Coefficient hrd
hre_square = abs(hre).^2;% Channel Coefficient hre
hse_square = abs(hse).^2;% Channel Coefficient hse
hsp_square = abs(hsp).^2;% Channel Coefficient hsp
hrp_square = abs(hrp).^2;% Channel Coefficient hrp
hr_square  =  abs(hr).^2;% Channel Coefficient hr - CCI
hd_square  =  abs(hd).^2;  % Channel Coefficient hd - CCI
hpr_square = abs(hpr).^2 ;
hpd_square = abs(hpd).^2 ;



Ps_vec=0:2:30;
A = 10.^(0.1.*Ps_vec);

for jj = 1:length(Ps_vec)

Pss = 10^(0.1*Ps_vec(jj));    
    
    
PS = min(Pmax,(I./hsp_square)); % Equation (1)
PR = min(Pmax,(I./hrp_square)); % Equation (2)

%Y_SR = (Pmax(jj))./(1 +(hr_square.*LD) );% Equation (3)                                     
%Y_RD = (Pmax(jj))./(1 +(hd_square.*LR) ); %Equation (4)                                           

Y_SR = (PS.*Pss.*hsr_square)./(1 +(hr_square.*LD)+hpr_square );% Equation (3)                                     
Y_RD = (PR.*Pss.*hrd_square)./(1 +(hd_square.*LR)+hpd_square ); %Equation (4)                                           

Y_RE = (PR.*hre_square);% Equation (7)
Y_SE = (PS.*hse_square);% Equation (6)

C_SR =  (1+Y_SR); % Equation (8)
C_SE =  (1+Y_SE); % Equation (8)

C_RD = (1+Y_RD); % Equation (8)
C_RE = (1+Y_RE); % Equation (8)

C_FirstHop  = C_SR./C_SE;% Equation (8) - Denklem 8'in ilk terimi
C_SecondHop = C_RD./C_RE;% Equation (8)- Denklem 8'in ikinci terimi
C_e2e = min(C_FirstHop,C_SecondHop);% Equation (8)

%%%%%%%%%%%%%%%%%%%%%%%%NO_CCI Hesaplanýyor%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Y_SR_NoCCI = (PS.*Pss.*hsr_square)./(1 +(hr_square.*LD) );% Equation (3)                                     
Y_RD_NoCCI  = (PR.*Pss.*hrd_square)./(1 +(hd_square.*LR) ); %Equation (4)                                           

Y_RE_NoCCI  = (PR.*hre_square);% Equation (7)
Y_SE_NoCCI  = (PS.*hse_square);% Equation (6)

C_SR_NoCCI  =  (1+Y_SR_NoCCI); % Equation (8)
C_SE_NoCCI  =  (1+Y_SE_NoCCI); % Equation (8)

C_RD_NoCCI  = (1+Y_RD_NoCCI); % Equation (8)
C_RE_NoCCI  = (1+Y_RE_NoCCI); % Equation (8)

C_FirstHop_NoCCI   = C_SR_NoCCI./C_SE_NoCCI;% Equation (8) - Denklem 8'in ilk terimi
C_SecondHop_NoCCI  = C_RD_NoCCI./C_RE_NoCCI;% Equation (8)- Denklem 8'in ikinci terimi
C_e2e_NoCCI  = min(C_FirstHop_NoCCI,C_SecondHop_NoCCI);% Equation (8)


SOP(jj) = length(find(C_e2e<p))./N % Equation (9)
SOP_NoCCI(jj) = length(find(C_e2e_NoCCI<p))./N % Equation (9)


end



semilogy(Ps_vec, (SOP),'Linewidth',1,'Color',[1.0,0.0,0.0],'LineStyle','-');
hold on
semilogy(Ps_vec, (SOP_NoCCI),'Linewidth',1,'Color',[0.0,0.0,1.0],'LineStyle','-');


%Hsr = 2 HRD = 2 HSP = 2 K =1 
Teo_CCI=[0.97247 0.923248 0.839213 0.721401 0.582894 0.443543 0.320393 0.222074 0.149287 0.0982164 0.0636777 0.0408865 0.0260873 0.016577 0.0105069 0.00664868];

%Hsr = 2 HRD = 2 HSP = 2 K =1 
Teo_NoCCI = [0.940329 0.861806 0.749671 0.614736 0.475021 0.347956 0.243948 0.165413 0.109498 0.0712923 0.0459044 0.0293428 0.0186681 0.0118409 0.00749604 0.00473966];

semilogy(Ps_vec, (Teo_CCI),'Linewidth',1,'Color',[0.0,0.0,0.0],'LineStyle','none','Marker','o');
semilogy(Ps_vec, (Teo_NoCCI),'Linewidth',1,'Color',[0.0,0.0,0.0],'LineStyle','none','Marker','o');

xlabel('The average SINR main links (dB)'),ylabel('SOP')
legend('Our study','[22]','Analytical');
grid on

 %a=[0.992398, 0.972048, 0.928164, 0.851768, 0.741376, 0.607467, 0.468642,0.342639, 0.239805, 0.162375, 0.107375, 0.069858, 0.0449583, 0.0287284, 0.0182733, 0.0115892];


%semilogy(Ps_vec, (a),'Linewidth',1,'Color',[0.0,0.0,1.0],'LineStyle','-');


