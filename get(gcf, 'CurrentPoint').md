Andre:
what did change on get(gcf, 'CurrentPoint') with R2025a?

Copilot:
Short answer
In R2025a the numeric coordinates returned by get(gcf, 'CurrentPoint') are reported in the figure container / screen coordinate space used by the new unified figure window system, not the old figure-local coordinate space. In practice that means the origin and scale can differ from prior releases, so code that assumed the old figure-local pixel origin may break.

What changed (practical effects)
- The coordinates are now relative to the figure container (window) / root coordinate system used by the new windowing model instead of the previous figure content origin. 
- Values can be offset by the figure window position on the screen and by any container chrome (title bar, toolbars) and so will differ from older MATLAB results for the same mouse position.
- Code that depended on get(gcf,'CurrentPoint') matching axes or figure content pixels will need an explicit conversion.

How to adapt (convert to old-style figure-local or axes-local coordinates)
1) To convert the reported container/screen point to figure-position-local pixels:
```matlab
pt = get(gcf, 'CurrentPoint');      % new container/screen coords
figPos = get(gcf, 'Position');      % [left bottom width height] in pixels (figure window position)
% If pt is [x y], convert to pixels measured from figure lower-left:
fig_local = pt - figPos(1:2);
```

2) To get pointer position relative to an axes (useful for plotting coordinates):
```matlab
% Get pointer in screen/container coords (as above), convert to figure-local
fig_pt = get(gcf, 'CurrentPoint') - get(gcf, 'Position')(1:2);

% Map figure-local to axes data coordinates
ax = gca;
axPos = get(ax, 'Position');   % normalized position within figure
figSize = get(gcf, 'Position')(3:4);
axPixelPos = [axPos(1)*figSize(1), axPos(2)*figSize(2), axPos(3)*figSize(1), axPos(4)*figSize(2)];

% relative position inside axes in pixels
rel = (fig_pt - axPixelPos(1:2)) ./ axPixelPos(3:4);

% convert to data coordinates
xl = xlim(ax); yl = ylim(ax);
xData = xl(1) + rel(1)*(xl(2)-xl(1));
yData = yl(1) + rel(2)*(yl(2)-yl(1));
```

Recommendations
- Prefer querying pointer location with functions whose coordinate space you control:
  - Use get(gca, 'CurrentPoint') for axes data coordinates (two-row matrix).
  - Use get(groot, 'PointerLocation') for screen coordinates relative to the root.
- If you must support multiple MATLAB releases, detect the release or validate coordinate assumptions and convert using the figure Position as shown above.
- Test interactive code on R2025a to confirm offsets and tweak conversion if your figures use custom toolbars or nondefault window styles.

If you want, provide a small example of the exact misbehavior you see (values before/after) and I will give the exact conversion code for your case.

Andre:
previously I used
startPosGui = get(gui, 'Position');
p1 = startPosGui(1:2) + get(gui,'CurrentPoint');

how to chang this for the new style?

Copilot:
Short answer: use root pointer location and convert explicitly. R2025a changed the coordinate origin for `get(fig,'CurrentPoint')`, so compute pointer and convert relative to the figure position yourself.

Examples — common conversions

1) Pointer in screen coordinates (pixels from root lower-left)
```matlab
ptScreen = get(groot, 'PointerLocation');   % [x y] in screen pixels
```

2) Pointer relative to figure lower-left (figure-local pixels)
```matlab
figPos = get(gui, 'Position');               % [left bottom width height]
ptScreen = get(groot, 'PointerLocation');    % screen coords
ptFigLocal = ptScreen - figPos(1:2);         % [x y] inside figure (pixels)
```

3) If you previously did
startPosGui = get(gui, 'Position');
p1 = startPosGui(1:2) + get(gui,'CurrentPoint');
and you want the same result under R2025a, replace with:
```matlab
startPosGui = get(gui, 'Position');         % [left bottom width height]
ptScreen = get(groot, 'PointerLocation');   % [x y]
p1 = startPosGui(1:2) + (ptScreen - startPosGui(1:2));  % equals ptScreen
% simpler:
p1 = ptScreen;
```

4) If you want pointer in axes data coordinates (preferred for plotting):
```matlab
% get pointer relative to axes in data units
ptScreen = get(groot, 'PointerLocation');
figPos   = get(gui, 'Position');
figPt    = ptScreen - figPos(1:2);

ax = gca;                             % or handle to specific axes
axPos = get(ax, 'Position');          % normalized within figure
figSize = figPos(3:4);
axPix = [axPos(1)*figSize(1), axPos(2)*figSize(2), ...
         axPos(3)*figSize(1), axPos(4)*figSize(2)];

rel = (figPt - axPix(1:2)) ./ axPix(3:4);   % normalized [0..1] inside axes
xl = xlim(ax); yl = ylim(ax);
xData = xl(1) + rel(1)*(xl(2)-xl(1));
yData = yl(1) + rel(2)*(yl(2)-yl(1));
```

Recommendation
- Use get(groot,'PointerLocation') for reliable screen coords.
- Convert to figure or axes coordinates explicitly (as above) to maintain compatibility across releases.

Andre:
in my case p1 should be the coordinate of the screen
How do I get tis?

Copilot:
Use the root pointer location. `get(groot,'PointerLocation')` returns the pointer position in screen pixels (root coordinate space). So if p1 should be the screen coordinate, do:

```matlab
p1 = get(groot, 'PointerLocation');   % [x y] in screen pixels (root lower-left origin)
```

Notes and gotchas
- Ensure you treat both as pixels: `get(gcf,'Position')` is also in pixels by default, but if you changed figure `Units` it may differ. Use `set(gui,'Units','pixels')` and `set(0,'Units','pixels')` if you need to be explicit.
- On multi-monitor setups the returned coordinates are in the root/virtual screen coordinate system; origin and sign depend on your display arrangement.
- If you need the pointer relative to the figure lower-left, convert with the figure Position:
```matlab
figPos = get(gui,'Position');          % [left bottom width height]
ptScreen = get(groot,'PointerLocation');
ptFigLocal = ptScreen - figPos(1:2);   % [x y] inside figure (pixels)
```

That gives you the same semantic result you intended previously.

Andre:
great, how do I adapt my code such that it runs n both versions?

Copilot:
Simplest, robust approach: always read the pointer from the root (screen) and convert as needed. That avoids release-specific behavior for get(fig,'CurrentPoint').

Use this portable pattern:

```matlab
% Ensure units are pixels for the conversion
oldFigUnits = get(gui, 'Units');
set(gui, 'Units', 'pixels');

% Pointer in screen coordinates (root/virtual screen pixels)
p1 = get(groot, 'PointerLocation');   % [x y] in screen pixels (root lower-left origin)

% If you need the pointer relative to the figure lower-left:
figPos = get(gui, 'Position');        % [left bottom width height] in pixels
ptFigLocal = p1 - figPos(1:2);        % [x y] inside figure (pixels)

% restore original units
set(gui, 'Units', oldFigUnits);
```

Why this works
- get(groot,'PointerLocation') returns screen coordinates consistently across releases.
- Converting with the figure Position yields figure-local coordinates regardless of how get(fig,'CurrentPoint') semantics changed.

Optional compatibility guard (if you must keep old behavior for very old MATLABs that might not support groot):
```matlab
if exist('groot','builtin') == 5 || exist('groot','var') == 1
    p1 = get(groot, 'PointerLocation');
else
    % fallback: older MATLABs; assume get(fig,'CurrentPoint') returned screen coords
    p1 = get(gui, 'CurrentPoint');  
end
```

Notes
- Make sure figure Units are pixels when using Position (or convert consistently if not).
- On multi-monitor setups coordinates are in the root/virtual-screen coordinate system.

Andre:
whix you check matlab version by exist('groot','builtin') == 5 || exist('groot','var') == 1 and not with verLessThan('matlab', '25.1') ?

Copilot:
Short answer
Because checking for the existence of the feature (the builtin `groot` object) is a feature-detection approach: it directly answers the question "does this MATLAB provide `groot`?" rather than asking "is this release newer/older than X?". Feature detection is simpler, faster, and more robust than string-based version checks.

Why prefer exist('groot',...) over verLessThan('matlab','25.1')
- Directly tests the capability you need (groot exists). If your code only needs `groot`/root pointer, that's sufficient.
- Avoids parsing/depending on release strings and mapping release → feature availability.
- Slightly faster and less prone to subtle mistakes if release numbering schemes change.
- Works if you care only about a single feature, not a whole release boundary.

Why not use verLessThan('matlab','25.1')
- verLessThan compares release/toolbox versions (string comparison) and is intended for toolbox-version checks. It can be used, but it relies on correct release numbering and is indirect.
- The documentation recommends using isMATLABReleaseOlderThan for release comparisons if you must compare releases.
- If your logic is simply "does groot exist?", feature detection is clearer.

Recommended patterns

1) Feature detection (preferred when you just need groot)
```matlab
if exist('groot','builtin') == 5
    % use groot (modern MATLAB)
    p = get(groot, 'PointerLocation');
else
    % fallback for older MATLABs
    p = get(0, 'PointerLocation');  % older root handle name
end
```

2) Release-based check (if you need to gate on a release boundary)
```matlab
if isMATLABReleaseOlderThan('25.1')
    % older behavior
else
    % new behavior
end
```

Notes and small gotchas
- exist('groot','builtin') returns 5 for a built-in; using this avoids false positives from variables or files named "groot".
- Some very old MATLABs used 0 (no groot) and used the root handle 0; your fallback can use get(0,'PointerLocation') or get(0,'CurrentPoint') depending on target releases.
- Prefer feature detection when the code change is about availability of a function/object; use release checks only when behavior truly depends on the release rather than on a single feature.

Andre:
and why you suggested "|| exist('groot','var') == 1" is this required?

Copilot:
Short answer
No — the `exist('groot','var') == 1` part is not required. Checking `exist('groot','builtin') == 5` is the correct, sufficient feature-detection test for the built-in root object. The `'var'` test would only be true if someone created a variable named `groot` in the workspace, which is unnecessary and usually undesirable to rely on.

Why I mentioned it
- `'builtin' == 5` detects the actual built-in `groot` object that modern MATLAB exposes.
- `'var' == 1` would detect a user workspace variable named `groot`. I suggested it only as an overly defensive fallback in case code in some environment shadows the name with a variable (rare and not recommended).

Recommended patterns

1) Preferred, simple feature-detection (sufficient):
```matlab
if exist('groot','builtin') == 5
    p = get(groot, 'PointerLocation');
else
    p = get(0, 'PointerLocation');   % fallback for older releases
end
```

2) Robust runtime attempt (concise and practical):
```matlab
try
    p = get(groot, 'PointerLocation');
catch
    p = get(0, 'PointerLocation');
end
```

3) Only use `'var'` if you intentionally expect a variable named groot (not recommended):
```matlab
if exist('groot','builtin') == 5
    p = get(groot,'PointerLocation');
elseif exist('groot','var') == 1
    p = get(groot,'PointerLocation');  % uses workspace variable
else
    p = get(0,'PointerLocation');
end
```

Recommendation
Use the first or second pattern. The `'var'` check is unnecessary for standard robust code and can mask problems caused by accidental shadowing.
