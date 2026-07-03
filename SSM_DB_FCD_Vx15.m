function [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,CovAgeBin,...
                                                        CovGenBin,Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                        SubjTIV,FixRa,FWER_thrIn,UseHarm)
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
 
    SSdir2 = which('SSM');
    SSdir2 = SSdir2(1:end-5);
    
    hObj = findobj('Type', 'figure', 'Name', 'Single-Subject Morphometry');
    handles = guidata(hObj);
    SmoKm = get(handles.PopMenuSmoothK, 'Value');
   
        switch SmoKm(1)
            case 1
                SmooK = 3;
            case 2
                SmooK = 5;
            case 3   
                SmooK = 7;
            case 4 
                SmooK = 9;
            case 5
                SmooK = 11;
        end
        
%% ============= ORIGINAL PIPELINE  =============

fprintf('-- Reshaping subject maps\n')
fkeepResh  = reshape(fkeep,[numel(fkeep),1]);
fkeepResh2 = reshape(fkeep2,[numel(fkeep2),1]);

% Reshaping the database maps 
tmptResh  = reshape(tmpt,[size(tmpt,1)*size(tmpt,2)*size(tmpt,3),size(tmpt,4)]);
tmptResh2 = reshape(tmpt2,[size(tmpt2,1)*size(tmpt2,2)*size(tmpt2,3),size(tmpt2,4)]);

TtmptResh  = [tmptResh';  fkeepResh'];
TtmptResh2 = [tmptResh2'; fkeepResh2'];

S3D_mat = size(fkeep);

clear tmptResh tmptResh2 tmpt tmpt2 fkeep fkeep2

%% ---------------- Background exclusion ----------------
fprintf('-- Starting procedures to exclude from the loop regions of backgroud\n');
ExclRegi = nifti([SSdir2,'AuxFiles',filesep,'SSM_FinalExclusionAreas_FCD.nii']);

ExcMat = ExclRegi.dat(:,:,:);
ExcMat(ExcMat > 0) = 1;
ExcMat(ExcMat < 1) = 0;
ExcMaResh  = reshape(ExcMat,[size(TtmptResh,2),1]);

TtmptResh = TtmptResh .* abs(ExcMaResh - 1)';
TtmptResh2 = TtmptResh2 .* abs(ExcMaResh - 1)';

testerMatx  = TtmptResh;
testerMatx2 = TtmptResh2;
Size_testerMatx = size(testerMatx);

testerMatx(testerMatx ~= 0)   = 1;
testerMatx2(testerMatx2 ~= 0) = 1;

vetBin  = sum(testerMatx, 1);
vetBin2 = sum(testerMatx2, 1);

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

if ~UseHarm % a new regression will be performed only if we are not using 
            % previously harmonized (and regressed) images
    fprintf('-- Creating Covariates\n')
    if size(Gen_Covar,2) > 1
        Gen_Covar = Gen_Covar';
    end

    if CovAgeBin && CovGenBin
        Covar2Ctr = horzcat(Age_Covar,Gen_Covar,DBTIV,ones(size(Age_Covar,1),1));
        Covar2Pac = [agePat,GenPat,SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
        CovIdx = [1,2];
    elseif CovAgeBin
        Covar2Ctr = horzcat(Age_Covar,DBTIV,ones(size(Age_Covar,1),1));
        Covar2Pac = [agePat,SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
        CovIdx = 1;
    elseif CovGenBin
        Covar2Ctr = horzcat(Gen_Covar,DBTIV,ones(size(Gen_Covar,1),1));
        Covar2Pac = [GenPat,SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
        CovIdx = 1;
    else
        Covar2Ctr = horzcat(DBTIV,ones(size(DBTIV,1),1));
        Covar2Pac = [SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    end

    %%% ---------------- Regression ----------------
    fprintf('-- Regressing confounders\n');
    betas1c = Covar2Ctr \ TtmptResh(1:end-1,:);
    TtmptReshTMP = TtmptResh(1:end-1,:) - (Covar2Ctr * betas1c) + betas1c(end,:);

    betas2c = Covar2Ctr \ TtmptResh2(1:end-1,:);
    TtmptReshTMP2 = TtmptResh2(1:end-1,:) - (Covar2Ctr * betas2c) + betas2c(end,:);

    fkeepResh = TtmptResh(end,:) - ((Covar2Pac - [MCov,0]) * betas1c) + betas1c(end, :);
    fkeepResh2 = TtmptResh2(end,:) - ((Covar2Pac - [MCov,0]) * betas2c) + betas2c(end, :);
    TtmptReshTMP = [TtmptReshTMP;fkeepResh];
    TtmptReshTMP2 = [TtmptReshTMP2;fkeepResh2];
else
    fprintf('-- Skiping regression at this point (harmonized data)\n')
    TtmptReshTMP = TtmptResh;
    TtmptReshTMP2 = TtmptResh2;
    clear TtmptResh TtmptResh2
end

TtmptReshTMP(TtmptReshTMP < 0.0005) = 0;
TtmptReshTMP2(TtmptReshTMP2 < 0.0005) = 0;


%% ---------------- Reinserting zeros ----------------
TtmptReshFF  = single(bsxfun(@and,vetBin, ones(1,Size_testerMatx(1))'));
TtmptReshFF2 = single(bsxfun(@and,vetBin2, ones(1,Size_testerMatx(1))'));

TtmptReshFF(TtmptReshFF ~= 0)   = TtmptReshTMP;
TtmptReshFF2(TtmptReshFF2 ~= 0) = TtmptReshTMP2;
clear testerMatx testerMatx2 vetBin vetBin2 TtmptReshTMP TtmptReshTMP2


%% ---------------- Separate patient ----------------
fkeepResh  = TtmptReshFF(end,:)';
fkeepResh2 = TtmptReshFF2(end,:)';

TtmptReshFF(end,:)  = [];
TtmptReshFF2(end,:) = [];

fprintf('-- Performing Global statistics\n')

TtmptReshFF(isnan(TtmptReshFF)) = 0;
TtmptReshFF2(isnan(TtmptReshFF2)) = 0;
fkeepResh(isnan(fkeepResh)) = 0;
fkeepResh2(isnan(fkeepResh2)) = 0;

% ----- Common support masking / Voxel prunning -----
aVET = (single(fkeepResh' == 0) +  single(fkeepResh2' == 0)) > 1;

TtmptReshFF(:,any(aVET,1))   = [];
TtmptReshFF2(:,any(aVET,1))   = [];
fkeepResh(any(aVET,1),:)   = [];
fkeepResh2(any(aVET,1),:)   = [];

IdxSurv = find(abs(aVET-1));

% ----- Stats ----- 
MtmptResh  = median(TtmptReshFF,1);
MtmptResh2 = median(TtmptReshFF2,1);
MADGM = median(abs(TtmptReshFF - MtmptResh),1);
MADWM = median(abs(TtmptReshFF2 - MtmptResh2),1);

% IdxGM = find(MADGM < 0.002);
% MADGM(IdxGM) = 0;
% MtmptResh(IdxGM) = 0;
% fkeepResh(IdxGM) = 0;

% IdxWM = find(MADWM < 0.002);
% MADWM(IdxWM) = 0;
% MtmptResh2(IdxWM) = 0;
% fkeepResh2(IdxWM) = 0;

%% ---------------- Final patient interactive T map  ----------------

%%%%%%%%%%%%
% Vox/Volume
zGMrb = (fkeepResh' - MtmptResh)   ./ ((MADGM * 1.4826) + 1e-6);
zWMrb = (MtmptResh2 - fkeepResh2') ./ ((MADWM * 1.4826) + 1e-6);

zGMrb(zGMrb < 0) = 0;
zWMrb(zWMrb < 0) = 0;
zGMrb(zGMrb > 20) = 20;
zWMrb(zWMrb > 20) = 20;

% Final VOX INTERACTION
Zvox = (((zGMrb + 1) .* (zWMrb + 1)) .^ 0.5);

% FINAL INTERACTION
Iteract_TmapF = Zvox;

% ----- Retrieving background ----- 
Iteract_Tmap  = single(bsxfun(@and,aVET == 0, ones(1,size(aVET,2))));
Iteract_Tmap(Iteract_Tmap ~= 0) = Iteract_TmapF;

% Iteract_Tmap  = single(bsxfun(@and,aVET == 0, ones(1,size(aVET,2))));
% Iteract_Tmap(Iteract_Tmap ~= 0) = Iteract_Tmap';
% fm = reshape(Iteract_Tmap,S3D_mat);
% figure;imagesc(fm(:,:,71));
clear fkeepResh fkeepResh2 AnalyMask Matmp1 Matmp2 MtmptResh MtmptResh2 STDtmptResh STDtmptResh2 tWMF tGMF fkeep2

if ~FixRa
    if isempty(FWER_thrIn)
        % ----- Estimating the Interactional threshold using permut.  ----- 
        fprintf('-- Estimating the Interactional threshold using permut\n');
        tic
        FWER_thr = SSM_Permut_FCD_vx15(TtmptReshFF,TtmptReshFF2,IdxSurv,S3D_mat);
        fprintf('-- ');
        toc
        fprintf('\n');
        fprintf('-- ** Estimated FWER threshold is: %.1f **\n',FWER_thr);
        Iteract_Tmap_Thr = Iteract_Tmap;
        Iteract_Tmap_Thr(Iteract_Tmap_Thr < FWER_thr) = 0;
    else
        FWER_thr = FWER_thrIn;
        Iteract_Tmap_Thr = Iteract_Tmap;
        Iteract_Tmap_Thr(Iteract_Tmap_Thr < FWER_thr) = 0;
        fprintf('-- Previousy estimated and stored FWER threshold: %.1f\n',FWER_thr);
    end
else
    FWER_thr = FWER_thrIn;
    Iteract_Tmap_Thr = Iteract_Tmap;
    Iteract_Tmap_Thr(Iteract_Tmap_Thr < FWER_thr) = 0;
    fprintf('-- ** Estimated FWER threshold is: %.1f **\n',FWER_thrIn);
end

fprintf('-- Done!\n');
    
end





