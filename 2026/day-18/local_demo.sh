#!/bin/bash
with_local() {
  local secret="hidden inside function"
  echo "Inside with_local: $secret"
}

without_local() {
  global_var="leaked outside function"
  echo "Inside without_local: $global_var"
}

with_local
echo "After with_local, secret = '${secret:-<unset>}'"

without_local
echo "After without_local, global_var = '${global_var:-<unset>}'"
