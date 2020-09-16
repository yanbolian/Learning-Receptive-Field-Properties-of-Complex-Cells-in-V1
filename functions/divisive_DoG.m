function [Ic, Is, Id] = divisive_DoG(sz, sigma_c, sigma_s, sigma_d)
% This function returns the filter needed to pre-process natural stimuli
% sz: size of the filter
% sigma_c: size of the center filter
% sigma_s: size of the surround filter
% sigma_d: size of the divisive filter
% 
% Author: Yanbo Lian (yanbo.lian@unimelb.edu.au)
% Date: 15/09/2020

% To make 'sz' odd
if mod(sz,2) == 0
    sz = sz + 1;
end

% sigma_c = 2; % sigma of center
% sigma_s = 1.5 * sigma_c; % sigma of surround
% sigma_d = sigma_s; % sigma of neighborhood

% generate axes
[X, Y] = meshgrid(1:sz, 1:sz); 
X = X - ceil(sz/2);
Y = Y - ceil(sz/2);
R = sqrt(X.*X + Y.*Y); % radius

Ic = exp(-R.^2/2/sigma_c^2);
Ic = normalize_matrix(reshape(Ic,sz*sz,1),'unit abs');

Is = exp(-R.^2/2/sigma_s^2);
Is = normalize_matrix(reshape(Is,sz*sz,1),'unit abs');

Id = exp(-R.^2/2/sigma_d^2);
Id = normalize_matrix(reshape(Id,sz*sz,1),'unit abs');

Ic = reshape(Ic, sqrt(size(Ic,1)),sqrt(size(Ic,1)));
Is = reshape(Is, sqrt(size(Is,1)),sqrt(size(Is,1)));
Id = reshape(Id, sqrt(size(Id,1)),sqrt(size(Id,1)));