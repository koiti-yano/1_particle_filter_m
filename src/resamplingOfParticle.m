% resamplingOfParticle.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function [resampledState, resampledIndex] = resamplingOfParticle(state, ...
    weight, numberOfParticle)

tmpIndex = 1:numberOfParticle;

resamplingFuncFlag = 'resamplingSystematic'; % Relatively fast
%resamplingFuncFlag = 'resamplingByHistc'; % It is same with resamplingSystematic
%resamplingFuncFlag = 'statisticsToolbox'; % Statistics toolbox is required

try
    switch resamplingFuncFlag
        case 'resamplingSystematic'
           resampledIndex  = resamplingSystematic(tmpIndex, weight);
            
        case 'resamplingByHistc'
            resampledIndex = resamplingByHistc(tmpIndex, weight);
                        
        case 'statisticsToolbox' % Statistics and machine learning toolbox is required.  
            [~, resampledIndex] = datasample(tmpIndex, numberOfParticle, ...
                'Weights', weight, 'Replace', true);
        otherwise
            warning('resamplingFuncFlag n resamplingOfParticle should be setted.')
    end
catch
    disp('Errors in resamplingOfParticle');
end
resampledState = state(resampledIndex, :);
%=========================================

