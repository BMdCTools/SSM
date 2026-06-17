function FWER_thr = SSM_DB_FCD_FixRan_CTRs_Vx15(tmpt,tmpt2,CovAgeBin,CovGenBin,Age_Covar,Gen_Covar,DBTIV)
%
% Brunno Machado de Campos
% University of Campinas, 2026
%
% Copyright (c) 2026, Brunno Machado de Campos
% All rights reserved.
% 
%      Redistribution and use in  source and  binary forms,  with  or without
%      modification, are permitted provided that the following conditions are
%      met:
%
%       * Redistributions  of  source  code  must retain  the above copyright
%         notice,  this list  of conditions  and  the  following  disclaimer.
%       * Redistributions in binary form must reproduce the  above  copyright
%         notice, this list of conditions and the following disclaimer in the 
%         documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR  IMPLIED WARRANTIES, INCLUDING, BUT  NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR  PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE  COPYRIGHT  OWNER OR CONTRIBUTORS  BE
% LIABLE   FOR  ANY   DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
% SUBSTITUTE GOODS OR SERVICES;  LOSS OF  USE, DATA, OR PROFITS;  OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON  ANY THEORY  OF LIABILITY,  WHETHER  IN
% CONTRACT,  STRICT LIABILITY, OR  TORT  (INCLUDING NEGLIGENCE  OR  OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
%
%  Read the manual for instructions 

%% ============= ORIGINAL PIPELINE  =============
    SSdir2 = which('SSM');
    SSdir2 = SSdir2(1:end-5);

    hObj = findobj('Type', 'figure', 'Name', 'Single-Subject Morphometry');
    handles = guidata(hObj);
    
    fprintf('-- Reshaping the database maps\n')
    TtmptResh  = reshape(tmpt,[size(tmpt,1)*size(tmpt,2)*size(tmpt,3),size(tmpt,4)]);
    TtmptResh2 = reshape(tmpt2,[size(tmpt2,1)*size(tmpt2,2)*size(tmpt2,3),size(tmpt2,4)]);
    
    TtmptResh  = TtmptResh';
    TtmptResh2 =  TtmptResh2';
    
    S3D_mat = size(tmpt);
    S3D_mat = S3D_mat(1:3);
    clear tmpt tmpt2 fkeep fkeep2

    %% ---------------- Background exclusion ----------------
    fprintf('-- Starting procedures to exclude regions of backgroud from the loop\n');
    ExclRegi = nifti([SSdir2,'SSM_FinalExclusionAreas_FCD.nii']);
    ExcMat = ExclRegi.dat(:,:,:);
    ExcMaResh  = reshape(ExcMat,[size(TtmptResh,2),1]);

    TtmptResh = TtmptResh .* abs(ExcMaResh - 1)';
    TtmptResh2 = TtmptResh2 .* abs(ExcMaResh - 1)';
    
    testerMatx  = TtmptResh;
    testerMatx2 = TtmptResh2;
    Size_testerMatx = size(testerMatx);

    testerMatx(testerMatx ~= 0)   = 1;
    testerMatx2(testerMatx2 ~= 0) = 1;

    vetBin  = sum(testerMatx,1);
    vetBin2 = sum(testerMatx2,1);

    vetBin(vetBin > 0)   = 1;
    vetBin2(vetBin2 > 0) = 1; 

    vetBinMat  = bsxfun(@and,vetBin, ones(1,size(testerMatx,1))');
    vetBinMat2 = bsxfun(@and,vetBin2,ones(1,size(testerMatx2,1))');

    TtmptResh  = TtmptResh .* vetBinMat;
    TtmptResh2 = TtmptResh2 .* vetBinMat2;

    fprintf('-- Removing zeros from the testing reshaped map\n')
    TtmptResh(:, ~any(TtmptResh,1))   = [];
    TtmptResh2(:,~any(TtmptResh2,1))  = [];
    fprintf('-- Done\n');
    clear vetBinMat vetBinMat2 testerMatx testerMatx2

    fprintf('-- Creating Covariates\n')
    
    if size(Gen_Covar,2) > 1
        Gen_Covar = Gen_Covar';
    end

    if CovAgeBin && CovGenBin
        Covar2Ctr = horzcat(Age_Covar,Gen_Covar,DBTIV,ones(size(Age_Covar,1),1));
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    elseif CovAgeBin
        Covar2Ctr = horzcat(Age_Covar,DBTIV,ones(size(Age_Covar,1),1));
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    elseif CovGenBin
        Covar2Ctr = horzcat(Gen_Covar,DBTIV,ones(size(Gen_Covar,1),1));
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    else
        Covar2Ctr = horzcat(DBTIV,ones(size(DBTIV,1),1));
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    end

    %% ---------------- Regression ----------------
    fprintf('-- Regressing confounders\n');
    betas1c = Covar2Ctr \ TtmptResh(1:end,:);
    TtmptReshTMP = TtmptResh(1:end,:) - (Covar2Ctr * betas1c) + betas1c(end,:);

    betas2c = Covar2Ctr \ TtmptResh2(1:end,:);
    TtmptReshTMP2 = TtmptResh2(1:end,:) - (Covar2Ctr * betas2c) + betas2c(end,:);
    
    TtmptReshTMP(TtmptReshTMP < 0.005) = 0;
    TtmptReshTMP2(TtmptReshTMP2 < 0.005) = 0;

    clear TtmptResh TtmptResh2

    %% ---------------- Reinserting zeros ----------------
    TtmptReshFF  = single(bsxfun(@and,vetBin, ones(1,Size_testerMatx(1))'));
    TtmptReshFF2 = single(bsxfun(@and,vetBin2,ones(1,Size_testerMatx(1))'));
    clear vetBin vetBin2
    
    TtmptReshFF(TtmptReshFF ~= 0)   = TtmptReshTMP;
    TtmptReshFF2(TtmptReshFF2 ~= 0) = TtmptReshTMP2;
    clear TtmptReshTMP TtmptReshTMP2
    
    Matmp1 = sum(TtmptReshFF > 0, 1);
    Matmp1(Matmp1 > 0) = 1;

    Matmp2 = sum(TtmptReshFF2 > 0, 1);
    Matmp2(Matmp2 > 0) = 1;

    AnalyMask = Matmp1 .* Matmp2;

    TtmptReshFF = TtmptReshFF .* AnalyMask;
    TtmptReshFF2 = TtmptReshFF2 .* AnalyMask;
    TtmptReshFF(isnan(TtmptReshFF)) = 0;
    TtmptReshFF2(isnan(TtmptReshFF2)) = 0;

    % ----- Voxel prunning -----
    aVET = (single(median(TtmptReshFF,1) == 0) + single(median(TtmptReshFF2,1) == 0)) > 1;
    % fm = reshape(aVET,S3D_mat);
    % figure;imagesc(fm(:,:,40));

    IdxSurv = find(abs(aVET-1));
    TtmptReshFF(:,any(aVET,1))   = [];
    TtmptReshFF2(:,any(aVET,1))   = [];

    clear fkeepResh fkeepResh2 AnalyMask Matmp1 Matmp2 MtmptResh MtmptResh2 STDtmptResh STDtmptResh2 tWMF tGMF fkeep2
    
    fprintf('-- Estimating the Interactional threshold using permut\n');
    tic
    FWER_thr = SSM_Permut_FCD_vx15(TtmptReshFF,TtmptReshFF2,IdxSurv,S3D_mat);
    fprintf('\n');
    fprintf('-- ');
    toc
    fprintf('\n');
    fprintf('-- ** Estimated FWER threshold is: %.1f **\n',FWER_thr);
    fprintf('-- Done!\n');
    
end





