function FWER_thr = SSM_Permut_GWM_vx15(TtmptReshFF,IdxSurv,MatS)
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
%  Read the manual for instructions 

%% ============= ORIGINAL PIPELINE  =============
    hObj = findobj('Type', 'figure', 'Name', 'Single-Subject Morphometry');
    handles = guidata(hObj);
    
    SmoKm = get(handles.PopMenuSmoothK, 'Value');
    
    Nperm = str2num(get(handles.nPermEdit, 'String'));
    frac = str2num(get(handles.SubFactEdit, 'String'));
    
    blobwise = get(handles.radiobutton15, 'Value');
    percL = str2num(get(handles.alphaL, 'String'));
    percL = 100 * (1-percL);
    
    if blobwise
        fprintf('--- Estimating local-blob-wise FWER threshold\n')

        switch SmoKm
            case 1
                Radius = 3; %round values divided by Vox of 1.5 mm
            case 2
                Radius = 4;
            case 3   
                Radius = 5;
            case 4 
                Radius = 7;
            case 5
                Radius = 8;
        end
        fprintf('--- The blobs are spheres with a %d voxels radius\n',Radius);

        dims = [MatS(1) MatS(2) MatS(3)];

        [dx,dy,dz] = ndgrid(-Radius:Radius, -Radius:Radius, -Radius:Radius);
        dist = sqrt(dx.^2 + dy.^2 + dz.^2);

        mask = dist <= Radius;   % esfera real
        nbr_offsets = [dx(mask), dy(mask), dz(mask)];
    else
        fprintf('--- Estimating voxel-wise FWER threshold\n')
    end
    
    SubsetIdx = cell(Nperm,1);
    Nctrl = size(TtmptReshFF,1);
    if Nctrl < 40
        Ns = Nctrl;
        Nperm = Nctrl;
        fprintf('--- ATTENTION: Ref. dataset with %d subjects\n',Nctrl)
        fprintf('--- Permutation test will be limited to a leave-one-out scheme (%d permutations)\n',Nctrl)
        for ft = 1:Nctrl
            SubsetIdx{ft} = 1:Nperm;
        end
    else
        Ns = round(frac * Nctrl);
    
        fprintf('--- Generating unique controls subsets\n')

        used = containers.Map('KeyType','char','ValueType','logical');
        k = 1;
        while k <= Nperm
            idx = sort(randperm(Nctrl, Ns));   % sorted for unique key
            key = sprintf('%d_', idx);
            if ~isKey(used, key)
                used(key) = true;
                SubsetIdx{k} = idx;
                k = k + 1;
            end
        end
    end
    
    MaxNull = zeros(Nperm,1,'single');
    
    TtmptReshFF = single(TtmptReshFF);
    MtmptResh  = median(TtmptReshFF,1);
    MADGM = median(abs(TtmptReshFF - MtmptResh),1);

    if Ns == Nperm
        fake_out = 1:Nperm;
    else
        fake_out = randi(Ns, 1, Nperm);
    end
    
    fprintf('--- Permutation loop\n');
    fprintf('--- Running:       ')
    
    if blobwise
        parfor p = 1:Nperm
            idx = SubsetIdx{p};

            GM_fake = TtmptReshFF(idx(fake_out(p)),:);
            GM_ctrl = TtmptReshFF(setdiff(idx,fake_out(p)),:);

            % Z-robusto
            mGM = median(GM_ctrl,1);
            MADGM = median(abs(GM_ctrl - mGM),1);
            IdxGM = find(MADGM < 0.002);
            mGM(IdxGM) = 0;
            GM_fake(IdxGM) = 0;
            MADGM(IdxGM) = 0;

            zGMrb = (mGM - GM_fake) ./ ((MADGM * 1.4826) + 1e-6);

            zGMrb(isnan(zGMrb)) = 0;
            zGMrb(zGMrb > 20) = 20;
            zGMrb(zGMrb < -20) = -20;

            Stat_null_Posi = zGMrb .* (zGMrb > 0);
            Stat_null_Neg = abs(zGMrb .* (zGMrb < 0));
            
            %%% Estimate FWER local-blob-wise using original
            %%% Smoothing kernel as blob size
            [~,vox_id] = max(Stat_null_Posi); % voxel-wise FWER
            [iid,jid,kid] = ind2sub(dims, IdxSurv(vox_id));
            nbr_coords = [iid jid kid] + nbr_offsets;
            valid = nbr_coords(:,1) >= 1 & nbr_coords(:,1) <= dims(1) & ...
                nbr_coords(:,2) >= 1 & nbr_coords(:,2) <= dims(2) & ...
                nbr_coords(:,3) >= 1 & nbr_coords(:,3) <= dims(3);

            nbr_coords = nbr_coords(valid,:);
            nbr_lin = sub2ind(dims, nbr_coords(:,1), nbr_coords(:,2), nbr_coords(:,3));  
            [tf, loc] = ismember(nbr_lin, IdxSurv);
            nbr_valid = loc(tf);   % indices no espaço compactado    
            local_vals = Stat_null_Posi(nbr_valid);
            local_mean = median(local_vals);
            MaxNull_Posi(p) = local_mean;

            [~,vox_id] = max(Stat_null_Neg); % voxel-wise FWER
            [iid,jid,kid] = ind2sub(dims, IdxSurv(vox_id));
            nbr_coords = [iid jid kid] + nbr_offsets;
            valid = nbr_coords(:,1) >= 1 & nbr_coords(:,1) <= dims(1) & ...
                nbr_coords(:,2) >= 1 & nbr_coords(:,2) <= dims(2) & ...
                nbr_coords(:,3) >= 1 & nbr_coords(:,3) <= dims(3);

            nbr_coords = nbr_coords(valid,:);
            nbr_lin = sub2ind(dims, nbr_coords(:,1), nbr_coords(:,2), nbr_coords(:,3));  
            [tf, loc] = ismember(nbr_lin, IdxSurv);
            nbr_valid = loc(tf);   % indices no espaço compactado    
            local_vals = Stat_null_Neg(nbr_valid);
            local_mean = median(local_vals);
            MaxNull_Neg(p) = local_mean;
            
            fprintf('\b\b\b\b\b\b')
            fprintf('%.3d%%  ',round(100*(p/Nperm)))
        end
        
        FWER_thr_Neg = prctile(MaxNull_Neg, percL);
        FWER_thr_Pos = prctile(MaxNull_Posi, percL);
        FWER_thr = [FWER_thr_Pos;-FWER_thr_Neg];
    else
        parfor p = 1:Nperm
            idx = SubsetIdx{p};

            GM_fake = TtmptReshFF(idx(fake_out(p)),:);
            GM_ctrl = TtmptReshFF(setdiff(idx,fake_out(p)),:);

            % Z-robusto
            mGM = median(GM_ctrl,1);
            MADGM = median(abs(GM_ctrl - mGM),1);
            
            IdxGM = find(MADGM < 0.002);
            mGM(IdxGM) = 0;
            GM_fake(IdxGM) = 0;
            MADGM(IdxGM) = 0;
            
            zGMrb = (mGM - GM_fake) ./ ((MADGM * 1.4826) + 1e-6);
            
            zGMrb(isnan(zGMrb)) = 0;
            zGMrb(zGMrb > 20) = 20;
            zGMrb(zGMrb < -20) = -20;
            
            %%% Estimate FWER voxel-wise
            MaxNull(p) = max(abs(zGMrb));

            fprintf('\b\b\b\b\b\b')
            fprintf('%.3d%%  ',round(100*(p/Nperm)))
        end
        
        FWER_thr = prctile(MaxNull, percL);
    end
%   figure;hist(MaxNull,50)

end