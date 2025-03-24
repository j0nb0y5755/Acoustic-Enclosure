% Acoustic Enclosure Optimizer with Proper Membrane Damping (Target 40 dBA)
clear; clc;

%% === USER-DEFINED ENCLOSURE SIZE ===
L = 9; W = 5; H = 3;
enclosure_dims = [L, W, H];

%% === FIXED INPUTS ===
panel_density = 2710;               % kg/m³ (steel)
membrane_density = 1800;            % kg/m³ (butyl-like)
frequencies = [125 250 500 1000 2000 4000 8000];
A_weighting = [-16.1 -8.6 -3.2 0 1.2 1.0 -1.1];
L_internal_raw = [94 84 85 83 80 75 66];

%% === TARGET SETTINGS ===
dBA_target = 40;
penalty_weight = 1000;

%% === DESIGN VARIABLES (11 total) ===
x_default = [0.03, 30, 0.12, 1e-3, 0.015, 1.5e-3, 1.5e-3, 100, 0.05, 1e-3, 2e-3];
x0 = x_default;
lb = [0.01, 10, 0.05, 0.0005, 0.000, 1e-3, 1e-3, 30, 0.025, 0.5e-3, 0];
ub = [0.10, 100, 0.30, 0.003, 0.050, 5e-3, 5e-3, 150, 0.25, 3e-3, 5e-3];

%% === OPTIMIZATION ===
opt_fun = @(x) cost_function_with_target(x, L_internal_raw, ...
    panel_density, membrane_density, enclosure_dims, frequencies, A_weighting, dBA_target, penalty_weight);

options = optimset('Display','iter','TolX',1e-3);
[x_opt, cost_min] = fmincon(opt_fun, x0, [], [], [], [], lb, ub, [], options);

%% === BREAKOUT CALCULATION ===
breakout_after = compute_L_breakout(x_opt, L_internal_raw, ...
    panel_density, membrane_density, enclosure_dims, frequencies);
L_A = breakout_after + A_weighting;
final_dBA = 10 * log10(sum(10.^(L_A / 10)));

%% === OUTPUT ===
fprintf('\n=== OPTIMIZATION RESULTS ===\n');
fprintf('Target breakout: %.1f dBA\n', dBA_target);
fprintf('Final breakout : %.1f dBA\n\n', final_dBA);

labels = {...};
for i = 1:length(x_opt)
    fprintf('%-35s: %.4f\n', labels{i}, x_opt(i));
end

% (Functions omitted here for brevity but included in actual file)
