function green2Magenta = Green2Magenta(num)
% Colormap of green/magenta
% 
% Author: Yanbo Lian (yanbo.lian@unimelb.edu.au)
% Date: 15/09/2020

green2Magenta = [];
whiteRange = floor(0.2*num);

green2Magenta(1,:) = [0 0.5 0]; % dark green for the minimum
green2Magenta(num+1:num+whiteRange,:) = ones(whiteRange,3); % white in the middle
green2Magenta(2*num+whiteRange,:) = [0.5 0 0.5]; % dark magenta for the maximum
green2Magenta(2*num+whiteRange+1,:) = [0 0 0]; % black for the boundaries

% Dark green to white
green2Magenta(1:num+1,1) = (0:1/num:1)';
green2Magenta(1:num+1,2) = (0.5:0.5/num:1)'; 
green2Magenta(1:num+1,3) = (0:1/num:1)';

% white to dark magenta
green2Magenta(num+whiteRange:2*num+whiteRange,1) = (1:-0.5/num:0.5)'; %ones(num+1,1);
green2Magenta(num+whiteRange:2*num+whiteRange,2) = (1:-1/num:0)';
green2Magenta(num+whiteRange:2*num+whiteRange,3) = (1:-0.5/num:0.5)'; %ones(num+1,1);