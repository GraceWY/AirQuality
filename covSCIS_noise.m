% This is covSMfast.  It overloads covSM in GPML for this demo.
% ��������SDM��
function K = covSCIS_noise(Q, hyp, x, z, i)

% Gaussian Spectral Mixture covariance function. The 
% covariance function is parameterized as:
%
% k(x^p,x^q) = w'*prod( exp(-2*pi^2*d^2*v)*cos(2*pi*d*m), 2), d = |x^p,x^q|
%
% where m(DxQ), v(DxQ) are the means and variances of the spectral mixture
% components and w are the mixture weights. The hyperparameters are:
%
% hyp = [ log(w)
%         log(m(:))
%         log(sqrt(v(:)))  ]
%
% For more help on design of covariance functions, try "help covFunctions".
%
% Copyright (c) by Andrew Gordon Wilson and Hannes Nickisch, 2013-10-09.
%
% For more details, see 
% 1) Gaussian Process Kernels for Pattern Discovery and Extrapolation,
% ICML, 2013, by Andrew Gordon Wilson and Ryan Prescott Adams.
% 2) GPatt: Fast Multidimensional Pattern Extrapolation with Gaussian 
% Processes, arXiv 1310.5288, 2013, by Andrew Gordon Wilson, Elad Gilboa, 
% Arye Nehorai and John P. Cunningham, and
% http://mlg.eng.cam.ac.uk/andrew/pattern
%
% See also COVFUNCTIONS.M.

%const variables notation
SE_PARA_NUM = 3; % SE�˲�������������
SE_NOISE_NUM = 1;

%disp('I am useful!%%%%%%%%%%%%%%%%%%%%%%%%%^^^^^^^^^^^^^)))))000000000000000000000');

if nargin<3, K = sprintf('%d + 3*%d',SE_PARA_NUM, Q); return; end   % report no of params
if nargin<4, z = []; end                                   % make sure, z exists
%xeqz = numel(z)==0; dg = strcmp(z,'diag') && numel(z)>0;        % determine mode
flagZ0 = numel(z) == 0;
flagDig = strcmp(z,'diag') && numel(z)>0; 


[n,D] = size(x); 
Q = (length(hyp) - SE_PARA_NUM) /3;

%����ԭʼ��w
w = exp(hyp(1:Q));                                             % mixture weights
%����ԭʼm
m = exp(hyp(Q+1 : 2*Q));
v = exp(2*hyp(2*Q + (1 : Q)));
% ����ԭʼSE�˺����Ĳ���
theta = exp(hyp(end-2));
ls = exp(hyp(end-1));
noise = exp(hyp(end));

%old statements
% m = exp(reshape(hyp(Q+(1:Q*D)),D,Q));                          % mixture centers
% v = exp(reshape(2*hyp(Q+Q*D+(1:Q*D)),D,Q));                  % mixture variances

% ����ԽǾ���
if flagDig                                     % compute squared distance d2
    % xiajibaluangai
  d2 = zeros([n,1,2]);
else
    % num of pram == 3
  if flagZ0                                                 % symmetric matrix Kxx
    d2 = zeros([n,n,2]);
    % Ϊÿ�����Լ������ƽ������
    d2(:, :, 1) = sq_dist(x(:,1)');
    d2(:, :, 2) = sq_dist(x(:, 2:end)');
    % ����x,z��ÿ������ƽ������
  else                                                   % cross covariances Kxz
    d2 = zeros([n,size(z,1),2]);
    d2(:, :, 1) = sq_dist(x(:,1)', z(:, 1)');
    d2(:, :, 2) = sq_dist(x(:, 2:end)', z(:, 2:end)');
  end
end
%�������
d = sqrt(d2);                                         % compute plain distance d

% dm = d*m d2v = d^2*m
k  = @(d2v,dm) exp(-2*pi^2*d2v).*cos(2*pi*dm);    % evaluation of the covariance
km = @(dm) -2*pi*tan(2*pi*dm).*dm;     % remainder when differentiating w.r.t. m
kv = @(d2v) -(2*pi)^2*d2v;             % remainder when differentiating w.r.t. v
% cal k_se
k_se = @(theta, d2, ls) theta.^2 .* exp(-d2 / ls);
% cal kl
% kl = @(ls, d2) d2 ./ ls;
kl = @(d2, ls) d2 ./ ls;



flag = 0;
%�����gradient
if nargin<5                                       % evaluation of the covariance
  c = 1;                                                   % initial value for C
  qq = 1:Q;                                          % indices q to iterate over
  % w����
elseif i<=Q                                               % derivatives w.r.t. w
  c = 1;
  qq = i;
% q��i��ÿ���������±꣬c�ǳ˻���
elseif i<=2*Q                                           % derivatives w.r.t. m
  q = i-Q; c = km(d(:,:,1)*m(q));
  if sum(sum(c == inf))
    disp('inf!');
    sum(sum(c == inf))
  end
  qq = q;
  % ��׼��v�ĵ���
elseif i<=3*Q                                         % derivatives w.r.t. v
  q = i-2*Q; c = kv(d2(:,:,1)*v(q));
  if sum(sum(c == inf))
    disp('inf!');
    sum(sum(c == inf))
  end
  qq = q;
%��������
elseif i == length(hyp)
   flag = 1;
% l����
elseif mod(i-3*Q, 2) == 0
    q = (i - 3 * Q) / 2;
    c = kl(d2(:,:,2), ls(q));
    if sum(sum(c == inf))
        disp('inf!');
        sum(sum(c == inf))
    end
    qq = 1:Q;
%theta����
else
    q = (i - 3 * Q + 1) / 2;
    c = 2;
    qq = 1:Q;
end

% output: K
K = 0;
if flag == 1
    K = 2 * noise ^ 2 * eye(size(K));
else
    for q=qq
      C = w(q)*c;
      C = C.*k(d2(:,:,1)*v(q),d(:,:,1)*m(q));
      K = K+C;
      if sum(sum(K == inf))
        disp('inf!');
        sum(sum(K == inf))
      end
    end
    % ��SE��
    K = K .* k_se(theta, d2(:, :, 2), ls);
    if flagZ0
        K = K + eye(size(K)) * noise ^ 2;
    end
end
% �ж��Ƿ�������������� or ��������
if sum(sum(K == inf))
    disp('inf!');
    sum(sum(K == inf))
end
if sum(sum(isnan(K)))
    disp('Nan!');
end
% [s, u] = eig(K);
% isZero = sum(diag(u) == 0);
% isNeg = sum(diag(u) < 0);
% if isZero > 0 && isNeg == 0
%     disp('����������\n');
% elseif isNeg > 0
%     disp('����������\n');
% elseif isZero == 0 && isNeg == 0
%     disp('��������\n');
% end     
end