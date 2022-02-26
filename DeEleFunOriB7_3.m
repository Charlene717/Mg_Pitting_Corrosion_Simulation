function [restNode3,restElem3,delExpoElemIdx3,A1] = DeEleFunOriB7_3(node,elem,restElem2,delExpoElemIdx2,PerCVolume,UEV,HPPC,FMF2,MF)
%% Create NewElementTable By Neighbor 3
nodeList3 = sort(restElem2(:, 12:19), 2);
nbrList3 = findNeighbor(nodeList3')';
%% Count NbrElement & Count ExpoFace & Select the ExpoElement 3
nbrList3 = [nbrList3, sum(nbrList3 ~= 0, 2)];% Count NbrElement 
ExpoFace3=[6*ones(size(restElem2,1),1)-nbrList3(:,7)]; %Count ExpoFace
ExpoElement3=[restElem2(:,1:22),ExpoFace3];
ExpoElement3=ExpoElement3(find(ExpoElement3(:,23)~=0),:); %Select the ExpoElement
%% Count the probability of corrosion 3
HPDElem = ExpoElement3(find(ExpoElement3(:,20).*ExpoElement3(:,21) >= HPPC),:);
HPDElem(:,23) = HPDElem(:,23).*FMF2;
F=(HPDElem(:,20).*HPDElem(:,21)).*HPDElem(:,22).*HPDElem(:,23);
F=round(F);
PFSum =sum(F);

%% Delete some elements with probability 3
% Set weights and random
A = [];
B = [];
for i=1:length(HPDElem(:,11))
    B = [HPDElem(i,11).*ones(F(i),1)];
    A = [A B'];
end

P2 =  MF*PerCVolume/(UEV*length(A));
% %A =A';
% % A1=find(rand(size(A,1), 1) <  P2);

A1=A(find(rand(length(A), 1) <  P2));
% %A1=A(find(rand(length(A,1), 1) <  P2),1);

A2 = unique(A1);
delExpoElemIdx3 = HPDElem(:,11);
delExpoElemIdx3=delExpoElemIdx3(find(ismember(delExpoElemIdx3(:,1),A2)), :);
%delExpoElemIdx3=delExpoElemIdx3(A2, :); %NG
delExpoElemIdx3=[delExpoElemIdx3; delExpoElemIdx2];
restElemIdx3 = elem(:,11);
restElemIdx3(delExpoElemIdx3,:) = [];
restElem3 = elem(restElemIdx3, :);

% Remove the floating point
nodeListD3 = sort(restElem3(:, 12:19), 2);
nbrListD3 = findNeighbor(nodeListD3')';
nbrListD3 = [nbrListD3, sum(nbrListD3 ~= 0, 2)];% Count NbrElement 
ExpoFaceD3=[6*ones(size(restElem3,1),1)-nbrListD3(:,7)]; %Count ExpoFace
restElem3=[restElem3(:,1:22),ExpoFaceD3];
restElem3=restElem3(find(restElem3(:,23) <= 4),:); %Select the ExpoElement
restElemIdx3 = restElem3(:,11);
delExpoElemIdx3 = elem(:,11);
delExpoElemIdx3(restElemIdx3,:) = [];


restNodeIdx3 = elem(restElemIdx3, 12:19);
restNodeIdx3 = unique(restNodeIdx3(:));
restNode3 = node(restNodeIdx3, :);
end