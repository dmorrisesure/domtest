declare
  
  cursor do_json is
  select empno,
         ename,
         job,
         mgr,
         level lvl,
         lag(level) over (order by ltrim(sys_connect_by_path(ename,','),',')) prev_lvl,
         lead(level) over (order by ltrim(sys_connect_by_path(ename,','),',')) nxt_lvl,
         ltrim(sys_connect_by_path(ename,','),',')
    from scott.emp
  start with empno = 7839
  connect by mgr = prior empno
  order by ltrim(sys_connect_by_path(ename,','),',');
  
  v_json clob;
  
begin
  for crow in do_json
  loop
    v_json := v_json||'{';
    v_json := v_json||'"Name":"'||crow.ename||'",';
    v_json := v_json||'"Empno":'||crow.empno||',';
    case
      when crow.nxt_lvl > crow.lvl
      then
          v_json := v_json||'"Lackeys": [ ';
      when crow.nxt_lvl = crow.lvl
      then
          v_json := rtrim(v_json,',')||' },';
      when crow.nxt_lvl < crow.lvl
      then
          v_json := rtrim(v_json,',')||' }]},';
       else
           v_json := rtrim(v_json,',')||'}';
           case
             when crow.lvl > 1
             then
                 v_json := rpad(v_json,length(v_json)+((crow.lvl-1)*2),']}');
             else null;
           end case;
    end case;
      
  end loop;
  --v_json := v_json||'}';
  dbms_output.put_line(v_json);
end;