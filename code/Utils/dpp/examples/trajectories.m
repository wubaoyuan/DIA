%% sample particle trajectories from a simple SDPP

% config
T = 100; % time steps
N = 100; % labels (positions)
D = 100;  % similarity feature dimension
k = 5;  % number of trajectories to sample

% init model
clear model;
model.T = T;
model.N = N;

% prefer starting near the center
model.Q1 = exp(-1000*((1:N)/N-0.5).^2);
model.Q = ones(1,N);

% enforce smoothness
model.A = bsxfun(@(a,b) exp(-(a-b).^2 *10000), (1:N)'/N, (1:N)/N);

% similarity features
model.G = bsxfun(@(a,b) exp(-(a-b).^2 ), (1:N)'/N, (1:D)/D);

% sample
C = decompose_kernel(bp(model,'covariance'));
sdpp_sample = sample_sdpp(model,C,k);
ind_sample = zeros(T,k);
for i = 1:k
  ind_sample(:,i) = bp(model,'sample');
end

% plot
subplot(1,2,1);
plot(sdpp_sample);
axis([1 T 1 N]);
axis square;
xlabel('time');
ylabel('position');
title('SDPP');

subplot(1,2,2);
plot(ind_sample);
axis([1 T 1 N]);
axis square;
xlabel('time');
ylabel('position');
title('Independent');
