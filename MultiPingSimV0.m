%--------------- Readme ----------
%-- *) Generic code for Multiping Integration on SNS data (ALTAS)
%-- *) Single Range and Single Bearing integration
%-- *) Initial Range (Km) and Bearing (degree) should be same as the Range (Km) and Bearing (degree) of the starting ping data


clc;
clear all;
close all;

load PhiOut.mat;
load RangeFull.mat
load BearinFull.mat
R_Index = squeeze(RangeFull(:,:,:,:,:));
Th_Index = squeeze(BearinFull(:,:,:,:,:));


MaxInd = 800;
nBeam = 180;
nVel = 21;
nCors = 5;
nPing = 10;
V_Tar = -50:5:50;

DecR = 1;
DecB = 1;
PingData_E = zeros(DecR,MaxInd/DecR,DecB,nBeam/DecB);
Cell_Out = zeros(800,180,nVel,nCors,nPing);
load PingData PingData
for i = 1:nPing
    
    PingNo = i;
    %fname = strcat("../MatFiles/ping ",string(PingNo));
    a = PingData(:,:,PingNo);
    if(size(a,1) > MaxInd)
        PingData1 = a(1:MaxInd,1:nBeam);
        clear a;
    else
        PingData1 = a(:,1:nBeam);
        clear a;
    end
    
%     PingData_D = imresize(PingData,[MaxInd/DecR,nBeam/DecB],'bilinear');
%     PingData_E = imresize(PingData_D,[MaxInd,nBeam],'bilinear');
    PingData_D = max(max(reshape(PingData1,DecR,MaxInd/DecR,DecB,nBeam/DecB),[],1),[],3);
    PingData_E = reshape(repmat(PingData_D,[DecR,1,DecB,1]),MaxInd,nBeam);
    R_Ind_P = squeeze(R_Index(:,:,:,i,:));
    Th_Ind_P = squeeze(Th_Index(:,:,:,i,:));
    linIndex = sub2ind(size(PingData_E),R_Ind_P(:),Th_Ind_P(:));
    Cell_Out(:,:,:,:,i) = reshape(PingData_E(linIndex),800,180,nVel,nCors);
    
end

MulPingOut = squeeze(max(max(sum(Cell_Out,5),[],3),[],4));
MulPingOut1 = squeeze(sum(Cell_Out(:,:,12,2,:),5));

figure(1)
imagesc(MulPingOut)

figure(2)
imagesc(MulPingOut1)
% legend(C_Tar);
