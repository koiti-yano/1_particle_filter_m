% An Implementation of Nalder Mead Simplex Algorithm for n independent variables
% Copyright (c) 2014, Michael Mathew
% All rights reserved.
% http://www.mathworks.com/matlabcentral/fileexchange/45475-nelder-mead-simplex-optimization
%
% [Reference] 
% Lagarias, Jeffrey C., et al., (1998), "Convergence properties of the Nelder--Mead 
% simplex method in low dimensions," SIAM Journal on Optimization 9.1, 112-147.
% http://www.personal.soton.ac.uk/rchc/Teaching/GTPBootstrap/ExtraDetails/NelderMeadProof.pdf
%
% [Usage]
% The required function should entered in the function "wrapFuncOrig" below 
% value of n should be modified; n= no of independent variables +1
%
% 2014, Modified by Koiti Yano

%% Nelder-Mead alogorithm
function [minima, varargout]=nelderMeadOrig(wrapFuncOrig, ...
    numOfVertices)
%clc;
%=== Debug flag ===
debug = 1; % Debug
%debug = 0; % No debug

%=== Parameters ===
StdVal=10; %any value for convergence
terminateCondition = 0.00001;

n = numOfVertices; %n=3; %value of N+1 (original code)

P=1; %reflection coefficient
Chi=2; %expansion coefficient
Gamma=0.5; %contraction coefficient
Sig=0.5; %shrink coefficient

maxOfIter = 400;

SortVertices = CreateInitialSimplex(n);

if(debug==1) tic; end
    disp(numOfVertices);

numOfIter=1;
minmas=0;
while(StdVal >= terminateCondition && numOfIter <= maxOfIter)
    SortVertices = BubbleSort(SortVertices,n);
    Centroid = CalculateCentroid(SortVertices,n);
    StdVal = CalculateStd(SortVertices,n);

    % Store min    
    minmas(numOfIter)=SortVertices(1).value; numOfIter=numOfIter+1;
    if debug==1 && rem(numOfIter,10)==0
        messageIter = ['Interation: ', num2str(numOfIter),  '.'];
        disp(messageIter)   
    end

    Reflect.coord = (1+P).*Centroid.coord - P.*SortVertices(n).coord; %Reflect
    Reflect.value = wrapFuncOrig(Reflect);
     
    if(SortVertices(1).value <= Reflect.value &&  ...
            Reflect.value < SortVertices(n-1).value)
        SortVertices(n)=Reflect;
        continue; %if the above criterion is sattisfied, then terminate 
                  %the iteration
    end
    
    if(Reflect.value < SortVertices(1).value) %Expand
        
        Expand.coord = (1-Chi).*Centroid.coord+Chi.*Reflect.coord;
        Expand.value = wrapFuncOrig(Expand);
        
        if(Expand.value < Reflect.value)
            
            SortVertices(n) = Expand;
            continue;
        else
            SortVertices(n) = Reflect;
            continue;
        end 
    end
    
    if(SortVertices(n-1).value <= Reflect.value) %Contract
        ContractOut.coord = (1-Gamma).*Centroid.coord + Gamma.*Reflect.coord; %Contract Outside
        ContractOut.value = wrapFuncOrig(ContractOut);
            
        ContractIn.coord = (1-Gamma).*Centroid.coord + Gamma.*SortVertices(n).coord;  %Contract Inside
        ContractIn.value= wrapFuncOrig(ContractIn);
            
        if(SortVertices(n-1).value <= Reflect.value && ...
                Reflect.value < SortVertices(n).value && ...
                ContractOut.value <= Reflect.value)
            SortVertices(n) = ContractOut;
            continue;
        elseif(SortVertices(n).value <= Reflect.value && ...
                    ContractIn.value < SortVertices(n).value) %Contract Inside
                SortVertices(n) = ContractIn;
                continue;
        else
            for numOfIter=2:n
                SortVertices(numOfIter).coord = (1-Sig).*SortVertices(1).coord + ...
                Sig.*SortVertices(numOfIter).coord;
            SortVertices(numOfIter).value = wrapFuncOrig(SortVertices(numOfIter));   
            end
        end
    end
end
if debug==1 toc; end

 % Check the number of iteration
if numOfIter >= maxOfIter
    messageMaxIter = ['Hit the upper limit of interation ',  ...
         num2str(numOfIter),  '.'];
     disp(messageMaxIter)   
end

minima=SortVertices(1);
varargout = {minmas, numOfIter};
end

%%
function [Vertices]=CreateInitialSimplex(n)
ExpectMin=rand((n-1),1).*50;
Vertices(1).coord=ExpectMin; % expected minima
Vertices(1).value=wrapFuncOrig(Vertices(1));

for i=2:n
    Vertices(i).coord=ExpectMin+50.*rand((n-1),1); %100 is the scale factor
    Vertices(i).value=wrapFuncOrig(Vertices(i));
end
    
end
%%
function [SortVertices]=BubbleSort(Vertices,n)
while(n~=0)
    for i=1:n-1
        if(Vertices(i).value<=Vertices(i+1).value)
            continue;
        else
            temp=Vertices(i);
            Vertices(i)=Vertices(i+1);
            Vertices(i+1)=temp;
        end
    end
    n=n-1;
end
SortVertices=Vertices;
    
end
%%
function [Centroid]=CalculateCentroid(Vertices,n)
Sum=zeros((n-1),1);
for i=1:n-1
    Sum=Sum+Vertices(i).coord;
end

Centroid.coord=Sum./(n-1);
Centroid.value=wrapFuncOrig(Centroid);
    
end
%%
% this is the tolerance value, the standard deviation of the converging values
function[StdVal]=CalculateStd(Vertices,n) 

ValueArray = zeros(n,1);
for i=1:n
    ValueArray(i)=Vertices(i).value;
end

StdVal=std(ValueArray,1);
    
end
