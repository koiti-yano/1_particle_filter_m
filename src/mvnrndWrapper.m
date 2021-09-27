function [ r ] = mvnrndWrapper( MU, SIGMA, cases )
% This function transpose r = mvnrnd(MU,SIGMA,cases) because the output
% r is row vectors. Most textbooks define r as a column vector.
% http://jp.mathworks.com/help/stats/multivariate-normal-distribution.html
%
% To run the function, Statistics and Machine Learning Toolbox is required.

MU = MU.';

switch nargin
    case 2
        r = mvnrnd(MU, SIGMA).'; % Transposed
    case 3
        r = mvnrnd(MU, SIGMA, cases).'; % Transposed
    otherwise
        disp('An error in mvnrndTranspose');
end

end

%{ 
% test code
MU = [1 ; 0]; 
SIGMA = [1 0.5; 0.5 1.1];
r = mvnrndWrapper(MU, SIGMA, 20 );
figure;
plot(r(1,:),r(2,:),'+')
%}
