function array = display_connection( OnOff, A, upper, numColumns, onFlag )
%  This function display the connection of A in an image where each block
%  of the image represents one column of A (all weight connecting to this cell)
% OnOff: which part of A should be displayed
% A: may represent the connections between two populations
% upper: upper value of the connection
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
sz = ceil( sqrt(L0) ); % The smallest size of a square large enough to display each column

% Zero-padded version of A
A_Padded = zeros(sz^2, M);
A_Padded(1:L0, 1:M) = A;

L = sz^2; % 
A_Padded = reshape(reshape(A_Padded,sz,sz,M),L,M);

% By default, the displayed image is square unless defined by 'numColumns'
if ~exist('numColumns', 'var')
    nCol = ceil(sqrt(M));
else
    nCol = numColumns;
end
nRow = ceil(M/nCol); % number of rows of the displayed image

buf = 2; % thickness of the boundary between different blocks in the image
boundary = 1.001 * upper;

% The array that saves the pixel values of the displayed image
array= boundary * ones( buf + nRow * (sz+buf), buf + nCol * (sz+buf) ); 

% fill 'array ' column by column
m=1; % index of the column of A
for i = 1 : nRow
    for j = 1 : nCol
        if m < M + 1

            % fill m-th column of A into 'array'
            array(  buf + (i-1) * (sz+buf) + (1:sz), ...
                    buf + (j-1) * (sz+buf) + (1:sz) ) = ...
                    reshape(A_Padded(:,m), sz, sz);
            
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
    imagesc(array,[0 boundary]);
    axis image off
    drawnow
end

end
