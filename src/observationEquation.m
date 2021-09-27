% observationEquation.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function observedValue = observationEquation(state, observationNoise, ...
     numberOfObs, modelFlag, paramObs, timeIndex)

switch modelFlag
    case 'oneDimLinearGaussian'
        observedValue = state + observationNoise;
        
    case 'oneDimNonLinear'
        observedValue = (state^2)/10 + observationNoise;
        
    case 'stocVol'
        observedValue = observationNoise * exp(state/2);
        
    case 'twoDimLinearGaussian'
        observedValue = state + observationNoise;
        
    case 'rbcSecondOrderItera'
        observedValue = state + observationNoise;

    case 'rbcSecondOrderIteraParallel'
        observedValue = state + observationNoise;

end
%=========================================

