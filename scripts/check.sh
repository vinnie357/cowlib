#!/bin/sh
set -u
mode=${1:-all}
log=".cowlib-check-$mode.log"
case "$mode" in
  structured-fields) ERL_COMPILER_OPTIONS='[warnings_as_errors]' make eunit t=cow_http_struct_hd EUNIT_OPTS=verbose >"$log" 2>&1 ;;
  all) ERL_COMPILER_OPTIONS='[warnings_as_errors]' make eunit EUNIT_OPTS=verbose >"$log" 2>&1 ;;
  secrets) "$(mise which gitleaks)" git . --log-opts='81161a5350dbec9d73a204c903cd23a2e3560e90..HEAD' --redact >"$log" 2>&1 ;;
  *) echo "ERROR cowlib: unknown check"; exit 2 ;;
esac
result=$?
if [ "$result" -eq 0 ]; then
  echo "PASS cowlib $mode"
else
  echo "FAIL cowlib $mode (exit $result; $log)"
  sed -n '/failed\|Failed\|error\|Error\|unexpected_success/,+12p' "$log" | head -35
fi
exit "$result"
