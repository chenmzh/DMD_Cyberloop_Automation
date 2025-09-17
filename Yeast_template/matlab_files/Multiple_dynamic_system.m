function [light,acc_error] = Multiple_dynamic_system(input_list,ic)

% load("controller_parameters.mat") % Load Kp_vector and Ki_vector
% Load 'Kp_vector', 'Ki_vector','Setpoint_vector'


area = input_list.area;
acc_error = input_list.acc_error;

sample_num = size(ic,2); % number of wells

Kp_vector = ones(1,sample_num)*7*6.25; % Kp = 7 for this case, * 6.25 because of the scaling of light intensity from mW to mW/cm2
Ki_vector = ones(1,sample_num)*0.6*6.25; % Ki = 0.6 for this case, * 6.25 because of the scaling of light intensity from mW to mW/cm2
Setpoint_vector = ones(1,sample_num)*0.15; % 0.15 for the first stage


light = zeros(1,sample_num);

error = zeros(1,sample_num);
% setpoint = 0.08*ones(1,6);
setpoint = Setpoint_vector;

% light = (area-setpoint)*kp + ki * acc_error where acc_error = integral of (area-setpoint)

for i = 1:sample_num

        kp =  Kp_vector(i);
        ki = Ki_vector(i);
        error(i) = area(i)-setpoint(i);
        acc_error(i) = acc_error(i) + error(i);
        maximum_output = 1.5*6.25;
        
        % Anti-windup set the Ki component to be less than 2/3 of maximum
        % input (maximum input is 1.5 here)
        if acc_error(i) > 2/3 * maximum_output/(ki*1/6) % 66% percent of the maximum input
            acc_error(i) = 2/3 * maximum_output/(ki*1/6);
        elseif acc_error(i) < 0
            acc_error(i) = 0;
        end
        
        light_temp = error(i)*kp + acc_error(i)*ki*1/6; % Assume run every 10 mins, time step is 1/6 hour

        if light_temp > maximum_output
            light(i) = maximum_output;
        elseif light_temp < 0
            light(i) = 0;
        else
            light(i) = light_temp;
        end

end

end