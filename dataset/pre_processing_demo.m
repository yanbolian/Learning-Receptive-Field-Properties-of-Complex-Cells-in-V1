%% This script shows how to pre-process natural stimuli as described in the paper
% (Lian et al. 2020)
% Author: Yanbo Lian
% Date: 15/09/2020

clc; close all; clear
addpath('functions')

%% Parameters of LGN pre-processing
image_scale = 8;
lgn.sz_DoG = 16;
lgn.sigma_c = 1;
lgn.sigma_s = 1.5 * lgn.sigma_c;
lgn.sigma_d = lgn.sigma_s;

[Ic, Is, Id] = divisive_DoG(lgn.sz_DoG, lgn.sigma_c, lgn.sigma_s, lgn.sigma_d);

Buff = lgn.sz_DoG / 2; % get rid of the pixels near by the boundary

%% An example of pre-precessing an input image
sz_input = 50; % Size of the input
img = rand(sz_input,sz_input); % image to be whitened; replaced by natural images or video frames in the paper

sz = sz_input - 2 * Buff; % size of the pre-processed images

% Divisive normalization (see detail in the paper)
img_filtered = imresize(imfilter(img,Ic-Is)./imfilter(img,Id),1);
img_whitened = img_filtered(Buff+1:sz_input-Buff,Buff+1:sz_input-Buff);

% The pixel intensity is scaled up before feeding into the model
whitened_img = image_scale * reshape(img_whitened,sz^2,1); 

