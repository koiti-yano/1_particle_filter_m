% An Implementation of Nalder Mead Simplex Algorithm for n independent variables
% Copyright (c) 2014, Michael Mathew
% All rights reserved.
%
% [Original code]
% http://www.mathworks.com/matlabcentral/fileexchange/45475-nelder-mead-simplex-optimization
% or refereceCode/nelderMead/nelderMeadMultiDim/original/Nelder_Mead_MultiDimMatrixForm.m
%
% [Reference] 
% Lagarias, Jeffrey C., et al., (1998), "Convergence properties of the Nelder--Mead 
% simplex method in low dimensions," SIAM Journal on Optimization 9.1, 112-147.
% http://www.personal.soton.ac.uk/rchc/Teaching/GTPBootstrap/ExtraDetails/NelderMeadProof.pdf
%
% [Usage]
% The required function should entered in the function "wrapFunc" below 
% value of n should be modified; n= no of independent variables +1
%
% 2014, Modified by Koiti Yano

%% Nelder-Mead alogorithm
function [minima, varargout]=nelderMead(wrapFunc, ...
    numOfVertices, observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr)
%clc;
%=== Debug flag ===
debug = 1; % Debug
%debug = 0; % No debug
%disp(observedValue);

%=== Parameters ===
StdVal=10; %any value for convergence
%terminateCondition = 0.0001;
terminateCondition = 0.001;

n = numOfVertices; %n=3; %value of N+1 (original code)

P=1; %reflection coefficient
Chi=2; %expansion coefficient
Gamma=0.5; %contraction coefficient
Sig=0.5; %shrink coefficient

maxOfIter = 50;

SortVertices = CreateInitialSimplex(n, observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);

if(debug==1) tic; end

numOfIter=1;
minmas=zeros(maxOfIter, 1);

%while(StdVal >= terminateCondition)
minValArray = NaN(maxOfIter, 1);
while(StdVal >= terminateCondition && numOfIter < maxOfIter)
    numOfIter=numOfIter+1;
    messageIter = ['Interation: ', num2str(numOfIter),  '.'];
    disp(messageIter)   

    SortVertices = BubbleSort(SortVertices, n);
    minValArray(numOfIter, 1) = SortVertices(1).value;
    plot(minValArray);
    title('The nagative log-likelihood')
    Centroid = CalculateCentroid(SortVertices, n, observedValue, ...
        timeLength, numberOfState, numberOfObs, numberOfParticle, ...
        modelFlag, paramSys, paramObs, initialDistr);
    StdVal = CalculateTerminateCond(SortVertices, n);

    % Store min    
    minmas(numOfIter)=SortVertices(1).value;

    Reflect.coord = (1+P).*Centroid.coord - P.*SortVertices(n).coord; %Reflect
    Reflect.value = wrapFunc(Reflect, observedValue, ...
        timeLength, numberOfState, numberOfObs, numberOfParticle, ...
        modelFlag, paramSys, paramObs, initialDistr);
     
    if(SortVertices(1).value <= Reflect.value &&  ...
            Reflect.value < SortVertices(n-1).value)
        SortVertices(n)=Reflect;
        continue; %if the above criterion is sattisfied, then terminate 
                  %the iteration
    end
    
    if(Reflect.value < SortVertices(1).value) %Expand
        
        Expand.coord = (1-Chi).*Centroid.coord+Chi.*Reflect.coord;
        Expand.value = wrapFunc(Expand, observedValue, ...
            timeLength, numberOfState, numberOfObs, numberOfParticle, ...
            modelFlag, paramSys, paramObs, initialDistr);
        
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
        ContractOut.value = wrapFunc(ContractOut, observedValue, ...
            timeLength, numberOfState, numberOfObs, numberOfParticle, ...
            modelFlag, paramSys, paramObs, initialDistr);
            
        ContractIn.coord = (1-Gamma).*Centroid.coord + Gamma.*SortVertices(n).coord;  %Contract Inside
        ContractIn.value= wrapFunc(ContractIn, observedValue, ...
            timeLength, numberOfState, numberOfObs, numberOfParticle, ...
            modelFlag, paramSys, paramObs, initialDistr);
            
        if(SortVertices(n-1).value <= Reflect.value && ...
                Reflect.value < SortVertices(n).value && ...
                ContractOut.value <= Reflect.value)
            SortVertices(n) = ContractOut;
            disp('Contract out');
            continue;
        elseif(SortVertices(n).value <= Reflect.value && ...
                    ContractIn.value < SortVertices(n).value) %Contract Inside
                disp('Contract inside');
                SortVertices(n) = ContractIn;
                continue;
        else
            for ii=2:n
                disp('Shrink');
                SortVertices(ii).coord = (1-Sig).*SortVertices(1).coord + ...
                    Sig.*SortVertices(ii).coord;
                SortVertices(ii).value = wrapFunc(SortVertices(ii), ...
                     observedValue, ...
                     timeLength, numberOfState, numberOfObs, numberOfParticle, ...
                     modelFlag, paramSys, paramObs, initialDistr);   
            end
        end
    end
end % while
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
function [Vertices]=CreateInitialSimplex(n, observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr)
%initialFlag = 'staticInit'; % Appendix, Nelder-Mead (1965)
initialFlag = 'stochasticInit'; % Original code

% Preallocate memory for a structure Vertices
tmpStruct = struct('coord', 0, 'value', 0);
Vertices = repmat(tmpStruct, n,1);

if strcmp(initialFlag, 'staticInit')
    
    % Generate initial vertices (see Appendix, Nelder-Mead (1965) )
%    ExpectMin=zeros((n-1),1);
    ExpectMin=rand((n-1),1); 
    Vertices(1).coord=ExpectMin; % expected minima
    Vertices(1).value=wrapFunc(Vertices(1), observedValue, ...
        timeLength, numberOfState, numberOfObs, numberOfParticle, ...
        modelFlag, paramSys, paramObs, initialDistr);
    
    identMat = eye((n-1), (n-1));
    for i=2:n
        Vertices(i).coord=identMat(:,(i-1)); %100 is the scale factor
        Vertices(i).value=wrapFunc(Vertices(i), observedValue, ...
            timeLength, numberOfState, numberOfObs, numberOfParticle, ...
            modelFlag, paramSys, paramObs, initialDistr);
    end
    
elseif strcmp(initialFlag, 'stochasticInit')
    
    % Generate initial vertices (Mathew's original code)
    scaleFactor = 1; %the scale factor
    ExpectMin=rand((n-1),1).*scaleFactor; 
    Vertices(1).coord=ExpectMin; % expected minima
    Vertices(1).value=wrapFunc(Vertices(1), observedValue, ...
        timeLength, numberOfState, numberOfObs, numberOfParticle, ...
        modelFlag, paramSys, paramObs, initialDistr);
    
    for i=2:n
        Vertices(i).coord=ExpectMin+scaleFactor.*rand((n-1),1); %50 is the scale factor
        Vertices(i).value=wrapFunc(Vertices(i), observedValue, ...
            timeLength, numberOfState, numberOfObs, numberOfParticle, ...
            modelFlag, paramSys, paramObs, initialDistr);
    end

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
function [Centroid]=CalculateCentroid(Vertices, n, observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr)
Sum=zeros((n-1),1);
for i=1:n-1
    Sum=Sum+Vertices(i).coord;
end

Centroid.coord=Sum./(n-1);
Centroid.value=wrapFunc(Centroid, observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr);
    
end
%%
% This is the tolerance value, the standard deviation of the converging values
function[terminateVal]=CalculateTerminateCond(Vertices,n) 

ValueArray = zeros(n,1);
for i=1:n
    ValueArray(i)=Vertices(i).value;
end

%StdVal=std(ValueArray,1);
terminateVal=var(ValueArray,1);    
end
