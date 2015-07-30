module AdminHelper
  def admin_obf(v)
    if current_user.team? 
      random_padding = rand(v.size)/2 * (rand > 0.5 ? -1 : 1)
      '*' * (v.size + random_padding)
    else
      v
    end
  end

  def link_to_admin_user(user)
    name = admin_obf(user.to_s) 
    link_to name, admin_user_path(user)
  end
end
