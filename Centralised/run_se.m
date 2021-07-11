function [baseMVA, bus, gen, branch, success, et, z, z_est, error_sqrsum,errors,iterNum] = ...
    run_se(casename, measure, plac_cent, sigma, type_initialguess, real_values, cent,V0)
%RUN_SE  Run state estimation.
%   [INPUT PARAMETERS]
%   measure: measurements
%   idx: measurement indices
%   sigma: measurement variances
%   [OUTPUT PARAMETERS]
%   z: Measurement Vector. In the order of PF, PT, PG, Va, QF, QT, QG, Vm (if
%   applicable), so it has ordered differently from original measurements
%   z_est: Estimated Vector. In the order of PF, PT, PG, Va, QF, QT, QG, Vm
%   (if applicable)
%   error_sqrsum: Weighted sum of error squares
%   created by Rui Bo on 2007/11/12

%   MATPOWER
%   Copyright (c) 1996-2016, Power Systems Engineering Research Center (PSERC)
%   by Rui Bo
%   and Ray Zimmerman, PSERC Cornell
%
%   This file is part of MATPOWER/mx-se.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See https://github.com/MATPOWER/mx-se/ for more info.

%% define named indices into data matrices
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

%% read data & convert to internal bus numbering
[baseMVA, bus, gen, branch] = loadcase(casename);
[i2e, bus, gen, branch] = ext2int(bus, gen, branch);

%% get bus index lists of each type of bus
[ref, pv, pq] = bustypes(bus, gen);

%% build admittance matrices
[Ybus, Yf, Yt] = makeYbus(baseMVA, bus, branch);
Ybus = full(Ybus);
Yf = full(Yf);
Yt = full(Yt);

%% prepare initial guess
if nargin < 8
    V0 = getV0(bus, gen, type_initialguess);
else
    V0 = getV0(bus, gen, type_initialguess, V0);
end

%% run state estimation
t0 = tic;
if cent == 1
    [V, success, iterNum, z, z_est, error_sqrsum,errors] = ...
        doSE(baseMVA, bus, gen, branch, Ybus, Yf, Yt, V0, ref, pv, pq, measure, plac_cent, sigma, real_values);
else
    [V, success, iterNum, z, z_est, error_sqrsum,errors,converged,iterNum_inner, error_sqrsum_inner] = ...
        doSE_decent(baseMVA, bus, gen, branch, Ybus, Yf, Yt, V0, ref, pv, pq, measure_decent, plac_decent, sigma, real_values,measure,plac_cent);
end
% update Pg and Qg using estimated values
if length(plac_cent.idx_zPG) > 0
    cnt = length(plac_cent.idx_zPF) + length(plac_cent.idx_zPT);
    gen(plac_cent.idx_zPG, PG) = z_est([cnt+1:cnt+length(plac_cent.idx_zPG)]) * baseMVA;
end
if length(plac_cent.idx_zQG) > 0
    cnt = length(plac_cent.idx_zPF) + length(plac_cent.idx_zPT) + length(plac_cent.idx_zPG) + ...
            length(plac_cent.idx_zVa) + length(plac_cent.idx_zQF) + length(plac_cent.idx_zQT);
    gen(plac_cent.idx_zQG, QG) = z_est([cnt+1:cnt+length(plac_cent.idx_zQG)]) * baseMVA;
end

%% update data matrices with solution, ie, V
% [bus, gen, branch] = updatepfsoln(baseMVA, bus, gen, branch, Ybus, V, ref, pv, pq);
[bus, gen, branch] = pfsoln(baseMVA, bus, gen, branch, Ybus, Yf, Yt, V, ref, pv, pq);
et = toc(t0);

%%-----  output results  -----
%% convert back to original bus numbering & print results
[bus, gen, branch] = int2ext(i2e, bus, gen, branch);
%% output power flow solution
outputpfsoln(baseMVA, bus, gen, branch, success, et, 1, iterNum);
%% output state estimation solution
outputsesoln(plac_cent, sigma, z, z_est, error_sqrsum);

