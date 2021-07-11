clear all;
clc;
close all;

%% calculate powerflow for the 14 bus and take it as the real solution
real_solution = runpf('case14'); %replace with mpc
if real_solution.success ~= 1
    error('There has been a problem with matpower. Please use another case or fix the error in the case data.');
end
real_solution = ext2int(real_solution);
%check positive definitheit of covariance matrix

%number of busses
N_bus = length(real_solution.bus(:,1));
%number of branches
N_branch = length(real_solution.branch(:,1));

%get the real network Values and some topology data
[real_values,Ybus,Yf,Yt,Adj,indexes,connected_busses,branch_val] = getSystemValues(real_solution, N_bus);


%% define sensor placements
plac_cent.idx_zPF = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20]; %index of branch
plac_cent.idx_zPT = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20]; %index of branch
plac_cent.idx_zPG = [1;2;3;4;5]; %index of generator
plac_cent.idx_zVa = []; %index of bus
plac_cent.idx_zQF = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20]; %index of branch
plac_cent.idx_zQT = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20]; %index of branch
plac_cent.idx_zQG = [1;2;3;4;5]; %index of generator
plac_cent.idx_zVm = [1;2;3;4;5;6;7;8;9;10;11;12;13;14]; %index of bus

%% specify measurement variances
sigma.sigma_PF = 0.02;
sigma.sigma_PT = 0.02;
sigma.sigma_PG = 0.015;
sigma.sigma_Va = [];
sigma.sigma_QF = 0.02;
sigma.sigma_QT = 0.02;
sigma.sigma_QG = 0.015;
sigma.sigma_Vm = 0.01;

meas_cent = getMeasurement_cent(real_values, plac_cent, sigma);


%% check input data integrity
nbus = 14;
[success, meas_cent, plac_cent, sigma] = checkDataIntegrity(meas_cent, plac_cent, sigma, N_bus);
if ~success
    error('State Estimation input data are not complete or sufficient!');
end
    
%% run state estimation
casename = 'case14.m';
type_initialguess = 2; % flat start
V0 = ones(N_bus,1);
cent = 1;
[baseMVA, est_bus, est_gen, est_branch, success, et, z, z_est, error_sqrsum,errors,iterNum] = run_se(casename, meas_cent, plac_cent, sigma, type_initialguess, real_values, cent, V0);
figure(1)
plot(1:length(errors.Norm),errors.Norm,'r*-');
title('Norm of G matrix at each iteration in IEEE 14 bus system')
xlabel('Iteration count of state estimation')
ylabel('Norm of G matrix')


figure(2)
plot(1:length(errors.Vm(:,2)),errors.Vm(:,2),'bo-');
ylim([0.95*min(errors.Vm(:,2))  1.05*max(errors.Vm(:,2))]);
title('Voltage error at bus 2 in IEEE 14 bus system')
xlabel('Iteration count of state estimation')
ylabel('Voltage error in p.u.')


figure(3)
plot(1:length(errors.Va(:,2)),errors.Va(:,2),'bo-');
ylim([0.999*min(errors.Va(:,2))  1.001*max(errors.Va(:,2))]);
title('Anlge error at bus 2 in IEEE 14 bus system')
xlabel('Iteration count of state estimation')
ylabel('Angle error in radians')


voltageerror = NaN(50,N_bus);
angleerror= NaN(50,N_bus);
iterations = NaN(50,1);
for k = 1:50
    meas_cent = getMeasurement_cent(real_values, plac_cent, sigma);    
    [baseMVA, est_bus, est_gen, est_branch, success, et, z, z_est, error_sqrsum,errors,iterNum] = run_se(casename, meas_cent, plac_cent, sigma, type_initialguess, real_values, cent, V0);
    
    voltageerror(k,:) = errors.Vm(end,:);
    angleerror(k,:) = errors.Va(end,:);
    iterations(k) = iterNum;
    
end

figure(4)
histogram(angleerror);
title('Anlge error at all busses in IEEE 14 bus system. Run 50 SE with different noises')
xlabel('Angle error in radians')
ylabel('Counts')

figure(5)
histogram(voltageerror);
title('Voltage error at all busses in IEEE 14 bus system. Run 50 SE with different noises')
xlabel('Voltage error in p.u.')
ylabel('Counts')

figure(6)
histogram(iterations);
title('Number of iterations needed to converge in IEEE 14 bus system. Run 50 SE with different noises')
xlabel('Number of iterations')
ylabel('Counts')
