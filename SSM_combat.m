function [bayesdata,var_pooled,stand_mean,gamma_star,delta_star] = SSM_combat(dat, batch, mod, parametric, ref_batch)
% =========================================================================
% COMBAT (ComBat Harmonization Method with Reference Batch Extension)
% =========================================================================
%
% ORIGINAL CREDITS:
% This function is derived from the original MATLAB implementation of ComBat
% developed by Jean-Philippe Fortin (subsequent to Johnson, Li & Rabinovic 2007).
% URL: https://github.com/Jfortin1/ComBatHarmonization
%
% METHODOLOGICAL EXTENSION (ETHICAL & SCIENTIFIC DISCLOSURE):
% This modified version implements a "Reference-Based ComBat" architecture 
% (akin to M-ComBat / Ref-ComBat frameworks; see Radua et al., 2020). 
%
% RATIONALE FOR MODIFICATION:
% In Single-Subject Morphometry (SSM) and clinical diagnostic pipelines, 
% evaluating new subjects against a gold-standard normative database requires 
% the reference cohort to remain strictly static and biologically uncorrupted. 
% 
% The standard, symmetrical ComBat algorithm maps all batches to an aggregate
% intermediate "half-space", which alters the variance and baseline of the 
% reference data on-the-fly and cancels the statistical contrast in single-subject 
% Z-score designs.
%
% This extension bypasses ordinary least squares across the pooled dataset by 
% forcing the standardization parameters (location and scale) to be derived 
% strictly from the user-defined 'ref_batch'. Consequently:
%   1. The reference batch undergoes zero adjustment (gamma = 0, delta = 1).
%   2. External batches are asymmetricaly projected into the reference space.
%   3. The baseline statistical properties of the normative database are preserved.
%
% INPUTS:
%   dat        - Data matrix (features x samples)
%   batch      - Batch indicator vector
%   mod        - Biological covariates matrix (optional)
%   parametric - Logical (1 for parametric EB, 0 for non-parametric EB)
%   ref_batch  - Numerical ID of the batch to be held static as reference
%
% Brunno M. Campos, 2026
% =========================================================================

    [sds] = std(dat')';
    wh = find(sds==0);
    [ns,ms] = size(wh);
    if ns > 0
        error('Error. There are rows with constant values across samples. Remove these rows and rerun ComBat.')
    end
    batchmod = categorical(batch);
    batchmod = dummyvar({batchmod});
	n_batch = size(batchmod,2);
	levels = unique(batch);
	fprintf('[combat] Found %d batches\n', n_batch);

	batches = cell(0);
	for i=1:n_batch
		batches{i}=find(batch == levels(i));
	end
	n_batches = cellfun(@length,batches);
	n_array = sum(n_batches);

% Identifies the numerical index of the reference batch within 'levels'
    ref_idx = find(levels == ref_batch);
    if isempty(ref_idx)
        error('Error. The specified ref_batch was not found in the batch vector.');
    end

	% Creating design matrix and removing intercept:
	design = [batchmod mod];
	intercept = ones(1,n_array)';
	wh = cellfun(@(x) isequal(x,intercept),num2cell(design,1));
	bad = find(wh==1);
	design(:,bad)=[];

	fprintf('[combat] Adjusting for %d covariate(s) of covariate level(s)\n',size(design,2)-size(batchmod,2))
	% Check if the design is confounded
	if rank(design)<size(design,2)
		nn = size(design,2);
	    if nn==(n_batch+1) 
	      error('Error. The covariate is confounded with batch. Remove the covariate and rerun ComBat.')
	    end
	    if nn>(n_batch+1)
	      temp = design(:,(n_batch+1):nn);
	      if rank(temp) < size(temp,2)
	        error('Error. The covariates are confounded. Please remove one or more of the covariates so the design is not confounded.')
	      else 
	        error('Error. At least one covariate is confounded with batch. Please remove confounded covariates and rerun ComBat.')
	      end
	    end
	 end

	fprintf('[combat] Standardizing Data across features (USING REFERENCE BATCH)\n')
    
    % --- STANDARDIZATION MODEL MODIFICATION ---
    % Instead of computing ordinary least squares across the entire matrix, the 
    % location (mean) and scale (variance) parameters are extracted strictly from the reference batch.
    B_hat = inv(design'*design)*design'*dat'; 
    
    % Forces the global mean to be strictly the intercept of the reference batch
    grand_mean = B_hat(ref_idx, :); 
    stand_mean = grand_mean'*repmat(1,1,n_array);
    
    % Calculates the pooled variance based solely on the residuals of the reference batch
    ref_indices = batches{ref_idx};
    n_ref = n_batches(ref_idx);
    var_pooled = ((dat(:,ref_indices) - (design(ref_indices,:)*B_hat)').^2) * repmat(1/n_ref, n_ref, 1);

	% Making sure pooled variances are not zero:
	wh = find(var_pooled==0);
	var_pooled_notzero = var_pooled;
	var_pooled_notzero(wh) = [];
	var_pooled(wh) = median(var_pooled_notzero);

	if not(isempty(design))
		tmp = design;
		tmp(:,1:n_batch) = 0;
		stand_mean = stand_mean+(tmp*B_hat)';
	end	
	s_data = (dat-stand_mean)./(sqrt(var_pooled)*repmat(1,1,n_array));

	%Get regression batch effect parameters
	fprintf('[combat] Fitting L/S model and finding priors\n')
	batch_design = design(:,1:n_batch);
	gamma_hat = inv(batch_design'*batch_design)*batch_design'*s_data';
	delta_hat = [];
	for i=1:n_batch
		indices = batches{i};
		delta_hat = [delta_hat; var(s_data(:,indices)')];
	end
    
    % --- ENFORCE REFERENCE BATCH PARAMETERS ---
    % The reference batch must not undergo any adjustment (gamma=0, delta=1)
    gamma_hat(ref_idx, :) = 0;
    delta_hat(ref_idx, :) = 1;

	%Find parametric priors:
	gamma_bar = mean(gamma_hat');
	t2 = var(gamma_hat');
	delta_hat_cell = num2cell(delta_hat,2);
	a_prior=[]; b_prior=[];
	for i=1:n_batch
		a_prior=[a_prior aprior(delta_hat_cell{i})];
		b_prior=[b_prior bprior(delta_hat_cell{i})];
	end
	
	if parametric
        fprintf('[combat] Finding parametric adjustments\n')
        gamma_star =[]; delta_star=[];
        for i=1:n_batch
            if i == ref_idx
                % Skips the Empirical Bayes estimation for the reference batch
                gamma_star = [gamma_star; zeros(1, size(s_data,1))];
                delta_star = [delta_star; ones(1, size(s_data,1))];
            else
                indices = batches{i};
                temp = itSol(s_data(:,indices),gamma_hat(i,:),delta_hat(i,:),gamma_bar(i),t2(i),a_prior(i),b_prior(i), 0.001);
                gamma_star = [gamma_star; temp(1,:)];
                delta_star = [delta_star; temp(2,:)];
            end
        end
    end
	    
    if (1-parametric)
        gamma_star =[]; delta_star=[];
        fprintf('[combat] Finding non-parametric adjustments\n')
        for i=1:n_batch
            if i == ref_idx
                % Pula a estimação Bayesiana para a referência
                gamma_star = [gamma_star; zeros(1, size(s_data,1))];
                delta_star = [delta_star; ones(1, size(s_data,1))];
            else
                indices = batches{i};
                temp = inteprior(s_data(:,indices),gamma_hat(i,:),delta_hat(i,:));
                gamma_star = [gamma_star; temp(1,:)];
                delta_star = [delta_star; temp(2,:)];
            end
        end
    end
	    
	fprintf('[combat] Adjusting the Data\n')
	bayesdata = s_data;
	j = 1;
	for i=1:n_batch
		indices = batches{i};
		bayesdata(:,indices) = (bayesdata(:,indices)-(batch_design(indices,:)*gamma_star)')./(sqrt(delta_star(j,:))'*repmat(1,1,n_batches(i)));
		j = j+1;
	end
	bayesdata = (bayesdata.*(sqrt(var_pooled)*repmat(1,1,n_array)))+stand_mean;
end