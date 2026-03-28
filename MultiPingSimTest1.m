%--------------- Readme ----------
%-- *) Generic code for Multiping Integration on SNS data (ALTAS)
%-- *) Single Range and Single Bearing integration
%-- *) Initial Range (Km) and Bearing (degree) should be same as the Range (Km) and Bearing (degree) of the starting ping data


clc;
clear all;
close all;

load PhiOut.mat;
%PhiOut = (1:180);
PhiOut = PhiOut* (180 /pi);
nBeam = length(PhiOut);

nPing = 10;
PRI = 16; % 18 sec
t = 0:PRI:PRI*(nPing-1);
c = 1500;
MaxRange = ((PRI) * c)/2;
MaxInd = (2 * MaxRange)/(c * 20e-3);

V_Own = 0;
V_Tar = -10:1:10;
% V_Tar = 5;
nVel = length(V_Tar);

C_Own = 0;
C_Tar = [0;45;90;135;180];
% C_Tar = 45;
nCors = size(C_Tar,1);

V_Own_X = V_Own * t * sind(C_Own);
V_Own_Y = V_Own * t * cosd(C_Own);


R_In = 1000;
Th_In = 45;

X_Cord = zeros(nVel,nPing,nCors);
Y_Cord = zeros(nVel,nPing,nCors);
for i = 1:nCors
    V_Tar_X = V_Tar' * t * sind(C_Tar(i));
    V_Tar_Y = V_Tar' * t * cosd(C_Tar(i));
    X_Cord(:,:,i) = R_In * sind(Th_In) + V_Tar_X - V_Own_X;
    Y_Cord(:,:,i) = R_In * cosd(Th_In) + V_Tar_Y - V_Own_Y;
end


R_Final = sqrt(X_Cord.^2 + Y_Cord.^2);
R_Index = round(2 .* R_Final./(c * 20e-3)); %% Range index final
ind = find(R_Index > MaxInd);
if(~isempty(ind))
    R_Index(ind) = MaxInd;
end

Th_Final = atan2d(X_Cord,Y_Cord);
ind = find(Th_Final > nBeam);
Th_Final(ind) = nBeam;
True_B = repmat(reshape(PhiOut,1,1,1,nBeam),[nVel,nPing,nCors]);
Th_Diff = abs(True_B - Th_Final);
[~,Th_Index] = min(Th_Diff,[],4); %% Theta index final

DecR = 1;
DecB = 1;
PingData_E = zeros(DecR,MaxInd/DecR,DecB,nBeam/DecB);
Cell_Out = zeros(nVel,nCors,nPing);
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
    R_Ind_P = squeeze(R_Index(:,i,:));
    Th_Ind_P = squeeze(Th_Index(:,i,:));
    linIndex = sub2ind([800 180],R_Ind_P(:),Th_Ind_P(:));
    Cell_Out(:,:,i) = reshape(PingData_E(linIndex),nVel,nCors);
    
end

MulPingOut = sum(Cell_Out,3);

figure(1)
plot(V_Tar,MulPingOut);
xlabel("Velocity");
ylabel("Power");
% legend(C_Tar);
