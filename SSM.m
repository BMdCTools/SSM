function SSM
% -------------------------------------------------------------------------
%          ____   ____   __  __ 
%         / ___| / ___| |  \/  |
%         \___ \ \___ \ | |\/| |   Single-Subject Morphometry Tool, v1.1
%          ___) | ___) || |  | |
%         |____/ |____/ |_|  |_|
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
%

% Copyright (c) 2026, Brunno Machado de Campos
% All rights reserved.
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
% Brunno Machado de Campos
% brunno AT unicamp DOT br
% University of Campinas, 2026

clc;
fprintf('SSM: %s\n',datetime);
help('SSM');

InsT = ver;
catE = find(contains({InsT.Name}, 'Computational Anatomy Toolbox', 'IgnoreCase', true));
catEv = InsT(catE).Version;
spmE = find(contains({InsT.Name}, 'Statistical Parametric Mapping', 'IgnoreCase', true));
spmEv = InsT(spmE).Version;

fprintf('Third-Party Prerequisites for SSM:\n');
if ~isempty(spmE)
    fprintf(' - Statistical Parametric Mapping (SPM): Installed (v%s)\n',spmEv)
else
    fprintf(' - Statistical Parametric Mapping (SPM): Not installed or added to the Matlab path\n')
end
if ~isempty(catE)
    fprintf(' - Computational Anatomy Toolbox (CAT12): Installed (v%s)\n',catEv)
else
    fprintf(' - Computational Anatomy Toolbox (CAT12): Not installed or added to the Matlab path\n')
end
fprintf(' - ComBat Multi-Site Harmonization Tool: Installed (Adapted version for SSM)\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code defined INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of parallel jobs for CAT12 processing
handles.nParallel = 3;

% Number of cores dedicated in the permutation loop
% If Parallel Computing Toolbox is not available, this option has no effect
handles.nParallelPerm = 6;

% This boolean indicates whether the SSM standard reference dataset (1)
% or a user-defined reference dataset (0) is used.
% The SSM reference dataset is encoded due to ethical approval constraints.
% SSM provides a function to assist users in creating their own reference dataset if desired.
handles.Run_Encode_DB = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ATTENTON: AFTER CHANGING ANY OF THESE OPTIONS, YOU SHOULD START THE SSM AGAIN
% ATTENTON: AFTER CHANGING ANY OF THESE OPTIONS, YOU SHOULD START THE SSM AGAIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.year = '2026';
handles.MainVersion = '1';
handles.MinorVersion = '1';

ScreSize = get(0,'screensize');
ScreSize = ScreSize(3:end);

SSfactorX = 0.4;
SSfactorY = 0.8;

handles.ImgIn = 0;

InipositX = (1-SSfactorX)/2;
InipositY = (1-SSfactorY)/2;

handles.SSfactorX = SSfactorX;
handles.SSfactorY = SSfactorY;

try 
    close('Single-Subject Morphometry')
end

MainFig = figure('Name','Single-Subject Morphometry','NumberTitle','off','Color',[0.9 0.9 0.9],...
            'Position',[ScreSize(1)*InipositX ScreSize(2)*InipositY ScreSize(1)*SSfactorX ScreSize(2)*SSfactorY],...
            'MenuBar','none','Tag','SSM_Main');

set(0, 'CurrentFigure', MainFig);

title = uicontrol('Parent',MainFig,'Style','text','Fontweight','bold','Units','Normalized',...
        'Position',[0.25 0.945 0.8 0.05],'FontUnits','normalized','FontSize',0.6,...
        'ForegroundColor',[0.35 0.35 0.35],'String','Single-Subject Morphometry',...
        'HorizontalAlignment','Left','BackgroundColor',[0.9 0.9 0.9],'Visible','on');
        
%%%%%%%%%%%%%%%%%%%%%%%%
% Study modality Panel
%%%%%%%%%%%%%%%%%%%%%%%%
    handles.hp1 = uipanel('Title','Study modality','FontSize',10,...
    'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.005 0.898 0.992 0.055]);

    handles.GMa = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
    'normalized','Position',[0.05 0.905 0.2 0.02],'FontUnits',...
    'normalized','FontSize',0.8,'String','Gray Matter','BackgroundColor',...
    [0.87 0.87 0.87],'ForegroundColor',[0 0 0],'Visible','on','Enable','on','Value',1,...
    'Tooltip',{'Select to analyze gray matter atrophy and hypertrophy'},...
    'Callback',@GMaf);

    handles.WMa = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
    'normalized','Position',[0.35 0.905 0.2 0.02 ],'FontUnits',...
    'normalized','FontSize',0.8,'String','White Matter','BackgroundColor',...
    [0.87 0.87 0.87],'ForegroundColor',[0 0 0],'Visible','on','Enable','on',...
    'Tooltip',{'Select to analyze white matter atrophy and hypertrophy'},...
    'Callback',@WMaf);

    handles.FCD = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
    'normalized','Position',[0.65 0.905 0.3 0.02],'FontUnits',...
    'normalized','ForegroundColor',[0 0 0],'FontSize',0.8,...
    'String','Focal Cortical Dysplasia','BackgroundColor',...
    [0.87 0.87 0.87],'Visible','on','Enable','on',...
    'Tooltip',{'Select for focal cortical dysplasia reports'},...
    'Callback',@FCDf);

%%%%%%%%%%%%%%%%%%%%%%%%
% Case(s) Panel
%%%%%%%%%%%%%%%%%%%%%%%%
    handles.hp2 = uipanel('Title','Cases','FontSize',10,...
    'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.005 0.795 0.992 0.104]);

    handles.AddPat = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
    'normalized','Position',[0.02 0.84 0.2 0.031 ],'FontUnits',...
    'normalized','ForegroundColor',[0 0 0],'FontSize',0.5,'String','Add T1-WI(s)...','BackgroundColor',...
    [0.8 0.8 0.8],'Visible','on','Enable','on',...
    'Tooltip',{'Add T1-weighted images for the selected subject(s)'},...
    'Callback',@AddPatf);

    handles.AddPatitxt = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','Position',[0.23 0.842 0.35 0.026],'FontUnits',...
    'normalized','ForegroundColor',[0 0 0],'FontSize',0.61,'String','','BackgroundColor',...
    [1 1 1],'HorizontalAlignment','Left','Visible','on','Enable','on');

    handles.HarmCB = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
    'normalized','Position',[0.6 0.84 0.38 0.035],'FontUnits',...
    'normalized','ForegroundColor',[0 0 0],'FontSize',0.46,'String','Harmonize with the SSM ref. dataset','BackgroundColor',[0.87 0.87 0.87],...
    'tooltip',{'Enable data harmonization (requires at least 10 cases)'},...
    'Visible','on','Enable','off','BackgroundColor',[0.87 0.87 0.87],'Callback',@HarmCBf);

    handles.HarmCBTxt = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','Position',[0.6 0.805 0.38 0.035],'FontSize',9,...
    'HorizontalAlignment','left','String','',...
    'BackgroundColor',[0.87 0.87 0.87],'ForegroundColor',[0 0.7 0],...
    'Enable','on');

    handles.AddFlairTxt2 = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.02 0.801 0.15 0.025],'FontUnits',...
    'normalized','FontSize',0.6,'String','Include FLAIR: ','BackgroundColor',...
    [0.87 0.87 0.87],'Visible','on','Enable','off',...
    'tooltip',{'Add FLAIR images for the selected subject(s). Optional, but improves sensitivity'});

    handles.AddFlair = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.162 0.803 0.07 0.03],'FontUnits',...
    'normalized','FontSize',0.5,'String','Yes','BackgroundColor',...
    [0.87 0.87 0.87],'Visible','on','Enable','off',...
    'tooltip',{'Add FLAIR images for the selected subject(s). Optional, but improves sensitivity'},...
    'Callback',@AddFlairf);

    handles.AddFlairNo = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.238 0.803 0.07 0.03],'FontUnits',...
    'normalized','FontSize',0.5,'String','No','BackgroundColor',...
    [0.87 0.87 0.87],'Visible','on','Enable','off',...
    'tooltip',{'Add FLAIR images for the selected subject(s). Optional, but improves sensitivity'},...
    'Callback',@AddFlairNof);

    handles.AddFlairTxt = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.315 0.805 0.265 0.026],'FontUnits',...
    'normalized','FontSize',0.61,'HorizontalAlignment','Left',...
    'String','','BackgroundColor',...
    [1 1 1],'Visible','on','Enable','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3 Sample Information Panel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handles.hp3 = uipanel('Title','Sample Information','FontSize',10,...
    'BackgroundColor',[0.87 0.87 0.87],'ForegroundColor',[0 0 0],'Units',...
    'normalized','BorderType', 'line','Position',[0.005 0.67 0.992 0.126]);

    %%%%%%%%%%%%%%%%%%%%%%%%
    % 3.1 Single Case Panel
    %%%%%%%%%%%%%%%%%%%%%%%%
        handles.hp31 = uipanel('Title','Single Case','FontSize',9,...
        'BackgroundColor',[0.87 0.87 0.87],'ForegroundColor',[0 0 0],'Units',...
        'normalized','BorderType', 'line','Position',[0.025 0.67 0.33 0.105]);

        handles.text4 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','Position',[0.04 0.709 0.18 0.028],'FontUnits',...
        'normalized','ForegroundColor',[0 0 0],'FontSize',0.6,'HorizontalAlignment','Left',...
        'String','Patient age (ys):','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','off',...
        'tooltip',{'For single-case analysis, define the subject age to enable age covariates'});

        handles.SubjAge = uicontrol('Parent',MainFig,'Style','edit','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.212 0.712 0.08 0.028],'FontUnits',...
        'normalized','FontSize',0.6,'HorizontalAlignment','center',...
        'String','','BackgroundColor',...
        [1 1 1],'Visible','on','Enable','off',...
        'tooltip',{'For single-case analysis, define the subject age to enable age covariates'},...
        'Callback',@SubjAgef);
    
        handles.maleP = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.06 0.68 0.18 0.028],'FontUnits',...
        'normalized','FontSize',0.6,'String','Male','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','off','Value',0,...
        'tooltip',{'For single-case analysis, define the subject sex to enable sex covariates'},...
        'Callback',@malePf);

        handles.femP = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.19 0.68 0.12 0.028],'FontUnits',...
        'normalized','FontSize',0.6,'String','Female','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','off','Value',0,...
        'tooltip',{'For single-case analysis, define the subject sex to enable sex covariates'},...
        'Callback',@femPf);

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3.2 Multiple Cases Panel
    %%%%%%%%%%%%%%%%%%%%%%%%%%
        handles.hp32 = uipanel('Title','Multiple Cases','FontSize',9,...
        'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.338 0.67 0.64 0.105]);

        handles.SubjList = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.35 0.715 0.21 0.025 ],'FontUnits',...
        'normalized','FontSize',0.55,'String','Check Subject Order...','BackgroundColor',...
        [0.8 0.8 0.8],'Visible','on','Enable','off',...
        'tooltip',{'Displays the subject order after MATLAB-based alphabetical sorting'},...
        'Callback',@SubjListf);

        handles.AddAgeList = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.48 0.685 0.15 0.025],'FontUnits',...
        'normalized','FontSize',0.55,'String','Add Age List...','BackgroundColor',...
        [0.8 0.8 0.8],'Visible','on','Enable','off',...
        'tooltip',{'Load a text or CSV or *.xlsx file containing a vector of subject ages'},...
        'Callback',@AddAgeListf);

        handles.checkbox5 = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.635 0.685 0.05 0.025],'FontUnits',...
        'normalized','FontSize',0.8,'String','','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','inactive');

        handles.genList = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.69 0.685 0.15 0.025],'FontUnits',...
        'normalized','FontSize',0.55,'String','Add Sex List...','BackgroundColor',...
        [0.8 0.8 0.8],'Visible','on','Enable','off',...
        'tooltip',{'Load a text or CSV or *.xlsx file containing subject sex (0 = female, 1 = male)'},...
        'Callback',@genListf);

        handles.checkbox11 = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.845 0.685 0.05 0.025],'FontUnits',...
        'normalized','FontSize',0.8,'String','','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','inactive');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3.3 Reference dataset demography Panel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handles.hp33 = uipanel('Title','Ref. Dataset','FontSize',10,...
    'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.005 0.28 0.992 0.391]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3.3.1 Fixed Settings (one ref. dataset for all)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        handles.hp331 = uipanel('Title','Fixed Settings','FontSize',9,...
        'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.027 0.391 0.952 0.26]);

        handles.FixRan = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.006 0.631 0.026 0.021],'FontUnits',...
        'normalized','FontSize',0.7,'String','','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','on','Value',1,...
        'tooltip',{'Use a fixed reference dataset for all loaded cases'},...
        'Callback',@FixRanf);

        handles.AllCtrDB = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.34 0.599 0.6 0.025],'FontUnits',...
        'normalized','FontSize',0.6,'String','USE THE ENTIRE REF. DATASET','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','on','Value',1,...
        'tooltip',{'Use the entire reference dataset (male and female subjects, 18ï¿½64 years, n = 188)'},...
        'Callback',@AllCtrDBf);

        handles.RefreshAge = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.3 0.51-0.005 0.36 0.028],'FontUnits',...
        'normalized','FontSize',0.57,'String','Refresh Ref. Dataset Demography','BackgroundColor',...
        [0.8 0.8 0.8],'Visible','on','Enable','on',...
        'tooltip',{'Update reference dataset demographics after parameter changes'},...
        'Callback',@RefreshAgef);
    
        handles.RefChe = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.662 0.51-0.005 0.025 0.025],'FontUnits',...
        'normalized','FontSize',0.7,'String','','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','inactive','Value',0);

        handles.text8 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.17 0.473-0.005 0.19 0.03],'FontUnits',...
        'normalized','FontSize',0.55,'HorizontalAlignment','Left',...
        'String','Number of controls:','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','on');

        handles.nOfCtr = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.36 0.481-0.005 0.1 0.023],'FontUnits',...
        'normalized','FontSize',0.8,'HorizontalAlignment','Center',...
        'String','','BackgroundColor',...
        [1 1 1],'Visible','on','Enable','on');

        handles.text14 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.475 0.473-0.005 0.19 0.03],'FontUnits',...
        'normalized','FontSize',0.55,'HorizontalAlignment','Left',...
        'String','Average age/STD:','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','on');

        handles.avgAge = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.659 0.481-0.005 0.1 0.023],'FontUnits',...
        'normalized','FontSize',0.8,'HorizontalAlignment','Center',...
        'String','','BackgroundColor',...
        [1 1 1],'Visible','on','Enable','on');

        handles.text16 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.17 0.44-0.005 0.19 0.03],'FontUnits',...
        'normalized','FontSize',0.55,'HorizontalAlignment','Left',...
        'String','Final lower age:','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','on');

        handles.text17 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.36 0.45-0.005 0.1 0.023],'FontUnits',...
        'normalized','FontSize',0.8,'HorizontalAlignment','Center',...
        'String','','BackgroundColor',...
        [1 1 1],'Visible','on','Enable','on');

        handles.text20 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.475 0.44-0.005 0.19 0.03],'FontUnits',...
        'normalized','FontSize',0.55,'HorizontalAlignment','Left',...
        'String','Final higher age:','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','on');

        handles.text21 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.659 0.45-0.005 0.1 0.023],'FontUnits',...
        'normalized','FontSize',0.8,'HorizontalAlignment','Center',...
        'String','','BackgroundColor',...
        [1 1 1],'Visible','on','Enable','on');

        handles.text10 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.17 0.41-0.005 0.19 0.03],'FontUnits',...
        'normalized','FontSize',0.55,'HorizontalAlignment','Left',...
        'String','Number of males:','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','on');

        handles.nOfMale = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.36 0.42-0.005 0.1 0.023],'FontUnits',...
        'normalized','FontSize',0.8,'HorizontalAlignment','Center',...
        'String','','BackgroundColor',...
        [1 1 1],'Visible','on','Enable','on');

        handles.text12 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.475 0.41-0.005 0.19 0.03],'FontUnits',...
        'normalized','FontSize',0.55,'HorizontalAlignment','Left',...
        'String','Number of females:','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','on');

        handles.nOfFemale = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.659 0.42-0.005 0.1 0.023],'FontUnits',...
        'normalized','FontSize',0.8,'HorizontalAlignment','Center',...
        'String','','BackgroundColor',...
        [1 1 1],'Visible','on','Enable','on');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 3.3.1.1 Age Range Panel
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            handles.hp3311 = uipanel('Title','Age Range','FontSize',9,...
            'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.05 0.545-0.008 0.52 0.058]);
                                        
            handles.text6 = uicontrol('Parent',MainFig,'Style','text','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.1 0.55-0.01 0.15 0.028],'FontUnits',...
            'normalized','FontSize',0.6,'HorizontalAlignment','Left',...
            'String','Minimum age:','BackgroundColor',...
            [0.87 0.87 0.87],'Visible','on','Enable','off',...
            'tooltip',{'Define the minimum age of the reference controls'});

            handles.MinAge = uicontrol('Parent',MainFig,'Style','edit','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.24 0.555-0.01 0.06 0.026],'FontUnits',...
            'normalized','FontSize',0.6,'HorizontalAlignment','Left',...
            'String','','BackgroundColor',[1 1 1],...
            'tooltip',{'Define the minimum age of the reference controls'},...
            'Visible','on','Enable','off','Callback',@MinAgef);

            handles.text7 = uicontrol('Parent',MainFig,'Style','text','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.31 0.55-0.01 0.15 0.028],'FontUnits',...
            'normalized','FontSize',0.6,'HorizontalAlignment','center',...
            'String','Maximum age:','BackgroundColor',...
            [0.87 0.87 0.87],'Visible','on','Enable','off',...
            'tooltip',{'Define the maximum age of the reference controls'});

            handles.MaxAge = uicontrol('Parent',MainFig,'Style','edit','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.458 0.555-0.01 0.06 0.026],'FontUnits',...
            'normalized','FontSize',0.6,'HorizontalAlignment','center',...
            'String','','BackgroundColor',[1 1 1],...
            'tooltip',{'Define the maximum age of the reference controls'},...
            'Visible','on','Enable','off','Callback',@MaxAgef);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 3.3.1.2  Sex Criteria Panel
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
            handles.hp3312 = uipanel('Title','Sex Criteria','FontSize',9,...
            'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.557 0.545-0.008 0.395 0.058]);

            handles.males = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.65 0.555-0.013 0.13 0.028],'FontUnits',...
            'normalized','FontSize',0.6,'HorizontalAlignment','Left',...
            'String','Males','BackgroundColor',[0.87 0.87 0.87],...
            'tooltip',{'Include male subjects in the reference dataset'},...
            'Visible','on','Enable','off','Value',1,'Callback',@malesf);

            handles.females = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.75 0.555-0.013 0.13 0.028],'FontUnits',...
            'normalized','FontSize',0.6,'HorizontalAlignment','Left',...
            'String','Females','BackgroundColor',[0.87 0.87 0.87],...
            'tooltip',{'Include female subjects in the reference dataset'},...
            'Visible','on','Enable','off','Value',1,'Callback',@femalesf);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3.3.2 Individualized Settings Panel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        handles.hp332 = uipanel('Title','Individualized Settings','FontSize',9,...
        'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units','normalized',...
        'ForegroundColor',[0 0 0],'Position',[0.027 0.28 0.952 0.112]);
                                               
        handles.FloaRan = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.006 0.372 0.025 0.025],'FontUnits',...
        'normalized','FontSize',0.8,'String','','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','off','Value',0,...
        'tooltip',{'For multiple cases, create subject-specific reference datasets automatically'},...
        'Callback',@FloaRanf);

        handles.text25 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.06 0.334 0.25 0.028],'FontUnits',...
        'normalized','FontSize',0.6,'HorizontalAlignment','left',...
        'String','Relative +/- age (years):',...
        'Tooltip',{'Define the age range (+- years) centered on each subject'},...
        'BackgroundColor',[0.87 0.87 0.87],'Visible','on','Enable','off');

        handles.AgeRanEdit = uicontrol('Parent',MainFig,'Style','edit','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.3 0.337 0.08 0.028],'FontUnits',...
        'normalized','FontSize',0.6,'HorizontalAlignment','center',...
        'String','','BackgroundColor',[1 1 1],...
        'Tooltip',{'Define the age range (+- years) centered on each subject'},...
        'Visible','on','Enable','off','Callback',@AgeRanEditf);

        handles.MatchSex = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.395 0.32 0.24 0.028],'FontUnits',...
        'normalized','FontSize',0.55,'String','Same-sex controls only','BackgroundColor',...
        [0.87 0.87 0.87],'Visible','on','Enable','off','Value',0,...
        'Tooltip',{'Restrict reference dataset to subjects of the same sex (may reduce reference dataset size)'},...
        'Callback',@MatchSexf);
    
        handles.RRnCtrTxt1 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.06 0.297 0.187 0.028],'FontUnits',...
        'normalized','FontSize',0.6,'HorizontalAlignment','left',...
        'String','Ref. dataset size:',...
        'Tooltip',{'Define the age range (+- years) centered on each subject'},...
        'BackgroundColor',[0.87 0.87 0.87],'Visible','on','Enable','off');
    
        handles.RRnCtrTxt2 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.3 0.301 0.08 0.026],'FontUnits',...
        'normalized','FontSize',0.65,'HorizontalAlignment','center',...
        'String','','BackgroundColor',[1 1 1],...
        'Tooltip',{'Define the age range (+- years) centered on each subject'},...
        'Visible','on','Enable','on');


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 3.3.2.1 Filling dataset options Panel
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            handles.hp3321 = uipanel('Title','Ref. dataset: gap-filling options','FontSize',9,...
            'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.645 0.28 0.31 0.094]);

            handles.ConstSS = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.66 0.321 0.25 0.026],'FontUnits',...
            'normalized','FontSize',0.58,'String','Constant sample size','BackgroundColor',[0.87 0.87 0.87],...
            'Tooltip',{'Include additional controls outside the age range to maintain a constant reference dataset size across loaded cases'},...
            'Visible','on','Enable','off','Value',1,'Callback',@ConstSSf);

            handles.FollRule = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
            'normalized','ForegroundColor',[0 0 0],'Position',[0.66 0.295 0.25 0.026],'FontUnits',...
            'normalized','FontSize',0.58,'String','Follow the defined rules','BackgroundColor',[0.87 0.87 0.87],...
            'Tooltip',{'Strictly follow defined age and sex criteria, even if this results in a smaller reference dataset'},...
            'Visible','on','Enable','off','Value',0,'Callback',@FollRulef);

%%%%%%%%%%%%%%%%%%%%%%
% 3.4 Smoothing factor Panel
%%%%%%%%%%%%%%%%%%%%%%
    handles.hp34 = uipanel('Title','Smoothing kernel','FontSize',10,...
    'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.005 0.206 0.992 0.075]);

    handles.PopMenuSmoothK = uicontrol('Parent',MainFig,'Style','popupmenu','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.04 0.22 0.5 0.03],'FontUnits',...
    'normalized','FontSize',0.5,'String',...
    {'FWHE = 4 x 4 x 4 mm² (very light)',...
     'FWHE = 6 x 6 x 6 mm² (light)',...
     'FWHE = 8 x 8 x 8 mm² (medium)',...
     'FWHE = 10 x 10 x 10 mm² (restrictive)',...
     'FWHE = 12 x 12 x 12 mm² (very restrictive)'},'Value',3,...
    'BackgroundColor',[1 1 1],'Visible','on','Enable','on',...
    'Callback',@PopMenuSmoothKf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4 Statistics and Results Report Panel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handles.hp4 = uipanel('Title','Statistics and Results Report','FontSize',10,...
    'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.005 0.075 0.992 0.132]);

    %%%%%%%%%%%%%%%%%%%%%%
    % 4.1 Covariates Panel
    %%%%%%%%%%%%%%%%%%%%%%
        handles.hp41 = uipanel('Title','Covariates','FontSize',9,...
        'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.025 0.075 0.228 0.111]);

        handles.covAge = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.04 0.12 0.16 0.03],'FontUnits',...
        'normalized','FontSize',0.5,'HorizontalAlignment','Left',...
        'String','Age covariate','BackgroundColor',[0.87 0.87 0.87],...
        'Tooltip',{'Check to use age as a covariate in the analysis'},...
        'Visible','on','Enable','off','Callback',@covAgef);
        
        handles.checkbox4 = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.04 0.09 0.16 0.03],'FontUnits',...
        'normalized','FontSize',0.5,'HorizontalAlignment','Left',...
        'String','Sex covariate','BackgroundColor',[0.87 0.87 0.87],...
        'Tooltip',{'Check to use the sex as a covariate in the analysis'},...
        'Visible','on','Enable','off','Callback',@checkbox4f);

    %%%%%%%%%%%%%%%%%%%%%%
    % 4.2 Permutation test Panel
    %%%%%%%%%%%%%%%%%%%%%%
        handles.hp41 = uipanel('Title','Permutation Test','FontSize',9,...
        'BackgroundColor',[0.87 0.87 0.87],'BorderType', 'line','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.25 0.075 0.727 0.111]);
    
        handles.text28 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.26 0.119 0.29 0.03],'FontUnits',...
        'normalized','FontSize',0.5,'HorizontalAlignment','Left',...
        'String','Ref. dataset subsampling factor:',...
        'Tooltip',{'Subsampling factor applied to the selected reference dataset to increase permutation combinations for FWER estimation'},...
        'BackgroundColor',[0.87 0.87 0.87],'Visible','on','Enable','on');

        handles.SubFactEdit = uicontrol('Parent',MainFig,'Style','edit','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.545 0.124 0.06 0.028],'FontUnits',...
        'normalized','FontSize',0.5,'HorizontalAlignment','center',...
        'String','0.95','BackgroundColor',[1 1 1],...
        'Tooltip',{'Subsampling factor applied to the selected reference dataset to increase permutation combinations for FWER estimation'},...
        'Visible','on','Enable','off','Callback',@SubFactEditf);
    
        handles.text24 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.63 0.119 0.14 0.03],'FontUnits',...
        'normalized','FontSize',0.5,'HorizontalAlignment','Left',...
        'String','FWER alpha:',...
        'Tooltip',{'FWER significance level (?) for max-statistic correction'},...
        'BackgroundColor',[0.87 0.87 0.87],'Visible','on','Enable','on');

        handles.alphaL = uicontrol('Parent',MainFig,'Style','edit','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.75 0.124 0.06 0.028],'FontUnits',...
        'normalized','FontSize',0.5,'HorizontalAlignment','center',...
        'String','0.05','BackgroundColor',[1 1 1],...
        'Tooltip',{'FWER significance level (?) for max-statistic correction'},...
        'Visible','on','Enable','on','Callback',@alphaLf);    

        handles.text27 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.26 0.089 0.23 0.03],'FontUnits',...
        'normalized','FontSize',0.5,'HorizontalAlignment','Left',...
        'String','Number of perm. tests:',...
        'Tooltip',{'Number of permutations used for FWER threshold estimation. The maximum number of permutations depends on the size of the reference dataset and the subsampling factor.'},...
        'BackgroundColor',[0.87 0.87 0.87],'Visible','on','Enable','on');

        handles.nPermEdit = uicontrol('Parent',MainFig,'Style','edit','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.465 0.094 0.1 0.028],'FontUnits',...
        'normalized','FontSize',0.5,'HorizontalAlignment','center',...
        'String','1000','BackgroundColor',[1 1 1],...
        'Tooltip',{'Number of permutation tests for FWER threshold estimation. The maximum number of permutations depends on the size of the reference dataset and the subsampling factor.'},...
        'Visible','on','Enable','off','Callback',@nPermEditf);    
    
        handles.text23 = uicontrol('Parent',MainFig,'Style','text','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.6 0.089 0.16 0.03],'FontUnits',...
        'normalized','FontSize',0.5,'HorizontalAlignment','Left',...
        'String','Ext. Thresh. (vx):',...
        'Tooltip',{'Minimum cluster size (in voxels, 28-connectivity)'},...
        'BackgroundColor',[0.87 0.87 0.87],'Visible','on','Enable','on');

        handles.edit6 = uicontrol('Parent',MainFig,'Style','edit','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.75 0.094 0.06 0.028],'FontUnits',...
        'normalized','FontSize',0.5,'HorizontalAlignment','center',...
        'String','25','BackgroundColor',[1 1 1],...
        'Tooltip',{'Minimum cluster size (in voxels, 28-connectivity)'},...
        'Visible','on','Enable','on');    
    
        handles.radiobutton15 = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.83 0.124 0.13 0.03],'FontUnits',...
        'normalized','FontSize',0.55,'String','Blob-wise','BackgroundColor',[0.87 0.87 0.87],...
        'Tooltip',{'Alternative FWER threshold estimation method: median value within a 3D neighborhood (with sizes defined by the smoothing kernel) centered on the maximum significant voxel at each permutation.'},...
        'Visible','on','Enable','on','Value',1,'Callback',@radiobutton15f);

        handles.radiobutton16 = uicontrol('Parent',MainFig,'Style','radiobutton','Units',...
        'normalized','ForegroundColor',[0 0 0],'Position',[0.83 0.094 0.13 0.03],'FontUnits',...
        'normalized','FontSize',0.55,'String','Voxel-wise','BackgroundColor',[0.87 0.87 0.87],...
        'Tooltip',{'Voxel-wise FWER estimation using global maximum statistics across permutations'},...
        'Visible','on','Enable','on','Value',0,'Callback',@radiobutton16f);

%%%%%%%%%%%%%%%%%%%%%%
% Out Panels
%%%%%%%%%%%%%%%%%%%%%%
    handles.ParallelCB = uicontrol('Parent',MainFig,'Style','checkbox','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.01 0.04 0.3 0.03],'FontUnits',...
    'normalized','FontSize',0.55,'HorizontalAlignment','Left',...
    'String','Paralellize processings','BackgroundColor',[0.9 0.9 0.9],...
    'Tooltip',{'Option to paralellize the CAT12 and permutation processings'},...
    'Visible','on','Enable','on','Value',1,'Callback',@ParallelCBf);

    handles.runb = uicontrol('Parent',MainFig,'Style','pushbutton','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.41 0.019 0.2 0.04],'FontUnits',...
    'normalized','FontSize',0.6,'String','Run!','BackgroundColor',[0.87 0.87 0.87],...
    'Tooltip',{''},'Visible','on','Enable','off','Callback',@runbf);
    
    handles.status_txt = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','Position',[0.63 0.02 0.365 0.035],'FontUnits',...
    'normalized','FontSize',0.7,'String','','BackgroundColor',[0.9 0.9 0.9],...
    'Tooltip',{''},'HorizontalAlignment','Left','ForegroundColor',[1 0 0],...
    'Visible','on','Enable','on');

    handles.version_txt = uicontrol('Parent',MainFig,'Style','text','Units',...
    'normalized','ForegroundColor',[0 0 0],'Position',[0.01 0.005 0.55 0.011],'FontUnits',...
    'normalized','FontSize',0.9,'String',...
    ['SSM Version ',handles.MainVersion,'.',handles.MinorVersion,'. Campos BM, ',handles.year,' - University of Campinas'],'BackgroundColor',[0.9 0.9 0.9],...
    'Tooltip',{},'HorizontalAlignment','Left','ForegroundColor',[0 0 0],...
    'Visible','on','Enable','off');

    handles.GenVet = 0;
    handles.ImgOk = 0;
    handles.AgeOk = 0;
    handles.SexOk = 0;
    handles.MainFig = MainFig;
    
set(0, 'CurrentFigure', MainFig)
handles.output = MainFig;
guidata(MainFig, handles);
RefreshAgef(MainFig,[])
end

function AddPatf(hObject, eventdata)
handles = guidata(hObject);

    set(handles.text4,'Enable','off')
    set(handles.SubjAge,'Enable','off')
    set(handles.maleP,'Enable','off')
    set(handles.femP,'Enable','off')
    set(handles.SubjList,'Enable','off')
    set(handles.AddAgeList,'Enable','off')
    set(handles.genList,'Enable','off')
    set(handles.RefreshAge,'Enable','off')
    
    set(handles.checkbox5,'Value',0)
    set(handles.checkbox11,'Value',0)
    set(handles.HarmCB,'Value',0)
    set(handles.HarmCBTxt,'String','')
    set(handles.AddFlairNo,'Value',0)
    set(handles.AddFlair,'Value',0)
    set(handles.AddFlairTxt,'String','')
    set(handles.SubjAge,'String','')
    set(handles.covAge,'Value',0)
    set(handles.checkbox4  ,'Value',0)
    set(handles.covAge,'Enable','off')
    set(handles.checkbox4,'Enable','off')
    
    [filesub,pathsub] = uigetfile({'*.nii' ,'*.nii (NIfTI)'},...
    'Select all the patient files' ,'MultiSelect','on');

if ~iscell(filesub)
    if isequal(filesub,0)
        set(handles.AddPatitxt,'String','No images loaded!')
        set(handles.HarmCB,'Enable','off')
        set(handles.HarmCB,'Value',0)
        set(handles.ParallelCB,'Enable','off')
        set(handles.ParallelCB,'Value',0)
        handles.ImgIn = 0;
        if get(handles.FCD,'Value')
            set(handles.AddFlairTxt2,'Enable','off');
            set(handles.AddFlairNo,'Enable','off');
            set(handles.AddFlairNo,'Value',0);
            set(handles.AddFlairTxt,'Enable','off');
            set(handles.AddFlair,'Enable','off');
            set(handles.AddFlair,'Value',0);
        end
    else
        filesub = {filesub};
        nsubje = 1;
        set(handles.AddPatitxt,'String','1 image loaded')
        set(handles.text4,'Enable','on')
        set(handles.SubjAge,'Enable','on')
        set(handles.maleP,'Enable','on')
        set(handles.femP,'Enable','on')
        set(handles.SubjList,'Enable','off')
        set(handles.AddAgeList,'Enable','off')
        set(handles.genList,'Enable','off')
        set(handles.checkbox4,'Enable','off')
        set(handles.checkbox4,'Value',0)
        set(handles.RefreshAge,'Enable','on')
        set(handles.HarmCB,'Enable','on')
        set(handles.runb,'Enable','on')
        ExpType = 'Single';
        handles.AgeOk = 1;
        handles.ImgOk = 1;
        filesub = sort(filesub);
        set(handles.ParallelCB,'Enable','on')
        set(handles.ParallelCB,'Value',1)
        set(handles.FixRan,'Value',1)
        
        handles.output = hObject;
        guidata(hObject, handles);
        FixRanf(hObject, eventdata)
        handles.ImgIn = 1;
        if get(handles.FCD,'Value')
            set(handles.AddFlairTxt,'Enable','on');
            set(handles.AddFlairTxt2,'Enable','on');
            set(handles.AddFlairNo,'Enable','on');
            set(handles.AddFlair,'Enable','on');
        end
    end
else
    nsubje = size(filesub,2);
    set(handles.AddPatitxt,'String',[num2str(nsubje) ' images loaded'])
    set(handles.SubjList,'Enable','on')
    set(handles.AddAgeList,'Enable','on')
    set(handles.genList,'Enable','on')
    set(handles.text4,'Enable','off')
    set(handles.SubjAge,'Enable','off')
    set(handles.maleP,'Enable','off')
    set(handles.femP,'Enable','off')
    set(handles.maleP,'Value',0)
    set(handles.femP,'Value',0)
    set(handles.SubjAge,'String','')
    set(handles.checkbox4,'Enable','off')
    set(handles.checkbox4,'Value',0)
    set(handles.RefreshAge,'Enable','on')
    set(handles.HarmCB,'Enable','on')
    set(handles.ParallelCB,'Enable','on')
    set(handles.ParallelCB,'Value',1)
    set(handles.runb,'Enable','on')
    ExpType = 'Multi';
    handles.ImgOk = 1;
    handles.AgeOk = 0;
    filesub = sort(filesub);
    handles.ImgIn = 1;
    if get(handles.FCD,'Value')
        set(handles.AddFlairTxt,'Enable','on');
        set(handles.AddFlair,'Enable','on');
        set(handles.AddFlairTxt2,'Enable','on');
        set(handles.AddFlairNo,'Enable','on');
    end
end
handles.nsubje = nsubje;
handles.ExpType = ExpType;
handles.pathsub = pathsub; 
handles.filesub = filesub;

handles.output = hObject;
guidata(hObject, handles);
end

function GMaf(hObject, eventdata)
handles = guidata(hObject);

    if isequal(get(handles.GMa, 'Value'),1)
        set(handles.WMa,'Value',0)
        set(handles.FCD,'Value',0)
        set(handles.edit6,'String','25')
        set(handles.AddFlairTxt,'Enable','off');
        set(handles.AddFlairTxt,'String','');
        set(handles.AddFlair,'Enable','off');
        set(handles.AddFlair,'Value',0);
        set(handles.AddFlairTxt2,'Enable','off');
        set(handles.AddFlairNo,'Enable','off');
        set(handles.AddFlairNo,'Value',0);

    else
        set(handles.GMa,'Value',1)
    end
    
handles.output = hObject;
guidata(hObject, handles);
end

function WMaf(hObject, eventdata)
handles = guidata(hObject);

    if isequal(get(handles.WMa, 'Value'),1)
        set(handles.GMa,'Value',0)
        set(handles.FCD,'Value',0)
        set(handles.edit6,'String','25')
        set(handles.AddFlairTxt,'Enable','off');
        set(handles.AddFlairTxt,'String','');
        set(handles.AddFlair,'Enable','off');
        set(handles.AddFlair,'Value',0);
        set(handles.AddFlairTxt2,'Enable','off');
        set(handles.AddFlairNo,'Enable','off');
        set(handles.AddFlairNo,'Value',0);
    else
        set(handles.WMa,'Value',1)
    end
    
handles.output = hObject;
guidata(hObject, handles);
end

function FCDf(hObject, eventdata)
handles = guidata(hObject);

    if isequal(get(handles.FCD, 'Value'),1)
        set(handles.GMa,'Value',0)
        set(handles.WMa,'Value',0)
        set(handles.edit6,'String','25')
        if handles.ImgIn
            set(handles.AddFlairTxt,'Enable','on');
            set(handles.AddFlairTxt2,'Enable','on');
            set(handles.AddFlair,'Enable','on');
            set(handles.AddFlairNo,'Enable','on');
        end
    else
         set(handles.FCD,'Value',1)
    end
handles.output = hObject;
guidata(hObject, handles);
end

function runbf(hObject, eventdata)%, handles)
handles = guidata(hObject);
    fprintf('\n\n##############################################\n');
    fprintf('- Procedures started at: %s\n\n',datetime);
    DatStrT = datestr(now, 'yymmddHHMM');

    handles.OutDirQ = [handles.pathsub,filesep,'0_Settings_Quality_and_Harmon_',DatStrT];
    mkdir(handles.OutDirQ);

    imgRR = getframe(handles.MainFig);
    imwrite(imgRR.cdata, [handles.OutDirQ,filesep,'00_user-defined_settings.png']);
    pathsub = handles.pathsub;
    filesub = handles.filesub;

    SSdir21 = which('SSM');
    SSdir2 = [SSdir21(1:end-5) 'DB' filesep];

    fprintf('- Gunziping files: %s\n',datetime);
    if ~exist([SSdir21(1:end-5),'AAL_SSM_vx15.nii'],'file')
        gunzip([SSdir21(1:end-5),'AAL_SSM_vx15.nii.gz']);
    end
    if ~exist([SSdir21(1:end-5),'SSM_Mean_WpMd_Thres0.15.nii'],'file')
        gunzip([SSdir21(1:end-5),'SSM_Mean_WpMd_Thres0.15.nii.gz']);
    end
    if ~exist([SSdir21(1:end-5),'SSM_Mean_WpMd_Mask.nii'],'file')
        gunzip([SSdir21(1:end-5),'SSM_Mean_WpMd_Mask.nii.gz']);
    end
    if ~exist([SSdir21(1:end-5),'SSM_Mean_WpMd.nii'],'file')
        gunzip([SSdir21(1:end-5),'SSM_Mean_WpMd.nii.gz']);
    end
    if ~exist([SSdir21(1:end-5),'SSM_mean_DB_P3_vx15.nii'],'file')
        gunzip([SSdir21(1:end-5),'SSM_mean_DB_P3_vx15.nii.gz']);
    end
    if ~exist([SSdir21(1:end-5),'SSM_mean_DB_P2_vx15.nii'],'file')
        gunzip([SSdir21(1:end-5),'SSM_mean_DB_P2_vx15.nii.gz']);
    end
    if ~exist([SSdir21(1:end-5),'SSM_mean_DB_P1_vx15.nii'],'file')
        gunzip([SSdir21(1:end-5),'SSM_mean_DB_P1_vx15.nii.gz']);
    end
    if ~exist([SSdir21(1:end-5),'SSM_FinalExclusionAreas_GM.nii'],'file')
        gunzip([SSdir21(1:end-5),'SSM_FinalExclusionAreas_GM.nii.gz']);
    end
    if ~exist([SSdir21(1:end-5),'SSM_FinalExclusionAreas_FCD.nii'],'file')
        gunzip([SSdir21(1:end-5),'SSM_FinalExclusionAreas_FCD.nii.gz']);
    end
    if ~exist([SSdir21(1:end-5),'SSM_DimTmpl.nii'],'file')
        gunzip([SSdir21(1:end-5),'SSM_DimTmpl.nii.gz']);
    end
    fprintf('- Done: %s\n',datetime);

    try
        ExpType = handles.ExpType;
    end
    try
        SelectVet = handles.SelectVet;
    end
    try
        GenVet = handles.GenVet;
    catch
        GenVet = [];
    end
    try
        AgeVet = handles.AgeVet;
    catch
        AgeVet = [];
    end
    
    if isequal(handles.ExpType,'Single')
        if get(handles.maleP,'Value')
            handles.GenVet = 1;
        else
            handles.GenVet = 0;
        end
        handles.AgeVet = str2num(get(handles.SubjAge,'String'));
    end
    
    set(handles.status_txt,'String','Running...');
    drawnow

    fprintf('- Starting some verifications...\n');

    switch get(handles.PopMenuSmoothK,'Value')
        case 1
            FWHMv = '4'; % the options are 4, 6, 8, 10 or 12;
        case 2
            FWHMv = '6';
        case 3
            FWHMv = '8';
        case 4
            FWHMv = '10';
        case 5
            FWHMv = '12';
    end

    if get(handles.GMa,'Value'); tissue = 'GM'; end
    if get(handles.WMa,'Value'); tissue = 'WM'; end
    if get(handles.FCD,'Value'); tissue = 'FCD'; end

    TextF = tissue;

    if get(handles.FixRan,'Value')
        fprintf('- Checking statistical conditions recquired\n');
        % If Fixed Range (one database for ALL SUBJECTS or in the case of a 
        % single subject included), the ranges and options for age and sex are
        % stored. In this case the possible harmonization step and regressions
        % will be performed with this very specific DATABASE

        if get(handles.AllCtrDB,'Value')
            MinAge = get(handles.text17,'String');
            MaxAge = get(handles.text21,'String');
        else
            MinAge = get(handles.MinAge,'String');
            MaxAge = get(handles.MaxAge,'String');
        end

        if get(handles.males,'Value'); SexM = 'M'; else SexM = ''; end
        if get(handles.females,'Value'); SexF = 'F'; else SexF = ''; end
        if get(handles.covAge,'Value'); AgeR = 'RegAge'; else AgeR = ''; end
        if get(handles.checkbox4,'Value'); SexR = 'RegSex'; else SexR = ''; end

        fwheU = FWHMv;
        CtrSub = get(handles.SubFactEdit,'String');
        nTests = get(handles.nPermEdit,'String');
        FWERu = get(handles.alphaL,'String');
        ExtTu = get(handles.edit6,'String');

        if get(handles.radiobutton15,'Value'); MaxTy = 'Blob'; else MaxTy = 'Vox'; end

        TextF = [TextF,'_',MinAge,'-',MaxAge,'_',SexM,'-',SexF,'_',AgeR,'-',SexR,'_',fwheU,'_',CtrSub,'_',nTests,'_',FWERu,'_',MaxTy];

        if exist([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'file')
            ThreshPrev = importdata([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt']);
            if isempty(ThreshPrev)
                ThreshPrev = [];
                PrevThresh = 0;
                fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                fprintf('- A new permutation loop will be recquired\n');
            else
                PrevThresh = 1;
                fprintf('- Previousy estimated and stored FWER threshold: %.1f\n',ThreshPrev);
            end
        else
            fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
            PrevThresh = 0;
            fprintf('- A new permutation loop will be recquired\n');
        end

        load([SSdir2 'Gene_Ctr.mat']);
        load([SSdir2 'Ida_Ctr.mat']);
        load([SSdir2 'TIV_Ctr.mat']);
    %     load([SSdir2 filesep 'SurfPara_Ctr.mat']);

        VetGenF = Gene_Ctr;
        AllAGEs = Ida_Ctr;
        DBTIV = DB_TIV;
        DBTIV(SelectVet == 0) = [];

    else
        fprintf('- Checking statistical conditions recquired\n');
        fprintf('- For "Relative Range" studies this condition is verified latter\n');
        % If Floating range (relative range option), the whole DB is processed
        % until the final patient loop. Possible regressions or harmonization
        % are performed with the whole DATABASE and not with the subject
        % specific final DATABASE subset. The permutation loop, for estimation
        % of the threshold, on the other hand, will be done with the subject
        % specific DATABASE

        SSdir2 = which('SSM');
        SSdir2 = [SSdir2(1:end-5) 'DB' filesep];

        load([SSdir2 'Gene_Ctr.mat']);
        load([SSdir2 'Ida_Ctr.mat']);
        load([SSdir2 'TIV_Ctr.mat']);
    %     load([SSdir2 filesep 'SurfPara_Ctr.mat']);

        SelectVet = ones(size(Gene_Ctr,1),1);
        VetGenF = Gene_Ctr;
        AllAGEs = Ida_Ctr;
        DBTIV = DB_TIV;

        if get(handles.covAge,'Value'); AgeR = 'RegAge'; else AgeR = ''; end
        if get(handles.checkbox4,'Value'); SexR = 'RegSex'; else SexR = ''; end

        fwheU = FWHMv;
        CtrSub = get(handles.SubFactEdit,'String');
        nTests = get(handles.nPermEdit,'String');
        FWERu = get(handles.alphaL,'String');
        ExtTu = get(handles.edit6,'String');

        if get(handles.radiobutton15,'Value'); MaxTy = 'Blob'; else MaxTy = 'Vox'; end
    end

    fprintf('- Loading Database (It is a heavy process)...');
    fprintf('.');

    Verif_Covar_Gender = get(handles.checkbox4,'Value');
    Verif_Covar_Age = get(handles.covAge,'Value');
    fprintf('.');


        %%%%%%%%%%%%%%%%%%%%%%%%%%% Conditions to load template variable
        if isequal(get(handles.GMa,'Value'),1)
            direi = which('SSM');
            direi = [direi(1:end-5) 'DB' filesep];
            % Loading GM DATABASE
            load([direi 'SC_Ctr_DB1_FWHM' FWHMv '.mat'])
            fprintf('..');
            load([direi 'SC_Ctr_DB2_FWHM' FWHMv '.mat'])
            fprintf('..');
            load([direi 'SC_Ctr_DB3_FWHM' FWHMv '.mat'])
            fprintf('- Done')
            fprintf('\n')

            if get(handles.FixRan,'Value')
                SC_Cat_Tmp = cat(4,SC_Tplate1,SC_Tplate2,SC_Tplate3);
                xlo=1;
                fprintf('- Selecting Defined Controls\n')
                for j = 1:size(SC_Cat_Tmp,4)
                    if isequal(SelectVet(j),1)
                        tpt4D_GM(:,:,:,xlo) = SC_Cat_Tmp(:,:,:,j);
                        xlo = xlo + 1;
                    end
                end
                tpt4D_GM = single(tpt4D_GM);

                clear SB_Cat_Tmp SC_Cat_Tmp SC_Tplate1 SC_Tplate2 SC_Tplate3 SB_Tplate1 SB_Tplate2 SB_Tplate3
                if get(handles.covAge,'Value')
                    Age_Covar = AllAGEs;
                    Age_Covar(SelectVet == 0) = [];
                else
                    Age_Covar = 0;
                end

                if get(handles.checkbox4,'Value')
                    Gen_Covar = VetGenF;
                    Gen_Covar(SelectVet == 0) = [];
                else
                    Gen_Covar = 0;
                end
                if get(handles.radiobutton15,'Value')
                    fprintf('- Blob-wise FWER Estimation -\n');
                else
                    fprintf('- Voxel-wise FWER Estimation -\n');
                end
                fprintf('  * As the controls dataset is fixed, this step will be performed once\n');
                fprintf('    and the statistical threshold found will be considered for all \n');
                fprintf('    testing images.\n');

                fprintf('- Done');
                fprintf('\n');

            else
                SC_Cat_Tmp = cat(4,SC_Tplate1,SC_Tplate2,SC_Tplate3);
                SC_Cat_Tmp = single(SC_Cat_Tmp);

                if get(handles.radiobutton15,'Value')
                    fprintf('- Blob-wise FWER Estimation -\n');
                else
                    fprintf('- Voxel-wise FWER Estimation -\n');
                end
                fprintf('  * As the controls dataset is variable (subject-specific),\n');
                fprintf('    this step will be performed individually latter\n'); 
                fprintf('    (if not previouly estimated) and the statistical\n');
                fprintf('    threshold found will be considered also individually.\n');

                fprintf('- Done');
                fprintf('\n');

                FWER_thrIn = [];
                clear SC_Tplate1 SC_Tplate2 SC_Tplate3 SB_Tplate1 SB_Tplate2 SB_Tplate3
            end
        end

        if isequal(get(handles.WMa,'Value'),1)
            direi = which('SSM');
            direi = [direi(1:end-5) 'DB' filesep];
            % Loading WM DATABASE
            load([direi 'SB_Ctr_DB1_FWHM' FWHMv '.mat'])
            fprintf('..');
            load([direi 'SB_Ctr_DB2_FWHM' FWHMv '.mat'])
            fprintf('..');
            load([direi 'SB_Ctr_DB3_FWHM' FWHMv '.mat'])
            fprintf('..');
            fprintf('- Done')
            fprintf('\n')

            if get(handles.FixRan,'Value')
                SB_Cat_Tmp = cat(4,SB_Tplate1,SB_Tplate2,SB_Tplate3);
                xlo=1;
                for j = 1:size(SB_Cat_Tmp,4)
                    if isequal(SelectVet(j),1)
                        tpt4D_WM(:,:,:,xlo) = SB_Cat_Tmp(:,:,:,j);
                        xlo = xlo + 1;
                    end
                end
                tpt4D_WM = single(tpt4D_WM);

                clear SB_Cat_Tmp SC_Cat_Tmp SC_Tplate1 SC_Tplate2 SC_Tplate3 SB_Tplate1 SB_Tplate2 SB_Tplate3
                if get(handles.covAge,'Value')
                    Age_Covar = AllAGEs;
                    Age_Covar(SelectVet == 0) = [];
                else
                    Age_Covar = 0;
                end

                if get(handles.checkbox4,'Value')
                    Gen_Covar = VetGenF;
                    Gen_Covar(SelectVet == 0) = [];
                else
                    Gen_Covar = 0;
                end
                if get(handles.radiobutton15,'Value')
                    fprintf('- Blob-wise FWER Estimation -\n');
                else
                    fprintf('- Voxel-wise FWER Estimation -\n');
                end
                fprintf('  * As the controls dataset is fixed, this step will be performed once\n');
                fprintf('    and the statistical threshold found will be considered for all \n');
                fprintf('    testing images.\n');

                fprintf('- Done');
                fprintf('\n');

            else
                SB_Cat_Tmp = cat(4,SB_Tplate1,SB_Tplate2,SB_Tplate3);
                SB_Cat_Tmp = single(SB_Cat_Tmp);

                if get(handles.radiobutton15,'Value')
                    fprintf('- Blob-wise FWER Estimation -\n');
                else
                    fprintf('- Voxel-wise FWER Estimation -\n');
                end
                fprintf('  * As the controls dataset is variable (subject-specific),\n');
                fprintf('    this step will be performed individually latter\n'); 
                fprintf('    (if not previouly estimated) and the statistical\n');
                fprintf('    threshold found will be considered also individually.\n');

                fprintf('- Done');
                fprintf('\n');

                FWER_thrIn = [];
                clear SC_Tplate1 SC_Tplate2 SC_Tplate3 SB_Tplate1 SB_Tplate2 SB_Tplate3
            end
        end

        % For Focal Cortical Dysplasia Study
        if isequal(get(handles.FCD,'Value'),1)

            direi = which('SSM');
            direi = [direi(1:end-5) 'DB' filesep];
            % Loading GM DATABASE
            load([direi 'SC_Ctr_DB1_FWHM' FWHMv '.mat'])
            fprintf('..');
            load([direi 'SC_Ctr_DB2_FWHM' FWHMv '.mat'])
            fprintf('..');
            load([direi 'SC_Ctr_DB3_FWHM' FWHMv '.mat'])
            fprintf('..');

            % Loading WM DATABASE
            load([direi 'SB_Ctr_DB1_FWHM' FWHMv '.mat'])
            fprintf('..');
            load([direi 'SB_Ctr_DB2_FWHM' FWHMv '.mat'])
            fprintf('..');
            load([direi 'SB_Ctr_DB3_FWHM' FWHMv '.mat'])
            fprintf('..');
            fprintf('- Done')
            fprintf('\n')

            if get(handles.FixRan,'Value')
                SC_Cat_Tmp = cat(4,SC_Tplate1,SC_Tplate2,SC_Tplate3);
                xlo=1;
                fprintf('- Selecting Defined Controls\n')
                for j = 1:size(SC_Cat_Tmp,4)
                    if isequal(SelectVet(j),1)
                        tpt4D_GM(:,:,:,xlo) = SC_Cat_Tmp(:,:,:,j);
                        xlo = xlo + 1;
                    end
                end
                tpt4D_GM = single(tpt4D_GM);

                SB_Cat_Tmp = cat(4,SB_Tplate1,SB_Tplate2,SB_Tplate3);
                xlo=1;
                for j = 1:size(SB_Cat_Tmp,4)
                    if isequal(SelectVet(j),1)
                        tpt4D_WM(:,:,:,xlo) = SB_Cat_Tmp(:,:,:,j);
                        xlo = xlo + 1;
                    end
                end
                tpt4D_WM = single(tpt4D_WM);

                clear SB_Cat_Tmp SC_Cat_Tmp SC_Tplate1 SC_Tplate2 SC_Tplate3 SB_Tplate1 SB_Tplate2 SB_Tplate3
                if get(handles.covAge,'Value')
                    Age_Covar = AllAGEs;
                    Age_Covar(SelectVet == 0) = [];
                else
                    Age_Covar = 0;
                end

                if get(handles.checkbox4,'Value')
                    Gen_Covar = VetGenF;
                    Gen_Covar(SelectVet == 0) = [];
                else
                    Gen_Covar = 0;
                end
                if get(handles.radiobutton15,'Value')
                    fprintf('- Blob-wise FWER Estimation -\n');
                else
                    fprintf('- Voxel-wise FWER Estimation -\n');
                end
                fprintf('  * As the controls dataset is fixed, this step will be performed once\n');
                fprintf('    and the statistical threshold found will be considered for all \n');
                fprintf('    testing images.\n');

                fprintf('- Done');
                fprintf('\n');

            else
                SC_Cat_Tmp = cat(4,SC_Tplate1,SC_Tplate2,SC_Tplate3);
                SB_Cat_Tmp = cat(4,SB_Tplate1,SB_Tplate2,SB_Tplate3);

                SC_Cat_Tmp = single(SC_Cat_Tmp);
                SB_Cat_Tmp = single(SB_Cat_Tmp);
                if get(handles.radiobutton15,'Value')
                    fprintf('- Blob-wise FWER Estimation -\n');
                else
                    fprintf('- Voxel-wise FWER Estimation -\n');
                end
                fprintf('  * As the controls dataset is variable (subject-specific),\n');
                fprintf('    this step will be performed individually latter\n'); 
                fprintf('    (if not previouly estimated) and the statistical\n');
                fprintf('    threshold found will be considered also individually.\n');

                fprintf('- Done');
                fprintf('\n');

                FWER_thrIn = [];
                clear SC_Tplate1 SC_Tplate2 SC_Tplate3 SB_Tplate1 SB_Tplate2 SB_Tplate3
            end
            fprintf('- Done\n')
        end

    %% CAT12 Preproc
    spm_jobman('initcfg');

    F2Run = {}; %subset of images that were not preprocessed
    kIdx = 1;
    fprintf('- %s\n',datetime);
    fprintf('- Verifying recquirements and performing basic preprocessing: Case 0001 (000%%)');
    for k = 1:size(filesub,2)
        
        if numel(filesub{k}(1:end-4)) > 30
            pathF = [pathsub filesub{k}(1:30) filesep];
        else
            pathF = [pathsub filesub{k}(1:end-4) filesep];
        end
        
        if ~exist(pathF,'dir')
            mkdir(pathF);
        end

        if ~exist([pathF,filesub{k}],'file')
            copyfile([pathsub,filesub{k}],[pathF,filesub{k}])
        end

        if ~exist([pathF,'mri',filesep,'mwp1',filesub{k}],'file') % checking for preprocessed images

            StruMat = nifti([pathF filesub{k}]);
            PixDim = StruMat.hdr.pixdim(2:4);
            % checking if file has desired resolution (vox of 1x1x1)
            % case not, a spline interpolation will be performed

            if any(PixDim ~= [1 1 1])
                clear matlabbatch
                matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[SSdir2(1:end-3),'SSM_DimTmpl.nii']};
                matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[pathF filesub{k}]};
                matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = '';
    %             spm_jobman('run',matlabbatch)
                SSM_run_batch(matlabbatch);

                movefile([pathF 'r' filesub{k}],[pathF filesub{k}])

                RegIni = 1; %flag for pre-interpolation (necessary for Native-Space returnal)
            else
                RegIni = 0;
            end

            % In the case there are no post-processed images, the file enter the preprocessing list
            F2Run{kIdx,1} = [pathF,filesub{k}]; 
            kIdx = kIdx + 1;    
        else
            % in the case there are preprocessed images, we just check if the
            % images were previously interpolated 
            StruMat = nifti([pathF filesub{k}]);
            PixDim = StruMat.hdr.pixdim(2:4);
            if any(PixDim ~= [1 1 1])
                RegIni = 1;
            else
                RegIni = 0;
            end
        end
        fprintf('\b\b\b\b\b\b\b\b\b\b\b');
        fprintf('%.4d (%.3d%%)',k,round(100*k/size(filesub,2)));
    end
    fprintf('\n');
    fprintf('- Done\n');

    % Case there are images to preprocess
    if ~isempty(F2Run)
        fprintf('- %s\n',datetime);
        fprintf('- Starting CAT12 Preprocessing\n');
        spmDIR = which('spm');
        clear matlabbatch
        matlabbatch{1}.spm.tools.cat.estwrite.data = F2Run;    
        matlabbatch{1}.spm.tools.cat.estwrite.data_wmh = {''};

        if get(handles.ParallelCB,'Value') && size(F2Run,1) > 1
            fprintf('- Creating parallel process\n');
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
        
        if size(F2Run,1) == 1 || get(handles.ParallelCB,'Value') == 0
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
        if size(F2Run,1) == 1 || get(handles.ParallelCB,'Value') == 0
            SSM_run_batch(matlabbatch);
        else
            spm_jobman('run',matlabbatch) % executes cat12 with parallel jobs            
        end

%         if get(handles.ParallelCB,'Value') && size(F2Run,1) > 1
%             spm_jobman('run',matlabbatch) % executes cat12 with parallel jobs
%         else
%             SSM_run_batch(matlabbatch);
%         end

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
        if get(handles.ParallelCB,'Value')
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
    end
    if size(F2Run,1) == 1 || handles.nParallel == 0
        fprintf('- Done\n');
    end
    fprintf('\n');
    fprintf('- %s\n',datetime);
    fprintf('- Compacting some resultant files: Case 0001 (000%%)');
    for k = 1:size(filesub,2)
        if numel(filesub{k}(1:end-4)) > 30
            pathF = [pathsub filesub{k}(1:30) filesep];
        else
            pathF = [pathsub filesub{k}(1:end-4) filesep];
        end
        if exist([pathF 'mri' filesep, 'iy_' filesub{k}],'file')
            gzip([pathF 'mri' filesep, 'iy_' filesub{k}]);
            delete([pathF 'mri' filesep, 'iy_' filesub{k}]);
        end
        if exist([pathF 'mri' filesep, 'y_' filesub{k}],'file')
            gzip([pathF 'mri' filesep, 'y_' filesub{k}]);
            delete([pathF 'mri' filesep, 'y_' filesub{k}]);
        end
        if exist([pathF 'mri' filesep, 'p0' filesub{k}],'file')
            gzip([pathF 'mri' filesep, 'p0' filesub{k}]);
            delete([pathF 'mri' filesep, 'p0' filesub{k}]);
        end
        if exist([pathF 'mri' filesep, 'wm' filesub{k}],'file')
            gzip([pathF 'mri' filesep, 'wm' filesub{k}]);
            delete([pathF 'mri' filesep, 'wm' filesub{k}]);
        end
        fprintf('\b\b\b\b\b\b\b\b\b\b\b');
        fprintf('%.4d (%.3d%%)',k,round(100*k/size(filesub,2)));
    end
    fprintf('\n');
    fprintf('- Done\n');
    SSdir3 = which('SSM');
    SSdir3 = SSdir3(1:end-5);
    ExclMask = nifti([SSdir3,'SSM_Mean_WpMd_Mask.nii']);
    MaskMat = ExclMask.dat(:,:,:);

    fprintf('- %s\n',datetime);
    fprintf('- Smoothing and thresholding images: Case 0001 (000%%)');
    for k = 1:size(filesub,2)
        if numel(filesub{k}(1:end-4)) > 30
            pathF = [pathsub filesub{k}(1:30) filesep];
        else
            pathF = [pathsub filesub{k}(1:end-4) filesep];
        end
        
        %%%%%%%%  Spatial Smooth
        if ~exist([pathF 'mri' filesep 's' FWHMv 'mwp1' filesub{k}],'file') || ~exist([pathF 'mri' filesep 's' FWHMv 'mwp2' filesub{k}],'file')
            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = {[pathF 'mri' filesep 'mwp1' filesub{k}]
                                                      [pathF 'mri' filesep 'mwp2' filesub{k}]};
            matlabbatch{1}.spm.spatial.smooth.fwhm = [str2num(FWHMv) str2num(FWHMv) str2num(FWHMv)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = ['s',FWHMv];
            SSM_run_batch(matlabbatch);

            stru = nifti([pathF 'mri' filesep 's' FWHMv 'mwp1' filesub{k}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat < Thresh) = 0; %Thresh came from the DATABASE threshold (saved/declared in the file)
            Mat = Mat .* MaskMat;
            stru.dat(:,:,:) = Mat;
            create(stru)
            
            stru = nifti([pathF 'mri' filesep 's' FWHMv 'mwp2' filesub{k}]);
            Mat = stru.dat(:,:,:);
            Mat(Mat < Thresh) = 0;
            Mat = Mat .* MaskMat;
            stru.dat(:,:,:) = Mat;
            create(stru)
        end
        fprintf('\b\b\b\b\b\b\b\b\b\b\b');
        fprintf('%.4d (%.3d%%)',k,round(100*k/size(filesub,2)));
    end
    fprintf('\n');
    fprintf('- Done\n');
    
    fprintf('- %s\n',datetime);
    fprintf('- Estimating TIV: Case 0001 (000%%)');
    for k = 1:size(filesub,2)
        fprintf('\b\b\b\b\b\b\b\b\b\b\b');
        fprintf('%.4d (%.3d%%)',k,round(100*k/size(filesub,2)));
        if numel(filesub{k}(1:end-4)) > 30
            pathF = [pathsub filesub{k}(1:30) filesep];
        else
            pathF = [pathsub filesub{k}(1:end-4) filesep];
        end
        %-----------------------------------------------------------
        if ~exist([pathF,filesep,filesub{k}(1:end-4),'_TIV.txt'])
            clear matlabbatch
            matlabbatch{1}.spm.tools.cat.tools.calcvol.data_xml = {[pathF,'report',filesep,'cat_',filesub{k}(1:end-4),'.xml']};
            matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_TIV = 1;
            matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_name = [pathF,filesep,filesub{k}(1:end-4),'_TIV.txt'];
            SSM_run_batch(matlabbatch);
        end
        GTIV(k) = importdata([pathF,filesep,filesub{k}(1:end-4),'_TIV.txt']);

    end
    fprintf('\n');
    fprintf('- Done\n');

    if get(handles.AddFlair,'Value')
        fprintf('- %s\n',datetime);
        fprintf('- Preparing FLAIR biased image: Case 0001 (000%%)');
        TypeSe = '';
        SegT = '';
        for k = 1:size(filesub,2)
            fprintf('\b\b\b\b\b\b\b\b\b\b\b');
            fprintf('%.4d (%.3d%%)',k,round(100*k/size(filesub,2)));
            if numel(filesub{k}(1:end-4)) > 30
                pathF = [pathsub filesub{k}(1:30) filesep];
            else
                pathF = [pathsub filesub{k}(1:end-4) filesep];
            end
            if ~exist([pathF,'mri',filesep,'fs',FWHMv,'mwp1',filesub{k}]) || ~exist([pathF,'mri',filesep,'fs',FWHMv,'mwp2',filesub{k}])
                mkdir([pathF,'FlairBiasOps']);
                copyfile([pathsub,filesub{k}],[pathF,'FlairBiasOps',filesep,filesub{k}]);
                RawT1 = [pathF,'FlairBiasOps',filesep,filesub{k}];

                copyfile([handles.pathFlair,handles.fileFlair{k}],[pathF,'FlairBiasOps',filesep,handles.fileFlair{k}]);
                RawFlair = [pathF,'FlairBiasOps',filesep,handles.fileFlair{k}];

                [TypeSe,SegT] = SSM_Add_FLAIRbias(RawT1,RawFlair,pathF,[str2num(FWHMv) str2num(FWHMv) str2num(FWHMv)],Thresh);

                rmdir([pathF,'FlairBiasOps'],'s');

            end
        end
        fprintf('\n');
        fprintf('%s\n',TypeSe);
        fprintf('%s\n',SegT);
        fprintf('- Done\n');
    end
    
    if numel(filesub{k}(1:end-4)) > 30
        pathF = [pathsub filesub{k}(1:30) filesep];
    else
        pathF = [pathsub filesub{k}(1:end-4) filesep];
    end
    
%     if size(filesub,2) >= 1
        fprintf('- %s\n',datetime);
        fprintf('- Starting Quality Measures (Pre-Harmonization)\n')
        ScreSize = get(0,'screensize');
        ScreSize = ScreSize(3:end);

        if isequal(get(handles.FCD,'Value'),1)
            for k = 1:size(filesub,2)
                if numel(filesub{k}(1:end-4)) > 30
                    pathF = [pathsub filesub{k}(1:30) filesep];
                else
                    pathF = [pathsub filesub{k}(1:end-4) filesep];
                end
                if get(handles.AddFlair,'Value')
                    F2Run1{k,1} = [pathF,'mri',filesep,'fs',FWHMv,'mwp1',filesub{k}];
                    F2Run2{k,1} = [pathF,'mri',filesep,'fs',FWHMv,'mwp2',filesub{k}];
                else
                    F2Run1{k,1} = [pathF,'mri',filesep,'s',FWHMv,'mwp1',filesub{k}];
                    F2Run2{k,1} = [pathF,'mri',filesep,'s',FWHMv,'mwp2',filesub{k}];
                end
            end
            fprintf('- Reading Images: Case 0001 (000%%)');
            for k = 1:size(filesub,2)
                fprintf('\b\b\b\b\b\b\b\b\b\b\b');
                fprintf('%.4d (%.3d%%)',k,round(100*k/size(filesub,2)));

                strux = nifti(F2Run1{k,1});
                gmmat(k,:) = reshape(strux.dat(:,:,:),[1,prod(strux.dat.dim(1:3))]);

                strux = nifti(F2Run2{k,1});
                wmmat(k,:) = reshape(strux.dat(:,:,:),[1,prod(strux.dat.dim(1:3))]);
            end
            fprintf('\n');
            if size(filesub,2) > 3
                Co2D = corrcoef(gmmat');
                CorrMed = (sum(Co2D,2) - 1) ./ (size(Co2D,2) - 1);
                [OutInd,Cutoff] = SSM_outlierdetec(CorrMed,'major','lowerside');

                FigAll = figure;
                set(FigAll,'Name','Images Correlations',...
                                'Position', round([ScreSize(1)*.2 ScreSize(2)*.1 ScreSize(2) ScreSize(2)*.5]),...
                                'Color',[1 1 1]);
                imagesc(Co2D);
                title('Images correlations and Detected Outliers')
                set(gca, 'XTick',10);
                set(gca, 'XTickLabel', OutInd);
                cb = colorbar;
                cb.Label.String = 'Inter-cases r-score';
                
                ax = gca;
                ax.Position = [0.1 0.15 0.8 0.8];

                annotation(FigAll,'textbox',[0.05 0.09 0.9 0.03],'String',...
                    ['- Relevant outliers (that should be inspected in the segmented images) ',...
                    'typically exhibit overall inter-subject correlations below 0.9. ',...
                    'The cutoff here was ',num2str(Cutoff)],'FitBoxToText','off',...
                    'EdgeColor','none','HorizontalAlignment','left',...
                    'Interpreter','none');

                annotation(FigAll,'textbox',[0.05 0.03 0.9 0.03],'String',...
                    ['- Minimum inter-subject correlation: ',num2str(min(CorrMed))],...
                    'FitBoxToText','off','EdgeColor','none','HorizontalAlignment','left',...
                    'Interpreter','none');
                
                imgRR = getframe(FigAll);
                imwrite(imgRR.cdata, [handles.OutDirQ filesep 'GM_0_Images_Inter-Correlations.png']);
                close(FigAll)


                Co2D = corrcoef(wmmat');
                CorrMed = (sum(Co2D,2) - 1) ./ (size(Co2D,2) - 1);
                [OutInd,Cutoff] = SSM_outlierdetec(CorrMed,'major','lowerside');

                FigAll = figure;
                set(FigAll,'Name','Images Correlations',...
                                'Position', round([ScreSize(1)*.2 ScreSize(2)*.1 ScreSize(2) ScreSize(2)*.5]),...
                                'Color',[1 1 1]);
                imagesc(Co2D);
                title('Images correlations and Detected Outliers')
                set(gca, 'XTick',10);
                set(gca, 'XTickLabel', OutInd);
                cb = colorbar;
                cb.Label.String = 'Inter-cases r-score';

                annotation(FigAll,'textbox',[0.05 0.09 0.9 0.03],'String',...
                    ['- Relevant outliers (that should be inspected in the segmented images) ',...
                    'typically exhibit overall inter-subject correlations below 0.9. ',...
                    'The cutoff here was ',num2str(Cutoff)],'FitBoxToText','off',...
                    'EdgeColor','none','HorizontalAlignment','left',...
                    'Interpreter','none');

                annotation(FigAll,'textbox',[0.05 0.03 0.9 0.03],'String',...
                    ['- Minimum inter-subject correlation: ',num2str(min(CorrMed))],...
                    'FitBoxToText','off','EdgeColor','none','HorizontalAlignment','left',...
                    'Interpreter','none');

                imgRR = getframe(FigAll);
                imwrite(imgRR.cdata, [handles.OutDirQ filesep 'WM_0_Images_Inter-Correlations.png']);
                close(FigAll)
            end
        end

        if isequal(get(handles.WMa,'Value'),1)
            for k = 1:size(filesub,2)
                if numel(filesub{k}(1:end-4)) > 30
                    pathF = [pathsub filesub{k}(1:30) filesep];
                else
                    pathF = [pathsub filesub{k}(1:end-4) filesep];
                end
                if get(handles.AddFlair,'Value')
                    F2Run2{k,1} = [pathF,'mri',filesep,'fs',FWHMv,'mwp2',filesub{k}];
                else
                    F2Run2{k,1} = [pathF,'mri',filesep,'s',FWHMv,'mwp2',filesub{k}];
                end
            end
            fprintf('- Reading Images: Case 0001 (000%%)');
            for k = 1:size(filesub,2)
                fprintf('\b\b\b\b\b\b\b\b\b\b\b');
                fprintf('%.4d (%.3d%%)',k,round(100*k/size(filesub,2)));

                strux = nifti(F2Run2{k,1});
                wmmat(k,:) = reshape(strux.dat(:,:,:),[1,prod(strux.dat.dim(1:3))]);
            end
            fprintf('\n');
            if size(filesub,2) > 3
                fprintf('\n');
                Co2D = corrcoef(wmmat');
                CorrMed = mean(Co2D,2);
                [OutInd,Cutoff] = SSM_outlierdetec(CorrMed,'severe','lowerside');

                FigAll = figure;
                set(FigAll,'Name','Images Correlations',...
                                'Position', round([ScreSize(1)*.2 ScreSize(2)*.1 ScreSize(2)*.75 ScreSize(2)*.5]),...
                                'Color',[1 1 1]);
                imagesc(Co2D);
                title('Images correlations and Detected Outliers')
                set(gca, 'XTick',10);
                set(gca, 'XTickLabel', OutInd);
                cb = colorbar;
                cb.Label.String = 'Inter-cases r-score';

                annotation(FigAll,'textbox',[0.05 0.09 0.9 0.03],'String',...
                    ['- Relevant outliers (that should be inspected in the segmented images) ',...
                    'typically exhibit overall inter-subject correlations below 0.9. ',...
                    'The cutoff here was ',num2str(Cutoff)],'FitBoxToText','off',...
                    'EdgeColor','none','HorizontalAlignment','left',...
                    'Interpreter','none');

                annotation(FigAll,'textbox',[0.05 0.03 0.9 0.03],'String',...
                    ['- Minimum inter-subject correlation: ',num2str(min(CorrMed))],...
                    'FitBoxToText','off','EdgeColor','none','HorizontalAlignment','left',...
                    'Interpreter','none');

                imgRR = getframe(FigAll);
                imwrite(imgRR.cdata, [handles.OutDirQ filesep 'WM_0_Images_Inter-Correlations.png']);
                close(FigAll)
            end
        end

        if isequal(get(handles.GMa,'Value'),1)
            for k = 1:size(filesub,2)
                if numel(filesub{k}(1:end-4)) > 30
                    pathF = [pathsub filesub{k}(1:30) filesep];
                else
                    pathF = [pathsub filesub{k}(1:end-4) filesep];
                end
                if get(handles.AddFlair,'Value')
                    F2Run1{k,1} = [pathF,'mri',filesep,'fs',FWHMv,'mwp1',filesub{k}];
                else
                    F2Run1{k,1} = [pathF,'mri',filesep,'s',FWHMv,'mwp1',filesub{k}];
                end
            end

            fprintf('- Reading Images: Case 0001 (000%%)');
            for k = 1:size(filesub,2)
                fprintf('\b\b\b\b\b\b\b\b\b\b\b');
                fprintf('%.4d (%.3d%%)',k,round(100*k/size(filesub,2)));

                strux = nifti(F2Run1{k,1});
                gmmat(k,:) = reshape(strux.dat(:,:,:),[1,prod(strux.dat.dim(1:3))]);

            end
            fprintf('\n');
            if size(filesub,2) > 3
                fprintf('\n');
                Co2D = corrcoef(gmmat');
                CorrMed = mean(Co2D,2);
                [OutInd,Cutoff] = SSM_outlierdetec(CorrMed,'severe','lowerside');

                FigAll = figure;
                set(FigAll,'Name','Images Correlations',...
                                'Position', round([ScreSize(1)*.2 ScreSize(2)*.1 ScreSize(2)*.75 ScreSize(2)*.5]),...
                                'Color',[1 1 1]);
                imagesc(Co2D);
                title('Images correlations and Detected Outliers')
                set(gca, 'XTick',10);
                set(gca, 'XTickLabel', OutInd);
                cb = colorbar;
                cb.Label.String = 'Inter-cases r-score';

                annotation(FigAll,'textbox',[0.05 0.09 0.9 0.03],'String',...
                    ['- Relevant outliers (that should be inspected in the segmented images) ',...
                    'typically exhibit overall inter-subject correlations below 0.9. ',...
                    'The cutoff here was ',num2str(Cutoff)],'FitBoxToText','off',...
                    'EdgeColor','none','HorizontalAlignment','left',...
                    'Interpreter','none');

                annotation(FigAll,'textbox',[0.05 0.03 0.9 0.03],'String',...
                    ['- Minimum inter-subject correlation: ',num2str(min(CorrMed))],...
                    'FitBoxToText','off','EdgeColor','none','HorizontalAlignment','left',...
                    'Interpreter','none');

                imgRR = getframe(FigAll);
                imwrite(imgRR.cdata, [handles.OutDirQ filesep 'GM_0_Images_Inter-Correlations.png']);
                close(FigAll)
            end
        end
        
    % if the study is a multi-subject study, harmonization is an option
    if get(handles.HarmCB,'Value')
        fprintf('- %s\n',datetime);
        fprintf('- Starting harmonization step 1\n')

        fprintf('- Harmonization step 1 (harmonizing images)\n')
        if handles.Run_Encode_DB
            if isequal(get(handles.FCD,'Value'),1)
                if get(handles.FloaRan,'Value')
                    [gmmat,wmmat,SC_Cat_Tmp,SB_Cat_Tmp] = SSM_Decode_Harmon_Tool_FCD(gmmat,wmmat,SC_Cat_Tmp,SB_Cat_Tmp,AgeVet,GenVet,GTIV,Ida_Ctr,Gene_Ctr,DB_TIV,handles.OutDirQ,handles.HarmRef);
                else
                    [gmmat,wmmat,tpt4D_GM,tpt4D_WM] = SSM_Decode_Harmon_Tool_FCD(gmmat,wmmat,tpt4D_GM,tpt4D_WM,AgeVet,GenVet,GTIV,Age_Covar,Gen_Covar,DBTIV,handles.OutDirQ,handles.HarmRef);
                end
            end

            if isequal(get(handles.WMa,'Value'),1)
                if get(handles.FloaRan,'Value')
                    [wmmat,SB_Cat_Tmp] = SSM_Decode_Harmon_Tool_WM(wmmat,SB_Cat_Tmp,AgeVet,GenVet,GTIV,Ida_Ctr,Gene_Ctr,DB_TIV,handles.OutDirQ);
                else
                    [wmmat,tpt4D_WM] = SSM_Decode_Harmon_Tool_WM(wmmat,tpt4D_WM,AgeVet,GenVet,GTIV,Age_Covar,Gen_Covar,DBTIV,handles.OutDirQ);
                end
            end

            if isequal(get(handles.GMa,'Value'),1)
                if get(handles.FloaRan,'Value')
                    [gmmat,SC_Cat_Tmp] = SSM_Decode_Harmon_Tool_GM(gmmat,SC_Cat_Tmp,AgeVet,GenVet,GTIV,Ida_Ctr,Gene_Ctr,DB_TIV,handles.OutDirQ);
                else
                    [gmmat,tpt4D_GM] = SSM_Decode_Harmon_Tool_GM(gmmat,tpt4D_GM,AgeVet,GenVet,GTIV,Age_Covar,Gen_Covar,DBTIV,handles.OutDirQ);
                end
            end
        else
            if isequal(get(handles.FCD,'Value'),1)
                if get(handles.FloaRan,'Value')
                    [gmmat,wmmat,SC_Cat_Tmp,SB_Cat_Tmp] = SSM_Harmon_Tool_FCD(gmmat,wmmat,SC_Cat_Tmp,SB_Cat_Tmp,AgeVet,GenVet,GTIV,Ida_Ctr,Gene_Ctr,DB_TIV,handles.OutDirQ);
                else
                    [gmmat,wmmat,tpt4D_GM,tpt4D_WM] = SSM_Harmon_Tool_FCD(gmmat,wmmat,tpt4D_GM,tpt4D_WM,AgeVet,GenVet,GTIV,Age_Covar,Gen_Covar,DBTIV,handles.OutDirQ);
                end
            end

            if isequal(get(handles.WMa,'Value'),1)
                if get(handles.FloaRan,'Value')
                    [wmmat,SB_Cat_Tmp] = SSM_Harmon_Tool_WM(wmmat,SB_Cat_Tmp,AgeVet,GenVet,GTIV,Ida_Ctr,Gene_Ctr,DB_TIV,handles.OutDirQ);
                else
                    [wmmat,tpt4D_WM] = SSM_Harmon_Tool_WM(wmmat,tpt4D_WM,AgeVet,GenVet,GTIV,Age_Covar,Gen_Covar,DBTIV,handles.OutDirQ);
                end
            end

            if isequal(get(handles.GMa,'Value'),1)
                if get(handles.FloaRan,'Value')
                    [gmmat,SC_Cat_Tmp] = SSM_Harmon_Tool_GM(gmmat,SC_Cat_Tmp,AgeVet,GenVet,GTIV,Ida_Ctr,Gene_Ctr,DB_TIV,handles.OutDirQ);
                else
                    [gmmat,tpt4D_GM] = SSM_Harmon_Tool_GM(gmmat,tpt4D_GM,AgeVet,GenVet,GTIV,Age_Covar,Gen_Covar,DBTIV,handles.OutDirQ);
                end
            end
        end

        fprintf('- Harmonization step 2: writing harmonized images: 000%%')
        for k = 1:size(filesub,2)
            try
                [ImPa,Imfile,Imext] = fileparts(F2Run1{k,1});
                strux = nifti(F2Run1{k,1});
                strux.dat.fname = [ImPa,filesep,'h',Imfile,Imext];
                strux.dat(:,:,:) = reshape(gmmat(k,:),strux.dat.dim(1:3));
                create(strux)
            end
            try
                [ImPa,Imfile,Imext] = fileparts(F2Run2{k,1});
                strux = nifti(F2Run2{k,1});
                strux.dat.fname = [ImPa,filesep,'h',Imfile,Imext];
                strux.dat(:,:,:) = reshape(wmmat(k,:),strux.dat.dim(1:3));
                create(strux)
            end
            fprintf('\b\b\b\b');
            fprintf('%.3d%%',round(100*k/size(filesub,2)));
        end
        fprintf('\n');
    end

    try
        delete(gcp('nocreate'))
    end
    if license('test','Distrib_Computing_Toolbox')
        if get(handles.ParallelCB,'Value')
            try
                parpool(handles.nParallelPerm);
            end
        else
            try
                parpool(1);
            end
        end
    else
       fprintf('- No Parallel Computing Toolbox available\n') 
    end

    if get(handles.FixRan,'Value')
        % In the case the DATABASE is fixed for all, the statistical condition
        % were already verified, so we already know if a new permutation will
        % be recquired or not. If not recquired, PrevThresh is 1, if recquired,
        % than the control the DATABASE subset will be used for a new permutation
        if PrevThresh
            FWER_thrIn = ThreshPrev;
        else
            if isequal(get(handles.FCD,'Value'),1)
                FWER_thrIn = SSM_Decode_DB_FCD_FixRan_CTRs_Vx15(tpt4D_GM,tpt4D_WM,...
                                get(handles.covAge,'Value'),get(handles.checkbox4,'Value'),...
                                Age_Covar,Gen_Covar,DBTIV);
                fprintf(fidThres,'%.1f',FWER_thrIn);
                fclose(fidThres);
            else
                if get(handles.GMa,'Value')
                    FWER_thrIn = SSM_Decode_DB_GWM_FixRan_CTRs_Vx15(tpt4D_GM,...
                                    get(handles.covAge,'Value'),get(handles.checkbox4,'Value'),...
                                    Age_Covar,Gen_Covar,DBTIV);
                else
                    FWER_thrIn = SSM_Decode_DB_GWM_FixRan_CTRs_Vx15(tpt4D_WM,...
                                    get(handles.covAge,'Value'),get(handles.checkbox4,'Value'),...
                                    Age_Covar,Gen_Covar,DBTIV);
                end
                            
                fprintf(fidThres,'%.1f\n',FWER_thrIn(1));
                fprintf(fidThres,'%.1f',FWER_thrIn(2));
                fclose(fidThres);
            end
        end
    else
        % in the case of Relative Range DATABASE, the statistical conditions
        % are subject specific and could not be verified yet.
        PrevThresh = 0;
    end
    
    fprintf('- Starting individual final procedures\n')
    for k = 1:size(filesub,2)
        fprintf('\n##########################################\n');
        fprintf('- Image %.4d - %s\n',k,datetime);
        fprintf('- %s\n',filesub{k}(1:end-4));
        fprintf('##########################################\n\n');

        SSdir2 = which('SSM');
        SSdir2 = [SSdir2(1:end-5) 'DB' filesep];
        TextF = tissue;
        clear imgF

        if numel(filesub{k}(1:end-4)) > 30
            pathF = [pathsub filesub{k}(1:30) filesep];
        else
            pathF = [pathsub filesub{k}(1:end-4) filesep];
        end
        SubjTIV = importdata([pathF,filesep,filesub{k}(1:end-4),'_TIV.txt']);

        if isequal(ExpType,'Multi') 
            % for the case multiple subjects were loaded.
            % For this case we have two main option: 
            % 1 - "Relative/Floating Range"
            % 2 - The "Fixed Range"

            CtrsPerAge = 4; %intrinsic to the database
            if handles.AgeOk
                agePat = AgeVet(k); % get case age
            end
            if handles.SexOk
                GenPat = GenVet(k);
            end

            % 1 - "Relative/Floating Range"
            if get(handles.FloaRan,'Value')

                if GenPat == 0
                    sexString = 'Female';
                else
                    sexString = 'Male';
                end

                VetGenF = Gene_Ctr;
                AllAGEs = Ida_Ctr;
                DBTIV = DB_TIV;

                AgeDesv = str2num(get(handles.AgeRanEdit,'String')); %getting the defined age deviation
                if get(handles.ConstSS,'Value')
                    FileString = ['Demographic_Description_RR_+-',get(handles.AgeRanEdit,'String'),'y_CoSS.txt']; % CHARGE OUTPUT LOG FILE
                else
                    FileString = ['Demographic_Description_RR_+-',get(handles.AgeRanEdit,'String'),'_FoDR.txt']; % CHARGE OUTPUT LOG FILE
                end

                fidDem = fopen([pathF FileString],'w+'); % CHARGE OUTPUT LOG FILE
                fprintf(fidDem,'Image: %s.\r\n\r\n',filesub{k});
                fprintf(fidDem,'Processing type: Varied control''s database ages (adaptative/subject specific controls sample).\r\n');
                fprintf(fidDem,'Alpha leval (p-value): %s\r\n',get(handles.alphaL,'String'));
                fprintf(fidDem,'Extend threshold (voxels): %s\r\n',get(handles.edit6,'String'));
                fprintf(fidDem,'Smooth kernel: %s\r\n',[FWHMv,'x',FWHMv,'x',FWHMv]);
                fprintf(fidDem,'Case age: %d\r\n',agePat);
                fprintf(fidDem,'Case sex: %s\r\n\r\n',sexString);

                SSSize = (AgeDesv * 2 * CtrsPerAge) + CtrsPerAge;% Suposed sample size

                N_afterAgeSex = 0; % current control sample size

                % In "Relative/Floating Range" we have more trwo main options:
                %
                % 1 - Force the same sampe size for all volunteers, even in the
                %     case is necessary to vary the age criteria. Tag "ConstSS"
                %
                % 2 - Follow the defined rules for age and sex. This option may
                % result in variable controls DATABASE size for each testing
                % subject. This occurs due to the the limits of the age range
                % (18-64). For example: if you defined a relative range of 
                % +- 10 years and the volu1teer has 18 years old, the database
                % would recquires control subjetcs from 8 to 28 and our lower
                % age is 18. For this case, this testing case database would
                % have only controls from 18 to 28, resulting in 40 subjects.
                % the Option 1 (force), would, in the other hand, adapt the
                % criteria, including subject from 18 to 38, keeping the final
                % control's subset stable in size

                % In the case the code should force the age range to keep Ctr sample size constant            
                if get(handles.ConstSS,'Value')
                    fprintf(fidDem,'\tControls database sample size: Constant size. Progressively varying (if necessary) the age range limits to fullfill the defined sample size.\r\n\r\n');
                    Loop = 0; % Age rang increment
                    Addt = 0;

                    while N_afterAgeSex < SSSize && Addt <= (max(AllAGEs) - min(AllAGEs))
                        % while teh sample is smaller than the suposed
                        % or until the loop run 80 times. *0 because this is the
                        % double of the control sample age range. Should be the
                        % double because the code will try to sum and to
                        % subtract the range in separated loop instances

                        if Loop == 0 % first iteration
                            FtmpImin = (AllAGEs >= agePat - (AgeDesv + Addt));
                            FtmpImax = (AllAGEs <= agePat + (AgeDesv + Addt));
                            Addt = 1;
                        else % other trials to fullfill the sample size.
                            if iseven(Loop)
                                FtmpImin = (AllAGEs >= agePat - (AgeDesv + Addt));
                            else
                                FtmpImax = (AllAGEs <= agePat + (AgeDesv + Addt));
                                Addt = Addt + 1;
                            end
                        end

                        FtmpI = FtmpImin .* FtmpImax;
                        CaseCTRages = AllAGEs .* FtmpI;

                        if get(handles.MatchSex,'Value')
                            VetAfterSex = (VetGenF == GenPat);
                            CaseCTRages_sex = CaseCTRages .* VetAfterSex;
                            N_afterAgeSex = nnz(CaseCTRages_sex);
                            VetIncluded = CaseCTRages_sex > 0;
                        else
                            CaseCTRages_sex = CaseCTRages;
                            N_afterAgeSex = nnz(CaseCTRages_sex);
                            VetIncluded = CaseCTRages_sex > 0;
                        end

                        Loop = Loop + 1;
                    end
                    if get(handles.MatchSex,'Value')
                        fprintf(fidDem,'Controls database filtered by sex: Yes, only controls of the same sex were included.\r\n\r\n');
                        if isequal(sexString,'M')
                            SexM = 'M';
                            SexF = '';
                        else
                            SexM = '';
                            SexF = 'F';
                        end
                    else
                        fprintf(fidDem,'Controls database filtered by sex: No, both sex included.\r\n');
                        SexM = 'M';
                        SexF = 'F';
                    end

                    fprintf(fidDem,'Final number of controls included: %d\r\n\r\n',N_afterAgeSex);
                    SexTemp = VetIncluded .* VetGenF;
                    SexTemp(SexTemp==0) = [];
                    fprintf(fidDem,'Number of male controls included: %d\r\n',size(SexTemp,1));
                    fprintf(fidDem,'Number of female controls included: %d\r\n',N_afterAgeSex-size(SexTemp,1));
                    AgesTemp = VetIncluded .* AllAGEs;
                    AgesTemp(AgesTemp == 0) = [];
                    fprintf(fidDem,'Controls median age: %.1f\r\n',median(AgesTemp));
                    fprintf(fidDem,'Controls min age: %d\r\n',min(AgesTemp));
                    fprintf(fidDem,'Controls max age: %d\r\n\r\n',max(AgesTemp));

                    MinAge = num2str(min(AgesTemp));
                    MaxAge = num2str(max(AgesTemp));
                    TextF = [TextF,'_',MinAge,'-',MaxAge,'_',SexM,'-',SexF,'_',AgeR,'-',SexR,'_',fwheU,'_',CtrSub,'_',nTests,'_',FWERu,'_',MaxTy];

                    if exist([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'file')
                        ThreshPrev = importdata([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt']);
                        if isempty(ThreshPrev)
                            fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                            ThreshPrev = [];
                            PrevThresh = 0;
                        else
                            PrevThresh = 1;
                            fprintf('- Previousy estimated and stored FWER threshold: %.1f\n',ThreshPrev);
                        end
                    else
                        fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                        PrevThresh = 0;
                    end
                else
                    fprintf(fidDem,'\tControls database sample size: Following the defined rule. The age range limits will be respected even in the case the control''s sample size reduces.\r\n\r\n');
                    FtmpImin = (AllAGEs >= agePat - AgeDesv);
                    FtmpImax = (AllAGEs <= agePat + AgeDesv);
                    FtmpI = FtmpImin .* FtmpImax;
                    CaseCTRages = AllAGEs .* FtmpI;

                    if get(handles.MatchSex,'Value')
                        fprintf(fidDem,'Controls database filtered by sex: Yes, only controls of the same sex were included.\r\n\r\n');
                        VetAfterSex = (VetGenF == GenPat);
                        CaseCTRages_sex = CaseCTRages .* VetAfterSex;
                        N_afterAgeSex = nnz(CaseCTRages_sex);
                        VetIncluded = CaseCTRages_sex > 0;
                        if isequal(sexString,'M')
                            SexM = 'M';
                            SexF = '';
                        else
                            SexM = '';
                            SexF = 'F';
                        end
                    else
                        fprintf(fidDem,'Controls database filtered by sex: No, both sex included.\r\n\r\n');
                        CaseCTRages_sex = CaseCTRages;
                        N_afterAgeSex = nnz(CaseCTRages_sex);
                        VetIncluded = CaseCTRages_sex > 0;
                        SexM = 'M';
                        SexF = 'F';
                    end

                    fprintf(fidDem,'Final number of controls included: %d\r\n\r\n',N_afterAgeSex);
                    SexTemp = VetIncluded .* VetGenF;
                    SexTemp(SexTemp==0) = [];
                    fprintf(fidDem,'Number of male controls included: %d\r\n',size(SexTemp,1));
                    fprintf(fidDem,'Number of female controls included: %d\r\n\r\n',N_afterAgeSex-size(SexTemp,1));
                    AgesTemp = VetIncluded .* AllAGEs;
                    AgesTemp(AgesTemp==0) = [];
                    fprintf(fidDem,'Controls median age: %.1f\r\n',median(AgesTemp));
                    fprintf(fidDem,'Controls min age: %d\r\n',min(AgesTemp));
                    fprintf(fidDem,'Controls max age: %d\r\n\r\n',max(AgesTemp));

                    MinAge = num2str(min(AgesTemp));
                    MaxAge = num2str(max(AgesTemp));
                    TextF = [TextF,'_',MinAge,'-',MaxAge,'_',SexM,'-',SexF,'_',AgeR,'-',SexR,'_',fwheU,'_',CtrSub,'_',nTests,'_',FWERu,'_',MaxTy];

                    if exist([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'file')
                        ThreshPrev = importdata([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt']);
                        if isempty(ThreshPrev)
                            fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                            ThreshPrev = [];
                            PrevThresh = 0;
                        else
                            PrevThresh = 1;
                            fprintf('- Previousy estimated and stored FWER threshold: %.1f\n',ThreshPrev);
                        end
                    else
                        fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                        PrevThresh = 0;
                    end
                end

                fclose(fidDem);

                DBTIV = DBTIV .* VetIncluded;
                DBTIV(DBTIV == 0) = [];

                if isequal(Verif_Covar_Age,1) % check if age covariate will be used
                    Age_Covar = AllAGEs .* VetIncluded;
                    Age_Covar(Age_Covar==0) = [];
                end

                if isequal(Verif_Covar_Gender,1) % check if sex covariate will be used
                    VetIncludedSex = single(VetIncluded);
                    VetIncludedSex(VetIncludedSex==0) = NaN;
                    Gen_Covar = VetGenF .* VetIncludedSex;
                    Gen_Covar(isnan(Gen_Covar)) = [];
                end

                SelectVet = VetIncluded;
            end

            % 2 - "Fixed range of controls"
            if get(handles.FixRan,'Value')

                if isequal(Verif_Covar_Age,1)
                    agePat = AgeVet(k); % get case age
                    Age_Covar = AllAGEs;
                end

                if isequal(Verif_Covar_Gender,1)
                    GenPat = GenVet(k);
                    Gen_Covar = transpose(Gen_Covar);
                end
                FileString = ['Demographic_Description_FR_',get(handles.text17,'String'),'y-',get(handles.text21,'String'),'y.txt'];

                fidDem = fopen([pathF FileString],'w+'); % CHARGE OUTPUT LOG FILE
                fprintf(fidDem,'Image: %s.\r\n\r\n',filesub{k});
                fprintf(fidDem,'Processing type: Multi Subjects. Fixed Range database.\r\n');
                fprintf(fidDem,'Alpha leval (p-value): %s\r\n',get(handles.alphaL,'String'));
                fprintf(fidDem,'Extend threshold (voxels): %s\r\n',get(handles.edit6,'String'));
                fprintf(fidDem,'Smooth kernel: %s\r\n',[FWHMv,'x',FWHMv,'x',FWHMv]);
                if isequal(Verif_Covar_Age,1)
                    fprintf(fidDem,'Case age: %d\r\n',agePat);
                else
                    fprintf(fidDem,'Case age: %s\r\n',get(handles.SubjAge,'String'));
                end

                if get(handles.maleP,'Value')
                    sexString = 'Male';
                else
                    sexString = 'Female';
                end
                fprintf(fidDem,'Case sex: %s\r\n\r\n',sexString);
                fprintf(fidDem,'\tControls database sample size: %s\r\n\r\n',get(handles.nOfCtr,'String'));
                if get(handles.males,'Value') && get(handles.females,'Value')
                    fprintf(fidDem,'Controls database filtered by sex: No, both sex included.\r\n');
                else
                    if get(handles.males,'Value')
                        fprintf(fidDem,'Controls database filtered by sex: Yes, only male controls were included.\r\n\r\n');
                    else
                        fprintf(fidDem,'Controls database filtered by sex: Yes, only female controls were included.\r\n\r\n');
                    end
                end
                fprintf(fidDem,'Number of male controls included: %s\r\n',get(handles.nOfMale,'String'));
                fprintf(fidDem,'Number of female controls included: %s\r\n',get(handles.nOfFemale,'String'));
                fprintf(fidDem,'Controls database age (average/STD): %s\r\n',get(handles.avgAge,'String'));
                fprintf(fidDem,'Controls lower age: %s\r\n',get(handles.text17,'String'));
                fprintf(fidDem,'Controls max age: %s\r\n\r\n',get(handles.text21,'String'));
                fclose(fidDem);

            end

        else % Here if for the case a single-case were loaded. For this case 
             % only Fixed range is allowed.
            VetGenF = Gene_Ctr;
            AllAGEs = Ida_Ctr;
            DBTIV = DB_TIV;

            if isequal(Verif_Covar_Age,1)
                agePat = str2num(get(handles.SubjAge,'String'));
                Age_Covar = AllAGEs;
            end

            if isequal(Verif_Covar_Gender,1)
                GenPat = get(handles.maleP,'Value');
                Gen_Covar = transpose(Gen_Covar);
            end

            FileString = ['Demographic_Description_FR_',get(handles.text17,'String'),'y-',get(handles.text21,'String'),'y.txt'];

            fidDem = fopen([pathF FileString],'w+'); % CHARGE OUTPUT LOG FILE
            fprintf(fidDem,'Image: %s.\r\n\r\n',filesub{k});
            fprintf(fidDem,'Processing type: Single Subject. Fixed Range database.\r\n');
            fprintf(fidDem,'Alpha leval (p-value): %s\r\n',get(handles.alphaL,'String'));
            fprintf(fidDem,'Extend threshold (voxels): %s\r\n',get(handles.edit6,'String'));
            fprintf(fidDem,'Smooth kernel: %s\r\n',[FWHMv,'x',FWHMv,'x',FWHMv]);
            if isequal(Verif_Covar_Age,1)
                fprintf(fidDem,'Case age: %d\r\n',agePat);
            else
                fprintf(fidDem,'Case age: %s\r\n',get(handles.SubjAge,'String'));
            end

            if get(handles.maleP,'Value')
                sexString = 'Male';
            else
                sexString = 'Female';
            end
            fprintf(fidDem,'Case sex: %s\r\n\r\n',sexString);
            fprintf(fidDem,'\tControls database sample size: %s\r\n\r\n',get(handles.nOfCtr,'String'));
            if get(handles.males,'Value') && get(handles.females,'Value')
                fprintf(fidDem,'Controls database filtered by sex: No, both sex included.\r\n');
            else
                if get(handles.males,'Value')
                    fprintf(fidDem,'Controls database filtered by sex: Yes, only male controls were included.\r\n\r\n');
                else
                    fprintf(fidDem,'Controls database filtered by sex: Yes, only female controls were included.\r\n\r\n');
                end
            end
            fprintf(fidDem,'Number of male controls included: %s\r\n',get(handles.nOfMale,'String'));
            fprintf(fidDem,'Number of female controls included: %s\r\n',get(handles.nOfFemale,'String'));
            fprintf(fidDem,'Controls database age (average/STD): %s\r\n',get(handles.avgAge,'String'));
            fprintf(fidDem,'Controls lower age: %s\r\n',get(handles.text17,'String'));
            fprintf(fidDem,'Controls max age: %s\r\n\r\n',get(handles.text21,'String'));
            fclose(fidDem);

            DBTIV = DBTIV .* SelectVet;
            DBTIV(DBTIV == 0) = [];

            if isequal(Verif_Covar_Age,1) % check if age covariate will be used
                Age_Covar = AllAGEs .* SelectVet;
                Age_Covar(Age_Covar==0) = [];
            end

            if isequal(Verif_Covar_Gender,1) % check if sex covariate will be used
                VetIncludedSex = single(SelectVet);
                VetIncludedSex(VetIncludedSex==0) = NaN;
                Gen_Covar = VetGenF .* VetIncludedSex;
                Gen_Covar(isnan(Gen_Covar)) = [];
            end

        end

        if get(handles.FloaRan,'Value')
            % For the case of Relative Range, finally we are in the subject
            % specific case, and we are now selecting this subject matched 
            % controls

            if isequal(get(handles.GMa,'Value'),1)
                clear tpt4D_GM
                xlo = 1;
                fprintf('- Selecting Defined Controls')
                for j = 1:size(SC_Cat_Tmp,4)
                    if isequal(SelectVet(j),1)
                        tpt4D_GM(:,:,:,xlo) = SC_Cat_Tmp(:,:,:,j);
                        xlo = xlo + 1;
                    end
                end
                fprintf('...');
                fprintf('- Done')
                fprintf('\n')
                tpt4D_GM = single(tpt4D_GM);
            end

            if isequal(get(handles.WMa,'Value'),1)
                clear tpt4D_WM
                xlo = 1;
                fprintf('- Selecting Defined Controls')
                for j = 1:size(SB_Cat_Tmp,4)
                    if isequal(SelectVet(j),1)
                        tpt4D_WM(:,:,:,xlo) = SB_Cat_Tmp(:,:,:,j);
                        xlo = xlo + 1;
                    end
                end
                tpt4D_WM = single(tpt4D_WM);
                fprintf('...');
                fprintf('- Done')
                fprintf('\n')
            end

            if isequal(get(handles.FCD,'Value'),1)
                clear tpt4D_GM tpt4D_WM
                xlo = 1;
                fprintf('- Selecting Defined Controls')

                for j = 1:size(SC_Cat_Tmp,4)
                    if isequal(SelectVet(j),1)
                        tpt4D_GM(:,:,:,xlo) = SC_Cat_Tmp(:,:,:,j);
                        tpt4D_WM(:,:,:,xlo) = SB_Cat_Tmp(:,:,:,j);
                        xlo = xlo + 1;
                    end
                end
                tpt4D_GM = single(tpt4D_GM);
                tpt4D_WM = single(tpt4D_WM);
                fprintf('...');
                fprintf('- Done')
                fprintf('\n')
            end
        end

        AlphaValue = str2num(get(handles.alphaL,'String'));

        %%%%%%%%%%%%%%%%%%%%% Conditions to define interactional parameters
        % Now, the code will start procedures to properly evaluate the images
        % and return the final contrast map. This step is separated by
        % evaluated tissue (GM, WM or FCD)
        
        if isequal(get(handles.GMa,'Value'),1)
            clear SB_Tplate1 SB_Tplate2 SB_Tplate3 SC_Tplate1 SC_Tplate2 SC_Tplate3
            if get(handles.HarmCB,'Value')
                GMdir = [pathF,filesep,'GM_Morp-SK',FWHMv,'-Harm_',DatStrT,filesep];
                fke = nifti([pathF 'mri' filesep 'hs' FWHMv 'mwp1' filesub{k}]); %reading segmented image
                UseHarm = 1;
            else
                GMdir = [pathF,filesep,'GM_Morp-SK',FWHMv,'_',DatStrT,filesep];
                fke = nifti([pathF 'mri' filesep 's' FWHMv 'mwp1' filesub{k}]); %reading segmented image
                UseHarm = 0;
            end

            % Reading post-processed GM map
            fkeep = fke.dat(:,:,:);

            mkdir(GMdir);

            movefile([pathF,filesep,FileString],...
                     [GMdir,FileString])

            % Renaming the database variable
            tmpt = tpt4D_GM;

            if ~get(handles.FixRan,'Value')
                clear tpt4D_GM tpt4D_WM
            end

            if handles.Run_Encode_DB
                % The SSM_Decode_DB_FCD_Vx15 function performs regressions of
                % covariates and the final test,
                % contrasting parameters to identify the lesion. In the case 
                % ThreshPrev is 0 (no previous threshold estimated with
                % permutation with the same exact parameters), the permutation
                % will be performed inside this function.

                if get(handles.covAge,'Value') && get(handles.checkbox4,'Value')
                % For the case age AND sex are covariates
                      if PrevThresh
                          % For the case there is previously estimated threshold
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                      else
                          % For the case there is not previously estimated threshold
                          % in this case, this very specific permutation
                          % condition will be stored and for further analysis,
                          % this condition will not required a permutation
                          % again.
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                          fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                          fprintf(fidThres,'%.1f\n',FWER_thr(1));
                          fprintf(fidThres,'%.1f',FWER_thr(2));
                          fclose(fidThres);
                      end
                else
                    if get(handles.covAge,'Value') || get(handles.checkbox4,'Value')
                    % For the case age OR sex is covariate
                        if get(handles.covAge,'Value')
                        % For the case only age is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f\n',FWER_thr(1));
                                  fprintf(fidThres,'%.1f',FWER_thr(2));
                                  fclose(fidThres);
                              end
                        end
                        if get(handles.checkbox4,'Value')
                        % For the case only sex is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f\n',FWER_thr(1));
                                  fprintf(fidThres,'%.1f',FWER_thr(2));
                                  fclose(fidThres);
                              end
                        end
                    else
                    % for the case neither age or sex were included as covariates
                          if PrevThresh
                              [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                            get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                            SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                          else
                              [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                            get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                            SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                              fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                              fprintf(fidThres,'%.1f\n',FWER_thr(1));
                              fprintf(fidThres,'%.1f',FWER_thr(2));
                              fclose(fidThres);
                          end
                    end
                end
            else
                % If the user provides a custom reference dataset,
                % these functions should be used, as no decoding is required.
                % The alternative functions in this section are 
                % open-source references for the SSM procedures.
                % They are identical to their p-coded counterparts,
                % differing only in the absence of decoding steps.
                    
                if get(handles.covAge,'Value') && get(handles.checkbox4,'Value')
                % For the case age AND sex are covariates
                      if PrevThresh
                          % For the case there is previously estimated threshold
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                      else
                          % For the case there is not previously estimated threshold
                          % in this case, this very specific permutation
                          % condition will be stored and for further analysis,
                          % this condition will not required a permutation
                          % again.
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                          fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                          fprintf(fidThres,'%.1f\n',FWER_thr(1));
                          fprintf(fidThres,'%.1f',FWER_thr(2));
                          fclose(fidThres);
                      end
                else
                    if get(handles.covAge,'Value') || get(handles.checkbox4,'Value')
                    % For the case age OR sex is covariate
                        if get(handles.covAge,'Value')
                        % For the case only age is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f\n',FWER_thr(1));
                                  fprintf(fidThres,'%.1f',FWER_thr(2));
                                  fclose(fidThres);
                              end
                        end
                        if get(handles.checkbox4,'Value')
                        % For the case only sex is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f\n',FWER_thr(1));
                                  fprintf(fidThres,'%.1f',FWER_thr(2));
                                  fclose(fidThres);
                              end
                        end
                    else
                    	% for the case neither age or sex were included as covariates
                        if PrevThresh
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                        else
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                          fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                          fprintf(fidThres,'%.1f\n',FWER_thr(1));
                          fprintf(fidThres,'%.1f',FWER_thr(2));
                          fclose(fidThres);
                        end
                    end
                end
            end

            % Reshaping thresholded the Z-map
            Zsc_map3Do = reshape(Iteract_Tmap_Thr',[size(fkeep,1),size(fkeep,2),size(fkeep,3)]);

            % Removing voxels with negative Z Score. Keep DB > Subj
            Zsc_map3D = Zsc_map3Do;
            Zsc_map3D(Zsc_map3D < 0) = 0;

            % Removing voxels with positive Z Score. Keep Subj > DB
            Zsc_map3Dneg = Zsc_map3Do;
            Zsc_map3Dneg(Zsc_map3Dneg > 0) = 0;
            Zsc_map3Dneg = abs(Zsc_map3Dneg);

            % Reshaping Z-map
            Zsc_map3Do2 = reshape(Iteract_Tmap',[size(fkeep,1),size(fkeep,2),size(fkeep,3)]);

            % Removing voxels with negative Z Score. Keep DB > Subj
            Zsc_map3D2 = Zsc_map3Do2;
            Zsc_map3D2(Zsc_map3D2 < 0) = 0;

            % Removing voxels with positive Z Score. Keep Subj > DB
            Zsc_map3Dneg2 = Zsc_map3Do2;
            Zsc_map3Dneg2(Zsc_map3Dneg2 > 0) = 0;
            Zsc_map3Dneg2 = abs(Zsc_map3Dneg2);
            
            gunzip([pathF 'mri' filesep 'wm' filesub{k} '.gz']);
            mStr = nifti([pathF 'mri' filesep 'wm' filesub{k}]); %reading segmented image
            MMat = mStr.dat(:,:,:);
            MMat(MMat < 0.3) = 0;
            MMat(MMat > 0) = 1;
            delete([pathF 'mri' filesep 'wm' filesub{k}]);
            
            extThre = str2num(get(handles.edit6,'String'));

            AtrophyFull = [GMdir filesub{k}(1:end-4),'_GM_Atrophy_Zmap_s',FWHMv,'.nii'];
            AtrophyThresh = [GMdir filesub{k}(1:end-4),'_GM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];
            HypertFull = [GMdir filesub{k}(1:end-4),'_GM_Hypertrophy_Zmap_s',FWHMv,'.nii'];
            HypertThresh = [GMdir filesub{k}(1:end-4),'_GM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];

            % Creating the whole-brain Z-Scored map
            fstru2 = fke;
            fstru2.dat.fname = AtrophyFull;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3D2 .* MMat;
            create(fstru2) 
                
            % Creating the whole-brain Z-Scored map
            fstru2 = fke;
            fstru2.dat.fname = HypertFull;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3Dneg2 .* MMat;
            create(fstru2) 

            % Labeling all final clusters to apply the extend threshold
            [L,NUM] = bwlabeln(Zsc_map3D > 0);
            Nclus = unique(L);
            ClusMask = ones(size(Zsc_map3D));

            % Reading all identified clusters and excluding smaller than the
            % "extThre"
            for uiy = 2:size(Nclus,1)
                ROI = single(L==Nclus(uiy));
                Nvox(uiy-1) = sum(ROI(:));
                if Nvox(uiy-1) < extThre
                    ClusMask = ClusMask - ROI;
                end
            end

            Zsc_map3D = Zsc_map3D .* ClusMask;

            % Labeling all final clusters to apply the extend threshold
            [Lneg,NUMneg] = bwlabeln(Zsc_map3Dneg > 0);
            Nclusneg = unique(Lneg);
            ClusMaskneg = ones(size(Zsc_map3Dneg));

            % Reading all identified clusters and excluding smaller than the
            % "extThre"
            for uiy2 = 2:size(Nclusneg,1)
                ROIneg = single(Lneg == Nclusneg(uiy2));
                NvoxNeg(uiy - 1) = sum(ROIneg(:));
                if NvoxNeg(uiy-1) < extThre
                    ClusMaskneg = ClusMaskneg - ROIneg;
                end
            end
            Zsc_map3Dneg = Zsc_map3Dneg .* ClusMaskneg;

            % Creating the final thresholded z_scored map
            fstru2 = fke;
            fstru2.dat.fname = AtrophyThresh;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3D .* MMat;
            create(fstru2) % Creating 4D file with the interaction maps
            fprintf('- Done\n');

            % Creating the whole-brain Z-Scored map
            fstru2 = fke;
            fstru2.dat.fname = HypertThresh;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3Dneg .* MMat;
            create(fstru2) 
            extThre = str2num(get(handles.edit6,'String'));

            % Labeling all final clusters to apply the extend threshold
            [L,NUM] = bwlabeln(Zsc_map3D > 0);
            Nclus = unique(L);
            ClusMask = ones(size(Zsc_map3D));

            % Reading all identified clusters and excluding smaller than the
            % "extThre"
            for uiy = 2:size(Nclus,1)
                ROI = single(L==Nclus(uiy));
                Nvox(uiy-1) = sum(ROI(:));
                if Nvox(uiy-1) < extThre
                    ClusMask = ClusMask - ROI;
                end
            end

            Zsc_map3D = Zsc_map3D .* ClusMask;

            % Labelling all final clusters to apply the extend threshold
            [Lneg,NUMneg] = bwlabeln(Zsc_map3Dneg > 0);
            Nclusneg = unique(Lneg);
            ClusMaskneg = ones(size(Zsc_map3Dneg));

            % Reading all identified clusters and excluding smaller than the
            % "extThre"
            for uiy2 = 2:size(Nclusneg,1)
                ROIneg = single(Lneg == Nclusneg(uiy2));
                NvoxNeg(uiy - 1) = sum(ROIneg(:));
                if NvoxNeg(uiy-1) < extThre
                    ClusMaskneg = ClusMaskneg - ROIneg;
                end
            end
            Zsc_map3Dneg = Zsc_map3Dneg .* ClusMaskneg;

            % Creating the final thresholded z_scored map
            fstru2 = fke;
            fstru2.dat.fname = AtrophyThresh;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3D .* MMat;
            create(fstru2) % Creating 4D file with the interaction maps
            fprintf('- Done\n');

            fprintf('- Creating slice view image with the results\n');
            imgBack = [pathF 'mri' filesep 'wm' filesub{k}];
            gunzip([imgBack,'.gz']);
            [~,nx1,~] = fileparts(AtrophyThresh);
            SSM_SliceView(imgBack,AtrophyThresh,0.01,0,'Axial','hot','best','Atrophy',...
                            [nx1,'.png'],GMdir)
            fprintf('- Done\n');

            % Creating the final thresholded z_scored map
            fstru2 = fke;
            fstru2.dat.fname = HypertThresh;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3Dneg .* MMat;
            create(fstru2) % Creating 4D file with the interaction maps
            fprintf('- Done\n');

            [~,nx2,~] = fileparts(HypertThresh);
            SSM_SliceView(imgBack,HypertThresh,0.01,0,'Axial','hot','best','Hypertrophy',...
                            [nx2,'.png'],GMdir)
            fprintf('-  Done\n');

            fprintf('- Starting procedures for anatomical description\n');
            SSM_AnatDescrip_Vx15({AtrophyThresh},...
                                    GMdir,[nx1,'.txt'],'map','AAL3');

            fprintf('- Done\n');
            SSM_AnatDescrip_Vx15({HypertThresh},...
                                    GMdir,[nx2,'.txt'],'map','AAL3');
            fprintf('- Done\n');

            fprintf('\n');
            fprintf('- Creating native/subjec space images\n');
            DefI = gunzip([pathF 'mri' filesep 'iy_' filesub{k} '.gz']);

            clear matlabbatch
            matlabbatch{1}.spm.util.defs.comp{1}.def = DefI;
            matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {AtrophyFull;
                                                               AtrophyThresh;
                                                               HypertFull;
                                                               HypertThresh};
            matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
            matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
            matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
            matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
            matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = 'Native_';
            SSM_run_batch(matlabbatch);

            delete([pathF 'mri' filesep 'iy_' filesub{k}])
            copyfile([pathsub,filesub{k}],[pathF,filesub{k}])
            StruMat = nifti([pathF filesub{k}]);
            PixDim = StruMat.hdr.pixdim(2:4);

            if any(PixDim ~= [1 1 1])
                copyfile([pathsub,filesub{k}],[pathF,'z0',filesub{k}])
                copyfile([pathsub,filesub{k}],[pathF,filesub{k}])
                StruMat = nifti([pathF filesub{k}]);
                PixDim = StruMat.hdr.pixdim(2:4);

                clear matlabbatch
                matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[SSdir2(1:end-3),'SSM_DimTmpl.nii']};
                matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[pathF filesub{k}]};
                matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
                SSM_run_batch(matlabbatch);

                clear matlabbatch
                matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[pathF,'z0',filesub{k}]};
                matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[pathF,'r',filesub{k}]};
                matlabbatch{1}.spm.spatial.coreg.estwrite.other = {[GMdir,'Native_',filesub{k}(1:end-4),'_GM_Atrophy_Zmap_s',FWHMv,'.nii'];
                                                                   [GMdir,'Native_',filesub{k}(1:end-4),'_GM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];
                                                                   [GMdir,'Native_',filesub{k}(1:end-4),'_GM_Hypertrophy_Zmap_s',FWHMv,'.nii'];
                                                                   [GMdir,'Native_',filesub{k}(1:end-4),'_GM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];};
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
                SSM_run_batch(matlabbatch);

                movefile([GMdir,'rNative_',filesub{k}(1:end-4),'_GM_Atrophy_Zmap_s',FWHMv,'.nii'],...
                         [GMdir,'Native_',filesub{k}(1:end-4),'_GM_Atrophy_Zmap_s',FWHMv,'.nii']);

                movefile([GMdir,'rNative_',filesub{k}(1:end-4),'_GM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'],...
                         [GMdir,'Native_',filesub{k}(1:end-4),'_GM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);

                movefile([GMdir,'rNative_',filesub{k}(1:end-4),'_GM_Hypertrophy_Zmap_s',FWHMv,'.nii'],...
                         [GMdir,'Native_',filesub{k}(1:end-4),'_GM_Hypertrophy_Zmap_s',FWHMv,'.nii']);

                movefile([GMdir,'rNative_',filesub{k}(1:end-4),'_GM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'],...
                         [GMdir,'Native_',filesub{k}(1:end-4),'_GM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            end
            
            gzip([GMdir,'Native_',filesub{k}(1:end-4),'_GM_Atrophy_Zmap_s',FWHMv,'.nii']);
            gzip([GMdir,'Native_',filesub{k}(1:end-4),'_GM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            gzip([GMdir,'Native_',filesub{k}(1:end-4),'_GM_Hypertrophy_Zmap_s',FWHMv,'.nii']);
            gzip([GMdir,'Native_',filesub{k}(1:end-4),'_GM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            
            delete([GMdir,'Native_',filesub{k}(1:end-4),'_GM_Atrophy_Zmap_s',FWHMv,'.nii']);
            delete([GMdir,'Native_',filesub{k}(1:end-4),'_GM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            delete([GMdir,'Native_',filesub{k}(1:end-4),'_GM_Hypertrophy_Zmap_s',FWHMv,'.nii']);
            delete([GMdir,'Native_',filesub{k}(1:end-4),'_GM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            
            delete(imgBack);
            
            if exist([pathF,filesub{k}],'file')
                delete([pathF,filesub{k}]);
            end
            if exist([pathF,'z0',filesub{k}],'file')
                delete([pathF,'z0',filesub{k}]);
            end
            if exist([pathF,'r',filesub{k}],'file')
                delete([pathF,'r',filesub{k}]);
            end
            if exist([pathF,'rr',filesub{k}],'file')
                delete([pathF,'rr',filesub{k}]);
            end
            if exist([pathF,filesub{k}],'file')
                delete([pathF,filesub{k}]);
            end
            
            clear tmpt
        end
        %%
        if isequal(get(handles.WMa,'Value'),1)
            
            if get(handles.HarmCB,'Value')
                WMdir = [pathF,filesep,'WM_Morp-SK',FWHMv,'-Harm_',DatStrT,filesep];
                fke = nifti([pathF 'mri' filesep 'hs' FWHMv 'mwp2' filesub{k}]); %reading segmented image
                UseHarm = 1;
            else
                WMdir = [pathF,filesep,'WM_Morp-SK',FWHMv,'_',DatStrT,filesep];
                fke = nifti([pathF 'mri' filesep 's' FWHMv 'mwp2' filesub{k}]); %reading segmented image
                UseHarm = 0;
            end

            mkdir(WMdir);

            movefile([pathF,filesep,FileString],...
                [WMdir,FileString])

            fkeep = fke.dat(:,:,:);

            % Renaming the database variable
            tmpt = tpt4D_WM; 

            if handles.Run_Encode_DB
                % The SSM_Decode_DB_FCD_Vx15 function performs regressions of
                % covariates and the final test,
                % contrasting parameters to identify the lesion. In the case 
                % ThreshPrev is 0 (no previous threshold estimated with
                % permutation with the same exact parameters), the permutation
                % will be performed inside this function.

                if get(handles.covAge,'Value') && get(handles.checkbox4,'Value')
                % For the case age AND sex are covariates
                      if PrevThresh
                          % For the case there is previously estimated threshold
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                      else
                          % For the case there is not previously estimated threshold
                          % in this case, this very specific permutation
                          % condition will be stored and for further analysis,
                          % this condition will not required a permutation
                          % again.
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                          fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                          fprintf(fidThres,'%.1f\n',FWER_thr(1));
                          fprintf(fidThres,'%.1f',FWER_thr(2));
                          fclose(fidThres);
                      end
                else
                    if get(handles.covAge,'Value') || get(handles.checkbox4,'Value')
                    % For the case age OR sex is covariate
                        if get(handles.covAge,'Value')
                        % For the case only age is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f\n',FWER_thr(1));
                                  fprintf(fidThres,'%.1f',FWER_thr(2));
                                  fclose(fidThres);
                              end
                        end
                        if get(handles.checkbox4,'Value')
                        % For the case only sex is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f\n',FWER_thr(1));
                                  fprintf(fidThres,'%.1f',FWER_thr(2));
                                  fclose(fidThres);
                              end
                        end
                    else
                    % for the case neither age or sex were included as covariates
                          if PrevThresh
                              [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                            get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                            SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                          else
                              [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                            get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                            SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                              fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                              fprintf(fidThres,'%.1f\n',FWER_thr(1));
                              fprintf(fidThres,'%.1f',FWER_thr(2));
                              fclose(fidThres);
                          end
                    end
                end
            else
                % If the user provides a custom reference dataset,
                % these functions should be used, as no decoding is required.
                % The alternative functions in this section are 
                % open-source references for the SSM procedures.
                % They are identical to their p-coded counterparts,
                % differing only in the absence of decoding steps.
                    
                if get(handles.covAge,'Value') && get(handles.checkbox4,'Value')
                % For the case age AND sex are covariates
                      if PrevThresh
                          % For the case there is previously estimated threshold
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                      else
                          % For the case there is not previously estimated threshold
                          % in this case, this very specific permutation
                          % condition will be stored and for further analysis,
                          % this condition will not required a permutation
                          % again.
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                          fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                          fprintf(fidThres,'%.1f\n',FWER_thr(1));
                          fprintf(fidThres,'%.1f',FWER_thr(2));
                          fclose(fidThres);
                      end
                else
                    if get(handles.covAge,'Value') || get(handles.checkbox4,'Value')
                    % For the case age OR sex is covariate
                        if get(handles.covAge,'Value')
                        % For the case only age is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f\n',FWER_thr(1));
                                  fprintf(fidThres,'%.1f',FWER_thr(2));
                                  fclose(fidThres);
                              end
                        end
                        if get(handles.checkbox4,'Value')
                        % For the case only sex is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f\n',FWER_thr(1));
                                  fprintf(fidThres,'%.1f',FWER_thr(2));
                                  fclose(fidThres);
                              end
                        end
                    else
                    % for the case neither age or sex were included as covariates
                          if PrevThresh
                              [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                            get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                            SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                          else
                              [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_GWM_Vx15(tmpt,fkeep,get(handles.covAge,'Value'),...
                                                                            get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                            SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                              fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                              fprintf(fidThres,'%.1f\n',FWER_thr(1));
                              fprintf(fidThres,'%.1f',FWER_thr(2));
                              fclose(fidThres);
                          end
                    end
                end
            end

            % Reshaping thresholded the Z-map
            Zsc_map3Do = reshape(Iteract_Tmap_Thr',[size(fkeep,1),size(fkeep,2),size(fkeep,3)]);

            % Removing voxels with negative Z Score. Keep DB > Subj
            Zsc_map3D = Zsc_map3Do;
            Zsc_map3D(Zsc_map3D < 0) = 0;

            % Removing voxels with positive Z Score. Keep Subj > DB
            Zsc_map3Dneg = Zsc_map3Do;
            Zsc_map3Dneg(Zsc_map3Dneg > 0) = 0;
            Zsc_map3Dneg = abs(Zsc_map3Dneg);

            % Reshaping Z-map
            Zsc_map3Do2 = reshape(Iteract_Tmap',[size(fkeep,1),size(fkeep,2),size(fkeep,3)]);

            % Removing voxels with negative Z Score. Keep DB > Subj
            Zsc_map3D2 = Zsc_map3Do2;
            Zsc_map3D2(Zsc_map3D2 < 0) = 0;

            % Removing voxels with positive Z Score. Keep Subj > DB
            Zsc_map3Dneg2 = Zsc_map3Do2;
            Zsc_map3Dneg2(Zsc_map3Dneg2 > 0) = 0;
            Zsc_map3Dneg2 = abs(Zsc_map3Dneg2);

            gunzip([pathF 'mri' filesep 'wm' filesub{k} '.gz']);
            mStr = nifti([pathF 'mri' filesep 'wm' filesub{k}]); %reading segmented image
            MMat = mStr.dat(:,:,:);
            MMat(MMat < 0.3) = 0;
            MMat(MMat > 0) = 1;
            delete([pathF 'mri' filesep 'wm' filesub{k}]);

            extThre = str2num(get(handles.edit6,'String'));

            AtrophyFull = [WMdir filesub{k}(1:end-4),'_WM_Atrophy_Zmap_s',FWHMv,'.nii'];
            AtrophyThresh = [WMdir filesub{k}(1:end-4),'_WM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];
            HypertFull = [WMdir filesub{k}(1:end-4),'_WM_Hypertrophy_Zmap_s',FWHMv,'.nii'];
            HypertThresh = [WMdir filesub{k}(1:end-4),'_WM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];

            % Creating the whole-brain Z-Scored map
            fstru2 = fke;
            fstru2.dat.fname = AtrophyFull;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3D2 .* MMat;
            delete(fstru2.dat.fname);

            % Creating the whole-brain Z-Scored map
            fstru2 = fke;
            fstru2.dat.fname = HypertFull;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3Dneg2 .* MMat;
            create(fstru2) 

            % Labelling all final clusters to apply the extend threshold
            [L,NUM] = bwlabeln(Zsc_map3D > 0);
            Nclus = unique(L);
            ClusMask = ones(size(Zsc_map3D));

            % Reading all identified clusters and excluding smaller than the
            % "extThre"
            for uiy = 2:size(Nclus,1)
                ROI = single(L==Nclus(uiy));
                Nvox(uiy-1) = sum(ROI(:));
                if Nvox(uiy-1) < extThre
                    ClusMask = ClusMask - ROI;
                end
            end

            Zsc_map3D = Zsc_map3D .* ClusMask;

            % Labelling all final clusters to apply the extend threshold
            [Lneg,NUMneg] = bwlabeln(Zsc_map3Dneg > 0);
            Nclusneg = unique(Lneg);
            ClusMaskneg = ones(size(Zsc_map3Dneg));

            % Reading all identified clusters and excluding smaller than the
            % "extThre"
            for uiy2 = 2:size(Nclusneg,1)
                ROIneg = single(Lneg == Nclusneg(uiy2));
                NvoxNeg(uiy - 1) = sum(ROIneg(:));
                if NvoxNeg(uiy-1) < extThre
                    ClusMaskneg = ClusMaskneg - ROIneg;
                end
            end
            Zsc_map3Dneg = Zsc_map3Dneg .* ClusMaskneg;

            % Creating the final thresholded z_scored map
            fstru2 = fke;
            fstru2.dat.fname = AtrophyThresh;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3D .* MMat;
            create(fstru2) % Creating 4D file with the interactional maps
            fprintf('- Done\n');

            % Creating the whole-brain Z-Scored map
            fstru2 = fke;
            fstru2.dat.fname = HypertThresh;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3Dneg .* MMat;
            create(fstru2) 

            extThre = str2num(get(handles.edit6,'String'));

            % Labelling all final clusters to apply the extend threshold
            [L,NUM] = bwlabeln(Zsc_map3D > 0);
            Nclus = unique(L);
            ClusMask = ones(size(Zsc_map3D));

            % Reading all identified clusters and excluding smaller than the
            % "extThre"
            for uiy = 2:size(Nclus,1)
                ROI = single(L==Nclus(uiy));
                Nvox(uiy-1) = sum(ROI(:));
                if Nvox(uiy-1) < extThre
                    ClusMask = ClusMask - ROI;
                end
            end

            Zsc_map3D = Zsc_map3D .* ClusMask;

            % Labelling all final clusters to apply the extend threshold
            [Lneg,NUMneg] = bwlabeln(Zsc_map3Dneg > 0);
            Nclusneg = unique(Lneg);
            ClusMaskneg = ones(size(Zsc_map3Dneg));

            % Reading all identified clusters and excluding smaller than the
            % "extThre"
            for uiy2 = 2:size(Nclusneg,1)
                ROIneg = single(Lneg == Nclusneg(uiy2));
                NvoxNeg(uiy - 1) = sum(ROIneg(:));
                if NvoxNeg(uiy-1) < extThre
                    ClusMaskneg = ClusMaskneg - ROIneg;
                end
            end
            Zsc_map3Dneg = Zsc_map3Dneg .* ClusMaskneg;

            % Creating the final thresholded z_scored map
            fstru2 = fke;
            fstru2.dat.fname = AtrophyThresh;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3D .* MMat;
            create(fstru2) % Creating 4D file with the interactional maps
            fprintf('- Done\n');

            fprintf('- Creating slice view image with the results\n');
            imgBack = [pathF 'mri' filesep 'wm' filesub{k}];
            gunzip([imgBack,'.gz']);
            [~,nx1,~] = fileparts(AtrophyThresh);
            SSM_SliceView(imgBack,AtrophyThresh,0.01,0,'Axial','hot','best','Atrophy',...
                            [nx1,'.png'],WMdir)
            fprintf('- Done\n');

            % Creating the final thresholded z_scored map
            fstru2 = fke;
            fstru2.dat.fname = HypertThresh;
            fstru2.dat.dim = [size(Zsc_map3D,1) size(Zsc_map3D,2) size(Zsc_map3D,3)];
            fstru2.dat(:,:,:) = Zsc_map3Dneg .* MMat;
            create(fstru2) % Creating 4D file with the interactional maps
            fprintf('- Done\n');

            [~,nx2,~] = fileparts(HypertThresh);
            SSM_SliceView(imgBack,HypertThresh,0.01,0,'Axial','hot','best','Hypertrophy',...
                            [nx2,'.png'],WMdir)
            fprintf('-  Done\n');

            fprintf('- Starting procedures for anatomical description\n');
            SSM_AnatDescrip_Vx15({AtrophyThresh},...
                                    WMdir,[nx1,'.txt'],'map','AAL3');

            fprintf('- Done\n');
            SSM_AnatDescrip_Vx15({HypertThresh},...
                                    WMdir,[nx2,'.txt'],'map','AAL3');
            fprintf('- Done\n');

            fprintf('\n');
            fprintf('- Creating native/subjec space images\n');
            DefI = gunzip([pathF 'mri' filesep 'iy_' filesub{k} '.gz']);

            clear matlabbatch
            matlabbatch{1}.spm.util.defs.comp{1}.def = DefI;
            matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {AtrophyFull;
                                                               AtrophyThresh;
                                                               HypertFull;
                                                               HypertThresh};
            matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
            matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
            matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
            matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
            matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = 'Native_';
            SSM_run_batch(matlabbatch);

            delete([pathF 'mri' filesep 'iy_' filesub{k}])
            copyfile([pathsub,filesub{k}],[pathF,filesub{k}])
            StruMat = nifti([pathF filesub{k}]);
            PixDim = StruMat.hdr.pixdim(2:4);

            if any(PixDim ~= [1 1 1])
                copyfile([pathsub,filesub{k}],[pathF,'z0',filesub{k}])
                copyfile([pathsub,filesub{k}],[pathF,filesub{k}])
                StruMat = nifti([pathF filesub{k}]);
                PixDim = StruMat.hdr.pixdim(2:4);

                clear matlabbatch
                matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[SSdir2(1:end-3),'SSM_DimTmpl.nii']};
                matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[pathF filesub{k}]};
                matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
                SSM_run_batch(matlabbatch);

                clear matlabbatch
                matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[pathF,'z0',filesub{k}]};
                matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[pathF,'r',filesub{k}]};
                matlabbatch{1}.spm.spatial.coreg.estwrite.other = {[WMdir,'Native_',filesub{k}(1:end-4),'_WM_Atrophy_Zmap_s',FWHMv,'.nii'];
                                                                   [WMdir,'Native_',filesub{k}(1:end-4),'_WM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];
                                                                   [WMdir,'Native_',filesub{k}(1:end-4),'_WM_Hypertrophy_Zmap_s',FWHMv,'.nii'];
                                                                   [WMdir,'Native_',filesub{k}(1:end-4),'_WM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];};
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
                SSM_run_batch(matlabbatch);

                movefile([WMdir,'rNative_',filesub{k}(1:end-4),'_WM_Atrophy_Zmap_s',FWHMv,'.nii'],...
                         [WMdir,'Native_',filesub{k}(1:end-4),'_WM_Atrophy_Zmap_s',FWHMv,'.nii']);

                movefile([WMdir,'rNative_',filesub{k}(1:end-4),'_WM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'],...
                         [WMdir,'Native_',filesub{k}(1:end-4),'_WM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);

                movefile([WMdir,'rNative_',filesub{k}(1:end-4),'_WM_Hypertrophy_Zmap_s',FWHMv,'.nii'],...
                         [WMdir,'Native_',filesub{k}(1:end-4),'_WM_Hypertrophy_Zmap_s',FWHMv,'.nii']);

                movefile([WMdir,'rNative_',filesub{k}(1:end-4),'_WM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'],...
                         [WMdir,'Native_',filesub{k}(1:end-4),'_WM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            end
            
            gzip([WMdir,'Native_',filesub{k}(1:end-4),'_WM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            gzip([WMdir,'Native_',filesub{k}(1:end-4),'_WM_Atrophy_Zmap_s',FWHMv,'.nii']);
            gzip([WMdir,'Native_',filesub{k}(1:end-4),'_WM_Hypertrophy_Zmap_s',FWHMv,'.nii']);
            gzip([WMdir,'Native_',filesub{k}(1:end-4),'_WM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            
            delete([WMdir,'Native_',filesub{k}(1:end-4),'_WM_Atrophy_Thresh',num2str(round(FWER_thr(1)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            delete([WMdir,'Native_',filesub{k}(1:end-4),'_WM_Atrophy_Zmap_s',FWHMv,'.nii']);
            delete([WMdir,'Native_',filesub{k}(1:end-4),'_WM_Hypertrophy_Zmap_s',FWHMv,'.nii']);
            delete([WMdir,'Native_',filesub{k}(1:end-4),'_WM_Hypertrophy_Thresh',num2str(round(FWER_thr(2)*10)/10),'_Zmap_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            
            delete(imgBack);
            
            if exist([pathF,filesub{k}],'file')
                delete([pathF,filesub{k}]);
            end
            if exist([pathF,'z0',filesub{k}],'file')
                delete([pathF,'z0',filesub{k}]);
            end
            if exist([pathF,'r',filesub{k}],'file')
                delete([pathF,'r',filesub{k}]);
            end
            if exist([pathF,'rr',filesub{k}],'file')
                delete([pathF,'rr',filesub{k}]);
            end
            if exist([pathF,filesub{k}],'file')
                delete([pathF,filesub{k}]);
            end

            clear tmpt tpt4D_WM
        end

        %% if Focal cortical dysplasia
        if isequal(get(handles.FCD,'Value'),1)
            clear SB_Tplate1 SB_Tplate2 SB_Tplate3 SC_Tplate1 SC_Tplate2 SC_Tplate3

            if get(handles.AddFlair,'Value')
                if get(handles.HarmCB,'Value')
                    FCDdir = [pathF,filesep,'FCD_Morph-SK',FWHMv,'-Fla-Harm_',DatStrT,filesep];
                    fke = nifti([pathF 'mri' filesep 'hfs' FWHMv 'mwp1' filesub{k}]); %reading segmented image
                    fke2 = nifti([pathF 'mri' filesep 'hfs' FWHMv 'mwp2' filesub{k}]); %reading segmented image
                    UseHarm = 1;
                else
                    FCDdir = [pathF,filesep,'FCD_Morph-SK',FWHMv,'-Fla_',DatStrT,filesep];
                    fke = nifti([pathF 'mri' filesep 'fs' FWHMv 'mwp1' filesub{k}]); %reading segmented image
                    fke2 = nifti([pathF 'mri' filesep 'fs' FWHMv 'mwp2' filesub{k}]); %reading segmented image
                    UseHarm = 0;
                end
            else
                if get(handles.HarmCB,'Value')
                    FCDdir = [pathF,filesep,'FCD_Morph-SK',FWHMv,'-Harm_',DatStrT,filesep];
                    fke = nifti([pathF 'mri' filesep 'hs' FWHMv 'mwp1' filesub{k}]); %reading segmented image
                    fke2 = nifti([pathF 'mri' filesep 'hs' FWHMv 'mwp2' filesub{k}]); %reading segmented image
                    UseHarm = 1;
                else
                    FCDdir = [pathF,filesep,'FCD_Morph-SK',FWHMv,'_',DatStrT,filesep];
                    fke = nifti([pathF 'mri' filesep 's' FWHMv 'mwp1' filesub{k}]); %reading segmented image
                    fke2 = nifti([pathF 'mri' filesep 's' FWHMv 'mwp2' filesub{k}]); %reading segmented image
                    UseHarm = 0;
                end
            end

            % Reading post-processed GM map
            fkeep = fke.dat(:,:,:);
            fkeep2 = fke2.dat(:,:,:);

            mkdir(FCDdir);

            movefile([pathF,filesep,FileString],...
                     [FCDdir,FileString])

            % Renaming the database variable
            tmpt = tpt4D_GM;
            tmpt2 = tpt4D_WM;

            if ~get(handles.FixRan,'Value')
                clear tpt4D_GM tpt4D_WM
            end

            if handles.Run_Encode_DB
                % The SSM_Decode_DB_FCD_Vx15 function performs regressions of
                % covariates and the final test,
                % contrasting parameters to identify the lesion. In the case 
                % ThreshPrev is 0 (no previous threshold estimated with
                % permutation with the same exact parameters), the permutation
                % will be performed inside this function.

                if get(handles.covAge,'Value') && get(handles.checkbox4,'Value')
                % For the case age AND sex are covariates
                      if PrevThresh
                          % For the case there is previously estimated threshold
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                      else
                          % For the case there is not previously estimated threshold
                          % in this case, this very specific permutation
                          % condition will be stored and for further analysis,
                          % this condition will not recquired a permutation
                          % again.
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                          fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                          fprintf(fidThres,'%.1f',FWER_thr);
                          fclose(fidThres);
                      end
                else
                    if get(handles.covAge,'Value') || get(handles.checkbox4,'Value')
                    % For the case age OR sex is covariate
                        if get(handles.covAge,'Value')
                        % For the case only age is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f',FWER_thr);
                                  fclose(fidThres);
                              end
                        end
                        if get(handles.checkbox4,'Value')
                        % For the case only sex is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f',FWER_thr);
                                  fclose(fidThres);
                              end
                        end
                    else
                    % for the case neither age or sex were included as covariates
                          if PrevThresh
                              [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                            get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                            SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                          else
                              [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_Decode_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                            get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                            SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                              fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                              fprintf(fidThres,'%.1f',FWER_thr);
                              fclose(fidThres);
                          end
                    end
                end
            else    % If the user provides a custom reference dataset,
                    % these functions should be used, as no decoding is required.
                    % The alternative functions in this section are 
                    % open-source references for the SSM procedures.
                    % They are identical to their p-coded counterparts,
                    % differing only in the absence of decoding steps.
                    
                if get(handles.covAge,'Value') && get(handles.checkbox4,'Value')
                % For the case age AND sex are covariates
                      if PrevThresh
                          % For the case there is previously estimated threshold
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                      else
                          % For the case there is not previously estimated threshold
                          % in this case, this very specific permutation
                          % condition will be stored and for further analysis,
                          % this condition will not recquired a permutation
                          % again.
                          [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                        get(handles.checkbox4,'Value'),Age_Covar,agePat,Gen_Covar,GenPat,DBTIV,...
                                                                        SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                          fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                          fprintf(fidThres,'%.1f',FWER_thr);
                          fclose(fidThres);
                      end
                else
                    if get(handles.covAge,'Value') || get(handles.checkbox4,'Value')
                    % For the case age OR sex is covariate
                        if get(handles.covAge,'Value')
                        % For the case only age is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),Age_Covar,agePat,[],[],DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f',FWER_thr);
                                  fclose(fidThres);
                              end
                        end
                        if get(handles.checkbox4,'Value')
                        % For the case only sex is covariate
                              if PrevThresh
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                              else
                                  [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                                get(handles.checkbox4,'Value'),[],[],Gen_Covar,GenPat,DBTIV,...
                                                                                SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                                  fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                                  fprintf(fidThres,'%.1f',FWER_thr);
                                  fclose(fidThres);
                              end
                        end
                    else
                    % for the case neither age or sex were included as covariates
                          if PrevThresh
                              [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                            get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                            SubjTIV,get(handles.FixRan,'Value'),ThreshPrev,UseHarm);
                          else
                              [Iteract_Tmap_Thr,Iteract_Tmap,FWER_thr] = SSM_DB_FCD_Vx15(tmpt,tmpt2,fkeep,fkeep2,get(handles.covAge,'Value'),...
                                                                            get(handles.checkbox4,'Value'),[],[],[],[],DBTIV,...
                                                                            SubjTIV,get(handles.FixRan,'Value'),FWER_thrIn,UseHarm);

                              fidThres = fopen([SSdir2(1:end-3),'TmpDir',filesep,TextF,'.txt'],'w+');
                              fprintf(fidThres,'%.1f',FWER_thr);
                              fclose(fidThres);
                          end
                    end
                end
            end

            % Removing INF values from the map (probably resultant from
            % comparison with zero)
            Zsc_map = Iteract_Tmap;

            Zsc_map(isnan(Zsc_map)) = 0;
            Zsc_map(isinf(Zsc_map)) = max(Zsc_map(:));

            % Reshaping the Z-map
            Zsc_map3D = reshape(Zsc_map',[size(fkeep,1),size(fkeep,2),size(fkeep,3)]);
            Zsc_map3D(Zsc_map3D < 0) = 0;

            Iteract_Tmap_Thr3D = reshape(Iteract_Tmap_Thr',[size(fkeep,1),size(fkeep,2),size(fkeep,3)]);
            Iteract_Tmap_Thr3D(Iteract_Tmap_Thr3D < 0) = 0;
            Iteract_Tmap_Thr3D(isnan(Iteract_Tmap_Thr3D)) = 0;

            % Reading subject post-processed whole-brain image to create final
            % inclusive mask
            gunzip([pathF 'mri' filesep 'wm' filesub{k} '.gz']);
            maskStr = nifti([pathF 'mri' filesep 'wm' filesub{k}]); %reading segmented image
            IncMask = maskStr.dat(:,:,:);
            IncMask(IncMask < 0.3) = 0;
            IncMask(IncMask > 0) = 1;
            delete([pathF 'mri' filesep 'wm' filesub{k}])

            fprintf('- Creating resultant maps\n');

            % Creating the whole-brain Z-Scored map
            fstru2 = fke;
            fstru2.dat.fname = [FCDdir filesub{k}(1:end-4),'_Interactional_Zmap_s',FWHMv,'.nii'];
            fstru2.dat.dim = [size(fkeep,1) size(fkeep,2) size(fkeep,3)];
            fstru2.dat(:,:,:) = Zsc_map3D .* IncMask;
            create(fstru2)

            % Appliyng the alpha mask to Z-map
    %             threshZ = Total_Sig_Bin_P_Map.*Zsc_map3D;
            threshZ = Iteract_Tmap_Thr3D .* IncMask;
            threshZ(isnan(threshZ)) = 0;
            threshZ(isinf(threshZ)) = 0;

            % Labelling all final clusters to apply the extend threshold
            extThre = str2num(get(handles.edit6,'String'));

            [L,NUM] = bwlabeln(threshZ>0,26);
            Nclus = unique(L);
            ClusMask = ones(size(threshZ));

            % Reading all identified clusters and excluding smaller than the
            % "extThre"
            for uiy = 2:size(Nclus,1)
                ROI = single(L == Nclus(uiy));
                Nvox(uiy-1) = sum(ROI(:));
                if Nvox(uiy-1) < extThre
                    ClusMask = ClusMask - ROI;
                end
            end

            threshZF = threshZ .* ClusMask;

            % Creating the final thresholded z_scored map
            fstru2 = fke;
            fstru2.dat.fname = [FCDdir filesub{k}(1:end-4),'_FCD_map_Zsc',num2str(round(FWER_thr*10)/10),'_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];
            fstru2.dat.dim = [size(fkeep,1) size(fkeep,2) size(fkeep,3)];
            fstru2.dat(:,:,:) = threshZF .* IncMask;
            create(fstru2); % Creating 4D file with the interactional maps

            clear tmpt tmpt2 Zsc_map Zsc_map2 Pmap Pmap2 threshZ threshZ2 threshZF P_map3D P_map3D2 P_map3D_Log P_map3D_Log2

            imgOvl = [FCDdir filesub{k}(1:end-4),'_FCD_map_Zsc',num2str(round(FWER_thr*10)/10),'_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];

            fprintf('- Performing anatomical description\n');
            SSM_AnatDescrip_Vx15({imgOvl},FCDdir,[filesub{k}(1:end-4),...
                '_AAL_FCD_map_Zsc',num2str(round(FWER_thr*10)/10),'_ClustSz',...
                num2str(extThre),'vx_s',FWHMv,'.txt'],'map','AAL3');

            fprintf('- Creating slice view image with the results\n');
            imgBack = [pathF 'mri' filesep 'wm' filesub{k}];
            gunzip([imgBack,'.gz']);
            SSM_SliceView(imgBack,imgOvl,0.01,0,'Axial','hot','best','FCD',...
                [filesub{k}(1:end-4),'_SliceView_FCD_map_Zsc',num2str(round(FWER_thr*10)/10),...
                '_ClustSz',num2str(extThre),'vx_s',FWHMv,'.png'],FCDdir);

            imgOv23 = [FCDdir filesub{k}(1:end-4),'_Interactional_Zmap_s',FWHMv,'.nii'];
            SSM_SliceView(imgBack,imgOv23,1,0,'Axial','hot','best','FCD',...
                [filesub{k}(1:end-4),'_SliceView_FCD_map_Unthresholded_s',FWHMv,'.png'],FCDdir);

            % Now, the deformation of the MNI ROI into the registered (or not)
            % native T1 space
            fprintf('\n');
            fprintf('- Creating native/subjec space images\n');
            DefI = gunzip([pathF 'mri' filesep 'iy_' filesub{k} '.gz']);
            
            clear matlabbatch
            matlabbatch{1}.spm.util.defs.comp{1}.def = DefI;
            matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {imgOvl};
            matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
            matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
            matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
            matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
            matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = 'Native_';
            SSM_run_batch(matlabbatch);

            clear matlabbatch
            matlabbatch{1}.spm.util.defs.comp{1}.def = DefI;
            matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {[FCDdir filesub{k}(1:end-4),'_Interactional_Zmap_s',FWHMv,'.nii']};
            matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
            matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
            matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
            matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
            matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = 'Native_';
            SSM_run_batch(matlabbatch);

            delete([pathF 'mri' filesep 'iy_' filesub{k}])
            copyfile([pathsub,filesub{k}],[pathF,filesub{k}])
            StruMat = nifti([pathF filesub{k}]);
            PixDim = StruMat.hdr.pixdim(2:4);

            if any(PixDim ~= [1 1 1])
                F1name = [FCDdir filesep,'Native_',filesub{k}(1:end-4),'_FCD_map_Zsc',num2str(round(FWER_thr*10)/10),'_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'];
                F2name = [FCDdir filesep,'Native_',filesub{k}(1:end-4),'_Interactional_Zmap_s',FWHMv,'.nii'];
                copyfile([pathsub,filesub{k}],[pathF,'z0',filesub{k}])
                copyfile([pathsub,filesub{k}],[pathF,filesub{k}])
                StruMat = nifti([pathF filesub{k}]);
                PixDim = StruMat.hdr.pixdim(2:4);

                clear matlabbatch
                matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[SSdir2(1:end-3),'SSM_DimTmpl.nii']};
                matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[pathF filesub{k}]};
                matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
                SSM_run_batch(matlabbatch);

                clear matlabbatch
                matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[pathF,'z0',filesub{k}]};
                matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[pathF,'r',filesub{k}]};
                matlabbatch{1}.spm.spatial.coreg.estwrite.other = {F1name;F2name};
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
                matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
                SSM_run_batch(matlabbatch);

                movefile([FCDdir filesep,'rNative_',filesub{k}(1:end-4),'_FCD_map_Zsc',num2str(round(FWER_thr*10)/10),'_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii'],...
                    [FCDdir filesep,'Native_',filesub{k}(1:end-4),'_FCD_map_Zsc',num2str(round(FWER_thr*10)/10),'_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
                movefile([FCDdir filesep,'rNative_',filesub{k}(1:end-4),'_Interactional_Zmap_s',FWHMv,'.nii'],...
                    [FCDdir filesep,'Native_',filesub{k}(1:end-4),'_Interactional_Zmap_s',FWHMv,'.nii']);
            end
            
            gzip([FCDdir filesep,'Native_',filesub{k}(1:end-4),'_FCD_map_Zsc',num2str(round(FWER_thr*10)/10),'_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            gzip([FCDdir filesep,'Native_',filesub{k}(1:end-4),'_Interactional_Zmap_s',FWHMv,'.nii']);
            gzip([FCDdir filesub{k}(1:end-4),'_Interactional_Zmap_s',FWHMv,'.nii']);
            gzip(imgOvl);
            
            delete([FCDdir filesep,'Native_',filesub{k}(1:end-4),'_FCD_map_Zsc',num2str(round(FWER_thr*10)/10),'_ClustSz',num2str(extThre),'vx_s',FWHMv,'.nii']);
            delete([FCDdir filesep,'Native_',filesub{k}(1:end-4),'_Interactional_Zmap_s',FWHMv,'.nii']);
            delete([FCDdir filesub{k}(1:end-4),'_Interactional_Zmap_s',FWHMv,'.nii']);
            delete(imgOvl);
            
            delete(imgBack);
            
            if exist([pathF,filesub{k}],'file')
                delete([pathF,filesub{k}]);
            end
            if exist([pathF,'z0',filesub{k}],'file')
                delete([pathF,'z0',filesub{k}]);
            end
            if exist([pathF,'r',filesub{k}],'file')
                delete([pathF,'r',filesub{k}]);
            end
            if exist([pathF,'rr',filesub{k}],'file')
                delete([pathF,'rr',filesub{k}]);
            end
            if exist([pathF,filesub{k}],'file')
                delete([pathF,filesub{k}]);
            end
        end

        fprintf('- Done!');
        fprintf('\n');
    end
    fclose('all');
    set(handles.status_txt,'String','Done!');
    fprintf('\n\n- Procedures fineshed at: %s\n',datetime);
    fprintf('##############################################\n');
handles.output = hObject;
guidata(hObject, handles);
end

function SubjAgef(hObject, eventdata)
handles = guidata(hObject);

    handles.AgeVet = str2num(get(handles.SubjAge,'String'));
    if ~isempty(handles.AgeVet)
        set(handles.covAge,'Enable','on')
        set(handles.covAge,'Value',1)
        handles.AgeOk = 1;
    else
        set(handles.covAge,'Enable','off')
        set(handles.covAge,'Value',0)
    end
    
handles.output = hObject;
guidata(hObject, handles);
end

function AddAgeListf(hObject, eventdata)
handles = guidata(hObject);

    filesub = handles.filesub;

    AgeVet = 0;
    [fileReg,pathReg] = uigetfile({'*.txt;*.xlsx;*.xls;*.csv','Tab Files'},'Select the colum tabulated file','MultiSelect','off',handles.pathsub);
    set(handles.AddAgeList,'String','Loading...');
    set(handles.AddAgeList,'ForegroundColor',[1 0 0]);
    drawnow
    
    RAW = readmatrix([pathReg fileReg]);
    %[NUM,TXT,RAW] = xlsread([pathReg fileReg]);
    %RAW(cellfun(@isempty,RAW)) = [];

    for xi = 1:size(RAW,1)
        if ~isnan(RAW(xi,1))
            AgeVet(xi,1) = RAW(xi,1);
        else
            AgeVet(xi,1) = [];
        end
    end

    if ~isequal(size(AgeVet,1),size(filesub,2))
        warndlg('The number of cells in your loaded file do not match with the number of subjects loaded!')
        set(handles.checkbox5,'Value',0)
    else
        set(handles.checkbox5,'Value',1)
        set(handles.covAge,'Value',1)
        set(handles.covAge,'Enable','on')
        set(handles.FloaRan,'Enable','on')
        handles.AgeOk = 1;
        if handles.ImgOk %&& handles.AgeOk && handles.SexOk 
            set(handles.runb,'Enable','on')
        end
        drawnow
    end

    handles.AgeVet = AgeVet;
    set(handles.AddAgeList,'String','Add Age List...');
    set(handles.AddAgeList,'ForegroundColor',[0 0 0]);
    drawnow

handles.output = hObject;
guidata(hObject, handles);
end

function SubjListf(hObject, eventdata)
handles = guidata(hObject);

    filesub = handles.filesub;

    subL = transpose(filesub);
    SSdir = which('SSM');
    tmpDIR = [SSdir(1:end-5) 'TmpDir' filesep];
    if ~exist(tmpDIR,'dir')
        mkdir(tmpDIR)
    end

    sList = size(subL,1);
    fideSL = fopen([tmpDIR 'Subject_List.txt'],'w+'); % CHARGE OUTPUT LOG FILE

    for lt = 1:sList
        fprintf(fideSL,'%.3d - %s\r\n',lt,filesub{lt});
    end
    fclose(fideSL)

    open([tmpDIR 'Subject_List.txt'])

handles.output = hObject;
guidata(hObject, handles);
end

function MinAgef(hObject, eventdata)
handles = guidata(hObject);

    set(handles.RefChe,'Value',0)
    set(handles.runb,'Enable','off')
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])

handles.output = hObject;
guidata(hObject, handles);
end

function MaxAgef(hObject, eventdata)
handles = guidata(hObject);

    set(handles.RefChe,'Value',0)
    set(handles.runb,'Enable','off')
    
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    
handles.output = hObject;
guidata(hObject, handles);
end

function AllCtrDBf(hObject, eventdata)
handles = guidata(hObject);

    SSdir2 = which('SSM');
    SSdir2 = [SSdir2(1:end-5) 'DB' filesep];
    load([SSdir2 'Ida_Ctr.mat']);
    set(handles.RefChe,'Value',0)
    set(handles.runb,'Enable','off')

    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])

    if isequal(get(handles.AllCtrDB, 'Value'),1)
        set(handles.text6,'Enable','off')
        set(handles.MinAge,'Enable','off')
        set(handles.text7,'Enable','off')
        set(handles.MaxAge,'Enable','off')
        set(handles.MinAge,'String','')
        set(handles.MaxAge,'String','')
        set(handles.males,'Enable','off')
        set(handles.females,'Enable','off')
        set(handles.males,'Value',1)
        set(handles.females,'Value',1)
        set(handles.MinAge,'String','')
        set(handles.MaxAge,'String','')
        set(handles.nPermEdit,'Enable','on')
        set(handles.SubFactEdit,'Enable','on')
    else
        set(handles.text6,'Enable','on')
        set(handles.MinAge,'Enable','on')
        set(handles.text7,'Enable','on')
        set(handles.MaxAge,'Enable','on')
        set(handles.males,'Enable','on')
        set(handles.females,'Enable','on')
        set(handles.MinAge,'String',num2str(min(Ida_Ctr)))
        set(handles.MaxAge,'String',num2str(max(Ida_Ctr)))
    end

    handles.output = hObject;
    guidata(hObject, handles);
    RefreshAgef(hObject, eventdata)
end

function RefreshAgef(hObject, eventdata)
handles = guidata(hObject);

    set(handles.RefChe,'Value',1)
    SSdir2 = which('SSM');
    SSdir2 = [SSdir2(1:end-5) 'DB' filesep];
    
    load([SSdir2 'Gene_Ctr.mat']);
    load([SSdir2 'Ida_Ctr.mat']);

    if isequal(get(handles.AllCtrDB,'Value'),1)
        SelectVet = ones(size(Gene_Ctr,1),1);
        VetGenF = Gene_Ctr;
        AllAGEs = Ida_Ctr;

        set(handles.nOfCtr,'String',num2str(size(Gene_Ctr,1)))
        set(handles.avgAge,'String',[num2str(round(mean(Ida_Ctr))) '/' num2str(round(std(Ida_Ctr)))])
        set(handles.text17,'String',num2str(min(Ida_Ctr)))
        set(handles.text21,'String',num2str(max(Ida_Ctr)))
        set(handles.nOfFemale,'String',num2str(size(Gene_Ctr,1)-sum(Gene_Ctr)))
        set(handles.nOfMale,'String',num2str(sum(Gene_Ctr)))
        if handles.ImgOk %&& handles.AgeOk && handles.SexOk 
            set(handles.runb,'Enable','on')
        end
        drawnow

        nCtr = str2num(get(handles.nOfCtr,'String'));

        if nCtr >= 40 %this is not a lock. This is a condition for statistical robustiness  (you can change)
            PercDB = str2num(get(handles.SubFactEdit,'String'));
            if (nCtr * PercDB) > 1
                MaxnTests = nchoosek(nCtr,nCtr - (round(nCtr .* PercDB)));
            else
                MaxnTests = nCtr;
            end
        else
            warndlg(sprintf('Your final sample size if smaller than 40 (%d). Your permutation test will be a leave-one-out with only %d iterations',nCtr,nCtr));
            MaxnTests = nCtr;
            set(handles.SubFactEdit,'String','1')
        end
        
        if MaxnTests > 1000 % 1000 is just a suggestion
        	set(handles.nPermEdit,'String','1000')
        else
            set(handles.nPermEdit,'String',num2str(MaxnTests))
        end

        set(handles.nPermEdit,'Enable','on')
        set(handles.SubFactEdit,'Enable','on')
    else
        if isequal(get(handles.males,'Value'),0)
           FtmpG = (Gene_Ctr == 0);
           FtmpG = single(FtmpG);
        end
        if isequal(get(handles.females,'Value'),0)
            FtmpG = (Gene_Ctr == 1);
           FtmpG = single(FtmpG);
        end

        if isequal((get(handles.females,'Value') + get(handles.males,'Value')),2)
           FtmpG = ones(size(Gene_Ctr,1),1);
        end

        FtmpImin = (Ida_Ctr >= str2num(get(handles.MinAge,'String')));
        FtmpImax = (Ida_Ctr <= str2num(get(handles.MaxAge,'String')));
        FtmpI = FtmpImin .* FtmpImax;

        SelectVet = FtmpG .* FtmpI;

        numOfsuj = sum(SelectVet);
        
        if handles.Run_Encode_DB
            % Changing this value will not solve the lock. This condition will be verified again latter.
            MinLimitSize = 10;
        else
            MinLimitSize = 0;
        end
        
        if numOfsuj < MinLimitSize
            warndlg('The current selection would result in a database with fewer than 10 subjects, which is not permitted', 'Attention');
            AllAGEs = [];
            VetGenF = [];
        else
            SelectAge = SelectVet .* Ida_Ctr;
            SelectAgeAvg = round((sum(SelectAge)) / nnz(SelectAge));

            AllAGEs = SelectAge;
            AllAGEs(AllAGEs == 0) = [];
            desvPad = round(std(AllAGEs));

            ActMinAge1 = SelectAge;
            ActMinAge1(ActMinAge1 == 0) = [];
            ActMinAge = min(ActMinAge1);

            ActMaxAge = max(SelectAge);

            NofFem = sum(SelectVet .* (single(Gene_Ctr==0)));
            VetFem = -1 * (SelectVet .* (single(Gene_Ctr==0)));
            NofMal = sum(SelectVet .* (single(Gene_Ctr==1)));
            VetMen = SelectVet .* (single(Gene_Ctr==1));

            VetGenF = VetFem + VetMen;
            VetGenF(VetGenF == 0) = [];
            VetGenF(VetGenF == -1) = 0; %1 for male 0 for female

            set(handles.nOfCtr,'String',num2str(numOfsuj))
            set(handles.avgAge,'String',[num2str(SelectAgeAvg) '/' num2str(desvPad)])
            set(handles.text17,'String',num2str(ActMinAge))
            set(handles.text21,'String',num2str(ActMaxAge))
            set(handles.nOfFemale,'String',num2str(NofFem))
            set(handles.nOfMale,'String',num2str(NofMal))

            nCtr = str2num(get(handles.nOfCtr,'String'));
            if nCtr >= 40 % this is not a lock. This is a condition for statistical robustiness (you can change)
                PercDB = str2num(get(handles.SubFactEdit,'String'));
                if PercDB == 1
                    PercDB = 0.95;
                    set(handles.SubFactEdit,'String','0.95')
                end
                if (nCtr * PercDB) > 1
                    MaxnTests = nchoosek(nCtr,nCtr - (round(nCtr .* PercDB)));
                else
                    MaxnTests = nCtr;
                end
            else
                warndlg(sprintf('Your final sample size if smaller than 40 (%d). Your permutation test will be a leave-one-out with only %d iterations',nCtr,nCtr));
                MaxnTests = nCtr;
                set(handles.SubFactEdit,'String','1')
            end
            
            if MaxnTests > 1000
                set(handles.nPermEdit,'String','1000')
            else
                set(handles.nPermEdit,'String',num2str(MaxnTests))
            end

            set(handles.nPermEdit,'Enable','on')
            set(handles.SubFactEdit,'Enable','on')
            if handles.ImgOk %&& handles.AgeOk && handles.SexOk 
                set(handles.runb,'Enable','on')
            end
        end
    end
    handles.MaxnTests = MaxnTests;
    
    handles.SelectVet = SelectVet;
    handles.AllAGEs = AllAGEs;
    handles.VetGenF = VetGenF;

handles.output = hObject;
guidata(hObject, handles);
end

function malesf(hObject, eventdata)
handles = guidata(hObject);

    if isequal(get(handles.males, 'Value'),0)
        set(handles.females,'Value',1)
    end
    
    set(handles.RefChe,'Value',0)
    set(handles.runb,'Enable','off')
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    
handles.output = hObject;
guidata(hObject, handles);
end

function femalesf(hObject, eventdata)
handles = guidata(hObject);

    if isequal(get(handles.females, 'Value'),0)
        set(handles.males,'Value',1)
    end
    set(handles.RefChe,'Value',0)
    set(handles.runb,'Enable','off')
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.9 0.3 0.3])
    pause(0.2)
    set(handles.RefreshAge,'BackgroundColor',[0.94 0.94 0.94])
    
handles.output = hObject;
guidata(hObject, handles);
end

function malePf(hObject, eventdata)
handles = guidata(hObject);

    if isequal(get(handles.maleP, 'Value'),1)
        set(handles.femP,'Value',0)
        handles.GenVet = 1;
        set(handles.checkbox4,'Value',1)
        set(handles.checkbox4,'Enable','on')
    else
        set(handles.femP,'Value',1)
        handles.GenVet = 0;
    end
    handles.SexOk = 1;
    
handles.output = hObject;
guidata(hObject, handles);
end

function femPf(hObject, eventdata)
handles = guidata(hObject);

    if isequal(get(handles.femP, 'Value'),1)
        set(handles.maleP,'Value',0)
        handles.GenVet = 1;
        set(handles.checkbox4,'Value',1)
        set(handles.checkbox4,'Enable','on')
    else
        set(handles.maleP,'Value',1)
        handles.GenVet = 0;
    end
    handles.SexOk = 1;
    
handles.output = hObject;
guidata(hObject, handles);
end

function genListf(hObject, eventdata)
handles = guidata(hObject);

    filesub = handles.filesub;
    GenVet = 0;
    [fileGen,pathGen] = uigetfile({'*.txt;*.xlsx;*.xls;*.csv','Tab Files'},'Select the colum tabulated file','MultiSelect','off',handles.pathsub);
    
    set(handles.genList,'String','Loading...');
    set(handles.genList,'ForegroundColor',[1 0 0]);
    drawnow
    
    RAW = readmatrix([pathGen fileGen]);

    for xi = 1:size(RAW,1)
        if ~isnan(RAW(xi,1))
            GenVet(xi,1) = RAW(xi,1);
        else
            GenVet(xi,1) = [];
        end
    end
%     [NUM2,TXT2,RAW2] = xlsread([pathGen fileGen]);
%     
%     RAW2(cellfun(@isempty,RAW2)) = [];
% 
%     for xi = 1:size(RAW2,1)
%         if ~isnan(RAW2{xi,1})
%             GenVet(xi,1) = RAW2{xi,1};
%         else
%             GenVet(xi,1) = [];
%         end
%     end

    if ~isequal(size(GenVet,1),size(filesub,2))
            warndlg('The number of cells in your loaded file file do not match with the number of subjects loaded!')
            set(handles.checkbox6,'Value',0)
    else
        if ~isequal(GenVet(1),1) 
            if ~isequal(GenVet(1),0)
                warndlg('The genders should to be defined as 0 for female and 1 for male!')
                set(handles.checkbox11,'Value',0)
            else
                set(handles.checkbox11,'Value',1)
                set(handles.checkbox4,'Enable','on')
                set(handles.checkbox4,'Value',1)
                handles.SexOk = 1;
            end
        else
            set(handles.checkbox11,'Value',1)
            set(handles.checkbox4,'Enable','on')
            set(handles.checkbox4,'Value',1)
            handles.SexOk = 1;
        end
    end
    if handles.ImgOk %&& handles.AgeOk && handles.SexOk 
        set(handles.runb,'Enable','on')
    end
    drawnow
    
    handles.GenVet = GenVet;
    set(handles.genList,'String','Add Sex List...');
    set(handles.genList,'ForegroundColor',[0 0 0]);
    drawnow
    
handles.output = hObject;
guidata(hObject, handles);
end

function PopMenuSmoothKf(hObject, eventdata)
handles = guidata(hObject);

    switch  get(handles.PopMenuSmoothK,'Value')
        case 1
            set(handles.edit6,'String',num2str(round((4/1.5)^3)))
        case 2
            set(handles.edit6,'String',num2str(round((6/1.5)^3)))
        case 3
            set(handles.edit6,'String',num2str(round((8/1.5)^3)))
        case 4
            set(handles.edit6,'String',num2str(round((10/1.5)^3)))
        case 5
            set(handles.edit6,'String',num2str(round((12/1.5)^3)))
    end
    
handles.output = hObject;
guidata(hObject, handles);
end

function FixRanf(hObject, eventdata)
handles = guidata(hObject);

    if get(handles.FixRan,'Value')
        set(handles.FloaRan,'Value',0)
        set(handles.text25,'Enable','off')
        set(handles.AgeRanEdit,'Enable','off')
        set(handles.ConstSS,'Enable','off')
        set(handles.FollRule,'Enable','off')

        set(handles.AllCtrDB,'Enable','on')
        set(handles.RefreshAge,'Enable','on')
        set(handles.MinAge,'Enable','off')
        set(handles.MaxAge,'Enable','off')
        set(handles.males,'Enable','off')
        set(handles.females,'Enable','off')

        set(handles.nOfCtr,'Enable','on')
        set(handles.avgAge,'Enable','on')
        set(handles.text17,'Enable','on')
        set(handles.text21,'Enable','on')
        set(handles.nOfMale,'Enable','on')
        set(handles.nOfFemale,'Enable','on')
    end
    
handles.output = hObject;
guidata(hObject, handles);
end

function FloaRanf(hObject, eventdata)
handles = guidata(hObject);

    if get(handles.FloaRan,'Value')
        set(handles.FixRan,'Value',0)
        set(handles.AllCtrDB,'Enable','off')
        set(handles.RefreshAge,'Enable','off')
        set(handles.MinAge,'Enable','off')
        set(handles.MaxAge,'Enable','off')
        set(handles.males,'Enable','off')
        set(handles.females,'Enable','off')
        set(handles.nOfCtr,'Enable','off')
        set(handles.avgAge,'Enable','off')
        set(handles.text17,'Enable','off')
        set(handles.text21,'Enable','off')
        set(handles.nOfMale,'Enable','off')
        set(handles.nOfFemale,'Enable','off')

        if get(handles.checkbox5,'Value')
            set(handles.text25,'Enable','on')
            set(handles.AgeRanEdit,'Enable','on')
            set(handles.ConstSS,'Enable','on')
            set(handles.FollRule,'Enable','on')
            set(handles.RRnCtrTxt1,'Enable','on')
        else
            set(handles.text25,'Enable','off')
            set(handles.AgeRanEdit,'Enable','off')
            set(handles.ConstSS,'Enable','off')
            set(handles.FollRule,'Enable','off')
        end
        if get(handles.checkbox11,'Value')
            set(handles.MatchSex,'Enable','on')
        else
            set(handles.MatchSex,'Enable','off')
        end
    end
    
handles.output = hObject;
guidata(hObject, handles);
end

function AgeRanEditf(hObject, eventdata)
handles = guidata(hObject);

    if ~isempty(str2num(get(handles.AgeRanEdit,'String')))
        set(handles.AgeRanEdit,'String',num2str(round(str2num(get(handles.AgeRanEdit,'String')))))
        
        % Changing this condition will not solve the lock. This condition will be verified again latter.
        if str2num(get(handles.AgeRanEdit,'String')) == 0
            set(handles.runb,'Enable','off')
            warndlg('The current selection would result in a database with fewer than 10 subjects, which is not permitted.', 'Attention');
        else
            if get(handles.FollRule,'Value') %get(handles.MatchSex,'Value') || 
                nCtr = (str2num(get(handles.AgeRanEdit,'String')) * 2 * 2) + 4;
                if nCtr > 188
                    nCtr = 188;
                end
                if nCtr < 40 %this is not a lock. This is a condition for statistical robustiness  (you can change)
                    warndlg('The current selection may result in a ref. dataset with fewer than 40 subjects (depending on the sex distribution - which may be unbalanced - and age limits of the ref. dataset). This is allowed; however, if the case, the permutation test will be limited to a leave-one-out scheme, resulting in a small and variable number of permutations.', 'Attention');
                end
                set(handles.RRnCtrTxt2,'String','Vary')
            else
                nCtr = (str2num(get(handles.AgeRanEdit,'String')) * 2 * 4) + 4;
                if nCtr > 188
                    nCtr = 188;
                end
                if nCtr < 40 %this is not a lock. This is a condition for statistical robustiness  (you can change)
                    warndlg(sprintf('Your final sample size if smaller than 40 (%d). Your permutation test will be a leave-one-out with only %d iterations',nCtr,nCtr));
                    MaxnTests = nCtr;
                    set(handles.SubFactEdit,'String','1')
                else
                    PercDB = str2num(get(handles.SubFactEdit,'String'));
                    if isempty(PercDB)
                        PercDB = 0.95;
                        set(handles.SubFactEdit,'String','0.95');
                    end
                    if PercDB == 1
                        MaxnTests = nchoosek(nCtr,nCtr - 1);
                    else
                        if (nCtr * PercDB) > 1
                            MaxnTests = nchoosek(nCtr,nCtr - (round(nCtr .* PercDB)));
                        else
                            MaxnTests = nCtr;
                        end
                    end
                end
                
                set(handles.RRnCtrTxt2,'String',num2str(nCtr))
                
                if MaxnTests > 1000
                    set(handles.nPermEdit,'String','1000');
                else
                    set(handles.nPermEdit,'String',num2str(MaxnTests));
                end
                
                set(handles.nPermEdit,'Enable','on')
                set(handles.SubFactEdit,'Enable','on')
                if handles.ImgOk %&& handles.AgeOk && handles.SexOk 
                    set(handles.runb,'Enable','on')
                end
                handles.MaxnTests = MaxnTests;
                drawnow
            end
        end
    else
        set(handles.runb,'Enable','off')
    end
    
handles.output = hObject;
guidata(hObject, handles);
end

function MatchSexf(hObject, eventdata)
handles = guidata(hObject);

    if get(handles.MatchSex,'Value')
        warndlg('With this option enabled, the reference dataset size may vary depending on sex distribution (which may be unbalanced) and age constraints')
        set(handles.checkbox4,'Enable','off')
        set(handles.checkbox4,'Value',0)
    else
        set(handles.checkbox4,'Enable','on')
        set(handles.checkbox4,'Value',0)
    end

handles.output = hObject;
guidata(hObject, handles);
AgeRanEditf(hObject, eventdata)
end

function nPermEditf(hObject, eventdata)
handles = guidata(hObject);

    if str2num(get(handles.nPermEdit,'String')) > handles.MaxnTests
        set(handles.nPermEdit,'String',num2str(handles.MaxnTests))
    end

handles.output = hObject;
guidata(hObject, handles);
end

function SubFactEditf(hObject, eventdata)
handles = guidata(hObject);

    if get(handles.FixRan,'Value')
        nCtr = str2num(get(handles.nOfCtr,'String'));
    else
        nCtr = (str2num(get(handles.AgeRanEdit,'String')) * 2 * 4) + 4;
        if nCtr > 188
            nCtr = 188;
        end
    end
    
    PercDB = str2num(get(handles.SubFactEdit,'String'));
    if PercDB == 1
        MaxnTests = nchoosek(nCtr,nCtr - 1);
    else
        if (nCtr .* PercDB) > 1
            MaxnTests = nchoosek(nCtr,nCtr - (round(nCtr .* PercDB)));
        else
            MaxnTests = nCtr;
        end
    end
    if MaxnTests > 1000
        set(handles.nPermEdit,'String','1000');
    else
        set(handles.nPermEdit,'String',num2str(MaxnTests));
    end
    handles.MaxnTests = MaxnTests;
    
handles.output = hObject;
guidata(hObject, handles);
end

function radiobutton15f(hObject, eventdata)
handles = guidata(hObject);

    if get(handles.radiobutton15,'Value')
        set(handles.radiobutton16,'Value',0)
    else
        set(handles.radiobutton16,'Value',1)
    end
    
handles.output = hObject;
guidata(hObject, handles);
end


function radiobutton16f(hObject, eventdata)
handles = guidata(hObject);

    if get(handles.radiobutton16,'Value')
        set(handles.radiobutton15,'Value',0)
    else
        set(handles.radiobutton15,'Value',1)
    end
    
handles.output = hObject;
guidata(hObject, handles);
end

function FollRulef(hObject, eventdata)
handles = guidata(hObject);

    if get(handles.FollRule,'Value')
        set(handles.ConstSS,'Value',0)
        AgeRanEditf(hObject, eventdata)
    else
        set(handles.FollRule,'Value',1)
        set(handles.ConstSS,'Value',0)
        AgeRanEditf(hObject, eventdata)
    end
    
handles.output = hObject;
guidata(hObject, handles);
end


function ConstSSf(hObject, eventdata)
handles = guidata(hObject);

    if get(handles.ConstSS,'Value')
        set(handles.FollRule,'Value',0)
        AgeRanEditf(hObject, eventdata)
    else
        set(handles.FollRule,'Value',0)
        set(handles.ConstSS,'Value',1)
        AgeRanEditf(hObject, eventdata)
    end
    
handles.output = hObject;
guidata(hObject, handles);
end

function AddFlairf(hObject, eventdata)
handles = guidata(hObject);

    if get(handles.AddFlair,'Value')
        [fileFlair,pathFlair] = uigetfile({'*.nii' ,'*.nii (NIfTI)'},...
            'Select all the patient files' ,'MultiSelect','on',handles.pathsub);

        if ~iscell(fileFlair)
            fileFlair = {fileFlair};
        end

        if ~isequal(size(fileFlair,2),size(handles.filesub,2))
            warndlg('The number of FLAIR images loaded should matches the number of T1-WI included','Attention');
            set(handles.AddFlairTxt,'String','No images loaded');
            set(handles.AddFlair,'Value',0);
        else
            set(handles.AddFlairTxt,'String',[num2str(size(fileFlair,2)),' image(s) loaded']);
            handles.fileFlair = fileFlair;
            handles.pathFlair = pathFlair;
        end
    end

handles.output = hObject;
guidata(hObject, handles);
end

function HarmCBf(hObject, eventdata)
handles = guidata(hObject);

    handles.HarmRef = [];
    
    if get(handles.HarmCB,'Value')      

        % Start NewGUI
        ScreSize = get(0,'screensize');
        ScreSize = ScreSize(3:end);

        SSfactorX2 = 0.4;
        SSfactorY2 = 0.43;

        InipositX2 = (1-SSfactorX2)/2;
        InipositY2 = (1-SSfactorY2)/2;

        MainFig2 = figure('Name','Single-Subject Morphometry: harmonization options','NumberTitle','off','Color',[0.9 0.9 0.9],...
                    'Position',[ScreSize(1)*InipositX2 ScreSize(2)*InipositY2 ScreSize(1)*SSfactorX2 ScreSize(2)*SSfactorY2],...
                    'MenuBar','none','Tag','SSM_Main','CloseRequestFcn',@closereqF);

        handles.HEstim = uicontrol('Parent',MainFig2,'Style','checkbox','Units',...
            'normalized','Position',[0.01 0.84 0.3 0.06],'FontUnits',...
            'normalized','FontSize',0.55,'String','Estimate using loaded cases','BackgroundColor',[0.9 0.9 0.9],...
            'tooltip',{'Requires at least 10 eligible loaded cases'},...
            'Visible','on','Enable','on','Callback',@HEstimf);

        handles.HAdd = uicontrol('Parent',MainFig2,'Style','checkbox','Units',...
            'normalized','Position',[0.3 0.84 0.35 0.06],'FontUnits',...
            'normalized','FontSize',0.55,'String','Add previuosly estimated param...','BackgroundColor',[0.9 0.9 0.9],...
            'tooltip',{'Select the HarmomParam_***.mat file containing the harmonization parameters for the current cases'},...
            'Visible','on','Enable','on','Callback',@HAddf);

        handles.HFlairOnly = uicontrol('Parent',MainFig2,'Style','checkbox','Units',...
            'normalized','Position',[0.62 0.84 0.35 0.06],'FontUnits',...
            'normalized','FontSize',0.55,'String','Use SSM''s native FLAIR bias param...','BackgroundColor',[0.9 0.9 0.9],...
            'tooltip',{'Enable data harmonization for undesired FLAIR images bias using SSM integrated parameters'},...
            'Visible','on','Enable','off','Callback',@HFlairOnlyf);
        
        handles.Finaltxt = uicontrol('Parent',MainFig2,'Style','edit','Units',...
            'normalized','Position',[0.01 0.1 0.98 0.7],'FontSize',10,...
            'String','','BackgroundColor',[1 1 1],'Min',1,'Max',10,...
            'HorizontalAlignment','Left','Enable','inactive');
        
        handles.SeCB = uicontrol('Parent',MainFig2,'Style','pushbutton','Units',...
            'normalized','Position',[0.33 0.02 0.35 0.06],'FontUnits',...
            'normalized','FontSize',0.55,'String','Save and Close','BackgroundColor',[0.9 0.9 0.9],...
            'tooltip',{''},...
            'Visible','on','Enable','on','Callback',@SeCBf);
            
        if get(handles.AddFlair,'Value')
            set(handles.HFlairOnly,'Enable','on')
        end
        
        TextOpt = {'1 - Estimate using loaded cases';...
                  ['Harmonization parameters are estimated directly from the currently loaded cases.',...
                  ' This approach uses the available sample to model and correct for shared biases',...
                  ' (e.g., scanner, acquisition protocol, or FLAIR-related effects).'];...
                  ['While convenient, this method should be used with caution, as effects',...
                  ' common to the sample including potential pathological patterns may',...
                  ' influence the estimation and be partially attenuated.'];...
                  '         - You will be asked how the loaded subjects should be used during parameter estimation.';...
                  '';...
                  '2 - Add previously estimated parameters';...
                 ['Harmonization is performed using parameters estimated from an external.',...
                  ' dataset. These parameters should ideally be derived from images acquired.',...
                  ' under similar conditions (e.g., same scanner, protocol, and sequence characteristics)..'];...
                 ['This is the recommended approach when suitable control data are available, as it ',...
                  ' reduces bias while minimizing the risk of attenuating relevant subject-specific alterations.'];...
                  '';...
                  '3 - Use SSM native FLAIR bias parameters';...
                  ['Predefined SSM harmonization parameters specifically designed to correct FLAIR-related',...
                  ' biases. These parameters were estimated by comparing the SSM reference dataset',...
                  ' with a control group with similar images (and Flair biased).'];...
                 ['This option is intended as a fallback when user-defined harmonization is not feasible,',...
                 ' helping to mitigate FLAIR-induced biases while preserving the potential advantages of including FLAIR information.']};
        set(handles.Finaltxt,'String',TextOpt);
        
        handles.HarmEstim = 0;
        handles.HarmNativeFlair = 0;
        handles.HarmnAdd = 0;

        handles.output = hObject;
        guidata(hObject, handles);
        
        waitfor(MainFig2,'Name');
    else
    	set(handles.HarmCBTxt,'String','')
    end

    function HEstimf(subObject, eventdata)
    handles = guidata(hObject);
        if get(handles.HEstim,'Value')
            handles.HarmEstim = 1;
            handles.HarmNativeFlair = 0;
            handles.HarmnAdd = 0;
            set(handles.HFlairOnly,'Value',0)
            set(handles.HAdd,'Value',0)
            
            if handles.nsubje < 10
                warndlg(['Its recquired more 10 or more subjects for harmonization parameter estimation, and you loaded ',num2str(handles.nsubje)],'Few Subjects Loaded');
                set(handles.HEstim,'Value',0);

                TextOpt = {'1 - Estimate using loaded cases: Not possible!';...
                          ['Harmonization  parameter  estimation  is  not  possible due to  the number  of  loaded cases (fewer than 10).',...
                           'You  may  still provide  pre-estimated  parameters.'];
                           '';...
                           ['These parameters  are  stored  in  MAT  files  within  the',...
                           ' "0_Quality_And_Harmon_*" folder generated during processing. For example, you may run SSM  with  a batch',...
                           ' of control subjects to estimate harmonization parameters and subsequently apply  them to  single or multiple',...
                           ' patient cases. This approach is preferable, as it ensures that harmonization accounts primarily for scanner-,',...
                           ' protocol-, and FLAIR-related biases without suppressing potentially relevant pathological findings.']};
                set(handles.Finaltxt,'String',TextOpt);
                handles.HarmEstim = 0;
                handles.HarmNativeFlair = 0;
                handles.HarmnAdd = 0;
                set(handles.HFlairOnly,'Value',0)
                set(handles.HAdd,'Value',0)
                set(handles.HEstim,'Value',0)
            else
                handles.HarmParaAdded = 0;
                HarAns = questdlg('Are the included test cases composed EXCLUSIVELY of reference subjects for harmonization parameter estimation?','User dataset harmonization definitions','Yes','No','Yes');
                if ~isempty(HarAns)
                    switch HarAns
                        case 'Yes'
                            handles.HarmRef = ones(size(handles.filesub,2),1);
                            TextOpt = {'1 - Estimate using loaded cases';...
                                        ['The harmonization parameters will be estimated using the entire loaded sample, comprising ',num2str(size(handles.filesub,2)),' images. In this',...
                                       ' case, a "HarmomParam***.mat" file will be saved in the "0_Quality_And_Harmon_*" folder within the subject''s',...
                                       ' T1-weighted image directory. This  file can later be loaded and used to harmonize subjects from the same',...
                                       ' scanner or batch, even when processed individually.'];...
                                       '';...
                                       ['As the full sample is used to estimate the harmonization parameters, any effects common to the sample  will',...
                                       ' influence the harmonization procedure and may be attenuated. While this approach can be applied to  dataset',...
                                       ' composed solely of patients, it should be used with caution, as sensitivity may decrease particularly  when',...
                                       ' the group exhibits consistent or homogeneous patterns of alterations.'];...
                                       '';...
                                       ['If both control and patient data are available with similar  acquisition biases, you may add then all and',...
                                       ' select "No" in the previous dialog, providing an Excel file specifying which subjects are controls (used for',... 
                                       ' harmonization parameter estimation) and which are patients.']};
                            set(handles.Finaltxt,'String',TextOpt);
                        case 'No'
                            [HarmFile,HarmPath] = uigetfile({'*.txt;*.xlsx;*.xls;*.csv','Tab Files'},'Select the data file with a binary vector (column) indicating the reference subjects within the included cases.','MultiSelect','off',handles.pathsub);
                            if isempty(HarmFile) || isequal(HarmFile,0)
                                handles.HarmEstim = 0;
                                handles.HarmNativeFlair = 0;
                                handles.HarmnAdd = 0;
                                set(handles.HFlairOnly,'Value',0)
                                set(handles.HAdd,'Value',0)
                                set(handles.HEstim,'Value',0)
                            else
%                                 [NUM2,TXT2,RAW2] = xlsread([HarmPath,HarmFile]);
                                RAW2 = readmatrix([HarmPath,HarmFile]);
                                for xi = 1:size(RAW2,1)
                                    if ~isnan(RAW2(xi,1))
                                        handles.HarmRef(xi,1) = RAW2(xi,1);
                                    else
                                        handles.HarmRef(xi,1) = [];
                                    end
                                end
%                                 RAW2(cellfun(@isempty,RAW2)) = [];
%                                 for xi = 1:size(RAW2,1)
%                                     if ~isnan(RAW2{xi,1})
%                                         handles.HarmRef(xi,1) = RAW2{xi,1};
%                                     else
%                                         handles.HarmRef(xi,1) = [];
%                                     end
%                                 end
                                
                                if sum(handles.HarmRef) < 10
                                    warndlg(['Its recquired more 10 or more reference subjects for harmonization parameter estimation, and your files indicated you have only ',num2str(sum(handles.HarmRef))],'Cancelling harmonization')
                                    TextOpt = {'1 - Estimate using loaded cases: Not possible!';...
                                              ['Harmonization  parameter  estimation  is  not  possible due to  the number  of  eligeble loaded cases (fewer than 10).',...
                                               'You  may  still provide  pre-estimated  parameters.'];
                                               '';...
                                               ['These parameters  are  stored  in  MAT  files  within  the',...
                                               ' "0_Quality_And_Harmon_*" folder generated during processing. For example, you may run SSM  with  a batch',...
                                               ' of control subjects to estimate harmonization parameters and subsequently apply  them to  single or multiple',...
                                               ' patient cases. This approach is preferable, as it ensures that harmonization accounts primarily for scanner-,',...
                                               ' protocol-, and FLAIR-related biases without suppressing potentially relevant pathological findings.']};
                                    set(handles.Finaltxt,'String',TextOpt);
                                    handles.HarmEstim = 0;
                                    handles.HarmNativeFlair = 0;
                                    handles.HarmnAdd = 0;
                                    set(handles.HFlairOnly,'Value',0)
                                    set(handles.HAdd,'Value',0)
                                    set(handles.HEstim,'Value',0)
                                else
                                    TextOpt = {'1 - Estimate using loaded cases';...
                                                ['The harmonization parameters will be estimated using ',num2str(sum(handles.HarmRef)),' subjects from the loaded sample, comprising  ',num2str(size(handles.filesub,2)),...
                                                ' images. In this case, a "HarmomParam***.mat" file will be saved in the "0_Quality_And_Harmon_*" folder',...
                                                ' within the subject sT1-weighted image directory. This file can later be loaded and used to harmonize',...
                                                ' subjects from the same scanner or batch, even when processed individually.'];...
                                                '';...
                                                ['As you defined a subsample for harmonization parameter estimation, only effects common to this subsample',...
                                                ' will influence the harmonization procedure and be attenuated. This is considered best practice, as it avoids',...
                                                ' data leakage from cases of interest, allowing the harmonization parameters to be driven primarily by control/ref.',...
                                                ' subjects, thereby improving specificity without compromising sensitivity.'];...
                                                '';...
                                                'After estimation, the harmonization parameters will be applied to the entire loaded sample.'};
                                    set(handles.Finaltxt,'String',TextOpt);
                                end
                                
                            end % conditional for "no file added"
                            
                    end % switch end
                    
                else % questioning dialog answere "if" "else"
                    handles.HarmEstim = 0;
                    handles.HarmNativeFlair = 0;
                    handles.HarmnAdd = 0;
                    set(handles.HFlairOnly,'Value',0)
                    set(handles.HAdd,'Value',0)
                    set(handles.HEstim,'Value',0)
                end
            end
        else
            handles.HarmEstim = 0;
            handles.HarmNativeFlair = 0;
            handles.HarmnAdd = 0;
            TextOpt = {'1 - Estimate using loaded cases';...
                  ['Harmonization parameters are estimated directly from the currently loaded cases.',...
                  ' This approach uses the available sample to model and correct for shared biases',...
                  ' (e.g., scanner, acquisition protocol, or FLAIR-related effects).'];...
                  ['While convenient, this method should be used with caution, as effects',...
                  ' common to the sample including potential pathological patterns may',...
                  ' influence the estimation and be partially attenuated.'];...
                  '         - You will be asked how the loaded subjects should be used during parameter estimation.';...
                  '';...
                  '2 - Add previously estimated parameters';...
                 ['Harmonization is performed using parameters estimated from an external.',...
                  ' dataset. These parameters should ideally be derived from images acquired.',...
                  ' under similar conditions (e.g., same scanner, protocol, and sequence characteristics)..'];...
                 ['This is the recommended approach when suitable control data are available, as it ',...
                  ' reduces bias while minimizing the risk of attenuating relevant subject-specific alterations.'];...
                  '';...
                  '3 - Use SSM native FLAIR bias parameters';...
                  ['Predefined SSM harmonization parameters specifically designed to correct FLAIR-related',...
                  ' biases. These parameters were estimated by comparing the SSM reference dataset',...
                  ' with a control group with similar images (and Flair biased).'];...
                 ['This option is intended as a fallback when user-defined harmonization is not feasible,',...
                 ' helping to mitigate FLAIR-induced biases while preserving the potential advantages of including FLAIR information.']};
            set(handles.Finaltxt,'String',TextOpt);
        end

    guidata(hObject, handles);
    end

    function HAddf(subObject, eventdata)
    handles = guidata(hObject);
    
        if get(handles.HAdd,'Value')
            set(handles.HFlairOnly,'Value',0)
            set(handles.HEstim,'Value',0)
            handles.HarmEstim = 0;
            handles.HarmNativeFlair = 0;
            handles.HarmnAdd = 1;
            
            handles.HarmRef = ones(size(handles.filesub,2),1);
            
            [handles.HarmVarsF,handles.HarmVarsFp] = uigetfile({'*.mat','MATLAB VAR files'},'Select the HarmomParam.mat file containing the harmonization parameters for the current cases','MultiSelect','off',handles.pathsub);
            
            if isempty(handles.HarmVarsF) || isequal(handles.HarmVarsF,0)
                handles.HarmEstim = 0;
                handles.HarmNativeFlair = 0;
                handles.HarmnAdd = 0;
                set(handles.HFlairOnly,'Value',0)
                set(handles.HAdd,'Value',0)
                set(handles.HEstim,'Value',0)
            else
                TextOpt = {'2 ï¿½ Add previously estimated parameters: Ok';...
                            ['The harmonization procedures will be performed using previously estimated parameters.',...
                            ' It is recommended that these parameters be derived from images acquired under similar',...
                            ' conditions, including the same scanner, acquisition protocol, and sequence characteristics.'];...
                            '';...
                            ['For example, if the parameters were estimated from a batch of control subjects acquired on a',...
                            ' specific scanner, they can be applied to patient cases acquired under the same conditions to',...
                            ' correct for scanner-related effects without compromising potentially relevant effects of interest.']};
                set(handles.Finaltxt,'String',TextOpt);
            end
        else
            handles.HarmEstim = 0;
            handles.HarmNativeFlair = 0;
            handles.HarmnAdd = 0;
            set(handles.HFlairOnly,'Value',0)
            set(handles.HAdd,'Value',0)
            set(handles.HEstim,'Value',0)
            
            TextOpt = {'1 - Estimate using loaded cases';...
                  ['Harmonization parameters are estimated directly from the currently loaded cases.',...
                  ' This approach uses the available sample to model and correct for shared biases',...
                  ' (e.g., scanner, acquisition protocol, or FLAIR-related effects).'];...
                  ['While convenient, this method should be used with caution, as effects',...
                  ' common to the sampleï¿½including potential pathological patternsï¿½may',...
                  ' influence the estimation and be partially attenuated.'];...
                  '         - You will be asked how the loaded subjects should be used during parameter estimation.';...
                  '';...
                  '2 - Add previously estimated parameters';...
                 ['Harmonization is performed using parameters estimated from an external.',...
                  ' dataset. These parameters should ideally be derived from images acquired.',...
                  ' under similar conditions (e.g., same scanner, protocol, and sequence characteristics)..'];...
                 ['This is the recommended approach when suitable control data are available, as it ',...
                  ' reduces bias while minimizing the risk of attenuating relevant subject-specific alterations.'];...
                  '';...
                  '3 - Use SSM native FLAIR bias parameters';...
                  ['Predefined SSM harmonization parameters specifically designed to correct FLAIR-related',...
                  ' biases. These parameters were estimated by comparing the SSM reference dataset',...
                  ' with a control group with similar images (and Flair biased).'];...
                 ['This option is intended as a fallback when user-defined harmonization is not feasible,',...
                 ' helping to mitigate FLAIR-induced biases while preserving the potential advantages of including FLAIR information.']};
            set(handles.Finaltxt,'String',TextOpt);
        end
        
    guidata(hObject, handles);
    end
    
    function HFlairOnlyf(subObject, eventdata)
    handles = guidata(hObject);
    
        if get(handles.HFlairOnly,'Value')
            set(handles.HAdd,'Value',0)
            set(handles.HEstim,'Value',0)
            handles.HarmEstim = 0;
            handles.HarmNativeFlair = 1;
            handles.HarmnAdd = 0;

            handles.HarmRef = ones(size(handles.filesub,2),1);

            TextOpt = {'3 - Use SSM native FLAIR bias parameters: Ok';...
                  ['Predefined SSM harmonization parameters specifically designed to correct FLAIR-related',...
                  ' biases. These parameters were estimated by comparing the SSM reference dataset',...
                  ' with a control group with similar images (and Flair biased).'];...
                 ['This option is intended as a fallback when user-defined harmonization is not feasible,',...
                 ' helping to mitigate FLAIR-induced biases while preserving the potential advantages of including FLAIR information.']};
            set(handles.Finaltxt,'String',TextOpt);
        else
            handles.HarmEstim = 0;
            handles.HarmNativeFlair = 0;
            handles.HarmnAdd = 0;
            set(handles.HFlairOnly,'Value',0)
            set(handles.HAdd,'Value',0)
            set(handles.HEstim,'Value',0)
            TextOpt = {'1 - Estimate using loaded cases';...
                  ['Harmonization parameters are estimated directly from the currently loaded cases.',...
                  ' This approach uses the available sample to model and correct for shared biases',...
                  ' (e.g., scanner, acquisition protocol, or FLAIR-related effects).'];...
                  ['While convenient, this method should be used with caution, as effects',...
                  ' common to the sampleï¿½including potential pathological patternsï¿½may',...
                  ' influence the estimation and be partially attenuated.'];...
                  '         - You will be asked how the loaded subjects should be used during parameter estimation.';...
                  '';...
                  '2 - Add previously estimated parameters';...
                 ['Harmonization is performed using parameters estimated from an external.',...
                  ' dataset. These parameters should ideally be derived from images acquired.',...
                  ' under similar conditions (e.g., same scanner, protocol, and sequence characteristics)..'];...
                 ['This is the recommended approach when suitable control data are available, as it ',...
                  ' reduces bias while minimizing the risk of attenuating relevant subject-specific alterations.'];...
                  '';...
                  '3 - Use SSM native FLAIR bias parameters';...
                  ['Predefined SSM harmonization parameters specifically designed to correct FLAIR-related',...
                  ' biases. These parameters were estimated by comparing the SSM reference dataset',...
                  ' with a control group with similar images (and Flair biased).'];...
                 ['This option is intended as a fallback when user-defined harmonization is not feasible,',...
                 ' helping to mitigate FLAIR-induced biases while preserving the potential advantages of including FLAIR information.']};
            set(handles.Finaltxt,'String',TextOpt);
        end
    
    guidata(hObject, handles);
    end

    function SeCBf(subObject, eventdata)
    handles = guidata(hObject);
    
    if isequal(handles.HarmEstim,0) && isequal(handles.HarmNativeFlair,0) && isequal(handles.HarmnAdd,0)
        set(handles.HarmCB,'Value',0)
    else
        if isequal(handles.HarmEstim,1)
            set(handles.HarmCBTxt,'String',['To be estimated based on ',num2str(sum(handles.HarmRef)),' loaded cases'])
        end
        if isequal(handles.HarmNativeFlair,1)
            set(handles.HarmCBTxt,'String','SSM default FLAIR bias parameters selected')
        end
        if isequal(handles.HarmnAdd,1)
            set(handles.HarmCBTxt,'String','User-specified parameters loaded')
        end
    end
    
    guidata(hObject, handles);
    delete(MainFig2)
    end

    function closereqF(subObject, eventdata)
    handles = guidata(hObject);
        set(handles.HarmCB,'Value',0)
	guidata(hObject, handles);
    delete(MainFig2)
    end

handles.output = hObject;
guidata(hObject, handles);

end

