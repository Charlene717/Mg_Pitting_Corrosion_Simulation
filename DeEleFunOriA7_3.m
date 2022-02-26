function [restNode1,restElem1,delExpoElemIdx1,A1] = DeEleFunOriA7_3(node,elem,PerCVolume,UEV,HPPC,FMF,MF)
%% Create NewElementTable By Neighbor 1
nodeList1 = sort(elem(:, 12:19), 2);
nbrList1 = findNeighbor(nodeList1')';
%% Count NbrElement & Count ExpoFace & Select the ExpoElement 1
nbrList1 = [nbrList1, sum(nbrList1 ~= 0, 2)];% Count NbrElement
ExpoFace1=[6*ones(size(elem,1),1)-nbrList1(:,7)]; %Count ExpoFace
ExpoElement1=[elem(:,1:22),ExpoFace1];
ExpoElement1=ExpoElement1(find(ExpoElement1(:,23)~=0),:); %Select the ExpoElement
%% Count the probability of corrosion 1
HPDElem = ExpoElement1(find(ExpoElement1(:,20).*ExpoElement1(:,21) >= HPPC),:);
HPDElem(:,23) = HPDElem(:,23).*FMF;
F=(HPDElem(:,20).*HPDElem(:,21)).*HPDElem(:,22).*HPDElem(:,23);
F=round(F);
PFSum =sum(F);  

%% Delete some elements with probability 1
% Set weights and random
A = [];
B = [];
for i=1:length(HPDElem(:,11))
    B = [HPDElem(i,11).*ones(F(i),1)];
    A = [A B'];
end

p1 = MF*PerCVolume/(UEV*length(A));
% % % A =A';
% % A1=find(rand(size(A,1), 1) <  p1);

A1=A(find(rand(length(A), 1) <  p1));
% % % A1=A(find(rand(length(A,1), 1) <  p1),1);

%A1=A1';
A2 = unique(A1);
delExpoElemIdx1 = HPDElem(:,11);
delExpoElemIdx1=delExpoElemIdx1(find(ismember(delExpoElemIdx1(:,1),A2)), :);
%delExpoElemIdx1=delExpoElemIdx1(A2, :); %NG
restElemIdx1 = elem(:,11);
restElemIdx1(delExpoElemIdx1,:) = [];
restElem1 = elem(restElemIdx1, :);

% Remove the floating point
nodeListD1 = sort(restElem1(:, 12:19), 2);
nbrListD1 = findNeighbor(nodeListD1')';
nbrListD1 = [nbrListD1, sum(nbrListD1 ~= 0, 2)];% Count NbrElement 
ExpoFaceD1=[6*ones(size(restElem1,1),1)-nbrListD1(:,7)]; %Count ExpoFace
restElem1=[restElem1(:,1:22),ExpoFaceD1];
restElem1=restElem1(find(restElem1(:,23) <= 4),:); %Select the ExpoElement
restElemIdx1 = restElem1(:,11);
delExpoElemIdx1 = elem(:,11);
delExpoElemIdx1(restElemIdx1,:) = [];


restNodeIdx1 = elem(restElemIdx1, 12:19);
restNodeIdx1 = unique(restNodeIdx1(:));
restNode1 = node(restNodeIdx1, :);
end