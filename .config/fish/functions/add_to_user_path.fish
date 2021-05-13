function add_to_user_path --description "Persistently prepends to your PATH via fish_user_paths"
  for path in $argv
    if not contains $path $fish_user_paths
      set --universal fish_user_paths $path $fish_user_paths
	  echo Added (tput setaf 13)$path(tput setaf 15) to (tput setaf 13)\$fish_ser_paths(tput setaf 15)
  else
	  echo (tput setaf 13)$path(tput setaf 15) already in (tput setaf 13)\$fish_user_paths(tput setaf 15), (tput setaf 1)skipping(tput setaf 15)
    end
  end
end
