function [filenameTemp] = WriteNewInpFun2_2_2(node,element,CTimes,inpfilename,Ver,CVer)
% inpfilename = 'TTT20161013drop';
 CTimes = num2str(CTimes);
% load restNode7.mat
% load restElem7.mat
% Node = num2str(restNode9);
%% Create New file
filenameTemp = [inpfilename CVer '_V' num2str(Ver) '_' CTimes];
fidin=fopen([inpfilename '.inp']);    


%% Write p1
       
fidout=fopen([filenameTemp '.txt'],'w');               % ??MKMATLAB.txt??
%
while ~feof(fidin)         % ?????????
    tline=fgetl(fidin);
    if strfind(tline,'(1i8,3e20.9e3)')    %????ESACC?????
        break
    end
  
    if ~isempty(tline)
        str=tline;
        fprintf(fidout,'%s ',str);
    end
    fprintf(fidout,'\r\n');
end
fprintf(fidout,'%s ','(1i8,3e20.9e3)');
fprintf(fidout,'\r\n');
%fclose(fidout);

%
%% Put in Nodes
formatSpec = ' %7.0f %19.9e %19.9e %19.9e\r\n';
fprintf(fidout,formatSpec,node');


%
%% Write p2

file_end_signal = 0;
index2 = fgetl(fidin);
while isempty(findstr(index2,'! end of nblock command'))
    index2 = fgets(fidin);
end
yes = 1;
fprintf(fidout,'%s ','! end of nblock command');
fprintf(fidout,'\r\n');
while ~feof(fidin)         % ?????????
    tline=fgetl(fidin);
    if strfind(tline,'(19i8)')    %????ESACC?????
        break
    end
  
    if ~isempty(tline)
        str=tline;
        fprintf(fidout,'%s ',str);
    end
    fprintf(fidout,'\r\n');
end
fprintf(fidout,'%s ','(19i8)');
fprintf(fidout,'\r\n');

%% Put in Element
formatSpec2 = ' %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f\r\n';
fprintf(fidout,formatSpec2,element');

%% Write p3
 
file_end_signal = 0;
index3 = fgetl(fidin);
while isempty(findstr(index3,'-1'))
    index3 = fgets(fidin);
end
yes = 1;
fprintf(fidout,'%s ','-1');
fprintf(fidout,'\r\n');
while ~feof(fidin)         % ?????????
    tline=fgetl(fidin);
    if strfind(tline,'/GOPR')    %????ESACC?????
        break
    end
  
    if ~isempty(tline)
        str=tline;
        fprintf(fidout,'%s ',str);
    end
    fprintf(fidout,'\r\n');
end
fprintf(fidout,'%s ','/GOPR');fprintf(fidout,'\r\n');
fprintf(fidout,'%s ','!');fprintf(fidout,'\r\n');
fprintf(fidout,'%s ','FINI');fprintf(fidout,'\r\n');
fprintf(fidout,'\r\n');
fprintf(fidout,'%s ','/GOPR');fprintf(fidout,'\r\n');
fclose(fidout);

%% Change txt to inp
%
fidin2=fopen([filenameTemp '.txt']);           
fidout2=fopen([filenameTemp '.inp'],'w');               % ??MKMATLAB.txt??

while ~feof(fidin2)                                      % ?????????
    tline=fgetl(fidin2);                                 % ?????
    if ~isempty(tline)
        str=tline;
        fprintf(fidout2,'%s ',str);
    end
    fprintf(fidout2,'\r\n');
end

fclose(fidout2);
end