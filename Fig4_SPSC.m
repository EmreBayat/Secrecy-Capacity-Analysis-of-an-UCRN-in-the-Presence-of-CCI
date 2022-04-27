
clear all;clc ;close all;

N = 1e6; %iterasyon

Pmax_dB = 1; %maximum transmission limit
Pmax = 10.^(0.1*Pmax_dB);

p_dB = 0;        % Secrecy Treshold in dB
p=10.^(0.1*p_dB);%Secrecy Treshold.

I_dB = 2; %makale de 2 dB diyor
I = 10.^(0.1*I_dB); %Imax interference limit
%I = 1;

LD = 2;
LR = 2;

%var_sr = 3; var_rd = 3; % Beta Variance
var_re = 1; var_se = 1; % Epsilon variance
var_sp = 2; var_rp = 2; % Alpha Variance
var_r  = 1; var_d  = 1; %Lambda Variance
var_pr = 1; var_pd = 1;

%hsr = sqrt(var_sr/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hsr
%hrd = sqrt(var_rd/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hrd
hre = sqrt(var_re/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hre
hse = sqrt(var_se/2)*(randn(1,N) + 1i*randn(1,N));% Channel Gain of hse
hsp = sqrt(var_sp/2)*(randn(1,N) + 1i*randn(1,N));% Channel Gain of hsp
hrp = sqrt(var_rp/2)*(randn(1,N) + 1i*randn(1,N));% Channel Gain of hrp
hr  = sqrt(var_r/2) *(randn(1,N) + 1i*randn(1,N));% Channel Gain of hr - CCI
hd  = sqrt(var_d/2) *(randn(1,N) + 1i*randn(1,N));% Channel Gain of hd - CCI
hpr = sqrt(var_pr/2) *(randn(1,N) + 1i*randn(1,N)); % hpr primary interference -->r c ve r eþit olmalý
hpd = sqrt(var_pd/2) *(randn(1,N) + 1i*randn(1,N)); %
        


%hsr_square = abs(hsr).^2; % Channel Coefficient hsr
%hrd_square = abs(hrd).^2; % Channel Coefficient hrd
hre_square = abs(hre).^2;% Channel Coefficient hre
hse_square = abs(hse).^2;% Channel Coefficient hse
hsp_square = abs(hsp).^2;% Channel Coefficient hsp
hrp_square = abs(hrp).^2;% Channel Coefficient hrp
hr_square  =  abs(hr).^2;% Channel Coefficient hr - CCI
hd_square  =  abs(hd).^2;  % Channel Coefficient hd - CCI
hpr_square = abs(hpr).^2 ;
hpd_square = abs(hpd).^2 ;



Ps_vec=0:2:30;
Setup = [1 1; 2 1; 1 2; 2 2; 3 3]

for kk=1:5
    
var_sr = Setup(kk,1); var_rd = Setup(kk,2); % Beta Variance
hsr = sqrt(var_sr/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hsr
hrd = sqrt(var_rd/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hrd
hsr_square = abs(hsr).^2; % Channel Coefficient hsr
hrd_square = abs(hrd).^2; % Channel Coefficient hrd

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

C_SR =  log2(1+Y_SR); % Equation (8)
C_SE =  log2(1+Y_SE); % Equation (8)

C_RD = log2(1+Y_RD); % Equation (8)
C_RE = log2(1+Y_RE); % Equation (8)

%C_FirstHop  = C_SR./C_SE;% Equation (8) - Denklem 8'in ilk terimi
%C_SecondHop = C_RD./C_RE;% Equation (8)- Denklem 8'in ikinci terimi

SR_SPC = C_SR-C_SE;
SD_SPC = C_RD-C_RE;


C_e2e = min(SR_SPC,SD_SPC);% Equation (8)

SPSC(kk,jj) = length(find(C_e2e>0))./N % Equation (9)
% SPSC_SR(jj) = length(find(SR_SPC>0))./N
% SPSC_RD(jj) = length(find(SD_SPC>0))./N

end

end

 figure,
 semilogy(Ps_vec,SPSC(1,:)),hold on
 semilogy(Ps_vec,SPSC(2,:)),
 semilogy(Ps_vec,SPSC(3,:))
 semilogy(Ps_vec,SPSC(4,:))
 semilogy(Ps_vec,SPSC(5,:))




%semilogy(Ps_vec, SPSC_SR.*SPSC_RD,'Linewidth',1,'Color',[0.0,1.0,0.0],'LineStyle','--');

Theo_SPSC_1_1=[0.0495762 0.0954807 0.168529 0.270372 0.393894 0.524576 0.646624 0.749125 0.828216 0.885469 0.92506 0.951586 0.968985 0.98024 0.987455 0.992054]
Theo_SPSC_1_2=[0.0798791 0.14381 0.236132 0.352686 0.481322 0.606512 0.71563 0.80248 0.866895 0.912242 0.943009 0.963364 0.976606 0.985126 0.99057 0.994032];
Theo_SPSC_2_1=[0.0798791 0.14381 0.236132 0.352686 0.481322 0.606512 0.71563 0.80248 0.866895 0.912242 0.943009 0.963364 0.976606 0.985126 0.99057 0.994032];
Theo_SPSC_2_2=[0.128704 0.216603 0.330854 0.46006 0.588155 0.701247 0.791999 0.859634 0.90738 0.939824 0.961306 0.975288 0.984287 0.990037 0.993694 0.996013];
Theo_SPSC_3_3=[0.204571 0.316117 0.444351 0.573411 0.688827 0.7824 0.85268 0.90257 0.9366 0.959192 0.97392 0.98341 0.989478 0.993339 0.995789 0.997339];
%semilogy(Ps_vec, SPSC1,'Linewidth',1,'Color',[0.0,1.0,0.0],'LineStyle','--');

%Theo_SPSC_CCIandPrimaryInterference = [0.00352962 0.0228159 0.0712217 0.156021 0.275893 0.416975 0.558329 0.682393 0.780715 0.853036 0.903526 0.937547 0.959941 0.974458 0.983777 0.98972];
%Theo_SPSC_CCIandPrimaryInterference1=[0.0594106 0.151049 0.266874 0.394995 0.525255 0.645736 0.747214 0.826071 0.883581 0.9236 0.95054 0.96827 0.979766 0.987146 0.991855 0.994847]


 semilogy(Ps_vec,Theo_SPSC_1_1,'ok'),
 semilogy(Ps_vec,Theo_SPSC_1_2,'rd','markersize',10),
 semilogy(Ps_vec,Theo_SPSC_2_1,'ok'),
 semilogy(Ps_vec,Theo_SPSC_2_2,'ok'),
 semilogy(Ps_vec,Theo_SPSC_3_3,'ok'),


xlabel('The average SINR of the main links (dB)'),ylabel('SPSC')
grid,legend('\sigma^2_{sr}=1, \sigma^2_{rd}=1','\sigma^2_{sr}=2, \sigma^2_{rd}=1','\sigma^2_{sr}=1, \sigma^2_{rd}=2','\sigma^2_{sr}=2, \sigma^2_{rd}=2','\sigma^2_{sr}=3, \sigma^2_{rd}=3','Analytical')



axis([0 30 0.3*1e-1 1.1])



