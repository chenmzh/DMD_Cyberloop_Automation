function [intensity,X_end,X] = Dynamic_system(Area,ic)
% input is the area calculated, is the ratio of area occupied between 0 and 1 
% ic is the initial condition
% Output is the light intensity, and the end value of inner plant X as the
% later input
% Simple birth-death dynamic is simulationed
% reaction 1: 0 -> X;
% reaction 2: X + fluor -> deg
% intensity is proportional to X: intensity = C*X

% Define the parameter here
% parameter.basel = -291.4385; % stop after 2.5 hrs running
% parameter.gamma = 2.0113;

% parameter.basel = -120.8895;
% parameter.gamma = 0.8351;
parameter.basal = -118.8;
parameter.gamma = 0.85; % 140-1000
parameter.alpha = 1.3;
parameter.C = 1;
C = parameter.C;

input = Area;
y0 = ic; % Start from 0
tspan = [0,60*10]; % Simulate the result for 10 mins simulation



[t,X] = ode45(@(t,X) odefun(t,X,input,parameter),tspan,y0);

X_end = X(end,:); % if multiple input

intensity = C.*X_end;% The last value of parameter C
figure
plot(t,X)
title("The dynamic of inner plant with various input fluorescence")
legend(string(Area),'Location','best')
xlabel("simulated time")
ylabel("concentration of output")
end