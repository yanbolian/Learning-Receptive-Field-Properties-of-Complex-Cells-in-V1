function image_sequence = generate_image_sequence(video, i_frame, num_frame, r, c, sz)
% This function returns a sequence of image patches from a video
% video: the video data
% i_frame:starting frame of the video
% num_frame: number of frames needed
% r,c: row and column index of the image patch (location)
% sz: size of the image patch
% image_sequence: a matrix with size of sz^2 * num_frame
% 
% Author: Yanbo Lian (yanbo.lian@unimelb.edu.au)
% Date: 15/09/2020

img_temp = zeros(sz, sz, num_frame);

for i = 1 : num_frame
    img_temp(:,:,i) = video(r:r+sz-1,c:c+sz-1,i_frame+i);
end

% Reshape the image sequence such that each column represents an image patch
image_sequence = reshape(img_temp, sz*sz, num_frame);