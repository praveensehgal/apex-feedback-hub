CREATE OR REPLACE PACKAGE afh_compile_flags AS
  -- Conditional-compilation flags. The installer ships test_mode = FALSE; the test runner
  -- recompiles this package with TRUE before a run and FALSE after. Package bodies that
  -- reference afh_compile_flags.test_mode inside $IF ... $END contain no impersonation
  -- code at all when the flag is FALSE.
  test_mode CONSTANT BOOLEAN := FALSE;
END afh_compile_flags;
/
