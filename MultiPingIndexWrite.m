clc; 
clear all; 
close all;

load PhiOut.mat;
PhiOut  = single(PhiOut * 180/pi);

PhiOut = (1:180);
nBeam   = length(PhiOut);

nPing    = 10;
PRI      = 16;
t        = single(0:PRI:PRI*(nPing-1));   % [1 x nPing]
c        = 1500;
MaxRange = (PRI * c) / 2;
MaxInd   = round((2 * MaxRange) / (c * 20e-3));

V_Own   = 0;  C_Own = 0;
V_Own_X = single(V_Own * t * sind(C_Own));
V_Own_Y = single(V_Own * t * cosd(C_Own));

V_Tar  = single((-10:1:10)');   % [nVel x 1]
nVel   = length(V_Tar);

C_Tar  = single([0; 45; 90; 135; 180]);
nCors  = size(C_Tar,1);

R_In   = single((1:800) * 15);  % [1 x nRange]
nRange = length(R_In);

Th_In  = PhiOut;                % [1 x nTh]
nTh    = length(Th_In);

assert(all(PhiOut >= 0 & PhiOut <= 180), ...
    'PhiOut contains bearings outside [0,180] deg.');

X_Cord = zeros(nRange, nTh, nVel, nPing, nCors, 'single');
Y_Cord = zeros(nRange, nTh, nVel, nPing, nCors, 'single');

for i = 1:nCors
    V_Tar_X = V_Tar * t * sind(C_Tar(i));   % [nVel x nPing]
    V_Tar_Y = V_Tar * t * cosd(C_Tar(i));
    for k = 1:nTh
        sinTh = sind(Th_In(k));
        cosTh = cosd(Th_In(k));
        for j = 1:nRange
            X_Cord(j,k,:,:,i) = R_In(j)*sinTh + V_Tar_X - V_Own_X;
            Y_Cord(j,k,:,:,i) = R_In(j)*cosTh + V_Tar_Y - V_Own_Y;
        end
    end
end


R_Final = sqrt(X_Cord.^2 + Y_Cord.^2);
R_Index = round(2 .* R_Final ./ (c * 20e-3));
clear R_Final;
R_Index = uint16(R_Index);                     % cast early to save RAM
R_Index(R_Index > uint16(MaxInd)) = NaN;         % out of range  → sentinel 0
R_Index(R_Index == 0) = NaN; 
Th_Final_deg = atan2d(X_Cord, Y_Cord);   % [nRange x nTh x nVel x nPing x nCors]
% PhiOut shape for broadcasting: [1 x 1 x 1 x 1 x 1 x nBeam]
PhiOut_bcast = reshape(PhiOut, 1, 1, 1, 1, nBeam);   % only nBeam, no repmat


RangeBuff   = '../BinaryFiles/RangeIndex';
BearingBuff = '../BinaryFiles/BearingIndex';
fid1 = fopen(RangeBuff,   'wb');
fid2 = fopen(BearingBuff, 'wb');

for i = 1:nPing
    % Slice: [nRange x nTh x nVel x nCors]
    Th_ping = squeeze(Th_Final_deg(:,:,:,i,:));   % [nRange x nTh x nVel x nCors]
    R_ping  = squeeze(R_Index(:,:,:,i,:));         % [nRange x nTh x nVel x nCors]

    % Add dim-5 for PhiOut broadcast: [nRange x nTh x nVel x nCors x 1]
    % vs PhiOut_bcast [1 x 1 x 1 x 1 x nBeam]
    % abs difference: [nRange x nTh x nVel x nCors x nBeam] — computed lazily
    [~, Th_Index] = min(abs(reshape(Th_ping,[],1) - PhiOut(:)'), [], 2);
    % Th_Index: [nRange*nTh*nVel*nCors x 1]
    Th_Index = reshape(uint16(Th_Index), nRange, nTh, nVel, nCors);

    % Flag bearings outside PhiOut coverage as 0
    out_of_fov = Th_ping < min(PhiOut) | Th_ping > max(PhiOut);
    Th_Index(out_of_fov) = NaN;

    fwrite(fid1, R_ping,   'uint16');
    fwrite(fid2, Th_Index, 'uint16');
    disp(['Ping No: ', num2str(i)]);
end

fclose(fid1);
fclose(fid2);