clc;
clear all;
close all;


% Your original scenario (bearing 45°)
[Range,Bearing] = target_track(1000, 90, 45, 5, 10, 16);

c = 1500;
RangeIndex = round(2 .* Range ./ (c * 20e-3));
load PhiOut.mat
PhiOut = PhiOut *180/pi;
[~,BearingIndx] = min(abs(Bearing-PhiOut),[],1);

PingData = zeros(800,180,10);

for i = 1:10
    PingData(RangeIndex(i),BearingIndx(i),i) = 100;
    for j = 1:3
        PingData(RangeIndex(i)+j,BearingIndx(i),i) = 30;
        PingData(RangeIndex(i)-j,BearingIndx(i),i) = 40;
        PingData(RangeIndex(i),BearingIndx(i)+1,i) = 20;
        PingData(RangeIndex(i),BearingIndx(i)-1,i) = 30;
        PingData(RangeIndex(i)-j,BearingIndx(i)+1,i) = 30;
        PingData(RangeIndex(i)-j,BearingIndx(i)-1,i) = 40;
        PingData(RangeIndex(i)+j,BearingIndx(i)-1,i) = 30;
        PingData(RangeIndex(i)+j,BearingIndx(i)+1,i) = 25;
    end

    % figure(1)
    % imagesc(PingData(:,:,i))
    % 
    % pause(1)
end


save PingData PingData




