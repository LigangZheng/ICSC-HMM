%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main demo scripts for the ICSC-HMM Segmentation Algorithm proposed in:
%
% N. Figueroa and A. Billard, “Transform-Invariant Non-Parametric Clustering 
% of Covariance Matrices and its Application to Unsupervised Joint Segmentation 
% and Action Discovery”
% Arxiv, 2017. 
%
% Author: Nadia Figueroa, PhD Student., Robotics
% Learning Algorithms and Systems Lab, EPFL (Switzerland)
% Email address: nadia.figueroafernandez@epfl.ch  
% Website: http://lasa.epfl.ch
% November 2016; Last revision: 25-May-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                    --Select a Dataset to Test--                       %%    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1) Toy 2D dataset, 3 Unique Emission models, 3 time-series, same swicthing
clc; clear all; close all;
N_TS = 3; display = 2 ; % 0: no-display, 1: raw data in one plot, 2: ts w/labels
[~, Data, True_states] = genToyHMMData_Gaussian( N_TS, display ); 
label_range = unique(True_states{1});

%% 2a) Toy 2D dataset, 4 Unique Emission models, max 5 time-series
clc; clear all; close all;
M = 4; % Number of Time-Series
[~, ~, Data, True_states] = genToySeqData_Gaussian( 4, 2, M, 500, 0.5 ); 

%% 2b) Toy 2D dataset, 2 Unique Emission models transformed, max 4 time-series
clc; clear all; close all;
M = 3; % Number of Time-Series
[~, TruePsi, Data, True_states] = genToySeqData_TR_Gaussian(4, 2, M, 500, 0.5 );
dataset_name = '2D Transformed'; 

% Similarity matrix S (4 x 4 matrix)
if exist('h1','var') && isvalid(h1), delete(h1);end
h1 = plotSimMat( TruePsi.S );

%% 3) Real 'Grating' 7D dataset, 3 Unique Emission models, 12 time-series
%Demonstration of a Carrot Grating Task consisting of 
%12 (7-d) time-series X = {x_1,..,x_T} with variable length T. 
%Dimensions:
% x = {pos_x, pos_y, pos_z, q_i, q_j, q_k, q_w}
% type= 'robot'/'grater'/'mixed'
% 
clc; clear all; close all;
data_path = './test-data/'; display = 1;  full = 0; use_vel = 0; type = 'mixed';
[data, TruePsi, Data, True_states ,Data_] = load_grating_dataset( data_path, type, display, full, use_vel);
dataset_name = 'Grating'; 


%% 4) Real 'Dough-Rolling' 12D dataset, 3 Unique Emission models, 12 time-series
% Demonstration of a Dough Rolling Task consisting of 
% 15 (13-d) time-series X = {x_1,..,x_T} with variable length T. 
%
% Dimensions:
% x = {pos_x, pos_y, pos_z, q_i, q_j, q_k, q_w, f_x, f_y, f_z, tau_x, tau_y, tau_z}
% - positions:         Data{i}(1:3,:)   (3-d: x, y, z)
% - orientations:      Data{i}(4:7,:)   (4-d: q_i, q_j, q_k, q_w)
% - forces:            Data{i}(8:10,:)   (3-d: f_x, f_y, f_z)
% - torques:           Data{i}(11:13,:) (3-d: tau_x, tau_y, tau_z)

% Dataset type:
%
% type: 'raw', raw sensor recordings at 500 Hz, f/t readings are noisy af and
% quaternions dimensions exhibit discontinuities
% This dataset is NOT labeled
%
% type: 'proc', sub-sampled to 100 Hz, smoothed f/t trajectories, fixed rotation
% discontinuities.

clc; clear all; close all;
data_path = './test-data/'; display = 1; type = 'proc'; full = 0; type2 = 'real'; 
% Type of data processing
% O: no data manipulation -- 1: zero-mean -- 2: scaled by range * weights
normalize = 2; 

% Define weights for dimensionality scaling
weights = [10*ones(1,3) 2*ones(1,4) 1/7*ones(1,3) 1/10*ones(1,3)]';

% Define if using first derivative of pos/orient
use_vel = 1;
[data, TruePsi, Data, True_states, Data_] = load_rolling_dataset( data_path, type, type2, display, full, normalize, weights, use_vel);
dataset_name = 'Rolling'; 

%% 5) Real 'Peeling' (max) 32-D dataset, 5 Unique Emission models, 3 time-series
% Demonstration of a Bimanual Peeling Task consisting of 
% 3 (32-d) time-series X = {x_1,..,x_T} with variable length T. 
%
% Dimensions:
% x_a = {pos_x, pos_y, pos_z, q_i, q_j, q_k, q_w, f_x, f_y, f_z, tau_x, tau_y, tau_z}
% - positions:              Data{i}(1:3,:)   (3-d: x, y, z)
% - orientations:           Data{i}(4:7,:)   (4-d: q_i, q_j, q_k, q_w)
% - forces:                 Data{i}(8:10,:)  (3-d: f_x, f_y, f_z)
% - torques:                Data{i}(11:13,:) (3-d: tau_x, tau_y, tau_z)
% x_p = {pos_x, pos_y, pos_z, q_i, q_j, q_k, q_w, f_x, f_y, f_z, tau_x, tau_y, tau_z}
% - same as above           Data{i}(14:26,:)
% x_o = {mu_r, mu_g, mu_b, sigma_r, sigma_g, sigma_b}
% - rate_mean:              Data{i}(27:29,:)   (3-d: mu_r, mu_g, mu_b)
% - rate_variance:          Data{i}(30:32,:)   (3-d: sigma_r, sigma_g, sigma_b)

% Dimension type:
% dim: 'all', include all 32 dimensions (active + passive robots + object)
% dim: 'robots', include only 26-d from measurements from active + passive robots
% dim: 'act+obj', include only 19-d from measurements from active robot + object
% dim: 'active', include only 13-d from measurements from active robot

% Dataset type:
% sub-sampled to 100 Hz (from 500 Hz), smoothed f/t trajectories, fixed rotation
% discontinuities.

% clc; 
clear all; close all
data_path = './test-data/'; display = 1; 

% Type of data processing
% O: no data manipulation -- 1: zero-mean -- 2: scaled by range * weights
normalize = 2; 

% Select dimensions to use
dim = 'robots'; 

% Define weights for dimensionality scaling
switch dim
    case 'active'
        weights = [5*ones(1,3) 2*ones(1,4) 1/10*ones(1,6)]'; % active    
    case 'act+obj'
        weights = [2*ones(1,7) 1/10*ones(1,6) 2*ones(1,6)]'; % act+obj
    case 'robots'
        weights = [5*ones(1,3) ones(1,4) 1/10*ones(1,6) ones(1,3) 2*ones(1,4) 1/20*ones(1,6) ]'; % robots(velocities)        
%         weights = [5*ones(1,3) 1/2*ones(1,4) 1/10*ones(1,6) ones(1,3) 1/2*ones(1,4) 1/20*ones(1,6) ]'; % robots(position)        
    case 'all'
        weights = [5*ones(1,3) ones(1,4) 1/10*ones(1,6) ones(1,3) 2*ones(1,4) 1/20*ones(1,6) 2*ones(1,6) ]'; % all        
end

% Define if using first derivative of pos/orient
use_vel = 1;

[data, TruePsi, Data, True_states, Data_] = load_peeling_dataset( data_path, dim, display, normalize, weights, use_vel);
dataset_name = 'Peeling';

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     Run E-M Model Selection for HMM with 10 runs in a range of K     %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Model Selection for HMM
K_range = [1:10]; repeats = 5; 
hmm_eval(Data, K_range, repeats)

%%  Fit HMM with 'optimal' K and Apply Viterbi for Segmentation
% Set "Optimal " GMM Hyper-parameters
K = 5; T = 10;
ts = [1:length(Data)];

% Segmentation Metric Arrays
hamming_distance   = zeros(1,T);
global_consistency = zeros(1,T);
variation_info     = zeros(1,T);

% Clustering Metric Arrays
cluster_purity = zeros(1,T);
cluster_NMI    = zeros(1,T);
cluster_F      = zeros(1,T);

% Model Metric Arrays
logliks        = zeros(length(ts),T);
label_range    = [1:K];
est_states     = [];

for run=1:T
    % Fit HMM with 'optimal' K to set of time-series
    [p_start, A, phi, loglik] = ChmmGauss(Data, K);
        
    true_states_all   = [];
    est_states_all    = [];
    
    % Calculate p(X) & viterbi decode fo reach time-series
    if run==T
        if exist('h0','var') && isvalid(h0), delete(h0);end
        h0 = figure('Color',[1 1 1]);
    end
    
    for i=1:length(ts)
        X = Data{ts(i)};
        
        if isfield(TruePsi, 'sTrueAll')
            true_states = TruePsi.s{ts(i)}';
        else
            true_states = True_states{ts(i)};
        end
        
        logp_xn_given_zn = Gauss_logp_xn_given_zn(Data{ts(i)}, phi);
        [~,~, logliks(i,run)] = LogForwardBackward(logp_xn_given_zn, p_start, A);
        est_states_ = LogViterbiDecode(logp_xn_given_zn, p_start, A);                       
        
        % Stack labels for state clustering metrics        
        true_states_all = [true_states_all; true_states];
        est_states_all  = [est_states_all; est_states_];
        
        % Plot segmentation Results on each time-series
        if run==T
            subplot(length(ts),1,i);
            data_labeled = [X est_states_]';
            plotLabeledData( data_labeled, [], strcat('Segmented Time-Series (', num2str(ts(i)),'), K:',num2str(K),', loglik:',num2str(loglik)), [],label_range)
            est_states{i} = est_states_;
        end
    end
    
    % Segmentation Metrics per run
    [relabeled_est_states_all, hamming_distance(run),~,~] = mapSequence2Truth(true_states_all,est_states_all);
    [~,global_consistency(run), variation_info(run)] = compare_segmentations(true_states_all,est_states_all);
    
    % Cluster Metrics per run
    [cluster_purity(run) cluster_NMI(run) cluster_F(run)] = cluster_metrics(true_states_all, est_states_all);
    
end

% Overall Stats for HMM segmentation and state clustering
clc;
fprintf('*** Hidden Markov Model Results*** \n Optimal States: %d \n Hamming-Distance: %3.3f (%3.3f) GCE: %3.3f (%3.3f) VO: %3.3f (%3.3f) \n Purity: %3.3f (%3.3f) NMI: %3.3f (%3.3f) F: %3.3f (%3.3f)  \n',[K mean(hamming_distance) std(hamming_distance)  ...
    mean(global_consistency) std(global_consistency) mean(variation_info) std(variation_info) mean(cluster_purity) std(cluster_purity) mean(cluster_NMI) std(cluster_NMI) mean(cluster_F) std(cluster_F)])

% Visualize Transition Matrix and Segmentation from 'Best' Run
if exist('h1','var') && isvalid(h1), delete(h1);end
h1 = plotTransMatrix(A);

%% Visualize Estimated Emission Parameters for 2D Data ONLY!
title_name  = 'Estimated Emission Parameters';
plot_labels = {'$x_1$','$x_2$'};
Est_theta.Mu = phi.mu;
Est_theta.Sigma = phi.Sigma;
Est_theta.K = K;
if exist('h2','var') && isvalid(h2), delete(h2);end
h2 = plotGaussianEmissions2D(Est_theta, plot_labels, title_name);

%% Visualize Segmented Trajectories in 3D ONLY!
labels    = unique(est_states_all);
titlename = strcat(dataset_name,' Demonstrations (Estimated Segmentation)');
% Plot Segmentated 3D Trajectories
if exist('h5','var') && isvalid(h5), delete(h5);end
h5 = plotLabeled3DTrajectories(Data_, est_states, titlename, labels);
% drawframe(eye(4), 0.1); 
axis tight

%% Plot Segmentated 3D Trajectories with "TRUE LABELS"
titlename = strcat(dataset_name,' Demonstrations (Ground Truth)');
if exist('h6','var') && isvalid(h6), delete(h6);end
h6 = plotLabeled3DTrajectories(Data_, True_states, titlename, unique(data.zTrueAll));
% drawframe(eye(4), 0.1); 
axis tight
