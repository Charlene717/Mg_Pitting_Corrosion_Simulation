function [Result] = RandomSamplingNoRepeatFun(A,m)
% m = 10;
% A = [ 11 11 11 22 33 44 44 77 17 17 17 17 17 17 17 17 77 77 77 55 55 17 7 88 7 7 17 66 66 66 17 17 55 77 55 66 8 9 9 5 5 6 33 1 12 12 44 33 65 75];
AN=A;
B = [];
for j=1:m
    eval(['A' num2str(j) '=AN']);
    A= eval(['A' num2str(j)]);
    n(j) = numel(AN);
    eval(['temp' num2str(j) '= randperm(n(j),m-numel(B))']);
    temp= eval(['temp' num2str(j)]);
    eval(['ans' num2str(j) '= AN(temp)']);
    ans= eval(['ans' num2str(j)]);
    eval(['B' num2str(j) '= unique([B ans]) ']);
    B= eval(['B' num2str(j)]);
    B(find(B==0))=[];
    eval(['UA' num2str(j) '= unique(A)']);
    UA= eval(['UA' num2str(j)]);
    eval(['C' num2str(j) '= setdiff(UA,B)']);
    C= eval(['C' num2str(j)]);
    
    for i=1:n(j)
        A2O(i) = ismember(AN(i),C);
        if A2O(i) == 1
            A2(i)=AN(i);
        end
        
    end
    
    A2(find(A2==0))=[];
    if numel(B)<= m-1,
        AN = A2;
        
    else
        Result = B;
        break
    end
end