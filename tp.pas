program main;
 var f:file;
begin
  assign(f,paramstr(1)+'.CHN');
  chain(f);
end.
