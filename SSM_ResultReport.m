function SSM_ResultReport(k,Outdir,handles,AnatT1,AnatT2)
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
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS'
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

fid = fopen([Outdir,'FinalReport.html'],'w+');

fprintf(fid,'<!DOCTYPE html>\n');
fprintf(fid,'<html>\n');

% Header
fprintf(fid,'<head>\n');

fprintf(fid,'<meta charset="UTF-8">\n');

fprintf(fid,'<style>\n');

fprintf(fid,'body{\n');
fprintf(fid,'font-family:Arial,Helvetica,sans-serif;\n');
fprintf(fid,'margin:20px;\n');
fprintf(fid,'color:#222;\n');
fprintf(fid,'font-size:12px;\n');
fprintf(fid,'}\n');

fprintf(fid,'.indent{\n');
fprintf(fid,'margin-left:30px;\n');
fprintf(fid,'}\n');

fprintf(fid,'h1{\n');
fprintf(fid,'color:#0055AA;\n');
fprintf(fid,'border-bottom:3px solid #0055AA;\n');
fprintf(fid,'padding-bottom:8px;\n');
fprintf(fid,'}\n');

fprintf(fid,'h2{\n');
fprintf(fid,'margin-top:35px;\n');
fprintf(fid,'color:#444;\n');
fprintf(fid,'}\n');

fprintf(fid,'table{\n');
fprintf(fid,'border-collapse:collapse;\n');
fprintf(fid,'width:100%%;\n');
fprintf(fid,'margin:1px 0;\n'); 
fprintf(fid,'}\n');

fprintf(fid,'th,td{\n');
fprintf(fid,'border:1px solid #cccccc;\n');
fprintf(fid,'padding:8px;\n');
fprintf(fid,'font-size:10px;\n'); 
fprintf(fid,'text-align:center;\n');
fprintf(fid,'}\n');

fprintf(fid,'th{\n');
fprintf(fid,'background:#efefef;\n');
fprintf(fid,'}\n');

fprintf(fid,'.box{\n');
fprintf(fid,'background:#F6F8FA;\n');
fprintf(fid,'padding:20px;\n');
fprintf(fid,'border-left:5px solid #0055AA;\n');
fprintf(fid,'margin-top:20px;\n');
fprintf(fid,'margin-bottom:30px;\n');
fprintf(fid,'}\n');

fprintf(fid,'img{\n');
fprintf(fid,'display:block;\n');
fprintf(fid,'margin:0 auto;\n');
fprintf(fid,'padding:0;\n');
fprintf(fid,'width:100%%;\n');
fprintf(fid,'}\n');

fprintf(fid,'.pagebreak{\n');
fprintf(fid,'page-break-before:always;\n');
fprintf(fid,'break-before:page;\n');
fprintf(fid,'}\n');

fprintf(fid,'footer{\n');
fprintf(fid,'margin-top:60px;\n');
fprintf(fid,'font-size:12px;\n');
fprintf(fid,'color:gray;\n');
fprintf(fid,'text-align:center;\n');
fprintf(fid,'}\n');

fprintf(fid,'</style>\n');
fprintf(fid,'</head>\n');

%% BODY
if get(handles.GMa,'Value')
    SSMMod = 'Grey Matter Morphology';
end
if get(handles.WMa,'Value')
    SSMMod = 'White Matter Morphology';
end
if get(handles.FCD,'Value')
    SSMMod = 'Focal Cortical Dysplasia Investigation';
end

fprintf(fid,'<body>\n');
fprintf(fid,'<h1>SSM - Single Subject Morphometry Tool</h1>\n');
fprintf(fid,'<p><b>Date:</b> %s</p>\n',datestr(now));

fprintf(fid,'<div class="box">\n');
fprintf(fid,['<b>Modality of Analysis:</b> ',SSMMod]);

%%%%%%
fprintf(fid,'<h3>Initial Settings</h3>\n');
fprintf(fid,'<div class="indent">\n');
if handles.nsubje > 1
    fprintf(fid,'<b> Processing type:</b> %s<br>\n',['Multiple-cases (with other ',num2str(handles.nsubje),' images)']);
else
    fprintf(fid,'<b> Processing type:</b> %s<br>\n','Single-case ');
end
fprintf(fid,'<b> Image:</b> %s<br>\n',handles.filesub{k});
if get(handles.AddFlair,'Value')
    fprintf(fid,'<b> FLAIR image included:</b> %s<br>\n',handles.fileFlair{k});
else
    fprintf(fid,'<b> FLAIR image included:</b> %s<br>\n','No');
end
if get(handles.HarmCB,'Value')
    fprintf(fid,'<b> Haronization procedure:</b> %s<br>\n','Yes');
    fprintf(fid,'<b> Haronization type:</b> %s<br>\n',get(handles.HarmCBTxt,'String'));
else
    fprintf(fid,'<b> Haronization procedure:</b> %s<br>\n','No');
end
fprintf(fid,'</div>\n');

%%%%%%
fprintf(fid,'<h3>Case Demographics</h3>\n');
fprintf(fid,'<div class="indent">\n');
fprintf(fid,'<b> Case age (years):</b> %s<br>\n',num2str(handles.AgeVet(k)));
Sex = handles.GenVet(k);
if Sex
    fprintf(fid,'<b> Case sex:</b> %s<br>\n','Male');
else
    fprintf(fid,'<b> Case sex:</b> %s<br>\n','Female');
end
fprintf(fid,'</div>\n');

%%%%%%
fprintf(fid,'<div class="indent">\n');
fprintf(fid,'<h3>Experiment Settings</h3>\n');

if get(handles.FloaRan,'Value')
    fprintf(fid,'<b> Individual reference database (Ref.D.) selection:</b> Individualized settings<br>\n');
    fprintf(fid,'<b> Individual Ref.D. relative +/- age (years):</b> %s<br>\n',get(handles.AgeRanEdit,'String'));
    if get(handles.MatchSex,'Value')
        fprintf(fid,'<b> Including both sexes:</b> %s<br>\n','No, only the same sex');
    else
        fprintf(fid,'<b> Including both sexes:</b> %s<br>\n','Yes');
    end
    if get(handles.ConstSS,'Value')
        fprintf(fid,'<b> Keeping constant Ref.D. size:</b> %s<br>\n','Yes');
    else
        fprintf(fid,'<b> Keeping constant Ref.D. size:</b> %s<br>\n','No, blindly following the previous rules');
    end
    fprintf(fid,'<b> Final individual Ref.D. size:</b> %s<br>\n',get(handles.RRnCtrTxt2,'String'));
else
    fprintf(fid,'<b> Individual reference database (Ref.D.) selection:</b> Fixed settings for all<br>\n');
    fprintf(fid,'<b> Minimum Ref.D. age defined (years):</b> %s<br>\n',get(handles.MinAge,'String'));
    fprintf(fid,'<b> Maximum Ref.D. age defined (years):</b> %s<br>\n',get(handles.MaxAge,'String'));
    if get(handles.males,'Value')
        fprintf(fid,'<b> Including male subjects:</b> Yes<br>\n');
    else
        fprintf(fid,'<b> Including male subjects:</b> No<br>\n');
    end
    if get(handles.females,'Value')
        fprintf(fid,'<b> Including female subjects:</b> Yes<br>\n');
    else
        fprintf(fid,'<b> Including female subjects:</b> No<br>\n');
    end
    fprintf(fid,'<b> Final Ref.D. size:</b> %s<br>\n',get(handles.nOfCtr,'String'));
    fprintf(fid,'<b> Final lower age:</b> %s<br>\n',get(handles.text17,'String'));
    fprintf(fid,'<b> Final higher age:</b> %s<br>\n',get(handles.text21,'String'));
    fprintf(fid,'<b> Ref.D. age (average/STD):</b> %s<br>\n',get(handles.avgAge,'String'));
    fprintf(fid,'<b> Number of males:</b> %s<br>\n',get(handles.nOfMale,'String'));
    fprintf(fid,'<b> Number of females:</b> %s<br>\n',get(handles.nOfFemale,'String'));
end
stSmo = get(handles.PopMenuSmoothK,'String');
fprintf(fid,'<b> Smoothing Kernel:</b> %s<br>\n',stSmo{get(handles.PopMenuSmoothK,'Value'),:});
fprintf(fid,'</div>\n');

%%%%%%
fprintf(fid,'<h3>Statistics and results Report Settings</h3>\n');
fprintf(fid,'<div class="indent">\n');
fprintf(fid,'<h4>Covariates</h4>\n');
fprintf(fid,'<div class="indent">\n');

if get(handles.covAge,'Value')
    fprintf(fid,'<b> Age covariate:</b> %s<br>\n','Yes');
else
    fprintf(fid,'<b> Age covariate:</b> %s<br>\n','No');
end
if get(handles.checkbox4,'Value')
    fprintf(fid,'<b> Sex covariate:</b> %s<br>\n','Yes');
else
    fprintf(fid,'<b> Sex covariate:</b> %s<br>\n','No');
end
fprintf(fid,'</div>\n');
fprintf(fid,'<h4>Permutation</h4>\n');
fprintf(fid,'<div class="indent">\n');

fprintf(fid,'<b> Number of permutations tests:</b> %s<br>\n',get(handles.nPermEdit,'String'));
fprintf(fid,'<b> Ref.D. subsampling for permutation leave-one-out:</b> %s<br>\n',get(handles.SubFactEdit,'String'));
fprintf(fid,'<b> Permutation maximum statistical value method:</b> %s<br>\n','Blob-wise');
fprintf(fid,'<b> FWER alpha level:</b> %s<br>\n',get(handles.alphaL,'String'));
fprintf(fid,'<b> Extend threshold (voxels):</b> %s<br>\n',get(handles.edit6,'String'));
fprintf(fid,'</div>');
fprintf(fid,'</div>');
fprintf(fid,'</div>\n');

fprintf(fid,'<div class="pagebreak"></div>\n');
%% Figure
switch SSMMod
    case 'Focal Cortical Dysplasia Investigation'
        
        aFCD = dir([Outdir,'*SliceView_FCD_map_Unthresholded_*.png']);
        fprintf(fid,'<h2>Unthresholded FCD Statistical map</h2>\n');
        fprintf(fid,['<img src="',aFCD.name,'">\n']);

        fprintf(fid,'<div class="pagebreak"></div>\n');

        aFCD = dir([Outdir,'*SliceView_FCD_map_Zsc*.png']);
        fprintf(fid,'<h2>Thresholded FCD Map</h2>\n');
        fprintf(fid,['<img src="',aFCD.name,'">\n']);
        
    case 'White Matter Morphology'
        
        aWM = dir([Outdir,'*WM_Atrophy_Thresh*.png']);
        fprintf(fid,'<h2>White Matter Thresholded Atrophy Map</h2>\n');
        fprintf(fid,['<img src="',aWM.name,'">\n']);
        
        fprintf(fid,'<div class="pagebreak"></div>\n');

        aWM = dir([Outdir,'*WM_Hypertrophy_Thresh*.png']);
        fprintf(fid,'<h2>White Matter Thresholded Hypertrophy Map</h2>\n');
        fprintf(fid,['<img src="',aWM.name,'">\n']);
        
    case 'Grey Matter Morphology'
        
        aGMa = dir([Outdir,'*GM_Atrophy_Thresh*.png']);
        fprintf(fid,'<h2>Grey Matter Thresholded Atrophy Map</h2>\n');
        fprintf(fid,['<img src="',aGMa.name,'">\n']);
        
        fprintf(fid,'<div class="pagebreak"></div>\n');
        
        aGMa = dir([Outdir,'*GM_Hypertrophy_Thresh*.png']);
        fprintf(fid,'<h2>Grey Matter Thresholded Hypertrophy Map</h2>\n');
        fprintf(fid,['<img src="',aGMa.name,'">\n']);
end

%% Table
fprintf(fid,'<div class="pagebreak"></div>\n');
switch SSMMod
    case 'Focal Cortical Dysplasia Investigation'
        fprintf(fid,'<h2>FCD Anatomical Description</h2>\n');
    case 'White Matter Morphology'
        fprintf(fid,'<h2>White Matter Atrophy Anatomical Description</h2>\n');
    case 'Grey Matter Morphology'
        fprintf(fid,'<h2>Grey Matter Atrophy Anatomical Description</h2>\n');
end        
fprintf(fid,'<table>\n');
fprintf(fid,'<tr>');

for r = 1:height(AnatT1)
    fprintf(fid,'<tr>');
    fprintf(fid,'<td>%s</td>',AnatT1{r,1}{1});
    fprintf(fid,'<td>%s</td>',AnatT1{r,2}{1});
    fprintf(fid,'<td>%s</td>',AnatT1{r,3}{1});
    fprintf(fid,'<td>%s</td>',AnatT1{r,4}{1});
    fprintf(fid,'<td>%s</td>',AnatT1{r,5}{1});
    fprintf(fid,'</tr>\n');
end

fprintf(fid,'</table>\n');

if ~isempty(AnatT2)
    fprintf(fid,'<div class="pagebreak"></div>\n');

    switch SSMMod
        case 'White Matter Morphology'
            fprintf(fid,'<h2>White Matter Hypertrophy Anatomical Description</h2>\n');
        case 'Grey Matter Morphology'
            fprintf(fid,'<h2>Grey Matter Hypertrophy Anatomical Description</h2>\n');
    end        
    fprintf(fid,'<table>\n');
    fprintf(fid,'<tr>');

    for r = 1:height(AnatT2)
        fprintf(fid,'<tr>');
        fprintf(fid,'<td>%s</td>',AnatT2{r,1}{1});
        fprintf(fid,'<td>%s</td>',AnatT2{r,2}{1});
        fprintf(fid,'<td>%s</td>',AnatT2{r,3}{1});
        fprintf(fid,'<td>%s</td>',AnatT2{r,4}{1});
        fprintf(fid,'<td>%s</td>',AnatT2{r,5}{1});
        fprintf(fid,'</tr>\n');
    end

    fprintf(fid,'</table>\n');
end

%% Footer
fprintf(fid,'<footer>\n');
fprintf(fid,'Generated by SSM - Single-Subject Morphometry Tool.<br>\n');
fprintf(fid,'Neuroimaging Laboratory - University of Campinas\n');
fprintf(fid,'</footer>\n');
fprintf(fid,'</body>\n');
fprintf(fid,'</html>\n');

fclose(fid);

html = fullfile([Outdir,'FinalReport.html']);
pdf  = fullfile([Outdir,'FinalReport.pdf']);

browser = SSM_findBrowser();

if isempty(browser)
    warning(['No Chromium-based browser was found.\n' ...
             'The HTML report was generated, but the PDF was not created.']);
else
    if ispc
        cmd = sprintf('"%s" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="%s" "%s"', ...
            browser, pdf, html);
    else
        cmd = sprintf('env -u LD_LIBRARY_PATH "%s" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="%s" "%s"', ...
            browser, pdf, html);
    end

    [status, cmdout] = system(cmd);

    if status ~= 0
        warning('PDF generation failed. Report is stil accecible via HTML');
    end
end

end