% Welcome!
% This easy demo first shows a simple toy BP-HMM dataset,
%  and then runs fast BP-HMM inference and visualizes the results!
% Make sure you've done these simple things to run this script:
%   -- install Eigen C++ library
%   -- install Lightspeed toolbox
%   -- Compile the MEX routines for fast sampling (./CompileMEX.sh)
%   -- Create local directories for saving results (./ConfigToolbox.sh)
% See QuickStartGuide.pdf in doc/ for details on configuring the toolbox

clear variables;
close all;

% -------------------------------------------------   CREATE TOY DATA!
fprintf( 'Creating some toy data...\n' );
% First, we'll create some toy data
%   5 sequences, each of length T=500.
%   Each sequences selects from 4 behaviors, 
%     and switches among its selected set over time.
%     We'll use K=4 behaviors, each of which defines a distinct Gaussian
%     emission distribution (with 2 dimensions).
% Remember that data is a SeqData object that contains
%   the true state sequence labels for each time series
[data, TruePsi] = genToySeqData_Gaussian( 4, 2, 5, 500, 0.5 ); 
% [data, TruePsi] = genToySeqData_Gaussian_null( 5, 2, 5, 500, 0.5 ); 
%%
% Visualize the raw data time series
%   with background colored by "true" hidden state
figure( 'Units', 'normalized', 'Position', [0.1 0.25 0.75 0.5] );
subplot(5, 1, 1 );
plotData( data, 1 );
subplot(5, 1, 2 );
plotData( data, 2 );
subplot(5, 1, 3 );
plotData( data, 3 );
subplot(5, 1, 4 );
plotData( data, 4 );
subplot(5, 1, 5 );
plotData( data, 5 );

%%
% -------------------------------------------------   RUN MCMC INFERENCE!
modelP = {'bpM.gamma', 2}; 
algP   = {'Niter', 100, 'HMM.doSampleHypers',0,'BP.doSampleMass',0,'BP.doSampleConc',0}; 
% Start out with just one feature for all objects
initP  = {'F.nTotal', 1}; 
CH = runBPHMM( data, modelP, {1, 1}, algP, initP );
% CH is a structure that captures the "Chain History" of the MCMC
%  it stores both model config at each each iteration (in Psi field)
%             and diagnostic information (log prob, sampler stats, etc.)

%%
% -------------------------------------------------   VISUALIZE RESULTS!
% Remember: the actual labels of each behavior are irrelevent
%   so there won't in general be direct match with "ground truth"
% For example, the true behavior #1 may be inferred behavior #4

% So we'll need to align recovered parameters (separately at each iter)
% Let's just look at iter 90 and iter 100

Psi90 = CH.Psi( CH.iters.Psi == 90 );
alignedPsi90 = alignPsiToTruth_OneToOne( Psi90, data );

Psi100 = CH.Psi( CH.iters.Psi == 100 );
alignedPsi100 = alignPsiToTruth_OneToOne( Psi100, data );


% Estimated feature matrix F
figure( 'Units', 'normalized', 'Position', [0 0.5 0.5 0.5] );
subplot(1,2,1);
figure;plotFeatMat( alignedPsi90 )
title( 'F (@ iter 90)', 'FontSize', 20 );
subplot(1,2,2);
figure;plotFeatMat( alignedPsi100 );
title( 'F (@ iter 100)', 'FontSize', 20 );
%%
% Estimated emission parameters
figure( 'Units', 'normalized', 'Position', [0.5 0.5 0.5 0.5] );
subplot(1,2,1);
plotEmissionParams( Psi90 );
title( 'Theta (@ iter 90)', 'FontSize', 20 );
subplot(1,2,2);
plotEmissionParams( Psi100 );
title( 'Theta (@ iter 100)', 'FontSize', 20 );

% Estimated state sequence
plotStateSeq( alignedPsi100, [1 2 3] );
set( gcf, 'Units', 'normalized', 'Position', [0.1 0.25 0.75 0.5] );
title('Est. Z : Seq 3', 'FontSize', 20 );

fprintf( 'Remember: actual labels for behaviors are *irrelevant* from model perspective\n');
fprintf( '  what matters: *aligned* behaviors consistently assigned to same datapoints as ground truth\n' );