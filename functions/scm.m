function m = scm(varargin),
% Colormap of red/blue
% 
% 30/10/2013 - Shaun L . Cloherty <s.cloherty@ieee.org>

if nargin < 1,
  N = size(get(gcf,'ColorMap'),1);
else,
  N = varargin{1}; % size of the colormap
end

k = 0.1; % 10% of colormap is white
if nargin > 1,
  k = min(abs(varargin{2}), 1.0); % 0.0 < k < 1.0
end

oddFlag = rem(N,2);

if ~oddFlag, % make N odd
  N = N + 1;
end

% make colormap
m = zeros([N,3]); % red, green, blue

% transition points for the colormap
M = floor(N/2) + 1;
n = round(k*N/2);

% p = [1, n/2, (N-n)/2, (N+n)/2, N-n/2, N]; % way points 
p = [1, n, M-n+1, M+n-1, N-n+1, N]; % way points 

% red
m(p(1):p(2),3) = linspace(0.5, 1.0, n); % ramp 0.5 ... 1.0
m(p(2):p(4),3) = 1.0;
m(p(4):p(5),3) = linspace(1.0, 0.0, M-2*(n-1));


% green
m(p(2):p(3),2) = linspace(0.0, 1.0, M-2*(n-1));
m(p(3):p(4),2) = 1.0;
m(p(4):p(5),2) = linspace(1.0, 0.0, M-2*(n-1));

% blue
m(p(2):p(3),1) = linspace(0.0, 1.0, M-2*(n-1));
m(p(3):p(5),1) = 1.0;
m(p(5):p(6),1) = linspace(1.0, 0.5, n);

if ~oddFlag, % make N even again
  m(M,:) = [];
  N = N - 1;
end

if 0,
  figure;
  subplot(3,1,1);
  plot([1:N], m(:,1), 'r');
  xlim([1, N]);
  
  subplot(3,1,2);
  plot([1:N], m(:,2), 'g');
  xlim([1, N]);
 
  subplot(3,1,3);
  plot([1:N], m(:,3), 'b');
  xlim([1, N]);
end

m(end+1,:)=[0 0 0];