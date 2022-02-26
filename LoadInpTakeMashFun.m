function [Nodes,Elements] = LoadInpTakeMashFun(filename)

%% Get Nodes
filenameNode = [filename '_Nodes'];
filenameEle = [filename '_Elements'];

fidin=fopen([filename '.inp']);                               % ??txt??
fidout=fopen([filenameNode '.txt'],'w');               % ??MKMATLAB.txt??

file_end_signal = 0;
index = fgetl(fidin);
while isempty(findstr(index,'(1i8,3e20.9e3)'))
    index = fgets(fidin);
end
yes = 1;


while ~feof(fidin)                                      % ?????????
    tline=fgetl(fidin);                                 % ?????
    temp=strfind(tline,' ');
    %temp = fgets(fid);          %?????
    if strfind(tline,'! end of nblock command')    %????ESACC?????
        break
    end
    if ~isempty(temp)
        str=tline(temp:end);
        temp=strfind(str,' ');
        temp(4)=length(str)+1;
        for m=1:3
            fprintf(fidout,'%s ',str(temp(m)+1:temp(m+1)-1));
        end
        fprintf(fidout,'\r\n');
    end
end
fclose(fidout);

%% Get Elements
fidin=fopen([filename '.inp']);                               % ??txt??
fidout=fopen([filenameEle '.txt'],'w');               % ??MKMATLAB.txt??

file_end_signal = 0;
index = fgetl(fidin);
while isempty(findstr(index,'(19i8)'))
    index = fgets(fidin);
end
yes = 1;


while ~feof(fidin)                                      % ?????????
    tline=fgetl(fidin);                                 % ?????
    temp=strfind(tline,' ');
    if strfind(tline,'-1')    %????ESACC?????
        break
    end
    if ~isempty(temp)
        str=tline(temp:end);
        temp=strfind(str,' ');
        temp(4)=length(str)+1;
        for m=1:3
            fprintf(fidout,'%s ',str(temp(m)+1:temp(m+1)-1));
        end
        fprintf(fidout,'\r\n');
    end
end
fclose(fidout);

%% Load Nodes
%load([filenameNode '.txt']);
Nodes=load([filenameNode '.txt']);
%save([filenameNode '.mat'],filenameNode);
%save('node.mat',filenameNode);

%% Load Elements
%load([filenameEle '.txt']);
Elements=load([filenameEle '.txt']);
%save([filenameEle '.mat'],filenameEle);
end
