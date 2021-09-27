% initialParticle.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html

function initParticle = initialParticle(initialDistr, ...
    numberOfParticle, modelFlag)

switch modelFlag
    case 'oneDimLinearGaussian'
        initParticle = initialDistr + randn(numberOfParticle,1);
        
    case 'oneDimNonLinear'
        initParticle = initialDistr + 5 * randn(numberOfParticle,1);
    
    case 'stocVol'
        initParticle = initialDistr + 1 * randn(numberOfParticle,1);
%        Improper prior distribution case
%        initParticle = initialDistr + 5 * randn(numberOfParticle,1); 
        
    case 'twoDimLinearGaussian'
        initParticle =  mvnrnd(initialDistr, [1 0 ; 0 1], numberOfParticle);
        
    case 'rbcSecondOrderItera'
        initParticle =  mvnrnd(initialDistr, [1 0 0; 0 1 0; 0 0 1], ...
            numberOfParticle);

    case 'rbcSecondOrderIteraParallel';
        initParticle =  mvnrnd(initialDistr, [1 0 0; 0 1 0; 0 0 1], ...
            numberOfParticle);

end
%=========================================

