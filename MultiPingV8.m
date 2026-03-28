clc; clear all; close all;

load PhiOut.mat;

PhiOut  = single(PhiOut * 180/pi);   % already in degrees from generation step

PhiOut = (1:180);
MaxInd  = 800;
nBeam   = 180;
nPing   = 10;
nRange  = 800;
nTh     = 180;
nVel    = 21;
nCors   = 5;
DecR    = 1;    % range decimation factor  (must divide MaxInd evenly)
DecB    = 1;    % bearing decimation factor (must divide nBeam evenly)

assert(mod(MaxInd, DecR)==0 && mod(nBeam, DecB)==0,'DecR and DecB must divide MaxInd and nBeam exactly.');


fid1    = fopen('../BinaryFiles/RangeIndex',   'rb');
fid2    = fopen('../BinaryFiles/BearingIndex', 'rb');
R_Index = fread(fid1, nRange*nTh*nVel*nCors*nPing, 'uint16');
fclose(fid1);
B_Index = fread(fid2, nRange*nTh*nVel*nCors*nPing, 'uint16');
fclose(fid2);

R_Index = reshape(uint16(R_Index), nRange, nTh, nVel, nCors, nPing);
B_Index = reshape(uint16(B_Index), nRange, nTh, nVel, nCors, nPing);

validMask = (R_Index >= 1) & (R_Index <= MaxInd) & (B_Index >= 1) & (B_Index <= nBeam);

% Safe linear index: clamp invalids to (1,1,1) temporarily; mask zeroes output
R_safe = max(R_Index, 1);
B_safe = max(B_Index, 1);
linIndex = sub2ind([MaxInd, nBeam, nPing],uint32(R_safe(:)), uint32(B_safe(:)),repmat(uint32(reshape(repmat(1:nPing,[nRange*nTh*nVel*nCors,1]),[],1)),1));

Range   = (1:MaxInd) * 15;       % metres
Bearing = PhiOut;                 % degrees (already converted)

fname = '../BinaryFiles/PingData';
fid   = fopen(fname, 'r');
Bytes1 = MaxInd * nBeam;
load PingData.mat
peakBearing = [];
peakRange   = [];

for i = 1:10
    Ping = PingData(:,:,i);
    [colMax, colIdx] = max(max(Ping, [], 1));   % max across range → [1 x nBeam]
    [~, bIdx]        = max(colMax);              % bearing index of peak
    [~, rIdx]        = max(Ping(:, bIdx));       % range index of peak
    peakBearing(end+1) = Bearing(bIdx);
    peakRange(end+1)   = Range(rIdx)

end



PingData_D = max(max(reshape(PingData,DecR, MaxInd/DecR, DecB, nBeam/DecB, nPing), [], 1), [], 3);

PingData_E = reshape(repmat(PingData_D, [DecR,1,DecB,1,1]), MaxInd, nBeam, nPing);

Cell_Out           = zeros(nRange, nTh, nVel, nCors, nPing, 'single');
validFlat          = validMask(:);
linIdx_flat        = linIndex;

% Only assign valid entries
Cell_Out(validFlat) = PingData_E(linIdx_flat(validFlat));

MulPingOut = max(max(sum(Cell_Out, 5), [], 4), [], 3);
% Result: [nRange x nTh] — the integrated target energy map

figure(1);
imagesc(Bearing, Range, MulPingOut);
colorbar;
xlabel('Bearing (deg)');
ylabel('Range (m)');
title(sprintf('Multi-ping integration | Peak @ %.0f deg, %.0f m',peakBearing(end), peakRange(end)));

elapsed = toc;
fprintf('Ping processed in %.2f s | Peak bearing: %.1f deg | Peak range: %.0f m\n', ...
        elapsed, peakBearing(end), peakRange(end));
pause(0.5);
