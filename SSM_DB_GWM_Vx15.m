function [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,CovAgeBin,CovGenBin,Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,SubjTIV,FixRa,FWER_thrIn,UseHarm)
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
    SSdir2 = [SSdir2(1:end-5)];
    
    hObj = findobj('Type', 'figure', 'Name', 'Single-Subject Morphometry');
    handles = guidata(hObj);
    GMs = get(handles.GMa, 'Value');

%% ============= ORIGINAL PIPELINE  =============

fprintf('-- Reshaping subject maps\n\n')
fkeepResh  = reshape(fkeep,[numel(fkeep),1]);

 % Reshaping the database maps 
tmptResh  = reshape(tmpt,[size(tmpt,1)*size(tmpt,2)*size(tmpt,3),size(tmpt,4)]);
% 
% RefCoilS_GM = nifti([SSdir2,'Ref_Coil_Gain_GM_vx15.nii']);
% RefC_mat_GM = RefCoilS_GM.dat(:,:,:);
% RefCresh_GM = single(reshape(RefC_mat_GM,[numel(fkeep),1]));
% RefCresh_GM(RefCresh_GM > 0) = 1;
% 
% RefCoilV_GM = RefCresh_GM .* median(tmptResh,2);
% RefCoilV_GM = median(RefCoilV_GM(RefCoilV_GM>0));
% CaseCoilV_GM = RefCresh_GM .* fkeepResh;
% CaseCoilV_GM = median(CaseCoilV_GM(CaseCoilV_GM>0));
% 
% Fac_GM = RefCoilV_GM / CaseCoilV_GM;
% 
% fprintf('-- Tissue scale factor: %.3f\n',Fac_GM)

% fkeepResh = fkeepResh .* Fac_GM;

TtmptResh  = [tmptResh';  fkeepResh'];

S3D_mat = size(fkeep);

clear tmptResh tmptResh2 tmpt tmpt2 fkeep fkeep2

%% ---------------- Background exclusion ----------------
if GMs
    fprintf('-- Starting procedures to exclude regions of backgroud from the loop\n\n');
    ExclRegi = nifti([SSdir2,'AuxFiles',filesep,'SSM_FinalExclusionAreas_GM.nii']);
    ExcMat = ExclRegi.dat(:,:,:);
    ExcMaResh  = reshape(ExcMat,[size(TtmptResh,2),1]);
    TtmptResh = TtmptResh .* abs(ExcMaResh - 1)';
end

testerMatx  = TtmptResh;
Size_testerMatx = size(testerMatx);
testerMatx(testerMatx ~= 0)   = 1;
vetBin  = sum(testerMatx, 1);
vetBin(vetBin > 0)   = 1;

vetBinMat  = bsxfun(@and,vetBin, ones(1,size(testerMatx,1))');

TtmptResh  = TtmptResh .* vetBinMat;

fprintf('-- Removing zeros from the testing reshaped map\n')
TtmptResh(:, ~any(TtmptResh,1))   = [];
fprintf('-- Done\n\n');
clear vetBinMat vetBinMat2 testerMatx testerMatx2

fprintf('-- Creating Covariates\n\n')
DBTIV = round(DBTIV);
SubjTIV = round(SubjTIV);

if ~UseHarm % a new regression will be performed only if we are not using 
            % previously harmonized (and regressed) images
    if size(Gen_Covar,2) > 1
        Gen_Covar = Gen_Covar';
    end

    if CovAgeBin && CovGenBin
        Covar2Ctr = horzcat(Age_Covar,Gen_Covar,DBTIV,ones(size(Age_Covar,1),1));
        Covar2Pac = [agePat,GenPat,SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    elseif CovAgeBin
        Covar2Ctr = horzcat(Age_Covar,DBTIV,ones(size(Age_Covar,1),1));
        Covar2Pac = [agePat,SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    elseif CovGenBin
        Covar2Ctr = horzcat(Gen_Covar,DBTIV,ones(size(Gen_Covar,1),1));
        Covar2Pac = [GenPat,SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    else
        Covar2Ctr = horzcat(DBTIV,ones(size(DBTIV,1),1));
        Covar2Pac = [SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    end

    %% ---------------- Regression ----------------
    fprintf('-- Regressing confounders\n\n');
    betas1c = Covar2Ctr \ TtmptResh(1:end-1,:);
    TtmptReshTMP = TtmptResh(1:end-1,:) - (Covar2Ctr * betas1c) + betas1c(end,:);

    fkeepResh = TtmptResh(end,:) - ((Covar2Pac - [MCov,0]) * betas1c) + betas1c(end, :);
    TtmptReshTMP = [TtmptReshTMP;fkeepResh];
    
else
    fprintf('-- Skiping regression (harmonized data)\n\n')
    TtmptReshTMP = TtmptResh;
    clear TtmptResh TtmptResh2
end

TtmptReshTMP(TtmptReshTMP < 0.005) = 0;

%% ---------------- Reinserting zeros ----------------
TtmptReshFF  = single(bsxfun(@and,vetBin, ones(1,Size_testerMatx(1))'));
TtmptReshFF(TtmptReshFF ~= 0)   = TtmptReshTMP;
clear testerMatx testerMatx2 vetBin vetBin2 TtmptReshTMP TtmptReshTMP2


%% ---------------- Separate patient ----------------
fkeepResh  = TtmptReshFF(end,:)';
TtmptReshFF(end,:)  = [];

fprintf('-- Performing Global statistics\n\n')

TtmptReshFF(isnan(TtmptReshFF)) = 0;
fkeepResh(isnan(fkeepResh)) = 0;

% ----- Common support masking / Voxel prunning -----
aVET = single((sum(TtmptReshFF,1) == 0) .* (fkeepResh' == 0));

IdxSurv = find(abs(aVET-1));
% ind3D = reshape(MAP,S3D_mat);
% figure;imagesc(ind3D(:,:,90));

TtmptReshFF(:,any(aVET,1))   = [];
fkeepResh(any(aVET,1),:)   = [];

% ----- Stats ----- 
MtmptResh  = median(TtmptReshFF,1);
MADGM = median(abs(TtmptReshFF - MtmptResh),1);

IdxGM = find(MADGM < 0.002);
MADGM(IdxGM) = 0;
MtmptResh(IdxGM) = 0;
fkeepResh(IdxGM) = 0;

%% ---------------- Final patient interactive T map  ----------------
zGMrb = (MtmptResh - fkeepResh') ./ ((MADGM * 1.4826) + 1e-6);

zGMrb(isnan(zGMrb)) = 0;
zGMrb(zGMrb > 20) = 20;
zGMrb(zGMrb < -20) = -20;

Iteract_TmapF = zGMrb;        

% ----- Retrieving background ----- 
Iteract_Tmap  = single(bsxfun(@and,aVET == 0, ones(1,size(aVET,2))));
Iteract_Tmap(Iteract_Tmap ~= 0) = Iteract_TmapF;
clear fkeepResh fkeepResh2 AnalyMask Matmp1 Matmp2 MtmptResh MtmptResh2 STDtmptResh STDtmptResh2 tWMF tGMF fkeep2

% MAPF  = single(bsxfun(@and,aVET == 0, ones(1,size(aVET,2))));
% MAPF(MAPF ~= 0) = MtmptResh;
% ind3D = reshape(MAPF,S3D_mat);
% figure;imagesc(ind3D(:,:,115));


if ~FixRa
    if isempty(FWER_thrIn)
        fprintf('-- Estimating the threshold using permut\n\n');
        tic
        FWER_thr = SSM_Permut_GWM_vx15(TtmptReshFF,IdxSurv,S3D_mat);
        fprintf('-- ');
        toc
        fprintf('\n');
        fprintf('-- ** Estimated FWER threshold is: %.1f **\n\n',FWER_thr);
        
        Iteract_Tmap_Posi_Thr = Iteract_Tmap.*(Iteract_Tmap > 0);
        Iteract_Tmap_Posi_Thr(Iteract_Tmap_Posi_Thr < FWER_thr(1)) = 0;
        
        Iteract_Tmap_Neg_Thr = abs(Iteract_Tmap.*(Iteract_Tmap < 0));
        Iteract_Tmap_Neg_Thr(Iteract_Tmap_Neg_Thr < abs(FWER_thr(2))) = 0;
        Iteract_Tmap_Neg_Thr = -1.*(Iteract_Tmap_Neg_Thr);
        
        Iteract_Tmap_Thr = (Iteract_Tmap_Posi_Thr + Iteract_Tmap_Neg_Thr);
    else
        FWER_thr = FWER_thrIn;
        
        Iteract_Tmap_Posi_Thr = Iteract_Tmap.*(Iteract_Tmap > 0);
        Iteract_Tmap_Posi_Thr(Iteract_Tmap_Posi_Thr < FWER_thr(1)) = 0;
        
        Iteract_Tmap_Neg_Thr = abs(Iteract_Tmap.*(Iteract_Tmap < 0));
        Iteract_Tmap_Neg_Thr(Iteract_Tmap_Neg_Thr < abs(FWER_thr(2))) = 0;
        Iteract_Tmap_Neg_Thr = -1.*(Iteract_Tmap_Neg_Thr);
        
        Iteract_Tmap_Thr = (Iteract_Tmap_Posi_Thr + Iteract_Tmap_Neg_Thr);
        fprintf('-- Previousy estimated and stored FWER threshold: %.1f\n\n',FWER_thr);
    end
else
    FWER_thr = FWER_thrIn;
    Iteract_Tmap_Posi_Thr = Iteract_Tmap.*(Iteract_Tmap > 0);
    Iteract_Tmap_Posi_Thr(Iteract_Tmap_Posi_Thr < FWER_thr(1)) = 0;

    Iteract_Tmap_Neg_Thr = abs(Iteract_Tmap.*(Iteract_Tmap < 0));
    Iteract_Tmap_Neg_Thr(Iteract_Tmap_Neg_Thr < abs(FWER_thr(2))) = 0;
    Iteract_Tmap_Neg_Thr = -1.*(Iteract_Tmap_Neg_Thr);

    Iteract_Tmap_Thr = (Iteract_Tmap_Posi_Thr + Iteract_Tmap_Neg_Thr);
    fprintf('-- ** Estimated FWER threshold is: %.1f **\n\n',FWER_thrIn);
end

fprintf('-- Done\n\n');
    
end





