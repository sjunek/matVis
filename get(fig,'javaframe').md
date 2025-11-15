Andre:
get(fig,'javaframe') is not supported anymore
How to add an figure icon to a figure, but not an uifigure?

Copilot:
Short answer
You can no longer use the unsupported JavaFrame hack. For standard (non‑UI) figures the supported way is to set the root default figure icon so new figure windows use your icon. There is no documented per‑figure Icon property for the old figure object; use the root default instead.

Example — set icon for new figures
```matlab
% Ensure the icon file is on the MATLAB path or give full path
iconFile = "myIcon.png";   % PNG, JPEG, GIF, or truecolor m-by-n-by-3 array

% Set the root default so subsequently created figures use this icon
set(groot, "defaultFigureIcon", iconFile);

% Create a normal figure; it will show the icon you set
f = figure("Name", "My Figure", "NumberTitle", "off");
```

Notes and tips
- Use a square PNG (e.g., 32×32 or 64×64) for best results. Animated GIFs show only the first frame.
- This sets the icon for all subsequently created standard figures. To revert:
```matlab
set(groot, "defaultFigureIcon", "");
```
- If you need per‑figure icons and you must target native OS windows, there is no supported per‑figure API for the classic figure. Platform‑specific workarounds (Windows API, .NET, or unsupported Java hacks) are fragile and not recommended.
- If you want an Icon property on a per‑window basis, consider migrating that UI to uifigure (matlab.ui.Figure), which supports the `Icon` property directly:
```matlab
% uifigure supports per-figure Icon
uf = uifigure("Icon", "myIcon.png");
```

If you want, tell me whether you need the icon only for new figures or per-figure, and which MATLAB release(s) you must support; I’ll give the exact portable code.

Andre:
I need the icon for each figure separately for Matlab starting R2025a

Copilot:
Short answer
There is no supported per‑classic‑figure Icon property in R2025a. The supported way is to set the root default icon for new figures. To get per‑figure icons you must temporarily change that root default for each creation, or else use unsupported, platform‑specific hacks (not recommended).

Safe, supported pattern — per‑figure icon at creation
```matlab
function f = figureWithIcon(iconFile, varargin)
% Create a normal (non-uifigure) figure that appears to have a per-figure icon
% by temporarily setting the root defaultFigureIcon.
% iconFile  : string, path to image (PNG, JPG, GIF, or RGB array)
% varargin  : other figure name-value pairs
%
% Returns the created figure handle.

% Save current default
oldIcon = get(groot, "defaultFigureIcon");

% Set requested icon for subsequently created figures
set(groot, "defaultFigureIcon", iconFile);

% Create the figure
f = figure(varargin{:});

% Restore previous default so other figures are unaffected
set(groot, "defaultFigureIcon", oldIcon);
end
```

Usage example:
```matlab
f1 = figureWithIcon("iconA.png", "Name","Fig A");
f2 = figureWithIcon("iconB.png", "Name","Fig B");
```

Notes and caveats
- This sets the icon only for the moment of creation. The created figure will show the icon selected at creation on supported platforms.
- There is no supported API to change the icon of an already‑existing classic figure in R2025a.
- The root default affects only subsequently created standard figures; restoring it prevents global side effects.
- Image formats: use square PNG (32×32 or 64×64) or other supported formats for best results.
- Platform / windowing model differences and the new docked figure container may affect appearance; test on target OS and multi‑monitor setups.
- If you need robust per‑window control (change icon at any time, per window), migrate to uifigure, which supports the Icon property:
```matlab
uf = uifigure("Icon","iconA.png");
```
- Avoid unsupported hacks (get(fig,'JavaFrame') etc.) — they are removed and fragile.

If you want, I can provide a version that also handles absolute/relative paths and validates the image before creating the figure.

Andre:
yes please

Copilot:
### Function: Create Figure With Validated Icon

Below is a concise helper that accepts a filename or image array, validates/resolves it, and sets a per-figure icon at creation time by temporarily setting the root default. It restores the previous root default even if an error occurs.

```matlab
function f = figureWithIconValidated(iconInput, varargin)
% figureWithIconValidated Create a normal figure with a validated icon.
%   f = figureWithIconValidated(iconInput, Name,Value,...) accepts:
%     - iconInput: string path (relative or absolute) to an image file
%                  (PNG, JPG, GIF, ICO supported by imread) OR
%                numeric MxNx3 RGB array (uint8/uint16/double in [0,1]).
%   Returns figure handle f. Additional figure Name-Value pairs are passed
%   to figure().
%
%   Behavior:
%     - Resolves relative paths via which() and fullfile(pwd,...).
%     - Validates that file exists and is readable by imread.
%     - Temporarily sets groot.defaultFigureIcon so only the created figure
%       gets the icon, then restores the previous default.
%     - Throws a clear error if the icon cannot be validated.

    narginchk(1, Inf);

    % --- Resolve and validate iconInput ---
    iconToSet = "";   % string path or RGB array
    if ischar(iconInput) || isstring(iconInput)
        iconStr = char(iconInput);
        % Try full path
        if exist(iconStr, 'file') == 2
            fullPath = iconStr;
        else
            % Try which (on-path)
            w = which(iconStr);
            if ~isempty(w)
                fullPath = w;
            else
                % Try relative to cwd
                rel = fullfile(pwd, iconStr);
                if exist(rel, 'file') == 2
                    fullPath = rel;
                else
                    error('figureWithIconValidated:IconNotFound', ...
                        'Icon file not found: %s', iconStr);
                end
            end
        end

        % Validate readable image
        try
            % imfinfo is lighter-weight for validation
            info = imfinfo(fullPath); %#ok<NASGU>
        catch ME
            error('figureWithIconValidated:InvalidImage', ...
                'Icon file could not be read as an image: %s\nOriginal error: %s', ...
                fullPath, ME.message);
        end
        iconToSet = fullPath;

    elseif isnumeric(iconInput)
        % Validate numeric RGB image
        img = iconInput;
        if ndims(img) == 3 && size(img,3) == 3
            % convert logical/different types to uint8 or double in [0,1]
            if islogical(img)
                img = uint8(img) * 255;
            elseif isinteger(img)
                % leave as-is (imwrite supports integer)
            elseif isfloat(img)
                if max(img(:)) > 1
                    % assume already in 0..255
                    img = uint8(round(img));
                end
                % else float in 0..1 is ok
            end
            iconToSet = img;  % pass array directly to defaultFigureIcon
        else
            error('figureWithIconValidated:BadArray', ...
                'Numeric icon must be an MxNx3 RGB array.');
        end
    else
        error('figureWithIconValidated:BadInput', ...
            'iconInput must be a filename (string) or an MxNx3 numeric array.');
    end

    % --- Temporarily set default and create figure, with safe restore ---
    oldIcon = get(groot, "defaultFigureIcon");
    restore = onCleanup(@() set(groot, "defaultFigureIcon", oldIcon)); %#ok<NASGU>

    set(groot, "defaultFigureIcon", iconToSet);
    f = figure(varargin{:});
end
```

Example usage
```matlab
% From file (relative or absolute)
f1 = figureWithIconValidated("icons/myIcon.png", "Name", "File Icon");

% From image array
img = imread("icons/myIcon.png");
f2 = figureWithIconValidated(img, "Name", "Array Icon");
```

Notes
- The function uses imfinfo to validate readable image files without fully loading them. For numeric arrays it validates shape only.
- This approach works on R2025a and later where defaultFigureIcon is supported. It provides per-figure icons at creation time and restores the previous root default to avoid global side effects.
- If you need to set icons after figure creation or change them later, migrate to uifigure (which has a per-figure Icon property) or use unsupported platform hacks (not recommended).
