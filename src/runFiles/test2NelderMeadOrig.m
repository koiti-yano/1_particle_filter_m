% Run nelderMeadMultiDim(@wrapFunc)
clear; close all;


%function [value]=wrapFunc(V) %Write your function in matrix form
%x=V.coord(1); y=V.coord(2);  
%value=(1-x)^2+100*(y-x^2)^2;  
%end

numOfVertices=3; %value of N+1 (the number of vetrices) for Rosenbrock's Function
%numOfVertices=5; %value of N+1 (the number of vetrices)

[minima, minmas, numOfIter] = nelderMeadOrig(@wrapFuncOrig, numOfVertices);

% Check results
minima.coord
minima.value

minmas;
numOfIter;

% Plot minmas
if(0) 
    plot(minmas);
    a=text(25,200, strcat('Nnumber of iterations = ', num2str(numOfIter)));
    set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 18, 'Color', 'red');
    xlabel('iterations');
    ylabel('error');
    title('Error Vs Iterations');
end
