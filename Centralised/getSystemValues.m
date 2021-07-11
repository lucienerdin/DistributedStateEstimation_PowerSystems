function [network_values,Ybus,Yf,Yt,Adj,indexes,connected_busses,branch_val] = getSystemValues(structure, N_bus)


%construct all needed values of the network
%Voltage vector
network_values.Vm = structure.bus(:,8);
%Angle vector
network_values.Va = structure.bus(:,9);


network_values.PG = structure.gen(:,2)/structure.baseMVA;
network_values.QG = structure.gen(:,3)/structure.baseMVA;
%Pij
network_values.PF = structure.branch(:,14)/structure.baseMVA;
%Pji
network_values.PT = structure.branch(:,16)/structure.baseMVA;
%Qij
network_values.QF = structure.branch(:,15)/structure.baseMVA;
%Qji
network_values.QT = structure.branch(:,17)/structure.baseMVA;


%Construct Admittance Matrix
[Ybus,Yf,Yt] = makeYbus(structure);

%Construct Adjacency Matrix
Adj = spones(Ybus);

%Construct indexes
indexes.bus = structure.bus(:,1);
indexes.branch = structure.branch(:,1:2);

%construct vectors per bus with the numbers of connected from and to busses
connected_busses = cell(N_bus,1);
for i = 1:N_bus
    connected_busses{i}.from = find(structure.branch(:,1)==i);
    connected_busses{i}.to = find(structure.branch(:,2)==i);
end

branch_val(:,1) = structure.branch(:,3)./(structure.branch(:,3).^2 + structure.branch(:,4).^2);
branch_val(:,2) = -structure.branch(:,4)./(structure.branch(:,3).^2 + structure.branch(:,4).^2);

end
