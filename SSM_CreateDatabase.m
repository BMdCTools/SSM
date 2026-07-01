function SSM_CreateDatabase()
% -------------------------------------------------------------------------
%          ____    ____    __  __ 
%         / ___|  / ___|  |  \/  |
%         \___ \  \___ \  | |\/| |   Single-Subject Morphometry Tool, v1.1
%          ___) | ___) |  | |  | |   - Control Database Creation Module -
%         |____/ |____/   |_|  |_|
% -------------------------------------------------------------------------
% University of Campinas, Neuroimaging Laboratory, 2026
%
% Redistribution  and  use  in  source  and  binary  forms, with  or  without
% modification, are permitted provided that the following conditions are met:
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
% CONTRACT,  STRICT LIABILITY, OR  TORT (INCLUDING NEGLIGENCE  OR  OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Copyright (c) 2026, Brunno Machado de Campos
% All rights reserved.
% 
% Brunno Machado de Campos
% brunno AT unicamp DOT br
% University of Campinas, 2026

clc;
fprintf('SSM DB Creation Module: %s\n', datetime);

ScreSize = get(0,'screensize');
ScreSize = ScreSize(3:end);

SSfactorX = 0.4;
SSfactorY = 0.6;

InipositX = (1-SSfactorX)/2;
InipositY = (1-SSfactorY)/2;

try 
    close('SSM - Create Control Database')
end

ScreSize = get(0,'screensize');
ScreSize = ScreSize(3:end);

SSfactorX = 0.4;
SSfactorY = 0.52; % Reduzido de 0.8 para 0.52 para eliminar o espaço sobressalente

InipositX = (1-SSfactorX)/2;
InipositY = (1-SSfactorY)/2;

try 
    close('SSM - Create Control Database')
end

MainFig = figure('Name','SSM - Create Control Database','NumberTitle','off','Color',[0.9 0.9 0.9],...
            'Position',[ScreSize(1)*InipositX ScreSize(2)*InipositY ScreSize(1)*SSfactorX ScreSize(2)*SSfactorY],...
            'MenuBar','none','Tag','SSM_DB_Main');

set(0, 'CurrentFigure', MainFig);

titleObj = uicontrol('Parent',MainFig,'Style','text','Fontweight','bold','Units','Normalized',...
        'Position',[0.1 0.93 0.8 0.05],'FontUnits','normalized','FontSize',0.6,...
        'ForegroundColor',[0.35 0.35 0.35],'String','SSM: Create Control Database',...
        'HorizontalAlignment','Center','BackgroundColor',[0.9 0.9 0.9],'Visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PANEL 1: Modality & Control Images Selection %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.hp1 = uipanel('Title','Database Input Modality','FontSize',10,...
    'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.005 0.52 0.992 0.39]);

% Modality 1 Radio
handles.ModRaw = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
    'normalized','Position',[0.05 0.83 0.5 0.045],'FontUnits','normalized',...
    'FontSize',0.5,'String','1 - Adding raw NIfTI files','BackgroundColor',[0.87 0.87 0.87],...
    'ForegroundColor',[0 0 0],'Visible','on','Value',1,'Callback',@ModRawf);

% Modality 2 Radio
handles.ModTissue = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
    'normalized','Position',[0.05 0.76 0.45 0.045],'FontUnits','normalized',...
    'FontSize',0.5,'String','2 - Adding CAT12 postprocessed maps','BackgroundColor',[0.87 0.87 0.87],...
    'ForegroundColor',[0 0 0],'Visible','on','Value',0,'Callback',@ModTissuef);

% Sub-options for Modality 2 (GM vs WM)
handles.ModTissueGM = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
    'normalized','Position',[0.52 0.76 0.2 0.04],'FontUnits','normalized',...
    'FontSize',0.55,'String','GM (mwp1)','BackgroundColor',[0.87 0.87 0.87],...
    'ForegroundColor',[0 0 0],'Visible','on','Enable','off','Value',1,'Callback',@ModTissueGMf);

handles.ModTissueWM = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
    'normalized','Position',[0.74 0.76 0.2 0.04],'FontUnits','normalized',...
    'FontSize',0.55,'String','WM (mwp2)','BackgroundColor',[0.87 0.87 0.87],...
    'ForegroundColor',[0 0 0],'Visible','on','Enable','off','Value',0,'Callback',@ModTissueWMf);

% Button to Add Images
handles.AddImages = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
    'normalized','Position',[0.02 0.67 0.32 0.055],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.42,'String','Select Control Images...','BackgroundColor',...
    [0.8 0.8 0.8],'Visible','on','Enable','on','Callback',@AddImagesf);

handles.TxtNumFiles = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','Position',[0.36 0.675 0.62 0.05],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.5,'String','No files selected.','BackgroundColor',...
    [1 1 1],'HorizontalAlignment','Left','Visible','on','Enable','on');

handles.AddOutDirB = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
    'normalized','Position',[0.02 0.6 0.32 0.055],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.42,'String','New Database Output Directory...','BackgroundColor',...
    [0.8 0.8 0.8],'Visible','on','Enable','on','Callback',@AddOutDirBf);

handles.TxtAddOutDir = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','Position',[0.36 0.605 0.62 0.05],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.5,'String','Not defined.','BackgroundColor',...
    [1 1 1],'HorizontalAlignment','Left','Visible','on','Enable','on');

handles.AddRepoDirB = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
    'normalized','Position',[0.02 0.53 0.32 0.055],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.42,'String','Define the CAT12 "report" Directory...','BackgroundColor',...
    [0.8 0.8 0.8],'Visible','on','Enable','off','Callback',@AddRepoDirBf);

handles.TxtAddRepoDir = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','Position',[0.36 0.535 0.62 0.05],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.5,'String','','BackgroundColor',...
    [1 1 1],'HorizontalAlignment','Left','Visible','on','Enable','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PANEL 2: Parameters & Covariates %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.hp2 = uipanel('Title','Parameters & Covariates','FontSize',10,...
    'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.005 0.19 0.992 0.30]);

% Gaussian Kernel FWHM
handles.LblKernel = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','Position',[0.02 0.4 0.45 0.04],'FontUnits','normalized',...
    'FontSize',0.55,'String','Gaussian Kernel FWHM:','BackgroundColor',[0.87 0.87 0.87],...
    'HorizontalAlignment','Left','ForegroundColor',[0 0 0]);

handles.EdtKernel = uicontrol('Parent',MainFig,'Style','edit','Units',...
    'normalized','Position',[0.205 0.405 0.125 0.045],'FontUnits','normalized',...
    'FontSize',0.55,'String','8','BackgroundColor',[1 1 1],...
    'ForegroundColor',[0 0 0],'HorizontalAlignment','Center');

% Age Vector Selection
handles.BtnAge = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
    'normalized','Position',[0.02 0.32 0.32 0.055],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.42,'String','Load Age Vector...','BackgroundColor',...
    [0.8 0.8 0.8],'Visible','on','Enable','off','Callback',@LoadAgef);

handles.TxtAgePath = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','Position',[0.36 0.32 0.62 0.045],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.5,'String','Select file (.txt, .csv, .xls/.xlsx)','BackgroundColor',...
    [1 1 1],'HorizontalAlignment','Left','Visible','on','Enable','on');

% Sex Vector Selection
handles.BtnSex = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
    'normalized','Position',[0.02 0.22 0.32 0.055],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.42,'String','Load Sex Vector...','BackgroundColor',...
    [0.8 0.8 0.8],'Visible','on','Enable','off','Callback',@LoadSexf);

handles.TxtSexPath = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','Position',[0.36 0.22 0.62 0.045],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.5,'String','Select file (0=Female, 1=Male)','BackgroundColor',...
    [1 1 1],'HorizontalAlignment','Left','Visible','on','Enable','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build Database Button %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.BtnBuild = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
    'normalized','Position',[0.3 0.05 0.4 0.08],'FontUnits','normalized',...
    'ForegroundColor',[0 0.5 0],'Fontweight','bold','FontSize',0.38,'String','Create Database Structure','BackgroundColor',...
    [0.8 0.8 0.8],'Visible','on','Enable','on','Callback',@BuildDBf);

handles.ParallelCB = 1;
handles.tissue = 'WG Matter';
guidata(MainFig, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function ModRawf(hObject, ~)
        handles = guidata(hObject); 
        if get(handles.ModRaw,'Value')
            handles.tissue = 'WG Matter';
            set(handles.ModRaw, 'Value', 1);
            set(handles.ModTissue, 'Value', 0);
            set(handles.ModTissueGM, 'Enable', 'off');
            set(handles.ModTissueWM, 'Enable', 'off');
            set(handles.AddRepoDirB, 'Enable', 'off');
            set(handles.TxtAddRepoDir, 'Enable', 'off');
        else
            handles.tissue = 'Grey Matter';
            set(handles.ModRaw, 'Value', 0);
            set(handles.ModTissue, 'Value', 1);
            set(handles.ModTissueGM, 'Value', 1);
            set(handles.ModTissueWM, 'Value', 0);
            set(handles.ModTissueGM, 'Enable', 'on');
            set(handles.ModTissueWM, 'Enable', 'on');
            set(handles.AddRepoDirB, 'Enable', 'on');
            set(handles.TxtAddRepoDir, 'Enable', 'on');
        end
        guidata(hObject, handles);
    end

    function ModTissuef(hObject, ~)
        handles = guidata(hObject); 
        if get(handles.ModTissue,'Value')
            
            handles.tissue = 'Grey Matter';
            set(handles.AddRepoDirB, 'Enable', 'on');
            set(handles.TxtAddRepoDir, 'Enable', 'on');
            set(handles.ModRaw, 'Value', 0);
            set(handles.ModTissue, 'Value', 1);
            set(handles.ModTissueGM, 'Value', 1);
            set(handles.ModTissueWM, 'Value', 0);
            set(handles.ModTissueGM, 'Enable', 'on');
            set(handles.ModTissueWM, 'Enable', 'on');
        else
            handles.tissue = 'WG Matter';
            set(handles.AddRepoDirB, 'Enable', 'off');
            set(handles.TxtAddRepoDir, 'Enable', 'off');
            set(handles.ModRaw, 'Value', 1);
            set(handles.ModTissue, 'Value', 0);
            set(handles.ModTissueGM, 'Enable', 'off');
            set(handles.ModTissueWM, 'Enable', 'off');
        end
        guidata(hObject, handles);
    end

    function ModTissueGMf(hObject, ~)
        handles = guidata(hObject); 
        if get(handles.ModTissueGM,'Value')
            handles.tissue = 'Grey Matter';
            set(handles.ModTissueGM, 'Value', 1);
            set(handles.ModTissueWM, 'Value', 0);
        else
            handles.tissue = 'White Matter';
            set(handles.ModTissueGM, 'Value', 0);
            set(handles.ModTissueWM, 'Value', 1);
        end
        guidata(hObject, handles);
    end

    function ModTissueWMf(hObject, ~)
        handles = guidata(hObject); 
        if get(handles.ModTissueWM,'Value')
            handles.tissue = 'White Matter';
            set(handles.ModTissueWM, 'Value', 1);
            set(handles.ModTissueGM, 'Value', 0);
        else
            handles.tissue = 'Grey Matter';
            set(handles.ModTissueWM, 'Value', 0);
            set(handles.ModTissueGM, 'Value', 1);
        end
        guidata(hObject, handles);
    end

    function AddImagesf(hObject, ~)
        handles = guidata(hObject);
        if get(handles.ModRaw, 'Value')
            [files, path] = uigetfile({'*.nii', 'NIfTI Images (*.nii)'}, ...
                'Select Control Images', 'MultiSelect', 'on');
        else
            if get(handles.ModTissueGM, 'Value')
                [files, path] = uigetfile({'mwp1*.nii', 'NIfTI Images (*.nii)'}, ...
                    'Select Control Images', 'MultiSelect', 'on');
            else
                [files, path] = uigetfile({'mwp2*.nii', 'NIfTI Images (*.nii)'}, ...
                    'Select Control Images', 'MultiSelect', 'on');
            end
        end
        
        if isequal(files, 0) || isequal(path, 0)
            return; % Usuário cancelou
        end
        
        if iscell(files)
            numFiles = length(files);
        else
            numFiles = 1;
        end
        
        set(handles.AddOutDirB,'Enable','on')
        set(handles.BtnAge,'Enable','on')
        set(handles.BtnSex,'Enable','on')
        set(handles.TxtNumFiles, 'String', sprintf(' %d file(s) successfully added.', numFiles));
        
        handles.ControlFiles = files;
        handles.ControlPath = path;
        handles.numFiles = numFiles;
        guidata(hObject, handles);
    end
    
    function AddRepoDirBf(hObject, ~)
        handles = guidata(hObject); 
        Repopath = uigetdir(handles.ControlPath,'Select the CAT12 resulting "report" directory');
        
        if isequal(Repopath, 0)
            return; 
        end
        
        set(handles.TxtAddRepoDir, 'String', Repopath);
        
        handles.Repopath = Repopath;
        guidata(hObject, handles);
    end

    function AddOutDirBf(hObject, ~)
        handles = guidata(hObject); 
        Outpath = uigetdir(handles.ControlPath,'Select the new database output directory');
        
        if isequal(Outpath, 0)
            return; % Usuário cancelou
        end
        
        set(handles.TxtAddOutDir, 'String', Outpath);
        
        handles.Outpath = Outpath;
        guidata(hObject, handles);
    end



    function LoadAgef(hObject, ~)
        handles = guidata(hObject); 
        [file, path] = uigetfile({'*.txt;*.csv;*.xls;*.xlsx', 'Vector Files (*.txt, *.csv, *.xls, *.xlsx)'}, ...
            'Select Age Vector File');
        if ~isequal(file,0)
            handles.AgeFile = fullfile(path, file);
            RAW = readmatrix(handles.AgeFile);
            for xi = 1:size(RAW,1)
                if ~isnan(RAW(xi,1))
                    AgeVet(xi,1) = RAW(xi,1);
                else
                    AgeVet(xi,1) = [];
                end
            end
            if ~isequal(numel(AgeVet),handles.numFiles)
                warndlg('Number of entries in the added file does not match the number of loaded images.', 'Attention')
            else
                set(handles.TxtAgePath, 'String', sprintf(' Loaded: %s', file));
            end
            handles.AgeVet = AgeVet;
            guidata(hObject, handles);
        end
        
    end

    function LoadSexf(hObject, ~)
        handles = guidata(hObject); 
        [file, path] = uigetfile({'*.txt;*.csv;*.xls;*.xlsx', 'Vector Files (*.txt, *.csv, *.xls, *.xlsx)'}, ...
            'Select Sex Vector File');
        if ~isequal(file,0)
            
            handles.SexFile = fullfile(path, file);
            RAW = readmatrix(handles.SexFile);
            for xi = 1:size(RAW,1)
                if ~isnan(RAW(xi,1))
                    GenVet(xi,1) = RAW(xi,1);
                else
                    GenVet(xi,1) = [];
                end
            end
            if ~isequal(numel(GenVet),handles.numFiles)
                warndlg('Number of entries in the added file does not match the number of loaded images.', 'Attention')
            else
                set(handles.TxtSexPath, 'String', sprintf(' Loaded: %s', file));
            end
            handles.GenVet = GenVet;
            guidata(hObject, handles);
        end
    end

    function BuildDBf(hObject, ~)
        handles = guidata(hObject); 
        
        if ~isfield(handles,'Outpath')
            warndlg('No output directory defined','Attention')
            return
        end
        
        if ~isfield(handles,'ControlFiles')
            warndlg('No files added','Attention')
            return
        end
        
        if ~isfield(handles,'AgeVet')
            warndlg('No Age file added','Attention')
            return
        end
        
        if ~isfield(handles,'GenVet')
            warndlg('No Age file added','Attention')
            return
        end
        
        fwhm = get(handles.EdtKernel,'String');

        disp('Running...')

        FWHM = [fwhm,'x',fwhm,'x',fwhm];

        Size1 = floor(handles.numFiles / 3);
        Size2 = Size1;
        Size3 = (handles.numFiles) - (Size1+Size2);
        
        exSt = nifti([handles.ControlPath handles.ControlFiles{1}]);
        FOV = exSt.dat.dim;
        
        SSdir2 = which('SSM');
        SSdir2 = SSdir2(1:end-5);
        ExclMask = nifti([SSdir2,'SSM_Mean_WpMd_Mask.nii']);
        MaskMat = ExclMask.dat(:,:,:);
        Gene_Ctr = handles.GenVet;
        Ida_Ctr = handles.AgeVet;
        OutDirF = [handles.Outpath,filesep,'DB'];
        
        mkdir(OutDirF)
        save([OutDirF,filesep,'Gene_Ctr.mat'],'Gene_Ctr','-v7.3')
        save([OutDirF,filesep,'Ida_Ctr.mat'],'Ida_Ctr','-v7.3')
        
        % After Smooth Thresholding:
        % This value will be stored with your new Reference Dataset, and used
        % further during SSM preprocessings, automatically
        Thresh = 0;

        switch handles.tissue
            case 'Grey Matter'
            %%%%%%%%%%%%%%%%
            %%% Grey Matter
            %%%%%%%%%%%%%%%%
                fprintf('Processing files\n')
                
                fprintf('- Estimating TIV: Case 0001 (000%%)');
                for k = 1:size(handles.ControlFiles,2)
                    fprintf('\b\b\b\b\b\b\b\b\b\b\b');
                    fprintf('%.4d (%.3d%%)',k,round(100*k/size(handles.ControlFiles,2)));

                    clear matlabbatch
                    matlabbatch{1}.spm.tools.cat.tools.calcvol.data_xml = {[handles.Repopath,filesep,'cat_',handles.ControlFiles{k}(5:end-4),'.xml']};
                    matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_TIV = 1;
                    matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_name = [handles.Repopath,filesep,handles.ControlFiles{k}(5:end-4),'_TIV.txt'];
                    SSM_run_batch(matlabbatch);

                    GTIV(k) = importdata([handles.Repopath,filesep,handles.ControlFiles{k}(5:end-4),'_TIV.txt']);
                end
                fprintf('\n');
                fprintf('- Done\n');

                DB_TIV = GTIV';
                save([OutDirF,filesep,'TIV_Ctr.mat'],'DB_TIV','-v7.3')
                
                fprintf('Running stage 1...\n')
                TivIdx = 1;
                SC_Tplate1 = zeros([FOV,Size1]);
                for i = 1:Size1

                    clear matlabbatch
                    matlabbatch{1}.spm.spatial.smooth.data = {[handles.ControlPath handles.ControlFiles{i}]};
                    matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{1}.spm.spatial.smooth.im = 0;
                    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                    SSM_run_batch(matlabbatch);

                    stru = nifti([handles.ControlPath,'s',handles.ControlFiles{i}]);
                    Mat = stru.dat(:,:,:);
                    Mat = Mat .* MaskMat;
                    SC_Tplate1(:,:,:,i) = Mat;
                    
                end
                
                findSep = strfind(FWHM,'x');
                SC_Tplate1 = single(SC_Tplate1);
                fprintf('Saving...\n')
                save([OutDirF,filesep,'SC_Ctr_DB1_FWHM' fwhm '.mat'],'SC_Tplate1','Thresh','-v7.3')
                clear SC_Tplate1
                
                fprintf('Running stage 2...\n')
                SC_Tplate2 = zeros([FOV,Size2]);
                for i = Size1 + 1:(Size1 + Size2)
                    clear matlabbatch
                    matlabbatch{1}.spm.spatial.smooth.data = {[handles.ControlPath,handles.ControlFiles{i}]};
                    matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{1}.spm.spatial.smooth.im = 0;
                    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                    SSM_run_batch(matlabbatch);

                    stru = nifti([handles.ControlPath,'s',handles.ControlFiles{i}]);
                    Mat = stru.dat(:,:,:);
                    Mat = Mat .* MaskMat;

                    SC_Tplate2(:,:,:,i - Size1) = Mat;
                end
                SC_Tplate2 = single(SC_Tplate2);
                fprintf('Saving...\n')
                save([OutDirF,filesep,'SC_Ctr_DB2_FWHM' fwhm '.mat'],'SC_Tplate2','Thresh','-v7.3')
                
                clear SC_Tplate2
                fprintf('Running stage 3...\n')
                SC_Tplate3 = zeros([FOV,Size3]);
                for i = (Size1 + Size2) + 1:handles.numFiles
                    clear matlabbatch
                    matlabbatch{1}.spm.spatial.smooth.data = {[handles.ControlPath,handles.ControlFiles{i}]};
                    matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{1}.spm.spatial.smooth.im = 0;
                    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                    SSM_run_batch(matlabbatch);

                    stru = nifti([handles.ControlPath,'s',handles.ControlFiles{i}]);
                    Mat = stru.dat(:,:,:);
                    Mat = Mat .* MaskMat;

                    SC_Tplate3(:,:,:,i - (Size1 + Size2)) = Mat;
                end
                SC_Tplate3 = single(SC_Tplate3);
                fprintf('Saving...\n')
                save([OutDirF,filesep,'SC_Ctr_DB3_FWHM' fwhm '.mat'],'SC_Tplate3','-v7.3')
                fprintf('Done!\n')
                clear SC_Tplate3

            case 'White Matter'
            %%%%%%%%%%%%%%%%
            %%% White Matter
            %%%%%%%%%%%%%%%%
                fprintf('Processing files\n')
                
                fprintf('- Estimating TIV: Case 0001 (000%%)');
                for k = 1:size(handles.ControlFiles,2)
                    fprintf('\b\b\b\b\b\b\b\b\b\b\b');
                    fprintf('%.4d (%.3d%%)',k,round(100*k/size(handles.ControlFiles,2)));

                    clear matlabbatch
                    matlabbatch{1}.spm.tools.cat.tools.calcvol.data_xml = {[handles.Repopath,filesep,'cat_',handles.ControlFiles{k}(5:end-4),'.xml']};
                    matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_TIV = 1;
                    matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_name = [handles.Repopath,filesep,handles.ControlFiles{k}(5:end-4),'_TIV.txt'];
                    SSM_run_batch(matlabbatch);

                    GTIV(k) = importdata([handles.Repopath,filesep,handles.ControlFiles{k}(5:end-4),'_TIV.txt']);
                end
                fprintf('\n');
                fprintf('- Done\n');

                DB_TIV = GTIV';
                save([OutDirF,filesep,'TIV_Ctr.mat'],'DB_TIV','-v7.3')
                
                fprintf('Running stage 1...\n')
                SB_Tplate1 = zeros([FOV,Size1]);
                for i = 1:Size1
                    clear matlabbatch
                    matlabbatch{1}.spm.spatial.smooth.data = {[handles.ControlPath,handles.ControlFiles{i}]};
                    matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{1}.spm.spatial.smooth.im = 0;
                    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                    SSM_run_batch(matlabbatch);

                    stru = nifti([handles.ControlPath,'s',handles.ControlFiles{i}]);
                    Mat = stru.dat(:,:,:);
                    Mat = Mat .* MaskMat;

                    SB_Tplate1(:,:,:,i) = Mat;
                end
                SB_Tplate1 = single(SB_Tplate1);
                fprintf('Saving...\n')
                save([OutDirF,filesep,'SB_Ctr_DB1_FWHM' fwhm '.mat'],'SB_Tplate1','-v7.3')
                
                fprintf('Running stage 2...\n')
                SB_Tplate2 = zeros([FOV,Size2]);
                for i = Size1 + 1:(Size1 + Size2)
                    clear matlabbatch
                    matlabbatch{1}.spm.spatial.smooth.data = {[handles.ControlPath,handles.ControlFiles{i}]};
                    matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{1}.spm.spatial.smooth.im = 0;
                    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                    SSM_run_batch(matlabbatch);

                    stru = nifti([handles.ControlPath,'s',handles.ControlFiles{i}]);
                    Mat = stru.dat(:,:,:);
                    Mat = Mat .* MaskMat;

                    SB_Tplate2(:,:,:,i-Size1) = Mat;
                end
                SB_Tplate2 = single(SB_Tplate2);
                fprintf('Saving...\n')
                save([OutDirF,filesep,'SB_Ctr_DB2_FWHM' fwhm '.mat'],'SB_Tplate2','-v7.3')
                
                fprintf('Running stage 3...\n')
                SB_Tplate3 = zeros([FOV,Size3]);
                for i = (Size1 + Size2) + 1:handles.numFiles
                    clear matlabbatch
                    matlabbatch{1}.spm.spatial.smooth.data = {[handles.ControlPath,handles.ControlFiles{i}]};
                    matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{1}.spm.spatial.smooth.im = 0;
                    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                    SSM_run_batch(matlabbatch);

                    stru = nifti([handles.ControlPath,'s',handles.ControlFiles{i}]);
                    Mat = stru.dat(:,:,:);
                    Mat = Mat .* MaskMat;

                    SB_Tplate3(:,:,:,i - (Size1 + Size2)) = Mat;
                end
                SB_Tplate3 = single(SB_Tplate3);
                save([OutDirF,filesep,'SB_Ctr_DB3_FWHM' fwhm '.mat'],'SB_Tplate3','-v7.3')
                fprintf('Done!\n')
            
                
            case 'WG Matter'
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Grey Matter AND White Matter (Raw file Added
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for k = 1:size(handles.ControlFiles,2)
                F2Run{k,1} = [handles.ControlPath,handles.ControlFiles{k}]; 
            end
            
            fprintf('- %s\n',datetime);
            fprintf('- Starting CAT12 Preprocessing\n');
            spmDIR = which('spm');
            clear matlabbatch
            matlabbatch{1}.spm.tools.cat.estwrite.data = F2Run;    
            matlabbatch{1}.spm.tools.cat.estwrite.data_wmh = {''};

            if handles.ParallelCB == 1 && size(F2Run,1) > 1
                fprintf('- Creating parallel process\n');
                handles.nParallel = 3;
                matlabbatch{1}.spm.tools.cat.estwrite.nproc = handles.nParallel;
            else
                matlabbatch{1}.spm.tools.cat.estwrite.nproc = 0;
            end

            matlabbatch{1}.spm.tools.cat.estwrite.useprior = '';
            matlabbatch{1}.spm.tools.cat.estwrite.opts.tpm = {[spmDIR(1:end-5) filesep 'tpm' filesep 'TPM.nii']};
            matlabbatch{1}.spm.tools.cat.estwrite.opts.affreg = 'mni';
            matlabbatch{1}.spm.tools.cat.estwrite.opts.biasstr = 0.75;
            matlabbatch{1}.spm.tools.cat.estwrite.opts.accstr = 0.75; 
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.restypes.fixed = [1 0.02];
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.setCOM = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.APP = 1070;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.affmod = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.NCstr = -Inf;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.LASstr = 0.5;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.LASmyostr = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.gcutstr = 2;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.cleanupstr = 0.5;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.BVCstr = 0.5;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.WMHC = 2;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.SLC = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.mrf = 1;
    %         matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.WMHtpm = {[spmDIR(1:end-5) filesep 'toolbox' filesep 'cat12' filesep 'templates_MNI152NLin2009cAsym' filesep 'cat_wmh_miccai2017.nii']};
    %         matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.BVtpm = {[spmDIR(1:end-5) filesep 'toolbox' filesep 'cat12' filesep 'templates_MNI152NLin2009cAsym' filesep 'cat_bloodvessels.nii']};
    %         matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.SLtpm = {[spmDIR(1:end-5) filesep 'toolbox' filesep 'cat12' filesep 'templates_MNI152NLin2009cAsym' filesep 'cat_strokelesions_ATLAS303.nii']};
    %         matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.regmethod.shooting.shootingtpm = {[spmDIR(1:end-5) filesep 'toolbox' filesep 'cat12' filesep 'templates_MNI152NLin2009cAsym' filesep 'Template_0_GS.nii']};
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.regmethod.shooting.regstr = 0.5;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.vox = 1.5;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.bb = 12;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.pbtres = 0.5;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.pbtmethod = 'pbtsimple';
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.SRP = 22;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.reduce_mesh = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.vdist = 2;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.scale_cortex = 0.7;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.add_parahipp = 0.1;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.close_parahipp = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.experimental = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.new_release = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.lazy = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.ignoreErrors = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.verb = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.print = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.output.BIDS.BIDSno = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.output.surface = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.surf_measures = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.neuromorphometrics = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.lpba40 = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.cobra = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.hammers = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.thalamus = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.thalamic_nuclei = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.suit = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.ibsr = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.aal3 = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.mori = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.anatomy3 = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.julichbrain = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.Tian_Subcortex_S4_7T = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.Schaefer2018_100Parcels_17Networks_order = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.Schaefer2018_200Parcels_17Networks_order = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.Schaefer2018_400Parcels_17Networks_order = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.Schaefer2018_600Parcels_17Networks_order = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.ownatlas = {''};
            matlabbatch{1}.spm.tools.cat.estwrite.output.GM.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.GM.warped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.GM.mod = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.output.GM.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.WM.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.WM.warped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.WM.mod = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.output.WM.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.CSF.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.CSF.warped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.CSF.mod = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.output.CSF.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ct.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ct.warped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.ct.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.pp.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.pp.warped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.pp.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.WMH.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.WMH.warped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.WMH.mod = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.WMH.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.SL.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.SL.warped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.SL.mod = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.SL.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.TPMC.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.TPMC.warped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.TPMC.mod = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.TPMC.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.atlas.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.label.native = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.output.label.warped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.label.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.labelnative = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.output.bias.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.bias.warped = 1;
            matlabbatch{1}.spm.tools.cat.estwrite.output.bias.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.las.native = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.las.warped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.las.dartel = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.jacobianwarped = 0;
            matlabbatch{1}.spm.tools.cat.estwrite.output.warps = [1 1];
            matlabbatch{1}.spm.tools.cat.estwrite.output.rmat = 0;

            cat12('expert'); % Cat12 recquires it to run in "expert mode"

            if size(F2Run,1) == 1 || handles.ParallelCB == 0
                fprintf('- %s\n',datetime);
                fprintf('- Running CAT12 preprocessings...\n');
            end

            h2 = findall(groot,'Type','figure'); % find cat12 windows
            fnames = get(h2, 'Tag');
            set(h2(1),'WindowState','minimized');
            set(h2(2),'WindowState','minimized');
            set(h2(3),'WindowState','minimized');

            DatStrT2 = datestr(now, 'yyyymmdd_HHMM');
    %         
            if size(F2Run,1) == 1 || handles.ParallelCB == 0
                SSM_run_batch(matlabbatch);
            else
                spm_jobman('run',matlabbatch) % executes cat12 with parallel jobs            
            end
            
            % All this needed only to safely close cat12 openned windows
            idx2close = [];
            for fcl = 1:size(fnames,1)
                if contains(fnames{fcl},'CAT') || contains(fnames{fcl},'Graphics') || contains(fnames{fcl},'Interactive')
                    idx2close = [idx2close,fcl];
                end
            end
            for delL = 1:numel(idx2close) 
                if ~ishandle(h2(idx2close(delL)))
                    idx2close(delL) = [];
                end
            end
            try
                close(h2(idx2close));
            end
            
            % As Cat12 parallel jobs runs in separately Matlab instances, this
            % instance will be free to continue even before the preprocessing
            % finish. The following while loop is necessary to wait for the
            % preprocessing end
            if handles.ParallelCB
                Allfiles = matlab.desktop.editor.getAll;
                pidT = dir(['catlog_main_',DatStrT2,'*.txt']);
                if isempty(pidT)
                    DatStrT2 = [DatStrT2(1:end-2),num2str(str2num(DatStrT2(end-2:end)) - 1)];
                    pidT = dir(['catlog_main_',DatStrT2,'*.txt']);
                end
                if isempty(pidT)
                    pidT = dir([pwd,'log',filesep,'catlog_main_',DatStrT2,'*.txt']);
                end
                % identifying new Matlab instances PID
                for ipd = 1:size(pidT,1)
                    lines = fileread(pidT(ipd).name);
                    posTini = strfind(lines,'MATLAB PID: ');
                    posTend = posTini + 11;
                    StrinPID = lines(posTini+11:posTini+18);
                    PIDNumb = isstrprop(StrinPID, 'digit');
                    PID(ipd) = str2num(StrinPID(PIDNumb));
                    arquivo = Allfiles.findEditor(pidT(ipd).name);
                    arquivo.close
                end

                fprintf('- Waiting for parallel process to finish...\n');
                fprintf('               <<***RUNNING***');
                Finished = 0;
                IxdAvoid = [];
                runL = 1;

                while Finished < size(pidT,1)
                    for ipd = 1:size(pidT,1)
                        if ~ismember(ipd,IxdAvoid)
                            lines = fileread(pidT(ipd).name);
                            if contains(lines,'CAT12 Segmentation job finished.')
                                pause(20);
                                Finished = Finished + 1;
                                % Cross-platform Process Termination
                                if ispc
                                    [~,~] = system(sprintf('taskkill /PID %d /F', PID(ipd))); 
                                else
                                    [~,~] = system(sprintf('kill -9 %d', PID(ipd)));
                                end
                                IxdAvoid = [IxdAvoid,ipd];
                            end
                        end
                    end

                    pause(5);

                    if iseven(runL)
                        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b<<###running###');
                    else
                        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b<<***RUNNING***');
                    end

                    runL = runL + 1;
                end
                fprintf('>>\n');
                fprintf('- Parallel process finished\n');
            else
    %             fprintf('- Waiting for parallel process to finish...\n');
            end
            
            pathF = [handles.ControlPath,'mri',filesep,];
            fprintf('- %s\n',datetime);
            fprintf('- Estimating TIV: Case 0001 (000%%)');
            for k = 1:size(handles.ControlFiles,2)
                fprintf('\b\b\b\b\b\b\b\b\b\b\b');
                fprintf('%.4d (%.3d%%)',k,round(100*k/size(handles.ControlFiles,2)));

                clear matlabbatch
                matlabbatch{1}.spm.tools.cat.tools.calcvol.data_xml = {[handles.ControlPath,'report',filesep,'cat_',handles.ControlFiles{k}(1:end-4),'.xml']};
                matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_TIV = 1;
                matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_name = [handles.ControlPath,'report',filesep,handles.ControlFiles{k}(1:end-4),'_TIV.txt'];
                SSM_run_batch(matlabbatch);
                
                GTIV(k) = importdata([handles.ControlPath,'report',filesep,handles.ControlFiles{k}(1:end-4),'_TIV.txt']);
                handles.ControlFilesGM{k} = ['mwp1',handles.ControlFiles{k}];
                handles.ControlFilesWM{k} = ['mwp2',handles.ControlFiles{k}];
            end
            fprintf('\n');
            fprintf('- Done\n');
            
            DB_TIV = GTIV';
            save([OutDirF,filesep,'TIV_Ctr.mat'],'DB_TIV','-v7.3')
            
            exSt = nifti([pathF,handles.ControlFilesGM{1}]);
            FOV = exSt.dat.dim;
            SC_Tplate1 = zeros([FOV,Size1]);

            for i = 1:Size1
                clear matlabbatch
                matlabbatch{1}.spm.spatial.smooth.data = {[pathF,handles.ControlFilesGM{i}]};
                matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                matlabbatch{1}.spm.spatial.smooth.im = 0;
                matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                SSM_run_batch(matlabbatch);

                stru = nifti([pathF,'s',handles.ControlFilesGM{i}]);
                Mat = stru.dat(:,:,:);
                Mat = Mat .* MaskMat;
                SC_Tplate1(:,:,:,i) = Mat;
            end

%             findSep = strfind(FWHM,'x');
            SC_Tplate1 = single(SC_Tplate1);
            save([OutDirF,filesep,'SC_Ctr_DB1_FWHM' fwhm '.mat'],'SC_Tplate1','-v7.3')
            disp('Running...')
            clear SC_Tplate1

            SC_Tplate2 = zeros([FOV,Size2]);
            for i = Size1 + 1:(Size1 + Size2)
                clear matlabbatch
                matlabbatch{1}.spm.spatial.smooth.data = {[pathF,handles.ControlFilesGM{i}]};
                matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                matlabbatch{1}.spm.spatial.smooth.im = 0;
                matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                SSM_run_batch(matlabbatch);

                stru = nifti([pathF,'s',handles.ControlFilesGM{i}]);
                Mat = stru.dat(:,:,:);
                Mat = Mat .* MaskMat;

                SC_Tplate2(:,:,:,i - Size1) = Mat;
            end
            SC_Tplate2 = single(SC_Tplate2);
            save([OutDirF,filesep,'SC_Ctr_DB2_FWHM' fwhm '.mat'],'SC_Tplate2','-v7.3')
            disp('Running...')
            clear SC_Tplate2

            SC_Tplate3 = zeros([FOV,Size3]);
            for i = (Size1 + Size2) + 1:handles.numFiles
                clear matlabbatch
                matlabbatch{1}.spm.spatial.smooth.data = {[pathF,handles.ControlFilesGM{i}]};
                matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                matlabbatch{1}.spm.spatial.smooth.im = 0;
                matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                SSM_run_batch(matlabbatch);

                stru = nifti([pathF,'s',handles.ControlFilesGM{i}]);
                Mat = stru.dat(:,:,:);
                Mat = Mat .* MaskMat;

                SC_Tplate3(:,:,:,i - (Size1 + Size2)) = Mat;
            end
            SC_Tplate3 = single(SC_Tplate3);
            save(['OutDirF,filesep,SC_Ctr_DB3_FWHM' fwhm '.mat'],'SC_Tplate3','-v7.3')
            disp('Done!')
            clear SC_Tplate3

        %%%%%%%%%%%%%%%%
        %%% White Matter
        %%%%%%%%%%%%%%%%
            SB_Tplate1 = zeros([FOV,Size1]);
            for i = 1:Size1
                clear matlabbatch
                matlabbatch{1}.spm.spatial.smooth.data = {[pathF,handles.ControlFilesWM{i}]};
                matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                matlabbatch{1}.spm.spatial.smooth.im = 0;
                matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                spm_jobman('run',matlabbatch)

                stru = nifti([pathF,'s',handles.ControlFilesWM{i}]);
                Mat = stru.dat(:,:,:);
                Mat = Mat .* MaskMat;

                SB_Tplate1(:,:,:,i) = Mat;
            end
            SB_Tplate1 = single(SB_Tplate1);
            save([OutDirF,filesep,'SB_Ctr_DB1_FWHM' fwhm '.mat'],'SB_Tplate1','-v7.3')
            disp('Running...')

                SB_Tplate2 = zeros([FOV,Size2]);
                for i = Size1 + 1:(Size1 + Size2)
                    clear matlabbatch
                    matlabbatch{1}.spm.spatial.smooth.data = {[pathF,handles.ControlFilesWM{i}]};
                    matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{1}.spm.spatial.smooth.im = 0;
                    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                    spm_jobman('run',matlabbatch)

                    stru = nifti([pathF,'s',handles.ControlFilesWM{i}]);
                    Mat = stru.dat(:,:,:);
                    Mat = Mat .* MaskMat;

                    SB_Tplate2(:,:,:,i-Size1) = Mat;
                end
                SB_Tplate2 = single(SB_Tplate2);
                save([OutDirF,filesep,'SB_Ctr_DB2_FWHM' fwhm '.mat'],'SB_Tplate2','-v7.3')
                disp('Running...')

                SB_Tplate3 = zeros([FOV,Size3]);
                for i = (Size1 + Size2) + 1:handles.numFiles
                    clear matlabbatch
                    matlabbatch{1}.spm.spatial.smooth.data = {[pathF,handles.ControlFilesWM{i}]};
                    matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(fwhm) str2num(fwhm) str2num(fwhm)];
                    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{1}.spm.spatial.smooth.im = 0;
                    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                    spm_jobman('run',matlabbatch)

                    stru = nifti([pathF,'s',handles.ControlFilesWM{i}]);
                    Mat = stru.dat(:,:,:);
                    Mat = Mat .* MaskMat;

                    SB_Tplate3(:,:,:,i - (Size1 + Size2)) = Mat;
                end
                SB_Tplate3 = single(SB_Tplate3);
                save([OutDirF,filesep,'SB_Ctr_DB3_FWHM' fwhm '.mat'],'SB_Tplate3','-v7.3')
                disp('Done!')
        end
        clear all
    end
end