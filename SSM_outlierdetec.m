function [OutInd,Cutoff] = SSM_outlierdetec(input,OutType,direction)
% SSM_OUTLIERDETEC Detects outliers in a numerical vector using the IQR method.
%
% Brunno Machado de Campos
% University of Campinas, 2026
%
% Copyright (c) 2026, Brunno Machado de Campos
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
%   * Redistributions of source code must retain the above copyright notice,
%     this list of conditions and the following disclaimer.
%   * Redistributions in binary form must reproduce the above copyright notice,
%     this list of conditions and the following disclaimer in the documentation
%     and/or other materials provided with the distribution.
% 
% [OutInd, Cutoff] = SSM_outlierdetec(input, OutType, direction)
%
% INPUTS:
%   input     - Numerical vector to be evaluated.
%   OutType   - Outlier threshold severity level:
%                 'major'  (Extreme outliers (hard to be consired one): 3.0 * IQR)
%                 'minor'  (Standard boxplot outliers: 1.5 * IQR) -> DEFAULT
%                 'severe' (Liberal outliers (easy to be consired one): 1.0 * IQR)
%   direction - Directionality of the outlier detection:
%                 'twosides'  (Detects both upper and lower outliers) -> DEFAULT
%                 'upperside' (Detects only abnormally high values)
%                 'lowerside' (Detects only abnormally low values)
%
% OUTPUTS:
%   OutInd    - Vector containing the indices of detected outliers relative 
%               to the original input vector position.
%   Cutoff    - Scalar or 2x1 vector containing the mathematical threshold(s).

    % --- Validate Input Arguments and Set Defaults ---
    if ~exist('direction','var') || isempty(direction)
        direction = 'twosides';
    end
    if ~exist('OutType','var') || isempty(OutType)
        OutType = 'minor';
    end

    if ~any(strcmp(OutType, {'major', 'minor', 'severe'}))
        error('Invalid OutType. Must be ''major'', ''minor'', or ''severe''.');
    end

    if ~any(strcmp(direction, {'twosides', 'upperside', 'lowerside'}))
        error('Invalid direction. Must be ''twosides'', ''upperside'', or ''lowerside''.');
    end
    
    % --- Safe NaN Handling ---
    % We extract valid numerical data for threshold calculation to prevent NaN
    % propagation, while preserving the original input vector to maintain 
    % exact indexing for mapped voxels or clinical subjects.
    if any(isnan(input))
        fprintf('\nSSM_outlierdetec: Warning - Ignoring NaN values for threshold calculation.\n');
    end
    
    input_valid = input(~isnan(input));
    
    if isempty(input_valid)
        OutInd = []; 
        Cutoff = []; 
        return;
    end
    
    Q_vals = quantile(input_valid, [0.25, 0.75]);
    Q1 = Q_vals(1);
    Q3 = Q_vals(2);
    IntQRng = Q3 - Q1;

    % --- Define IQR Multiplication Factor ---
    switch OutType
        case 'major'
            fac = 3.0;
        case 'minor'
            fac = 1.5;
        case 'severe'
            fac = 1.0;
    end

    % --- Establish Cutoff Boundaries ---
    InnerQ1 = Q1 - (IntQRng * fac);
    InnerQ3 = Q3 + (IntQRng * fac);

    % --- Identify Outliers Preserving Original Vector Indices ---
    switch direction
        case 'twosides'
            OutInd = find(input < InnerQ1 | input > InnerQ3);
            Cutoff = [InnerQ3; InnerQ1];
        case 'upperside'
            OutInd = find(input > InnerQ3);
            Cutoff = InnerQ3;
        case 'lowerside'
            OutInd = find(input < InnerQ1);
            Cutoff = InnerQ1;
    end
end