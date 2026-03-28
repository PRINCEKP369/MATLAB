function [Range_m,Bearing_d] = target_track(R0, B0, course, speed, nPing, PRI, c, cellSize)

if nargin < 6, PRI      = 16;   end
if nargin < 7, c        = 1500; end
if nargin < 8, cellSize = 15;   end


t = (0:nPing-1) * PRI;          % [1 x nPing]


Vx = speed * sind(course);      % East  component (m/s)
Vy = speed * cosd(course);      % North component (m/s)


X0 = R0 * sind(B0);
Y0 = R0 * cosd(B0);


X = X0 + Vx * t;               % [1 x nPing]
Y = Y0 + Vy * t;               % [1 x nPing]


Range_m   = sqrt(X.^2 + Y.^2);
Bearing_d = atan2d(X, Y);


%RangeIndex = round(2 .* Range_m ./ (c * 20e-3));
% equivalent: round(Range_m / cellSize)


% dRange   = [0, diff(Range_m)];
% dBearing = [0, diff(Bearing_d)];
% 
% fprintf('\n======================================================\n');
% fprintf('  TARGET TRACK SIMULATION\n');
% fprintf('======================================================\n');
% fprintf('  Initial Range   : %.1f m\n', R0);
% fprintf('  Initial Bearing : %.3f deg\n', B0);
% fprintf('  Course          : %.1f deg\n', course);
% fprintf('  Speed           : %.2f m/s\n', speed);
% fprintf('  PRI             : %.1f s\n', PRI);
% fprintf('  Sound speed     : %.0f m/s\n', c);
% fprintf('  Cell size       : %.1f m\n', cellSize);
% fprintf('  Displacement/ping: %.2f m  (%.2f range cells)\n', ...
%         speed*PRI, speed*PRI/cellSize);
% fprintf('------------------------------------------------------\n');
% fprintf('%-5s %-8s %-10s %-12s %-12s %-12s %-12s\n', ...
%         'Ping','t (s)','X (m)','Y (m)','Range (m)','Bearing°','R_Index');
% fprintf('------------------------------------------------------\n');
% for i = 1:nPing
%     fprintf('%-5d %-8.0f %-10.1f %-12.1f %-12.1f %-12.3f %-12d\n', ...
%             i, t(i), X(i), Y(i), Range_m(i), Bearing_d(i), RangeIndex(i));
% end
% fprintf('------------------------------------------------------\n');
% fprintf('  Total range change   : %.2f m\n',   Range_m(end)   - Range_m(1));
% fprintf('  Total bearing change : %.3f deg\n', Bearing_d(end) - Bearing_d(1));
% fprintf('======================================================\n\n');
% 
% figure('Name','Target Track','NumberTitle','off','Color','w');
% 
% subplot(2,2,1);
% plot(X, Y, 'b.-', 'MarkerSize', 12, 'LineWidth', 1.2); hold on;
% plot(X(1),   Y(1),   'go', 'MarkerSize', 10, 'LineWidth', 2);
% plot(X(end), Y(end), 'rs', 'MarkerSize', 10, 'LineWidth', 2);
% plot(0, 0, 'k^', 'MarkerSize', 10, 'LineWidth', 2);
% for i = 1:nPing
%     text(X(i)+20, Y(i)+20, num2str(i), 'FontSize', 8, 'Color', 'b');
% end
% grid on; axis equal;
% xlabel('East (m)'); ylabel('North (m)');
% title('Target track (Cartesian)');
% legend('Track','Start','End','Own ship','Location','best');
% 
% % ── Subplot 2: Range vs Ping ──
% subplot(2,2,2);
% plot(1:nPing, Range_m, 'r.-', 'MarkerSize', 12, 'LineWidth', 1.2);
% grid on;
% xlabel('Ping number'); ylabel('Range (m)');
% title('Range vs ping');
% xticks(1:nPing);
% 
% % ── Subplot 3: Bearing vs Ping ──
% subplot(2,2,3);
% plot(1:nPing, Bearing_d, 'g.-', 'MarkerSize', 12, 'LineWidth', 1.2);
% grid on;
% xlabel('Ping number'); ylabel('Bearing (deg)');
% title('Bearing vs ping');
% xticks(1:nPing);
% 
% % ── Subplot 4: Range index vs Ping ──
% subplot(2,2,4);
% stem(1:nPing, RangeIndex, 'b', 'LineWidth', 1.5, 'MarkerSize', 6);
% grid on;
% xlabel('Ping number'); ylabel('Range cell index');
% title('Range index vs ping');
% xticks(1:nPing);
% 
% sgtitle(sprintf('Course=%.0f°  Speed=%.1f m/s  PRI=%.0fs  R_0=%.0fm  B_0=%.0f°', ...
%         course, speed, PRI, R0, B0), 'FontWeight', 'bold');
end