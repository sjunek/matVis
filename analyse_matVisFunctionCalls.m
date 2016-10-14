function analyse_matVisFunctionCalls(S)
  % Function to analyses matVis function calls
  %
  % analyse_matVisFunctionCalls(matVisFunctionCalls)
  %
  % requires debugging mode called by: matVis(... ,'debug',1)
  %
  
  
  S = orderfields(S);
  fnames = fieldnames(S);
  sw = 1;
  for n = 1:length(fnames)
    if ~strcmp(fnames{n},'matVis') && ~isempty(S.(fnames{n}).callFct) && length(fieldnames(S.(fnames{n}).callFct))>1
      sw = 0;
      fprintf('<a href="matlab:matlab.desktop.editor.openAndGoToFunction(which(''matVis.m''),''%s'');">%s</a> is called:\n',fnames{n},fnames{n})
      fnamesCall = fieldnames(S.(fnames{n}).callFct);
      for n1 = 1:length(fnamesCall)
        fprintf('\t\t%3dx from <a href="matlab:matlab.desktop.editor.openAndGoToFunction(which(''matVis.m''),''%s'');">%s</a>\n',...
        S.(fnames{n}).callFct.(fnamesCall{n1}).count, fnamesCall{n1}, fnamesCall{n1})
      end
    end
  end
  if sw
    fprintf('No Functoion calls from different subfunctions!!!\n\n',fnames{n})
  end 
end