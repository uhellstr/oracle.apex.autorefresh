--------------------------------------------------------
--  File created - måndag-juli-31-2017   
--------------------------------------------------------
DROP PROCEDURE "DO_LONGRUN";
DROP PACKAGE "PKG_SESSION_LONGOPS";
DROP PACKAGE BODY "PKG_SESSION_LONGOPS";


--------------------------------------------------------
--  DDL for Package PKG_SESSION_LONGOPS
--------------------------------------------------------

CREATE OR REPLACE PACKAGE "PKG_SESSION_LONGOPS" is
  procedure do_init (p_opname in varchar2, p_target in number, p_units in varchar2);
  procedure do_update (p_opname in varchar2, p_status in number);
end pkg_session_longops;
/
show errors

--------------------------------------------------------
--  DDL for Package Body PKG_SESSION_LONGOPS
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY "PKG_SESSION_LONGOPS" is
  type t_array is table of number index by varchar2(255);
  g_arr_rindex t_array;
  g_arr_slno   t_array;
  g_arr_total  t_array;

  procedure do_init (p_opname in varchar2, p_target in number, p_units in varchar2) is
    l_rindex binary_integer := dbms_application_info.set_session_longops_nohint;
    l_slno   binary_integer;
  begin
    dbms_application_info.set_session_longops(
      rindex       => l_rindex,
      slno         => l_slno,
      op_name      => p_opname,
      target       => 0,
      context      => 0,
      sofar        => 0,
      totalwork    => p_target,
      target_desc  => 'no target',
      units        => p_units
    );
    g_arr_rindex(p_opname) := l_rindex;
    g_arr_slno(p_opname) := l_slno;
    g_arr_total(p_opname) := p_target;
  end do_init;

  procedure do_update (p_opname in varchar2, p_status in number) is
    l_rindex binary_integer := g_arr_rindex(p_opname);
    l_slno   binary_integer := g_arr_slno(p_opname);
  begin
    dbms_application_info.set_session_longops(
      rindex       => l_rindex,
      slno         => l_slno,
      op_name      => p_opname,
      target       => 0,
      context      => 0,
      sofar        => p_status,
      totalwork    => g_arr_total(p_opname),
      target_desc  => 'no target',
      units        => null
    );
    g_arr_rindex(p_opname) := l_rindex;
    g_arr_slno(p_opname) := l_slno;
  end do_update;
end pkg_session_longops;
/

--------------------------------------------------------
--  DDL for Procedure DO_LONGRUN
--------------------------------------------------------
set define off;

CREATE OR REPLACE PROCEDURE "DO_LONGRUN" as
begin
  apex_util.set_workspace('APEX_ULF');
  -- APEX 5.0 and earlier: 
  -- apex_util.set_security_group_id(apex_util.find_security_group_id('{my workspace}'));
  pkg_session_longops.do_init('DO_LONGRUN', 300, 'seconds');
  for i in 1..30 loop
    apex_util.pause(10);
    pkg_session_longops.do_update('DO_LONGRUN', (i * 10));
  end loop;
end;
/