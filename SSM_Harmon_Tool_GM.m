function [gmmatPos,SC_Cat_Tmp] = SSM_Harmon_Tool_GM(gmmat,SC_Cat_Tmp,AgeVet,GenVet,GTIV,Ida_Ctr,Gene_Ctr,DB_TIV,OutDir)
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
 
hObj = findobj('Type', 'figure', 'Name', 'Single-Subject Morphometry');
    handles = guidata(hObj);
    CovAgeBin = get(handles.covAge, 'Value');
    CovGenBin = get(handles.covAge, 'checkbox4');

sizeTMP = size(SC_Cat_Tmp);
    
SC_Cat_TmpResh = reshape(SC_Cat_Tmp,[sizeTMP(1)*sizeTMP(2)*sizeTMP(3),sizeTMP(4)])';

vetBatch = [ones(size(SC_Cat_TmpResh,1),1);2 .* ones(size(gmmat,1),1)];

SC_Cat_TmpCat = [SC_Cat_TmpResh;gmmat];
clear SC_Cat_TmpResh SB_Cat_TmpResh

testerMatx  = SC_Cat_TmpCat;
Size_testerMatx = size(testerMatx);
testerMatx(testerMatx ~= 0)   = 1;
vetBin  = sum(testerMatx, 1);
vetBin(vetBin > 0)   = 1;

if handles.HarmnAdd %load user previously estimated parameter
    load([handles.HarmVarsFp,filesep,handles.HarmVarsF])
    % makes the vetBinMat be in the size of the current SC_Cat_TmpCat
    vetBinMat  = bsxfun(@and,vetBinMat(1,:), ones(1,size(testerMatx,1))');
end

if handles.HarmEstim % estimates new harm parameters
    vetBinMat  = bsxfun(@and,vetBin, ones(1,size(testerMatx,1))');
end

TtmptResh  = SC_Cat_TmpCat .* vetBinMat;

fprintf('-- Removing zeros from the reshaped maps\n\n')
TtmptResh(:, ~any(TtmptResh,1))   = [];

fprintf('-- Creating Covariates\n\n')
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
fprintf('-- Regressing confounders\n\n');
betas1c = Covar2Ctr \ TtmptResh(1:size(Covar2Ctr,1),:);
TtmptReshTMP = TtmptResh(1:size(Covar2Ctr,1),:) - (Covar2Ctr * betas1c) + betas1c(end,:);

fkeepResh = TtmptResh(size(Covar2Ctr,1) + 1:end,:) - ((Covar2Pac - [MCov,0]) * betas1c) + betas1c(end, :);

if sum(HarmRef) == numel(HarmRef)
    TtmptResh = [TtmptReshTMP;fkeepResh];
else
    TtmptResh = [TtmptReshTMP;fkeepResh(find(HarmRef),:)];
end

DBsize1 = size(TtmptReshTMP,1);

if handles.HarmnAdd % Case harm weights are addded
    TtmptReshDumm1 = TtmptResh;
    gamma_Added = gamma_starGM(2,:)'; 
    delta_Added = delta_starGM(2,:)';

    for it = (DBsize1 + 1):size(TtmptResh,1)
        Pac1 = TtmptResh(it,:)';
        s_data_pac = (Pac1 - stand_meanGM) ./ sqrt(var_pooledGM);
        bayesdata_pac = (s_data_pac - gamma_Added) ./ sqrt(delta_Added);
        Harm_Pac = (bayesdata_pac .* sqrt(var_pooledGM)) + stand_meanGM;
        TtmptReshDumm1(it,:) = Harm_Pac';
    end
    TtmptResh = single(TtmptReshDumm1);
    clear TtmptReshDumm1
    
else %HARMONIZING, estimating harm weights
    
    % GM
    [TtmptResh,var_pooledGM,stand_meanGM,gamma_starGM,delta_starGM]  = SSM_combat(double(TtmptResh'),vetBatch,[],1,1);
    TtmptResh = TtmptResh';
    stand_meanGM = stand_meanGM(:,1);

    if sum(HarmRef) ~= numel(HarmRef) % In the case harm was estimated only for a subgroup of the user  loaded data, here, we will apply it for all
        TtmptReshDumm1 = zeros(size(fkeepResh,1) + DBsize1,size(fkeepResh,2));
        TtmptReshDumm1(1:DBsize1,:) = TtmptResh(1:DBsize1,:);
        TtmptReshDumm1(find(HarmRef) + DBsize1,:) = TtmptResh(DBsize1 + 1:end,:);
        gamma_Added = gamma_starGM(2, :)'; 
        delta_Added = delta_starGM(2, :)';

        PacIdxs = find(abs(HarmRef - 1));
        for it = 1:numel(PacIdxs)
            Pac1 = fkeepResh(PacIdxs(it), :)';
            s_data_pac = (Pac1 - stand_meanGM) ./ sqrt(var_pooledGM);
            bayesdata_pac = (s_data_pac - gamma_Added) ./ sqrt(delta_Added);
            paciente_harmonizado = (bayesdata_pac .* sqrt(var_pooledGM)) + stand_meanGM;
            TtmptReshDumm1(DBsize1 + PacIdxs(it), :) = paciente_harmonizado';
        end
        TtmptResh = single(TtmptReshDumm1);
        clear TtmptReshDumm1
    else
        TtmptResh = single(TtmptResh);
    end
    
    save([OutDir,filesep,'HarmomParam_GM.mat'],'var_pooledGM','stand_meanGM','gamma_starGM',...
        'delta_starGM','vetBinMat');
end

TtmptReshFF  = single(bsxfun(@and,vetBin, ones(1,Size_testerMatx(1))'));
TtmptReshFF(TtmptReshFF ~= 0)   = TtmptResh;
gmmatPos = TtmptReshFF(sizeTMP(4) + 1:end,:);
 
SC_Cat_Tmp = TtmptReshFF(1:sizeTMP(4),:);
SC_Cat_Tmp = reshape(SC_Cat_Tmp',sizeTMP);

fprintf('-- Generating resultant harm. plots: GM\n\n')
SSM_HarmPlots(SC_Cat_TmpCat,TtmptReshFF,vetBatch,'GM',OutDir)
end