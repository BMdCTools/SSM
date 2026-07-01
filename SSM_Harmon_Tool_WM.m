function [wmmatPos,SB_Cat_Tmp] = SSM_Harmon_Tool_WM(wmmat,SB_Cat_Tmp,AgeVet,GenVet,GTIV,Ida_Ctr,Gene_Ctr,DB_TIV,OutDir)
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
    hObj = findobj('Type', 'figure', 'Name', 'Single-Subject Morphometry');
    handles = guidata(hObj);
    CovAgeBin = get(handles.covAge, 'Value');
    CovGenBin = get(handles.checkbox4, 'Value');

    sizeTMP = size(SB_Cat_Tmp);
    SB_Cat_TmpResh = reshape(SB_Cat_Tmp,[sizeTMP(1)*sizeTMP(2)*sizeTMP(3),sizeTMP(4)])';

    vetBatch = [ones(size(SB_Cat_TmpResh,1),1);2 .* ones(size(wmmat,1),1)];

    SB_Cat_TmpCat = [SB_Cat_TmpResh;wmmat];
    clear SB_Cat_TmpResh

    testerMatx2 = SB_Cat_TmpCat;
    Size_testerMatx = size(testerMatx2);

    testerMatx2(testerMatx2 ~= 0) = 1;

    vetBin2 = sum(testerMatx2, 1);

    vetBin2(vetBin2 > 0) = 1; 

    if handles.HarmnAdd %load user previously estimated parameter
        load([handles.HarmVarsFp,filesep,handles.HarmVarsF])
        % makes the vetBinMat be in the size of the current SC_Cat_TmpCat
        vetBinMat2  = bsxfun(@and,vetBinMat(1,:), ones(1,size(testerMatx,1))');
    end

    if handles.HarmEstim % estimates new harm parameters
        vetBinMat2  = bsxfun(@and,vetBin2, ones(1,size(testerMatx,1))');
    end

    TtmptResh2 = SB_Cat_TmpCat .* vetBinMat2;

    fprintf('-- Removing zeros from the reshaped maps\n')
    TtmptResh2(:,~any(TtmptResh2,1))  = [];

    fprintf('-- Creating Covariates\n')
    if size(Gene_Ctr,2) > 1
        Gene_Ctr = Gene_Ctr';
    end

    if CovAgeBin && CovGenBin
        Covar2Ctr = horzcat(Ida_Ctr,Gene_Ctr,DB_TIV,ones(size(Ida_Ctr,1),1));
        Covar2Pac = [AgeVet,GenVet,GTIV',ones(size(AgeVet,1),1)];
        MCov = mean(Covar2Ctr(:,1:end - 1));
        Covar2Ctr(:,1:end - 1) = Covar2Ctr(:,1:end - 1) - MCov;

    elseif CovAgeBin
        Covar2Ctr = horzcat(Ida_Ctr,DB_TIV,ones(size(Ida_Ctr,1),1));
        Covar2Pac = [agePat,SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    elseif CovGenBin
        Covar2Ctr = horzcat(Gene_Ctr,DB_TIV,ones(size(Gene_Ctr,1),1));
        Covar2Pac = [GenPat,SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    else
        Covar2Ctr = horzcat(DB_TIV,ones(size(DB_TIV,1),1));
        Covar2Pac = [SubjTIV,1];
        MCov = mean(Covar2Ctr(:,1:end-1));
        Covar2Ctr(:,1:end-1) = Covar2Ctr(:,1:end-1) - MCov;
    end

    %%% ---------------- Regression ----------------
    fprintf('-- Regressing confounders\n');
    betas2c = Covar2Ctr \ TtmptResh2(1:size(Covar2Ctr,1),:);
    TtmptReshTMP2 = TtmptResh2(1:size(Covar2Ctr,1),:) - (Covar2Ctr * betas2c) + betas2c(end,:);

    fkeepResh2 = TtmptResh2(size(Covar2Ctr,1) + 1:end,:) - ((Covar2Pac - [MCov,0]) * betas2c) + betas2c(end, :);

    if sum(HarmRef) == numel(HarmRef)
        TtmptResh2 = [TtmptReshTMP2;fkeepResh2];
    else
        TtmptResh2 = [TtmptReshTMP2;fkeepResh2(find(HarmRef),:)];
    end

    DBsize1 = size(TtmptReshTMP2,1);

    if handles.HarmnAdd % Case harm weights are addded
        TtmptReshDumm2 = TtmptResh2;
        gamma_Added2 = gamma_starWM(2,:)'; 
        delta_Added2 = delta_starWM(2,:)';

        for it = (DBsize1 + 1):size(TtmptResh2,1)
            Pac2 = TtmptResh2(it,:)';
            s_data_pac2 = (Pac2 - stand_meanWM) ./ sqrt(var_pooledWM);
            bayesdata_pac2 = (s_data_pac2 - gamma_Added2) ./ sqrt(delta_Added2);
            Harm_Pac2 = (bayesdata_pac2 .* sqrt(var_pooledWM)) + stand_meanWM;
            TtmptReshDumm2(it,:) = Harm_Pac2';
        end
        TtmptResh2 = single(TtmptReshDumm2);
        clear TtmptReshDumm1 TtmptReshDumm2

    else %HARMONIZING, estimating harm weights
        % WM
        [TtmptResh2,var_pooledWM,stand_meanWM,gamma_starWM,delta_starWM] = SSM_combat(double(TtmptResh2'),vetBatch,[],1,1);
        TtmptResh2 = TtmptResh2';
        stand_meanWM = stand_meanWM(:,1);

        if sum(HarmRef) ~= numel(HarmRef) % In the case harm was estimated only for a subgroup of the user  loaded data, here, we will apply it for all

            TtmptReshDumm2 = zeros(size(fkeepResh2,1) + DBsize1,size(fkeepResh2,2));
            TtmptReshDumm2(1:DBsize1,:) = TtmptResh2(1:DBsize1,:);
            TtmptReshDumm2(find(HarmRef) + DBsize1,:) = TtmptResh2(DBsize1 + 1:end,:);
            gamma_Added2 = gamma_starWM(2, :)'; 
            delta_Added2 = delta_starWM(2, :)';

            PacIdxs = find(abs(HarmRef - 1));
            for it = 1:numel(PacIdxs)
                Pac2 = fkeepResh2(PacIdxs(it), :)';
                s_data_pac2 = (Pac2 - stand_meanWM) ./ sqrt(var_pooledWM);
                bayesdata_pac2 = (s_data_pac2 - gamma_Added2) ./ sqrt(delta_Added2);
                paciente_harmonizado2 = (bayesdata_pac2 .* sqrt(var_pooledWM)) + stand_meanWM;
                TtmptReshDumm2(DBsize1 + PacIdxs(it), :) = paciente_harmonizado2';
            end
            TtmptResh2 = single(TtmptReshDumm2);
            clear TtmptReshDumm1 TtmptReshDumm2

        else
            TtmptResh2 = single(TtmptResh2);
        end

        save([OutDir,filesep,'HarmomParam_WM.mat'],'var_pooledWM','stand_meanWM',...
            'gamma_starWM','delta_starWM','vetBinMat2');
    end

    TtmptReshFF2 = single(bsxfun(@and,vetBin2, ones(1,Size_testerMatx(1))'));
    TtmptReshFF2(TtmptReshFF2 ~= 0) = TtmptResh2;
    wmmatPos = TtmptReshFF2(sizeTMP(4) + 1:end,:);
    SB_Cat_Tmp = TtmptReshFF2(1:sizeTMP(4),:);
    SB_Cat_Tmp = reshape(SB_Cat_Tmp',sizeTMP);

    fprintf('-- Encoding database\n')
    for k = 1:size(SB_Cat_Tmp,4)
        SB_Cat_Tmp(:,:,:,k) = SB_Cat_Tmp(vetx,vety,vetz,k);
    end
    
    if size(wmmatPos,1) > 3
        fprintf('-- Generating resultant harm. plots: WM\n')
        SSM_HarmPlots(SB_Cat_TmpCat,TtmptReshFF2,vetBatch,'WM',OutDir)
    else
        fprintf('-- The loaded sample is to small to generate harm. plots\n')
    end
end