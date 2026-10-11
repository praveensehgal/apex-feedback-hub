-- AFH_V_MY_WORK_TASKS: alias of AFH_V_MY_TASKS kept for the design document's page map.
CREATE OR REPLACE FORCE VIEW afh_v_my_work_tasks AS
SELECT * FROM afh_v_my_tasks;
COMMENT ON TABLE afh_v_my_work_tasks IS 'Open direct tasks of the current user (same as AFH_V_MY_TASKS)';
