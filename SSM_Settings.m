function SSM_Settings()
% -------------------------------------------------------------------------
%          ____    ____    __  __ 
%         / ___|  / ___|  |  \/  |
%         \___ \  \___ \  | |\/| |   Single-Subject Morphometry Tool, v1.1
%          ___) | ___) |  | |  | |   - Settings & Database Configuration -
%         |____/ |____/   |_|  |_|
% -------------------------------------------------------------------------
% University of Campinas, Neuroimaging Laboratory, 2026
%
% Redistribution  and  use  in  source  and  binary  forms, with  or  without
% modification, are permitted provided that the following conditions are met:
%       * Redistributions  of  source  code  must retain  the above copyright
%         notice,  this list  of conditions  and  the  following  disclaimer.
% 
% Brunno Machado de Campos
% brunno AT unicamp DOT br
% University of Campinas, 2026

clc;

fprintf('SSM Configuration Module: %s\n', datetime);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ssmDir = which('SSM');
ssmDir = ssmDir(1:end-5);
ConfigFile = fullfile(ssmDir, 'SSM_config.mat');

if exist(ConfigFile, 'file')
    fprintf('Loading existing configuration file...\n');
    load(ConfigFile);
    handles.RefDBPath   = RefDBPath;
    handles.DBDescrip   = DBDescrip;
    handles.nParallel   = nParallel;
    handles.nParallelPerm = nParallelPerm;
else
    fprintf('First run detected. Initializing default settings...\n');
    RefDBPath   = [ssmDir,'SSM_Enc_DB',filesep];
    
    if exist([RefDBPath,'Gene_Ctr.mat'])
        dbData = load([RefDBPath,'Gene_Ctr.mat']);
        DBDescrip   = dbData.Descrip;
        RefDBPath   = RefDBPath;
    else
        RefDBPath   = '';
        DBDescrip   = 'No Reference Database Found';
    end
    nParallel   = 3;
    nParallelPerm = 6;
    
    handles.RefDBPath   = RefDBPath;
    handles.DBDescrip   = DBDescrip;
    handles.nParallel   = nParallel;
    handles.nParallelPerm = nParallelPerm;
    
end

ScreSize = get(0,'screensize');
ScreSize = ScreSize(3:end);

SSfactorX = 0.4;
SSfactorY = 0.45; % Layout compacto focado nos parâmetros configurados

InipositX = (1-SSfactorX)/2;
InipositY = (1-SSfactorY)/2;

try 
    close('SSM - Settings & Reference Database')
end

MainFig3 = figure('Name','SSM - Settings & Reference Database','NumberTitle','off','Color',[0.9 0.9 0.9],...
            'Position',[ScreSize(1)*InipositX ScreSize(2)*InipositY ScreSize(1)*SSfactorX ScreSize(2)*SSfactorY],...
            'MenuBar','none','Tag','SSM_Settings_Main');

set(0, 'CurrentFigure', MainFig3);

titleObj = uicontrol('Parent',MainFig3,'Style','text','Fontweight','bold','Units','Normalized',...
        'Position',[0.1 0.91 0.8 0.06],'FontUnits','normalized','FontSize',0.55,...
        'ForegroundColor',[0.35 0.35 0.35],'String','SSM: Configuration & Environment Settings',...
        'HorizontalAlignment','Center','BackgroundColor',[0.9 0.9 0.9],'Visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PANEL 1: Reference Database Configuration %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.hp1 = uipanel('Title','Reference Database','FontSize',10,...
    'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.005 0.52 0.992 0.36]);

% Button to Change Folder
handles.BtnChangeFolder = uicontrol('Parent',MainFig3,'Style','pushbutton','Units',...
    'normalized','Position',[0.02 0.76 0.32 0.07],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.38,'String','Define Reference Database Folder...','BackgroundColor',...
    [0.8 0.8 0.8],'Visible','on','Enable','on','Callback',@ChangeFolderf);

% Text Box showing Current Reference DB Path
handles.TxtDBPath = uicontrol('Parent',MainFig3,'Style','text','Units',...
    'normalized','Position',[0.36 0.765 0.62 0.06],'FontUnits','normalized',...
    'ForegroundColor',[0 0 0],'FontSize',0.45,'String',handles.RefDBPath,'BackgroundColor',...
    [1 1 1],'HorizontalAlignment','Left','Visible','on','Enable','on');

% Label for Description
handles.LblDescrip = uicontrol('Parent',MainFig3,'Style','text','Units',...
    'normalized','Position',[0.02 0.60 0.18 0.06],'FontUnits','normalized',...
    'FontSize',0.45,'String','Database Description:','BackgroundColor',[0.87 0.87 0.87],...
    'HorizontalAlignment','Left','ForegroundColor',[0 0 0]);

% Text Box showing Database Description (Descrip)
handles.TxtDescrip = uicontrol('Parent',MainFig3,'Style','text','Units',...
    'normalized','Position',[0.205 0.56 0.775 0.1],'FontUnits','normalized',...
    'ForegroundColor',[0.4 0.4 0.4],'FontSize',0.3,'String',handles.DBDescrip,'BackgroundColor',...
    [1 1 1],'HorizontalAlignment','Left','Visible','on','Enable','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PANEL 2: Parallel Processing Settings %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.hp2 = uipanel('Title','Parallel Processing Settings','FontSize',10,...
    'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.005 0.18 0.992 0.30]);

% CAT12 Parallel Jobs
handles.LblParallel = uicontrol('Parent',MainFig3,'Style','text','Units',...
    'normalized','Position',[0.02 0.36 0.55 0.06],'FontUnits','normalized',...
    'FontSize',0.45,'String','Number of parallel jobs for CAT12 processing:','BackgroundColor',[0.87 0.87 0.87],...
    'HorizontalAlignment','Left','ForegroundColor',[0 0 0]);

handles.EdtParallel = uicontrol('Parent',MainFig3,'Style','edit','Units',...
    'normalized','Position',[0.4 0.365 0.15 0.07],'FontUnits','normalized',...
    'FontSize',0.50,'String',num2str(handles.nParallel),'BackgroundColor',[1 1 1],...
    'ForegroundColor',[0 0 0],'HorizontalAlignment','Center');

% Permutation Parallel Jobs
handles.LblParallelPerm = uicontrol('Parent',MainFig3,'Style','text','Units',...
    'normalized','Position',[0.02 0.24 0.55 0.06],'FontUnits','normalized',...
    'FontSize',0.45,'String','Dedicated cores in the permutation loop:','BackgroundColor',[0.87 0.87 0.87],...
    'HorizontalAlignment','Left','ForegroundColor',[0 0 0]);

handles.EdtParallelPerm = uicontrol('Parent',MainFig3,'Style','edit','Units',...
    'normalized','Position',[0.4 0.245 0.15 0.07],'FontUnits','normalized',...
    'FontSize',0.50,'String',num2str(handles.nParallelPerm),'BackgroundColor',[1 1 1],...
    'ForegroundColor',[0 0 0],'HorizontalAlignment','Center');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save & Apply Configuration Button %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.BtnSave = uicontrol('Parent',MainFig3,'Style','pushbutton','Units',...
    'normalized','Position',[0.3 0.04 0.4 0.09],'FontUnits','normalized',...
    'ForegroundColor',[0 0.4 0.8],'Fontweight','bold','FontSize',0.38,'String','Save Configuration','BackgroundColor',...
    [0.8 0.8 0.8],'Visible','on','Enable','on','Callback',@SaveConfigf);

% Salvando a estrutura handles na figura
guidata(MainFig3, handles);
uiwait(MainFig3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function ChangeFolderf(hObject, ~)
        h = guidata(hObject);
        chosenDir = uigetdir(h.RefDBPath, 'Select Reference Database Folder');
        if isequal(chosenDir, 0)
            return; 
        end
        nf = dir([chosenDir,'*Ctr_DB*_FWHM*']);
        if numel(nf) >= 3
            DBfiN = 1;
        end
        if DBfiN && exist([chosenDir,filesep,'Gene_Ctr.mat'],'file') && exist([chosenDir,filesep,'Ida_Ctr.mat'],'file') && exist([chosenDir,filesep,'TIV_Ctr.mat'],'file')
            aD = load([chosenDir,filesep,'Gene_Ctr.mat']);
            set(h.TxtDescrip, 'String', aD.DBDescrip);
            h.DBDescrip = aD.DBDescrip;
            h.RefDBPath = chosenDir;
            set(h.TxtDBPath, 'String', chosenDir);
        else
            warndlg('The defined folder does not contains database files', 'Attention');
            set(h.TxtDescrip, 'String', '');
        end
        guidata(hObject, h);
    end

    function SaveConfigf(hObject, ~)
        h = guidata(hObject);
        
        % Captura e valida os inputs numéricos dos Edit Boxes
        valParallel = str2double(get(h.EdtParallel, 'String'));
        valPerm     = str2double(get(h.EdtParallelPerm, 'String'));
        
        if isnan(valParallel) || valParallel <= 0 || isnan(valPerm) || valPerm <= 0
            warndlg('Please enter valid positive numbers for parallel jobs.', 'Attention');
            return;
        end
        
        % Atualiza a estrutura handles
        RefDBPath = h.RefDBPath;
        DBDescrip = h.DBDescrip;
        nParallel = round(valParallel);
        nParallelPerm = round(valPerm);
        
        % Salva no arquivo SSM_config.mat
        try
            save(ConfigFile,'RefDBPath','DBDescrip','nParallel','nParallelPerm');
            uiwait(msgbox('Configuration parameters saved successfully!', 'SSM'));
            delete(MainFig3);
        catch ME
            errordlg(sprintf('Failed to save configuration: %s', ME.message), 'Error');
        end
    end

end