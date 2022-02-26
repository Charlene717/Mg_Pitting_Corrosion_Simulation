clc;clear all;close all;
%% Parameter setting
filename = 'AZ61SquareMS000125';
CVer= '_C7_3'; % Coding version
Ver= 14; % version
TV = 450; % Total volume(mm^3)
Surface = 570; % Surface area (mm^2)
MD = 1.777; % Magnesium alloy density (mg/mm^3)
a = 2.83e-04; b = -3.06e-02; %y=ax+b
CRate = a*Surface; % Corrosion Rate (mg/hr)
HPN = fix((100/(15*15))*Surface) ; % Hot points Number
PHP = 1/7; % Proportion of Hot points
HPPC = 0.6; % Hot points Probability Contral 
HPPC2 = 0.8; % Hot points probibility Contral for outer ring
HPT = 3;% Hot points times

PRF = 1; % point radius Factor
PR=sqrt(PHP*Surface/(pi*HPN))*PRF; % point radius
%PR=1; % point radius
PR2=1/3*PR; % point radius proportion for inner

StressMF = 0.1; % Stress Modify Factor for refinrment
StressMF2 = 0.1; % Stress Modify Factor for refinrment for second state
OxLPC = 0.000001 ; % Oxide layer Probability Contral for refinrment
FMF = 1; % Face Modify Factor
FMF2 = 1; %  Face Modify Factor for second state
MF = 1; % Modify factor
%%
NodeColor = 'k'; RNodeColor = 'g';
SumCTime = 500; % Sum of Corrosion time (hr)
CTimes = 20;% Corrosion times
PerCTime = SumCTime/CTimes; % Per Corrosion time (hr)
PerCMass =  PerCTime*CRate; % Per time Corrosion Mass(mg)
PerCVolume =  PerCMass/MD; % Per time Corrosion volume(mm^3)

%% read inp files
[node,elem] = LoadInpTakeMashFun(filename); % Mesh model
TElem = length(elem); % Total elements number
UEV = TV/TElem; % Unit element volume(mm^3)
One = ones(length(elem),1); % For oxide layer and hot points
% stress
Stress =load([filename '_Stress.txt']);
Stress2 = Stress;

StressMF = StressMF*mean(Stress(:,2)); % Stress Modify Factor
Stress =Stress/StressMF;
elemF = [elem One One Stress(:,2)]; % Element with factors

StressMF2 = StressMF2*mean(Stress2(:,2));
Stress2 =Stress2/StressMF2;
elemF2 = [elem One One Stress2(:,2)];

%
%control without stress
elemF(:,22)=1;
elemF2(:,22)=1;
%}

%% Set the oxide layer
nodeList = sort(elem(:, 12:19), 2);
nbrList = findNeighbor(nodeList')';
nbrList = [nbrList, sum(nbrList ~= 0, 2)];% Count NbrElement
ExpoFace=[6*ones(size(elem,1),1)-nbrList(:,7)]; %Count ExpoFace
elemF =[elemF,ExpoFace];

for o=1:1:length(elem)
    if elemF(o,23) ~= 0,
        elemF(o,20) = elemF(o,20)*OxLPC;
    else
        elemF(o,20) = elemF(o,20);
    end
end
elemF2 =[elemF2,ExpoFace];
for p=1:1:length(elem)
    if elemF2(p,23) ~= 0,
        elemF2(p,20) = elemF2(p,20)*OxLPC;
    else
        elemF2(p,20) = elemF2(p,20);
    end
end
%}
%% Set the Random hot points
% Find ExpoNode
A2 = elem(:, 12:19);
A2 = sort(reshape(A2, [], 1));
A = node(:,1);
C = [node(:,1),histc(A2,A)];
F = find(C(:,2)<8);
ExpoNode = node(F, :);
% Catch Random Node
RExpoNode =ExpoNode(:,1);
Rand = RExpoNode(randperm(length(RExpoNode)));% Take Random number
RandHP = sort(Rand(1:HPN)); % Rand hot point
nodeRandHP = node(RandHP, :);

% Take the range of the Random Node
for r=1:1:length(nodeRandHP)
    for n=1:1:length(ExpoNode)
        
        AB = ExpoNode(n,2:4) - nodeRandHP(r,2:4);
        if norm(AB) < PR2,
            nodeRandHPR(n,:) = ExpoNode(n,:);
            continue
        else if   norm(AB)>=PR2 &  norm(AB)<= PR,
                nodeRandHPR2(n,:) = ExpoNode(n,:);
                %      continue
            end
        end
        
    end
    
end
nodeRandHPR=nodeRandHPR(find(nodeRandHPR(:,1)>0),:);
RandHPR = nodeRandHPR(:,1);  % Rand hot points range
nodeRandHPR2=nodeRandHPR2(find(nodeRandHPR2(:,1)>0),:);
nodeRandHPR2 = nodeRandHPR2(find(ismember(nodeRandHPR2(:,1),setdiff(nodeRandHPR2(:,1),nodeRandHPR(:,1)))), :);
RandHPR2 = nodeRandHPR2(:,1);

%
for h=1:1:length(elem)
    
    if sum(ismember(elemF(h,12:19),RandHPR)) >= 1,
        %        if ismember(elemF(h,12:19),RandHPR)== 1 % & elemF(o,23) ~= 0,
        elemF(h,21) = elemF(h,21)/OxLPC;
        elemF2(h,21) = HPPC.*elemF2(h,21)/OxLPC;
    else if sum(ismember(elemF(h,12:19),RandHPR2)) >= 1,
            %        if ismember(elemF(h,12:19),RandHPR)== 1 % & elemF(o,23) ~= 0,
            elemF(h,21) = HPPC2.*elemF(h,21)/OxLPC;
            elemF2(h,21) = HPPC2.*HPPC.*elemF2(h,21)/OxLPC;
            
        else
            elemF(h,21) = elemF(h,21);
            elemF2(h,21) = elemF2(h,21);
        end
    end
    
end
%}
%% Set the specific hot points



%% Corrosion process
%1
[restNode1,restElem1,delExpoElemIdx1,aoutputCheck1] = DeEleFunOriA7_3(node,elemF,PerCVolume,UEV,HPPC2*HPPC,FMF,MF); %% DeEleFunctionA

for d=2:1:HPT
    SN=num2str(d);SNP=num2str(d-1);
    restElemP = eval(['restElem' SNP]); delExpoElemIdxP = eval(['delExpoElemIdx' SNP]);
    [restNode,restElem,delExpoElemIdx,aoutputCheck2] = DeEleFunOriB7_3(node,elemF,restElemP,delExpoElemIdxP,PerCVolume,UEV,HPPC2*HPPC,FMF,MF); %% DeEleFunctionB
    eval(['restNode' SN '=restNode']); eval(['restElem' SN '=restElem']); eval(['delExpoElemIdx' SN '=delExpoElemIdx']);
end

%2-CTimes
for c=(HPT+1):1:CTimes
    SN2=num2str(c);SNP=num2str(c-1);
    restElemP = eval(['restElem' SNP]); delExpoElemIdxP = eval(['delExpoElemIdx' SNP]);
    [restNode,restElem,delExpoElemIdx,aoutputCheck3] = DeEleFunOriB7_3(node,elemF2,restElemP,delExpoElemIdxP,PerCVolume,UEV,HPPC2*HPPC,FMF2,MF); %% DeEleFunctionB
    eval(['restNode' SN2 '=restNode']); eval(['restElem' SN2 '=restElem']); eval(['delExpoElemIdx' SN2 '=delExpoElemIdx']);
end

%% export inp files & Mass Loss
for n=1:1:CTimes
    nodeC = eval(['restNode' num2str(n)]); elementC = eval(['restElem' num2str(n)]);
    [filenameTemp] = WriteNewInpFun2_2_2(nodeC,elementC(:,1:19),n,filename,Ver,CVer);
    LenE = length(elementC(:,1));
    eval(['LenE' num2str(n) '=LenE']); % rest element number
    LenE = eval(['LenE' num2str(n)])
    eval(['RElemV' num2str(n) '=LenE*UEV']); % Total volume of rest element
    RElemV = eval(['RElemV' num2str(n)]);
    eval(['ML' num2str(n) '=(TV-RElemV)*MD']); % Mass Loss
    ML(n) = eval(['ML' num2str(n)]);
end
% Mass Loss Figure
for k=1:1:CTimes
    time(k)=(SumCTime/CTimes)*k;
end
ML = [0 ML/Surface]; time = [0 time];
y = a*time + b;
figure(1);plot(time,ML,'m--*',time,y,'b');xlabel('Time(h)');;ylabel('Mass Loss(mg/mm^2)'); title([filename '-V' num2str(Ver) '-Mass Loss']);legend('Simulation','Experiment','Location','northwest');
saveas(gcf,[filename CVer '-V' num2str(Ver) '-Mass Loss'],'png')
saveas(gcf,[filename CVer '-V' num2str(Ver) '-Mass Loss'],'fig')
xlswrite([filename CVer '-V' num2str(Ver) '-Mass Loss'],[time;ML]','ML' ,['A2:A' num2str(CTimes+2) ':B2:B' num2str(CTimes+2)]); %
xlswrite([filename CVer '-V' num2str(Ver) '-Mass Loss'],{'Time','ML'},'ML' );

%% Export settings
fidout=fopen([filename CVer '-V' num2str(Ver) '-Export settings.txt'],'w');
fprintf(fidout,'%s ',[filename '-V' num2str(Ver) '-Export settings:']);
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['Total volume(mm^3):' num2str(TV) '                   Surface area(mm^2):' num2str(Surface) '                        MgA density (mg/mm^3):' num2str(MD)]);
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['Total elements number:' num2str(TElem)]);
fprintf(fidout,'\r\n');
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['y=ax+b:' ' a=' num2str(a) ' b=' num2str(b)]);
fprintf(fidout,'\r\n');
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['Corrosion Rate (mg/hr):' num2str(CRate) '           Total Corrosion time (hr):' num2str(SumCTime) '                Corrosion times:' num2str(CTimes)]);
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['Per Corrosion time (hr):' num2str(PerCTime) '               Per time Corrosion Mass(mg):' num2str(PerCMass) '           Per time Corrosion volume(mm^3):' num2str(PerCVolume)]);
fprintf(fidout,'\r\n');
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['Proportion of Hot points:' num2str(PHP) '             Stress Modify Factor:' num2str(StressMF) '              Stress Modify Factor2:' num2str(StressMF2)]);
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['Hot points Probability Contral:' num2str(HPPC)  '       Hot points probibility Contral for outer ring:' num2str(HPPC2)]);
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['Oxide layer Probability Contral:' num2str(OxLPC)]);
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['Hot points times:' num2str(HPT) '                       Face Modify Factor:' num2str(FMF) '                         Face Modify Factor2:' num2str(FMF2)]);
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['Hot points number:' num2str(HPN) '                     Point Radius Factor:' num2str(PRF)]);
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ',['Point radius:' num2str(PR)   '                      Point radius proportion for inner:' num2str(PR2)]);
fprintf(fidout,'\r\n');
fclose(fidout);

aoutputCheck1
aoutputCheck2
aoutputCheck3
%% plot results
%{
    figure(2);
    for p=1:1:CTimes
        
        restNode = eval(['restNode' num2str(p)]);
        subplot(CTimes, 1, p);
        scatter3(node(:, 2), node(:, 3), node(:, 4), NodeColor); hold on;title(['Corrosion time: ' num2str((SumCTime/CTimes)*p) ' hr']);
        scatter3(restNode(:, 2), restNode(:, 3), restNode(:, 4), RNodeColor);
        ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        text(0.5, 1,[filename '-V' num2str(Ver)],'fontsize',17,'fontweight','bold','HorizontalAlignment' ,'center','VerticalAlignment', 'top')
        
    end
    saveas(gcf,[filename CVer '-V' num2str(Ver)],'png')
    saveas(gcf,[filename CVer '-V' num2str(Ver)],'fig')
%}