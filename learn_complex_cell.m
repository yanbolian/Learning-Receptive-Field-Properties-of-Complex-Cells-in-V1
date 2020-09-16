% This script learns complex cells using the method described in the paper
% (Lian et al. 2020)
% Simple cells should be learned first before learing complex cells
% Author: Yanbo Lian (yanbo.lian@unimelb.edu.au)
% Date: 15/09/2020

clc; close all; clear
addpath('functions')

%% Load natural video data
% The video is a 2-min pre-whitened natural video from https://youtu.be/K-Vr2bSMU7o
% Please do not use the video without the permisson from the video owner
% Due to the file size limit on Github, only a 200*200*50 (50 is the frame) video sample are put here
load('dataset\nature_walk_sample.mat', 'video');
num_frames = size(video, 3);
image_size_y = size(video, 1);
image_size_x = size(video, 2);

%% Load parameters of simple cells and LGN
load('results\simple.mat', 'simple', 'lgn', 'W_visual');

input_length = size(simple.A_up,1)/2; % Length of the input vector
input_size = sqrt(input_length); % Size of the input image

%% Set parameters of complex cells
complex.num_epoch = 4e6; % Number of epoches for learning
complex.num_cell = 100; % Number of complex cells
complex.a_upper = 1; % Upper bound of the weights of simple-to-complex connection
complex.learning_rule = 'NBCM'; % or 'BCM'
complex.num_frame = 15; % Number of video frames used in each epoch
complex.a_eta = 1e-3; % Learning rate of simple-to-complex connection
complex.a_theta = 1e-3; % Update rate of the threshold theta
complex.weight_cost = 1e-4; % Weight regularization parameter
if isequal(complex.learning_rule, 'NBCM')
    complex.alpha = 0.01;
    complex.beta = 12;
end

display_every = 100; % Frequency of displaying plots

%% Symbols of the model

% LGN and simple cells
U_lgn = randn(2*input_length, complex.num_frame); % Membrane potential of ON-OFF LGN cells
S_lgn = rand(2*input_length, complex.num_frame); % Firing rate of ON-OFF LGN cells
U_simple = randn(simple.num_cell, complex.num_frame); % Membrane potential of simple cells
S_simple = rand(simple.num_cell, complex.num_frame); % Firing rate of simple cells

% Complex cells
a_initial_mean = 0.5;
S_complex = rand( complex.num_cell, 1 ); % Firing rates of complex cells
Theta_complex = 0.1 * rand(complex.num_cell , 1); % initialisation of the learning threshold of complex cells
complex.A = exprnd(a_initial_mean, simple.num_cell, complex.num_cell); % Initialize simpel-to-complex connections by a exponential distribution

%% main loop
a_eta_c = complex.a_eta;
for i_epoch = 1 : complex.num_epoch

    
    % Generate a sequence of image patches from a random location of a video
    i_image = ceil( (num_frames-complex.num_frame-1) * rand );
    r =  ceil((image_size_y-input_size) * rand); % select y coordinate
    c =  ceil((image_size_x-input_size) * rand); % select x coordinate
    image_sequence = generate_image_sequence(video, i_image, complex.num_frame, r, c, input_size);
    
    % Apply the 2D Gaussian to the input image
    X_data = reshape(W_visual, input_size*input_size, 1) .* image_sequence;

    % ON and OFF LGN input
    X_ON = max( X_data, 0 );
    X_OFF = -min( X_data, 0 );
    
    X( 1 : input_length, : ) = X_ON;
    X( input_length+1 : 2*input_length, : ) = X_OFF;
    
    % Compute S and U for LGN and simple cells
    [ S_simple, U_simple, S_lgn, U_lgn] = Compute_S_U_LGN_V1_UpDown( S_simple, U_simple, S_lgn, U_lgn,...
        X, simple.A_up, simple.A_down, simple.lambda, lgn.s_b, simple.u_eta, simple.n_u, simple.thresh_type, simple.s_max, lgn.s_max);
    
    % Average activity of simple cells in response to consecutive frames
    S_simple_ave = mean(S_simple,2);
    
    % Compute complex cell responses
    S_complex_linear = complex.A' * S_simple_ave;
    if isequal(complex.learning_rule, 'BCM')
        S_complex = 10 * S_complex_linear; % The response is scaled up by 10 for BCM
    elseif isequal(complex.learning_rule, 'NBCM')
        S_complex = complex.beta * S_complex_linear ./ (complex.alpha + repmat(sqrt(sum(S_complex_linear.^2)), complex.num_cell, 1));
    end
    
    % Update simple-to-complex connection	
    dA_complex = a_eta_c * S_simple_ave * ( S_complex' .* (S_complex-Theta_complex)' ); % The amount of change based on BCM learning rule
    complex.A = complex.A + dA_complex + a_eta_c * (- complex.weight_cost * complex.A); % Update simple-to-complex connection     
    complex.A = min(max(complex.A, 0), complex.a_upper); % Keep simple-to-complex connection bounded
        
    % Update the learnign threshold
    dTheta_complex = complex.a_theta * (S_complex.^2-Theta_complex); % The amount of change for the threshold
    Theta_complex = Theta_complex + dTheta_complex;
    
    % Display plots and print status
    if ( mod(i_epoch, display_every) == 0 )        
        fprintf('Iteration %6d \n', i_epoch);
        
        % Display the synaptic field of simple cells
        figure(1);
        display_matrix( 'ONOFF', simple.A_up, 3);
        title('Synaptic fields (S_f): A_{ON,Up}-A_{OFF,Up}');
        colormap(scm(256));
        colorbar
        
        % Display simple-complex connection
        figure(2);
        display_connection( '', complex.A, complex.a_upper); title('simple-complex connection');
        colormap gray;
        colorbar
        
        % Dsiplay one exampel of 15 consecutive frames of the video
        figure(3);
        display_matrix('', X_data, 3); title('15 consecutive frames')
        colormap gray;
    end
end

%% Save data
% save( 'results\complex.mat', 'complex');

