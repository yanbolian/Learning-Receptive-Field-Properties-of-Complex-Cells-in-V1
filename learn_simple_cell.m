% This script learns simple cells using the method described in the paper
% (Lian et al. 2020)
% Author: Yanbo Lian (yanbo.lian@unimelb.edu.au)
% Date: 15/09/2020

clc; close all; clear
addpath('functions')

%% LGN parameters for pre-processing natural stimuli
image_scale = 8; % The pixel intensity is scaled up before feeding into the model
lgn.sz_DoG = 16;
lgn.sigma_c = 1;
lgn.sigma_s = 1.5 * lgn.sigma_c;
lgn.sigma_d = lgn.sigma_s;
lgn.s_b = 0.5; % background firing rate that gives an offset of the reconstruction error
lgn.s_max = 3; % maximum firing rate of LGN cells
lgn.visual_field = '2D Gaussian';
lgn.radius = 3;

BUFF = 2*lgn.sz_DoG;

%% load van hateren imc images (The images here are already pre-processing using above LGN parameters)
% Due to the file size limit on Github, only 2 pre-processed images are put here
load('dataset\van_Hateran_sample.mat', 'IMAGES_WHITENED')

num_images = size(IMAGES_WHITENED,3);
image_size = size(IMAGES_WHITENED,1);
display_every = 100; % the frequency of displaying plots
resize_factor = 3; % higher resolution when displaying images

%% Simple cell parameters

simple.num_epoch = 100000;
simple.lambda = 0.1;
simple.weight_cost = 1e-3;
simple.a_eta = 3; % learning rate of connections A1
simple.a_bound = 0.3;

simple.batch_size = 100;
simple.s_max = 3; % maximum firing rate of simple cells
simple.u_eta = 0.4; % updating rate of membrane potentials U ( uEta = dt / tau )
simple.n_u = 20; % number of iterations of calculating membrane potentials U
simple.thresh_type = 'non-negative soft'; % type of thresholding function that computes firing rates of simple cells from membrane potentials

%% Definitions of symbols
sz = 16; L = sz^2; % size of the image patch; L ON units and L OFF units
simple.num_cell = 100; % number of simple cells

%% 2D Gaussian field of LGN
sz1 = sqrt(L);
x0 = (sz1+1)/2; y0 = x0; 
[xx, yy] = meshgrid(1:sz1,1:sz1);

W_visual = exp( -0.5*((xx-x0).^2+(yy-y0).^2)/(lgn.radius^2));

%% connections
% feedforward (up) connections between M1 simple cells and M2 complex cells
a_initial_mean = 0.1; % for exponential distribution: var = mean ^ 2;

% feedforward (down) connections between 2L LGN cells and M1 simple cells
simple.A_up_pos = exprnd(a_initial_mean,[2*L simple.num_cell]); % positive connections
simple.A_up_neg = -exprnd(a_initial_mean,[2*L simple.num_cell]); % negative connections
simple.A_up_pos = min( simple.A_up_pos , simple.a_bound );
simple.A_up_neg = max( simple.A_up_neg, -simple.a_bound );
simple.A_down_pos = -simple.A_up_neg;
simple.A_down_neg = -simple.A_up_pos;

simple.A_up = simple.A_up_pos + simple.A_up_neg; % overall feedforward connections
simple.A_down = simple.A_down_pos + simple.A_down_neg; % overall feedback connections

%% input, membrane potentials and firing rates
X_Data = zeros( L, simple.batch_size ); % input image patches
X = zeros( 2*L, simple.batch_size ); % input with ON and OFF channels

U_L = randn( 2*L, simple.batch_size ); % membrane potential of ON-OFF LGN cells
S_L = rand( 2*L, simple.batch_size ); % firing rate of ON-OFF LGN cells
U1 = randn( simple.num_cell, simple.batch_size ); % membrane potential of simple cells
S1 = rand( simple.num_cell, simple.batch_size ); % firing rate of simple cells

%% main loop
a_eta = simple.a_eta;
for i_epoch = 1 : simple.num_epoch
    
    % Choose an image at random out of 50 images in the dataset
    i_image = ceil( num_images * rand );
    this_image = IMAGES_WHITENED(:,:,i_image);
    
    % extract image patches at random from this image to make data vector
    for i_batch = 1 : simple.batch_size    
        r = BUFF + ceil((image_size-sz-2*BUFF)*rand); % select y coordinate
        c = BUFF + ceil((image_size-sz-2*BUFF)*rand); % select x coordinate
        X_Data( : , i_batch ) = reshape( W_visual.*imresize(this_image(r:r+sz-1,c:c+sz-1),[sz sz]),...
            L, 1 ); % apply 2D Gaussian field of LGN cells
    end
    
    % ON and OFF LGN input
    X_ON = max( X_Data, 0 );
    X_OFF = -min( X_Data, 0 );
    
    X( 1:L, : ) = X_ON;
    X( L+1:2*L, : ) = X_OFF;

    % Compute S and U for LGN and simple cells using previous values
    [S1, U1, S_L, U_L] = Compute_S_U_LGN_V1_UpDown( S1, U1, S_L, U_L,...
        X, simple.A_up, simple.A_down, simple.lambda, lgn.s_b, simple.u_eta, simple.n_u, simple.thresh_type, simple.s_max, lgn.s_max);
    
    % Update up and down connections between LGN and simple cells
    dA = a_eta * ( S_L - lgn.s_b ) * S1' / simple.batch_size; % learning rule
    
    dA_up_pos = dA + a_eta * (- simple.weight_cost * simple.A_up_pos); % weight regularisation included           
    simple.A_up_pos = max( simple.A_up_pos + 1*dA_up_pos, 0 );
    
    dA_up_neg = dA + a_eta * ( - simple.weight_cost * simple.A_up_neg);
    simple.A_up_neg = min( simple.A_up_neg + 1*dA_up_neg, 0 );
      
    simple.A_up_pos = min(simple.A_up_pos, simple.a_bound);
    simple.A_up_neg = max(simple.A_up_neg, -simple.a_bound);

    simple.A_down_pos = -simple.A_up_neg;
    simple.A_down_neg = -simple.A_up_pos;

    simple.A_up = simple.A_up_pos + simple.A_up_neg; % overall feedforward connections
    simple.A_down = simple.A_down_pos + simple.A_down_neg; % overall feedback connections
    
    % Display the connection during learning
    if ( mod(i_epoch,display_every) == 0 )
    
        % print current status of learning
        fprintf('Iteration %6d \n', i_epoch);
        
        % Display the connections from ON and OFF LGN cells to simple cells
        figure(1);
        subplot(231); display_matrix( 'ON', simple.A_up_pos, resize_factor ); title('A^{+}_{ON,Up}');
        subplot(232); display_matrix( 'ON', simple.A_up_neg, resize_factor ); title('A^{-}_{ON,Up}');
        subplot(233); display_matrix( 'ON', simple.A_up, resize_factor ); title('A_{ON,Up}');
        subplot(234); display_matrix( 'OFF', simple.A_up_pos, resize_factor ); title('A^{+}_{OFF,Up}');
        subplot(235); display_matrix( 'OFF', simple.A_up_neg, resize_factor ); title('A^{-}_{OFF,Up}');
        subplot(236); display_matrix( 'OFF', simple.A_up, resize_factor ); title('A_{OFF,Up}');
        colormap(Green2Magenta(64));
        
        % Display the overall receptive fields of simple cells: Aon - Aoff
        figure(2);
        display_matrix( 'ONOFF', simple.A_up, resize_factor);
        title('Synaptic fields (S_f): A_{ON,Up}-A_{OFF,Up}');
        colormap(scm(256));
    end
end

%% Save data
% save( 'results\simple.mat', 'simple', 'lgn', 'W_visual', 'image_scale');