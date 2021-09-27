%%
% Author: Michael Jacob Mathew; 
% http://www.mathworks.com/matlabcentral/fileexchange/45475-nelder-mead-simplex-optimization

function [value]=wrapFunc(V, observedValue, ...
    timeLength, numberOfState, numberOfObs, numberOfParticle, ...
    modelFlag, paramSys, paramObs, initialDistr) %Write your function in matrix form
%in case of any of the three trial functions un comment two lines

algorithmFlag = 'particleFilter';
%algorithmFlag = 'auxiliaryParticleFilter'; % Not good.

switch modelFlag
   case 'oneDimLinearGaussian'
        paramSys = abs(V.coord(1));
        paramObs = abs(V.coord(2));
        
    case 'oneDimNonLinear'
        paramSys = abs(V.coord(1));
        paramObs = abs(V.coord(2));
        
    case 'stocVol'
        paramSys.mu = (V.coord(1));
        paramSys.phi = (V.coord(2));
        paramSys.sigma = abs(V.coord(3));
        
        paramObs.sigma = abs(V.coord(4));
        paramSys
        paramObs

   otherwise
      disp('Error in wrapFunc!')
end


if strcmp(algorithmFlag, 'particleFilter')
    
    [stateEstimated, logLikeli, lowerBound, upperBound] = ...
        particleFilter(observedValue, ...
        timeLength, numberOfState, numberOfObs, numberOfParticle, ...
        modelFlag, paramSys, paramObs, initialDistr);
    value = -logLikeli;
    disp(['The nagative log-likelihood: ', num2str(value),'.'])
    
elseif strcmp(algorithmFlag, 'auxiliaryParticleFilter')
    
    [auxStateEstimated, auxLogLikeli, auxLowerBound, auxUpperBound] = ...
        auxiliaryParticleFilter(observedValue, ...
        timeLength, numberOfState, numberOfObs, numberOfParticle, modelFlag, ...
        paramSys, paramObs, initialDistr);
    value = -auxLogLikeli;
    disp(['The nagative log-likelihood: ', num2str(value),'.'])
    
end
    
end
