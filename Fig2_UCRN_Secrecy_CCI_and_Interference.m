
clear all;clc ;close all;


N = 1e6; %9*1e6; %iterasyon

Pmax_dB = 1; %0:10:30; %maximum transmission limit
Pmax = 10.^(0.1*Pmax_dB);

p_dB = 1;         % Secrecy Treshold in dB
p = 10.^(0.1*p_dB);% Secrecy Treshold.

I_dB = 2; % sultan deneme, makale de 2 dB diyor
I = 10.^(0.1*I_dB); %Imax interference limit
%I = 1;

LD = 2;
LR = 2;

K = 1; % secondary destination sayýsý

%var_sr = 2; var_rd = 2; % Beta Variance
var_re = 1; var_se = 1; % Epsilon variance
var_sp = 1; var_rp = 1; % Alpha Variance
var_r  = 1; var_d  = 1; %Lambda Variance
var_pr = 1; var_pd = 1;



N0=1;
Ps_vec=0:2:30; %maximum transmission limit

Setup = [1 1; 2 1; 1 2; 2 2; 3 3]; % Beta1 ve Beta2

for kk = 1:max(size(Setup))
    var_sr = Setup(kk,1); var_rd = Setup(kk,2); % Beta Variance
    for jj = 1:length(Ps_vec)
        Pss = 10^(0.1*Ps_vec(jj));
        % kanallarýn üretilmesi
        hsr = sqrt(var_sr/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hsr
        hrd = sqrt(var_rd/2)*(randn(K,N) + 1i*randn(K,N)); % Channel Gain of hrd
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
        
        
        
        PS = min(Pmax,(I./hsp_square)); % Equation (1)
        %Su(jj)=mean(PS);
        PR = min(Pmax,(I./hrp_square)); % Equation (2)
        
        %Y_SR = (Pmax(jj))./(1 +(hr_square.*LD) );% Equation (3)
        %Y_RD = (Pmax(jj))./(1 +(hd_square.*LR) ); %Equation (4)
        
        Y_SR = ((PS./N0).*hsr_square*Pss)./( 1 +(hr_square.*LR)+hpr_square );% Equation (3)
        % Y_RD = (PR)./(1 +(hd_square.*LR) ); %Equation (4)
        for k_iter=1:K
            Eq4(k_iter,:) = hrd_square(k_iter,:)./(1 +(hd_square.*LD)+hpr_square);
        end
        if K==1 % tek dest. durumu
        Y_RD = Pss*(PR./N0).*Eq4(1,:); %Equation (4)  Sultan
        else
        Y_RD = Pss*(PR./N0).*max(Eq4); %Equation (4)  Sultan
        end
                       
        
        Y_RE = (PR/N0).*hre_square;% Equation (7) ok!
        Y_SE = (PS./N0).*hse_square;% Equation (6) ok!
        
        C_SR =  (1+Y_SR); % Equation (8)
        C_SE =  (1+Y_SE); % Equation (8)
        
        C_RD = (1+Y_RD); % Equation (8)
        C_RE = (1+Y_RE); % Equation (8)
        
               
        C_FirstHop  = C_SR./C_SE;% Equation (8) - Denklem 8'in ilk terimi
        C_SecondHop = C_RD./C_RE;% Equation (8)- Denklem 8'in ikinci terimi
        
        SOP_event = 0;
        
%         for ww=1:N
%             
%             C_e2e(ww) = min(C_FirstHop(ww),C_SecondHop(ww));% Equation (8)
%             if C_e2e(ww)<p
%                 SOP_event = SOP_event+1;
%             end
%         end
        C_e2e = min(C_FirstHop,C_SecondHop);% Equation (8)
        SOP(kk,jj) = length(find(C_e2e<p))./length(C_e2e) % Equation (9)
        
    end
    
end
 semilogy(Ps_vec,SOP(1,:)),hold on
 semilogy(Ps_vec,SOP(2,:),'--g'),
 semilogy(Ps_vec,SOP(3,:),'--k'),
 semilogy(Ps_vec,SOP(4,:),'--r'),
 semilogy(Ps_vec,SOP(5,:),'--c'),

%HSR HRD = 1 K = 1 LD,LR= 2 HSP = 1 
Theo_1_1=[0.993253 0.971712 0.925545 0.847505 0.736946 0.604025 0.466529 0.3416 0.239414 0.162298 0.107415 0.0699264 0.0450206 0.0287759 0.0183065 0.0116121];
%HSR=1 HRD = 2 K = 1 LD,LR=2 HSP = 1 
Theo_2_1=[0.98376 0.945987 0.877592 0.776704 0.650065 0.513057 0.383213 0.273084 0.187521 0.125278 0.0820887 0.0530839 0.0340281 0.0216886 0.0137729 0.00872766];
%HSR=1 HRD = 2 K = 1 LD,LR=2 HSP = 1 
Theo_1_2=[0.98376 0.945987 0.877592 0.776704 0.650065 0.513057 0.383213 0.273084 0.187521 0.125278 0.0820887 0.0530839 0.0340281 0.0216886 0.0137729 0.00872766];
%Hsr = 2 HRD = 2 HSP = 2 K =1 
Theo_2_2=[0.960913 0.896867 0.798757 0.673031 0.534491 0.401191 0.286885 0.197439 0.132086 0.086622 0.0560436 0.0359364 0.0229091 0.0145494 0.00921843 0.00583477];
%HSR=3 HRD = 3 K = 1LD,LR= 2 HSP = 1 
Theo_3_3=[0.91503 0.81753 0.691597 0.552089 0.416657 0.299386 0.206833 0.138762 0.0911798 0.0590708 0.0379107 0.0241816 0.0153632 0.00973631 0.00615941 0.00390052];

 semilogy(Ps_vec,Theo_1_1,'ob'),
 semilogy(Ps_vec,Theo_2_1,'og'),
 semilogy(Ps_vec,Theo_1_2,'pk'),
 semilogy(Ps_vec,Theo_2_2,'dr'),
 semilogy(Ps_vec,Theo_3_3,'dc'),

 
%semilogy(Ps_vec, (Theo4),'Linewidth',2,'Color',[0.0,0.0,1.0],'LineStyle','none','Marker','*');

grid,legend('\sigma^2_{sr}=1, \sigma^2_{rd}=1','\sigma^2_{sr}=2, \sigma^2_{rd}=1','\sigma^2_{sr}=1, \sigma^2_{rd}=2','\sigma^2_{sr}=2, \sigma^2_{rd}=2','\sigma^2_{sr}=3, \sigma^2_{rd}=3','Analytical')
xlabel('Average main link SINR (dB)'),ylabel('SOP')

%% Sultan Çizim
figure(10)
semilogy(Ps_vec,SOP(1,:)),hold on
semilogy(Ps_vec,SOP(2,:)),
semilogy(Ps_vec,SOP(3,:)),
semilogy(Ps_vec,SOP(4,:)),
semilogy(Ps_vec,SOP(5,:)),

semilogy(Ps_vec,Theo_1_1,'ok'),
semilogy(Ps_vec,Theo_2_1,'ok'),
semilogy(Ps_vec,Theo_1_2,'dr','markersize',10),
semilogy(Ps_vec,Theo_2_2,'ok'),
semilogy(Ps_vec,Theo_3_3,'ok'),

 
%semilogy(Ps_vec, (Theo4),'Linewidth',2,'Color',[0.0,0.0,1.0],'LineStyle','none','Marker','*');

grid,legend('\sigma^2_{sr}=1, \sigma^2_{rd}=1','\sigma^2_{sr}=2, \sigma^2_{rd}=1','\sigma^2_{sr}=1, \sigma^2_{rd}=2','\sigma^2_{sr}=2, \sigma^2_{rd}=2','\sigma^2_{sr}=3, \sigma^2_{rd}=3','Analytical')
xlabel('The average SINR main links (dB)'),ylabel('SOP')

axis([0 30  2*1e-3 1])