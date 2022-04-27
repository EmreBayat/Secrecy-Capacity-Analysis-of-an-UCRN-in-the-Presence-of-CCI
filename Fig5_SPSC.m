
clear all;clc ;close all;

N = 1e6; %iterasyon

Pmax_dB = 1; %maximum transmission limit
Pmax = 10.^(0.1*Pmax_dB);

p_dB = 0;        % Secrecy Treshold in dB
p=10.^(0.1*p_dB);%Secrecy Treshold.

I_dB = 4; %makale de 2 dB diyor
I = 10.^(0.1*I_dB); %Imax interference limit
%I = 1;

%LD = 2;
%LR = 2;

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
Setup = [1 1; 1 2; 2 1; 2 2; 3 3]; % LR ve LD

for kk=1:5
    
    LR=Setup(kk,1);   LD=Setup(kk,2);

for jj = 1:length(Ps_vec)

hr  = sqrt(Setup(kk,1)/2) *(randn(1,N) + 1i*randn(1,N));% Channel Gain of hr - CCI
hd  = sqrt(Setup(kk,2)/2) *(randn(1,N) + 1i*randn(1,N));% Channel Gain of hd - CCI
hpr = sqrt(Setup(kk,1)/2) *(randn(1,N) + 1i*randn(1,N)); % hpr primary interference -->r c ve r eþit olmalý
hpd = sqrt(Setup(kk,2)/2) *(randn(1,N) + 1i*randn(1,N)); %
        
hr_square  =  abs(hr).^2;% Channel Coefficient hr - CCI
hd_square  =  abs(hd).^2;  % Channel Coefficient hd - CCI
hpr_square = abs(hpr).^2 ;
hpd_square = abs(hpd).^2 ;  
    
    
    
    
    
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

SPSC(kk,jj) = length(find(C_e2e>=0))./N % Equation (9)
% SPSC_SR(jj) = length(find(SR_SPC>0))./N
% SPSC_RD(jj) = length(find(SD_SPC>0))./N

end

end


 semilogy(Ps_vec,SPSC(1,:)),hold on
 semilogy(Ps_vec,SPSC(2,:)),
 semilogy(Ps_vec,SPSC(3,:)),
 semilogy(Ps_vec,SPSC(4,:))
 semilogy(Ps_vec,SPSC(5,:))


 
 Theo_SPSC_1_1=[0.182754, 0.288317, 0.413468, 0.54325, 0.662517, 0.76148, 0.837193,0.891688, 0.92923, 0.954322, 0.970755, 0.981375, 0.988178, 0.992513,0.995265, 0.997008];
 Theo_SPSC_1_2=[0.108708,0.185621,0.289068,0.411187,0.538258,0.656098,0.755048,0.831679,0.887428,0.926162,0.952213,0.969349,0.980456,0.987585,0.992133,0.995023];
 Theo_SPSC_2_1=[0.108708,0.185621,0.289068,0.411187,0.538258,0.656098,0.755048,0.831679,0.887428,0.926162,0.952213,0.969349,0.980456,0.987585,0.992133,0.995023];
 Theo_SPSC_2_2=[0.0649628,0.120504,0.202296,0.313228,0.437305,0.5653,0.680963,0.775708,0.847507,0.898832,0.934024,0.95747,0.972794,0.982682,0.989012,0.993042];
 %Theo_SPSC_3_3=[0.0341862, 0.0686724, 0.127253, 0.215001, 0.329481, 0.459215 0.587885 0.701383 0.792322 0.859983 0.907676 0.940047 0.961463 0.975394 0.984357 0.990082];
Theo_SPSC_3_3=[0.0321862, 0.0601055, 0.0988574, 0.178658, 0.27804, 0.390075,0.519844, 0.641814, 0.744899, 0.824878, 0.883024, 0.923359, 0.950443,0.968234, 0.979754, 0.987143];
%  Theo_SPSC_1_1=[0.076919 0.139918 0.231806 0.348643 0.478131 0.604357 0.714359 0.801809 0.86657 0.912094 0.942945 0.963337 0.976595 0.985122 0.990568 0.994031];
%  Theo_SPSC_1_2=[0.0617524 0.115583 0.197651 0.307024 0.433974 0.563055 0.679648 0.77502 0.847176 0.898683 0.93396 0.957443 0.972782 0.982678 0.98901 0.993042]
%  Theo_SPSC_2_1=[0.0617524 0.115583 0.197651 0.307024 0.433974 0.563055 0.679648 0.77502 0.847176 0.898683 0.93396 0.957443 0.972782 0.982678 0.98901 0.993042]
%  Theo_SPSC_2_2=[0.0495762 0.0954807 0.168529 0.270372 0.393894 0.524576 0.646624 0.749125 0.828216 0.885469 0.92506 0.951586 0.968985 0.98024 0.987455 0.992054]
%  Theo_SPSC_3_3=[0.0341862, 0.0686724, 0.127253, 0.215001, 0.329481, 0.459215 0.587885 0.701383 0.792322 0.859983 0.907676 0.940047 0.961463 0.975394 0.984357 0.990082]


  semilogy(Ps_vec,Theo_SPSC_1_1,'ok'),
  semilogy(Ps_vec,Theo_SPSC_1_2,'rd','markersize',10),
  semilogy(Ps_vec,Theo_SPSC_2_1,'ok'),
  semilogy(Ps_vec,Theo_SPSC_2_2,'ok'),
  semilogy(Ps_vec,Theo_SPSC_3_3,'ok'),


xlabel('The average SINR of the main link (dB)'),ylabel('SPSC')
grid,legend('L_R,\sigma^2_{pr},\sigma^2_{ir},L_D,\sigma^2_{pd},\sigma^2_{id}= 1'...
,'L_R,\sigma^2_{pr},\sigma^2_{ir}=2, L_D,\sigma^2_{pd},\sigma^2_{id}= 1'...
,'L_R,\sigma^2_{pr},\sigma^2_{ir}=1, L_D,\sigma^2_{pd},\sigma^2_{id}= 2'...
,'L_R,\sigma^2_{pr},\sigma^2_{ir},L_D,\sigma^2_{pd},\sigma^2_{id}= 2'...
,'L_R,\sigma^2_{pr},\sigma^2_{ir},L_D,\sigma^2_{pd},\sigma^2_{id}= 3'...
,'Analytical')
xlabel('The average SINR of the main links (dB)'),ylabel('SPSC')

axis([0 30 1e-2 1.1])



