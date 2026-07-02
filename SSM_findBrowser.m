function browser = SSM_findBrowser()
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
%
% FINDBROWSER Finds a Chromium-based browser capable of printing HTML to PDF.
%
% Supported:
%   - Google Chrome
%   - Microsoft Edge
%   - Chromium
%   - Brave
%
% Returns:
%   browser : full executable path, or [] if not found.

browser = [];

if ispc

    candidates = { ...
        fullfile(getenv('ProgramFiles'),'Google','Chrome','Application','chrome.exe')
        fullfile(getenv('ProgramFiles(x86)'),'Google','Chrome','Application','chrome.exe')
        fullfile(getenv('LocalAppData'),'Google','Chrome','Application','chrome.exe')

        fullfile(getenv('ProgramFiles'),'Microsoft','Edge','Application','msedge.exe')
        fullfile(getenv('ProgramFiles(x86)'),'Microsoft','Edge','Application','msedge.exe')

        fullfile(getenv('ProgramFiles'),'BraveSoftware','Brave-Browser','Application','brave.exe')
        fullfile(getenv('ProgramFiles(x86)'),'BraveSoftware','Brave-Browser','Application','brave.exe')

        fullfile(getenv('ProgramFiles'),'Chromium','Application','chrome.exe')
        fullfile(getenv('ProgramFiles(x86)'),'Chromium','Application','chrome.exe')
        };

    for i = 1:numel(candidates)
        if exist(candidates{i},'file')
            browser = candidates{i};
            return
        end
    end

    names = { ...
        'chrome'
        'msedge'
        'brave'
        'chromium'
        };

    for i = 1:numel(names)

        [status,out] = system(['where ',names{i}]);

        if status == 0

            lines = regexp(strtrim(out),'\r\n|\n','split');

            if ~isempty(lines)

                browser = strtrim(lines{1});
                return

            end
        end
    end

else
    names = { ...
        'google-chrome'
        'google-chrome-stable'
        'microsoft-edge'
        'chromium'
        'chromium-browser'
        'brave-browser'
        };

    for i = 1:numel(names)

        [status,out] = system(['which ',names{i}]);

        if status == 0

            browser = strtrim(out);
            return

        end

    end

end