function meas_cent = getMeasurement_cent(real_values, plac_cent, sigma)
NmeasPF = length(plac_cent.idx_zPF);
NmeasPT = length(plac_cent.idx_zPT);
NmeasPG = length(plac_cent.idx_zPG);
NmeasVa = length(plac_cent.idx_zVa);
NmeasQF = length(plac_cent.idx_zQF);
NmeasQT = length(plac_cent.idx_zQT);
NmeasQG = length(plac_cent.idx_zQG);
NmeasVm = length(plac_cent.idx_zVm);



meas_cent.PF = real_values.PF(plac_cent.idx_zPF) + sigma.sigma_PF*randn(NmeasPF,1);
meas_cent.PT = real_values.PT(plac_cent.idx_zPT) + sigma.sigma_PT*randn(NmeasPT,1);
meas_cent.PG = real_values.PG(plac_cent.idx_zPG) + sigma.sigma_PG*randn(NmeasPG,1);

meas_cent.QF = real_values.QF(plac_cent.idx_zQF) + sigma.sigma_QF*randn(NmeasQF,1);
meas_cent.QT = real_values.QT(plac_cent.idx_zQT) + sigma.sigma_QT*randn(NmeasQT,1);
meas_cent.QG = real_values.QG(plac_cent.idx_zQG) + sigma.sigma_QG*randn(NmeasQG,1);

meas_cent.Vm = real_values.Vm(plac_cent.idx_zVm) + sigma.sigma_Vm*randn(NmeasVm,1);
meas_cent.Va = real_values.Va(plac_cent.idx_zVa) + sigma.sigma_Va*randn(NmeasVa,1);





end