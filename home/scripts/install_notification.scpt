on run argv
  if (count of argv) > 0 then
    display notification "App installed/started:" & (item 1 of argv) sound name "Frog"
  else
    display notification "App installed/started!" sound name "Frog"
  end if
end run

