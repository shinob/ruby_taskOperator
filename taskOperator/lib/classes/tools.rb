$flg_debug = true

def debug(txt)
  
  if $flg_debug then
    puts "<div class='debug'>#{txt}</div>\n"
  end
  
end

def get_dir()
  
  return Dir.getwd + "/"
  
end

def load_template(values, filename)
  
  dir = $templateDir
  debug(dir + filename)
  
  html = ""
  html = File.read(dir + filename, encoding: 'utf-8')
  
  return make_html_by_values(values, html)
  
  #values.each_pair { |key, val|
  #  html = html.gsub("_%#{key}%_", val.to_s)
  #}
  #
  #return html

end

def make_html_by_values(values, str)
  
  html = str
  
  values.each_pair { |key, val|
    html = html.gsub("_%#{key}%_", val.to_s)
  }
  
  return html

end

def get_login_user()
  
  #wk = ENV['REMOTE_USER'].to_s
  wk = $session["user"].to_s
  #if wk == "" then
  #  wk = "admin"
  #end
  
  return wk

end

def set_auth_type()
  
  #usr = DocUsers.new()
  $auth_type = $usr.get_auth_type()
  #$auth_type = "admin"
  
end

def is_guest()
  
  #usr = DocUsers.new()
  flg = false
  #if usr.get_auth_type() == "guest" then
  if $auth_type == "guest" then
    flg = true
  end
  return flg
  
end

def is_admin()
  
  #usr = DocUsers.new()
  flg = false
  if $auth_type == "admin" then
    flg = true
  end
  return flg
  
end
