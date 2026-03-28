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
V_Tar = -50:5:50;
% V_Tar = 5;
nVel = length(V_Tar);

C_Own = 0;
C_Tar = [0;45;90;135;180];
% C_Tar = 45;
nCors = size(C_Tar,1);

V_Own_X = V_Own * t * sind(C_Own);
V_Own_Y = V_Own * t * cosd(C_Own);

RangeFull = zeros(800,180,21,10,5);
BearinFull = zeros(800,180,21,10,5);

for k = 1:180

    for j = 1:800

        R_In = j*15;
        Th_In = k;
       
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
            R_Index(ind) = 1;
        end

        ind = find(R_Index == 0);
        if(~isempty(ind))
            R_Index(ind) = 1;
        end
        
        Th_Final = atan2d(X_Cord,Y_Cord);
        ind = find(Th_Final > nBeam);
        Th_Final(ind) = 1;

        ind = find(Th_Final == 0);
        Th_Final(ind) = 1;

        True_B = repmat(reshape(PhiOut,1,1,1,nBeam),[nVel,nPing,nCors]);
        Th_Diff = abs(True_B - Th_Final);
        [~,Th_Index] = min(Th_Diff,[],4); %% Theta index final
        
        RangeFull(j,k,:,:,:) = R_Index;
        BearinFull(j,k,:,:,:) = Th_Index;
    end

    disp(k)

end

save BearinFull BearinFull
save RangeFull RangeFull