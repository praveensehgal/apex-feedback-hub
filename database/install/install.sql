-- =============================================================================
-- APEX Feedback Hub — ordered database installer
-- Run as the product schema (AFH) with SQLcl or SQL*Plus from this directory:
--     cd database/install && sql afh/<pwd>@<db> @install.sql
-- Re-running against the same installed version is safe (every step is guarded).
-- Never run this as SYS, SYSTEM, or an APEX internal schema.
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO OFF
SET TIMING OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
WHENEVER OSERROR  EXIT FAILURE ROLLBACK

DEFINE afh_product_version = '0.1.0'

PROMPT ==== APEX Feedback Hub &afh_product_version — installing into schema
SELECT USER AS schema_name, SYSTIMESTAMP AS started_at FROM dual;

PROMPT ---- 00 prerequisites
@@00_prereq.sql
-- Substitution stays ON only for the version banner and the prerequisite check above.
-- PL/SQL sources may contain '&' (SQL*Plus would prompt 'Enter value for ...' and skip
-- the rest of the file when stdin is closed - found 2026-09-06 on a fresh sqlplus install).
SET DEFINE OFF
PROMPT ---- 00 sequences
@@00_sequences.sql
PROMPT ---- 01 tables
@@01_tables.sql
PROMPT ---- 02 constraints
@@02_constraints.sql
PROMPT ---- 03 indexes
@@03_indexes.sql
PROMPT ---- 04 triggers
@@04_triggers.sql
PROMPT ---- 06 package specifications
@@06_packages.sql
PROMPT ---- 05 views
@@05_views.sql
PROMPT ---- 07 package bodies
@@07_package_bodies.sql
PROMPT ---- 08 jobs
@@08_jobs.sql
PROMPT ---- 09 seed
@@09_seed.sql
COMMIT;
PROMPT ---- 99 verify
@@99_verify.sql
PROMPT ==== install complete
EXIT SUCCESS
