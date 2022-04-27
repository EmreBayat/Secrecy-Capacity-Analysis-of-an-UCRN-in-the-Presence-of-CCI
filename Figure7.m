
clear all;clc;close all


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

var_sr = 1; var_rd = 1; % Beta Variance
var_re = 1; var_se = 1; % Epsilon variance
var_sp = 1; var_rp = 1; % Alpha Variance
var_r  = 1; var_d  = 1; %Lambda Variance
var_pr = 1; var_pd = 1;


N0=1;
Ps_vec = 0:2:100; %maximum transmission limit


power=0:3;
lin = 10.^(0.1.*power);
%1.0000    1.2589    1.5849    1.9953


Setup = [1 1; 1 1.2589; 1 1.2589; 1.5849 1.5849; 1.9953 1.9953]; % LR ve LD

for kk = 1:max(size(Setup))
    
    for jj = 1:length(Ps_vec)
        Pss = 10^(0.1*Ps_vec(jj));
%         var_sr = 10^(0.1*Ps_vec(jj));
%         var_rd = 10^(0.1*Ps_vec(jj));
        % kanallarýn üretilmesi
        hsr = sqrt(var_sr/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hsr
        hrd = sqrt(var_rd/2)*(randn(K,N) + 1i*randn(K,N)); % Channel Gain of hrd
        hre = sqrt(var_re/2)*(randn(1,N) + 1i*randn(1,N)); % Channel Gain of hre
        hse = sqrt(var_se/2)*(randn(1,N) + 1i*randn(1,N));% Channel Gain of hse
        hsp = sqrt(var_sp/2)*(randn(1,N) + 1i*randn(1,N));% Channel Gain of hsp
        hrp = sqrt(var_rp/2)*(randn(1,N) + 1i*randn(1,N));% Channel Gain of hrp
%         hr  = sqrt(Setup(kk,1)/2) *(randn(1,N) + 1i*randn(1,N));% Channel Gain of hr - CCI
%         hd  = sqrt(Setup(kk,2)/2) *(randn(1,N) + 1i*randn(1,N));% Channel Gain of hd - CCI
%         hpr = sqrt(Setup(kk,1)/2) *(randn(1,N) + 1i*randn(1,N)); % hpr primary interference -->r c ve r eþit olmalý
%         hpd = sqrt(Setup(kk,2)/2) *(randn(1,N) + 1i*randn(1,N)); %
%         
        hsr_square = abs(hsr).^2; % Channel Coefficient hsr
        hrd_square = abs(hrd).^2; % Channel Coefficient hrd
        hre_square = abs(hre).^2;% Channel Coefficient hre
        hse_square = abs(hse).^2;% Channel Coefficient hse
        hsp_square = abs(hsp).^2;% Channel Coefficient hsp
        hrp_square = abs(hrp).^2;% Channel Coefficient hrp
%         hr_square  =  abs(hr).^2;% Channel Coefficient hr - CCI
%         hd_square  =  abs(hd).^2;  % Channel Coefficient hd - CCI
%         hpr_square = abs(hpr).^2 ;
%         hpd_square = abs(hpd).^2 ;
        
        hr_square  =  Setup(kk,1);% Channel Coefficient hr - CCI
        hd_square  =  Setup(kk,2);  % Channel Coefficient hd - CCI
        hpr_square =  Setup(kk,1) ;
        hpd_square =  Setup(kk,2) ;
        
        
        PS = min(Pmax,(I./hsp_square)); % Equation (1)
        %Su(jj)=mean(PS);
        PR = min(Pmax,(I./hrp_square)); % Equation (2)
        
        %Y_SR = (Pmax(jj))./(1 +(hr_square.*LD) );% Equation (3)
        %Y_RD = (Pmax(jj))./(1 +(hd_square.*LR) ); %Equation (4)
        
        Y_SR = ((PS./N0).*hsr_square*Pss)./( 1 +(hr_square.*LR)+hpr_square );% Equation (3)
        % Y_RD = (PR)./(1 +(hd_square.*LR) ); %Equation (4)
        for k_iter=1:K
            Eq4(k_iter,:) = hrd_square(k_iter,:)./(1 + (hd_square.*LD)+hpd_square);
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
        SOP(kk,jj) = length(find(C_e2e<=p))./length(C_e2e) % Equation (9)
        
    end
    
end


 semilogy(Ps_vec,SOP(1,:)),hold on
 semilogy(Ps_vec,SOP(2,:),'--g'),
 semilogy(Ps_vec,SOP(3,:),'--k'),
 semilogy(Ps_vec,SOP(4,:),'--r'),
 semilogy(Ps_vec,SOP(5,:),'--c'),

%HSR HRD = 1 K = 1 LD,LR= 1 HSP = 1 
Theo_1_1=[0.984277 0.947494 0.880123 0.779757 0.652964 0.515315 0.384701 0.273938 0.18796 0.125486 0.082182 0.053124 0.034045 0.0216957 0.0137759 0.00872695];
%HSR HRD = 1 K = 1 LD=2,LR=1 HSP = 1 
Theo_2_1=[0.9897 0.961461 0.905525 0.816735 0.697859 0.561909 0.427074 0.308596 0.214108 0.14409 0.0948866 0.0615628 0.0395485 0.0252422 0.0160438 0.0101706];
%HSR HRD = 1 K = 1 LD=1,LR=2 HSP = 1
Theo_1_2=[0.9897 0.961461 0.905525 0.816735 0.697859 0.561909 0.427074 0.308596 0.214108 0.14409 0.0948866 0.0615628 0.0395485 0.0252422 0.0160438 0.0101706];
%HSR HRD = 1 K = 1 LD,LR= 2 HSP = 1 
Theo_2_2=[0.993253 0.971712 0.925545 0.847505 0.736946 0.604025 0.466529 0.3416 0.239414 0.162298 0.107415 0.0699264 0.0450206 0.0287759 0.0183065 0.0116121];
%HSR HRD = 1 K = 1 LD,LR= 3 HSP = 1 
Theo_3_3=[0.996901 0.983811 0.951553 0.890959 0.796508 0.67266 0.534547 0.401077 0.28656 0.197033 0.13171 0.0863228 0.0558255 0.0357915 0.022845 0.0142854];


 semilogy(Ps_vec,Theo_1_1,'ob'),
 semilogy(Ps_vec,Theo_2_1,'og'),
 semilogy(Ps_vec,Theo_1_2,'pk'),
 semilogy(Ps_vec,Theo_2_2,'dr'),
 semilogy(Ps_vec,Theo_3_3,'dc'),
 
grid,legend('L_R=1, L_D=1','L_R=1, L_D=2','L_R=2, L_D=1','L_R=2, L_D=2','L_R=3, L_D=3','Analytical')
xlabel('Average main link SINR (dB)'),ylabel('SOP')


% dim = [0.2 0.5 0.3 0.7];
% str = {'K=1, h_{sp}=1h_{IR}, h_{ID}, h_{PR}, h_{PD} = 1'};
% annotation('textbox','String',str,'FitBoxToText','on');


sim_a=[0.940579, 0.862193, 0.750161, 0.615265, 0.475518, 0.348373, 0.244269,0.165645, 0.109658, 0.0713991, 0.0459743, 0.0293879, 0.018697,0.0118593, 0.00750774, 0.00474708];
sim_b=[0.976893, 0.9331, 0.857669, 0.750027, 0.619376, 0.482521, 0.356385,0.25173, 0.171734, 0.114208, 0.0746037, 0.048145, 0.0308212,0.0196279, 0.0124576, 0.00788962];
sim_c=[0.976893, 0.9331, 0.857669, 0.750027, 0.619376, 0.482521, 0.356385,0.25173, 0.171734, 0.114208, 0.0746037, 0.048145, 0.0308212,0.0196279, 0.0124576, 0.00788962];
sim_d=[0.991014, 0.967523, 0.918915, 0.837585, 0.723775, 0.589053, 0.451868,0.328932, 0.229481, 0.155043, 0.102374, 0.0665395, 0.0427955,0.0273354, 0.0173827, 0.0110222];
sim_e=[0.998857, 0.993122, 0.97631, 0.939049, 0.871239, 0.768815, 0.639379,0.50028, 0.370216, 0.261573, 0.178353, 0.118517, 0.0773615,0.0498954, 0.0319288, 0.0203125];


% çizim Sultan
figure(10),
semilogy(Ps_vec,SOP(1,:)),hold on
semilogy(Ps_vec,SOP(2,:)),
semilogy(Ps_vec,SOP(3,:)),
semilogy(Ps_vec,SOP(4,:)),
semilogy(Ps_vec,SOP(5,:)),

semilogy(Ps_vec,sim_a,'ok'),
semilogy(Ps_vec,sim_b,'ok'),
semilogy(Ps_vec,sim_c,'rd','markersize',10),
semilogy(Ps_vec,sim_d,'ok'),
semilogy(Ps_vec,sim_e,'ok'),

grid,legend('L_R=1, L_D=1','L_R=1, L_D=2','L_R=2, L_D=1','L_R=2, L_D=2','L_R=3, L_D=3','Analytical')
xlabel('The average SINR of the main links (dB)'),ylabel('SOP')

axis([0 30  4*1e-3 1])


% figure (11)
% semilogy(Ps_vec,SOP(1,:)),hold on
% a=[0.982844, 0.943029, 0.872029, 0.768989, 0.641283, 0.504408, 0.375612,0.266984, 0.182962, 0.122048, 0.0798863, 0.0516217, 0.0330747,0.0210743, 0.0133801, 0.00847573];
% semilogy(Ps_vec,a,'ok'),
% 
% semilogy(Ps_vec,SOP(2,:)),
% b=[0.994854, 0.97661, 0.936275, 0.867379, 0.767771, 0.64388, 0.510118,0.382903, 0.274267, 0.189199, 0.126867, 0.083358, 0.0540088,0.0346664, 0.0221147, 0.0140515];
% semilogy(Ps_vec,b,'ok'),
% 
% semilogy(Ps_vec,SOP(3,:)),
% semilogy(Ps_vec,b,'rd','markersize',10),
% 
% 
% semilogy(Ps_vec,SOP(4,:)),
% d=[0.998456, 0.990397, 0.968267, 0.923864, 0.849658, 0.744101, 0.615648,0.480491, 0.355369, 0.251215, 0.171448, 0.114032, 0.0744896,0.0480698, 0.0307719, 0.0195958];
% semilogy(Ps_vec,d,'ok'),
% 
% 
% semilogy(Ps_vec,SOP(5,:)),
% e=[0.999894, 0.998565, 0.99264, 0.976622, 0.942349, 0.880578, 0.786346,0.664336, 0.528942, 0.398009, 0.285243, 0.196667, 0.131753,0.0864894, 0.0559958, 0.0359184];
% semilogy(Ps_vec,e,'ok'),


% 
% sim_a=[0.982783000000000,0.951978000000000,0.890585000000000,0.794554000000000,0.668308000000000,0.528677000000000,0.395077000000000,0.282539000000000,0.194222000000000,0.129526000000000,0.0845550000000000,0.0545580000000000,0.0348820000000000,0.0222850000000000,0.0140010000000000,0.00904900000000000];
% sim_b=[0.993403000000000,0.978009000000000,0.943334000000000,0.879460000000000,0.783496000000000,0.660093000000000,0.527132000000000,0.396815000000000,0.285465000000000,0.198102000000000,0.133312000000000,0.0872370000000000,0.0569970000000000,0.0364410000000000,0.0236460000000000,0.0147220000000000];
% sim_c=[0.993356000000000,0.978242000000000,0.943704000000000,0.879976000000000,0.782964000000000,0.661261000000000,0.526035000000000,0.396752000000000,0.285670000000000,0.198766000000000,0.133467000000000,0.0875700000000000,0.0574830000000000,0.0364230000000000,0.0233730000000000,0.0150610000000000];
% sim_d=[0.997431000000000,0.990346000000000,0.971012000000000,0.930012000000000,0.859140000000000,0.755247000000000,0.629021000000000,0.492557000000000,0.367864000000000,0.262150000000000,0.179863000000000,0.119763000000000,0.0784520000000000,0.0507640000000000,0.0323360000000000,0.0208510000000000];
% sim_e=[0.999481000000000,0.997559000000000,0.991133000000000,0.974375000000000,0.938544000000000,0.875460000000000,0.781318000000000,0.663235000000000,0.531482000000000,0.402808000000000,0.291885000000000,0.203801000000000,0.136868000000000,0.0906500000000000,0.0586910000000000,0.0382710000000000];





% sim_a=[0.952534, 0.88137, 0.77506, 0.642647, 0.501648, 0.370564, 0.261484,0.178137, 0.118305, 0.0771953, 0.0497769, 0.0318479, 0.020274,0.0128644, 0.00814598, 0.00515141];
% sim_b=[0.966264, 0.907784, 0.813801, 0.689161, 0.549031, 0.412797, 0.295407,0.20336, 0.136056, 0.0892241, 0.0577251, 0.0370134, 0.0235953,0.0149852, 0.00949411, 0.00600573];
% sim_c=[0.966264, 0.907784, 0.813801, 0.689161, 0.549031, 0.412797, 0.295407,0.20336, 0.136056, 0.0892241, 0.0577251, 0.0370134, 0.0235953,0.0149852, 0.00949411, 0.00600573];
% sim_d=[0.976023, 0.928317, 0.845871, 0.729621, 0.59191, 0.452197, 0.327773,0.227808, 0.153449, 0.101096, 0.0656068, 0.0421514, 0.0269053,0.0171014, 0.0108404, 0.00685931];
% sim_e=[0.987188, 0.954759, 0.891243, 0.791735, 0.66247, 0.520776, 0.386583,0.273649, 0.186785, 0.124192, 0.081092, 0.0523117, 0.0334726,0.0213445, 0.0136658, 0.00909397];


