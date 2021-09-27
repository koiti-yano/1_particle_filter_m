function [ y ] = mvnpdfWrapper(X, MU, SIGMA)
% This function transpose y = mvnpdf(X,MU,SIGMA) because the output
% y is row vectors. Most textbooks define y as a column vector.
% http://jp.mathworks.com/help/stats/multivariate-normal-distribution.html
%
% To run the function, Statistics and Machine Learning Toolbox is required.

X = X.';
MU = MU.';

switch nargin
    case 2
        y = mvnpdf(X, MU).';
    case 3
        y = mvnpdf(X, MU, SIGMA).';
    otherwise
        disp('An error in mvnpdfTranspose');
end

end

%{
% test code
mu = [1 ; -1]; 
SIGMA = [.9 .4; .4 .3]; 
X = mvnrndWrapper(mu,SIGMA,10); 
p = mvnpdfWrapper(X,mu,SIGMA); 
%}


