function array = display_matrix( OnOff, A, resizeFactor, numColumns, onFlag )
%  This function display the columns of A in an image where each rectangle
%  of the image represents the column of A
% OnOff: which part of A should be displayed
% A: may represent the connections between two populations
% resizeFactor: the factor for a higher resolution
% numColumns: # of rectangles in each row of the image
% onFlag: whether to display the image
% 
% Author: Yanbo Lian (yanbo.lian@unimelb.edu.au)
% Date: 15/09/2020

if isequal( OnOff, 'ON') || isequal( OnOff, 'on')
    A = A( 1:size(A,1)/2, : );
elseif isequal( OnOff, 'OFF') || isequal( OnOff, 'off')
    A = A( size(A,1)/2+1:size(A,1), : );
elseif isequal( OnOff, 'ONOFF') || isequal( OnOff, 'onoff')
    A = A( 1:size(A,1)/2, : ) - A( size(A,1)/2+1:size(A,1), : );
end

[L0, M] = size(A); % L: length of the column; M: number of columns of A
sz0 = ceil( sqrt(L0) ); % The smallest size of a square large enough to display each column

% Zero-padded version of A
A_Padded = zeros(sz0^2, M);
A_Padded(1:L0, 1:M) = A;

% Set defaul value for 'resizeFactor'
if ~exist('resizeFactor','var')
    resizeFactor=1;
end

sz = sz0 * resizeFactor; % size of the resized square
L = sz^2; % 
A_Padded = reshape(imresize(reshape(A_Padded,sz0,sz0,M),resizeFactor,'lanczos3'),L,M);

% By default, the displayed image is square unless defined by 'numColumns'
if ~exist('numColumns', 'var')
    nCol = ceil(sqrt(M));
else
    nCol = numColumns;
end
nRow = ceil(M/nCol); % number of rows of the displayed image

buf = 2; % thickness of the boundary between different blocks in the image
black = 1.02;

% The array that saves the pixel values of the displayed image
array= black * ones( buf + nRow * (sz+buf), buf + nCol * (sz+buf) ); 

% fill 'array ' column by column
m=1; % index of the column of A
for i = 1 : nRow
    for j = 1 : nCol
        if m < M + 1
            % clim: larget absolute value in m-th column of A
            clim = max( abs( A_Padded(:,m) ) );
            if clim==0
                clim=1;
            end
            % fill m-th column of A into 'array'
            array(  buf + (i-1) * (sz+buf) + (1:sz), ...
                    buf + (j-1) * (sz+buf) + (1:sz) ) = ...
                    reshape(A_Padded(:,m), sz, sz) / clim;
            
            % used when plotting samples
%             array(  buf + (i-1) * (sz+buf) + (1:sz), ...
%                     buf + (j-1) * (sz+buf) + (1:sz) ) = ...
%                     reshape(A_Padded(:,m), sz, sz);
        end
        m = m + 1; % update m with the index of next column
    end
end

% The image will be displayed by default unless stated otherwise
if ~exist('onFlag', 'var')
    onFlag = 1;
end

% Display the image
if onFlag == 1
%     colormap gray
    imagesc(array,[-1 black]);
    axis image off
    drawnow
end

end
