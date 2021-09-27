% push.m
% Copyright (c) 2013, Koiti Yano
%
% This script is distributed under the GNU Lesser General Public License.
% https://www.gnu.org/licenses/lgpl.html
%{ 
three = zeros(2, 3, 4); three(:,:,1) = 1; three(:,:,2) = 2; three(:,:,3) = 3; three(:,:,4) = 4; three(2,:,1) = 1.1; three(2,:,2) = 1.2; three, two
% example 1
three([1 1], : , :); two = zeros(2,3); three(:,:, 2:4) = three(:,:, 1:3); three(:,:,1) = two
% example 2
push(three, two)
%}
function threeDimArray = push(threeDimArray, twoDimArray)
[m, p, t] = size(threeDimArray);
threeDimArray(:, :, (2:t)) = threeDimArray(:, :, (1:(t-1)));
threeDimArray(:, :, 1) = twoDimArray;
%=========================================

