class KmrUsers < Model
  
  def initialize()
    set_value($db, "kmrusers")
    @message = "&nbsp;"
    debug("KmrUsers")
  end
  
  def show(id)
    
    vals = get_data_by_id(id)
    return get_show_form(vals)
    
  end
  
  def edit(id)
    
    vals = get_data_by_id(id)
    vals["auth_type"] = get_auth_select_form(vals["auth_type"])
    return get_edit_form(vals)
    
  end
  
  def add()
    
    vals = get_blank_data()
    vals["auth_type"] = get_auth_select_form(vals["auth_type"])
    return get_edit_form(vals)
    
  end
  
  def get_edit_form(vals)
    
    html = load_template(vals, "edit_user.html")
    return html
    
  end
  
  def get_show_form(vals)
    
    html = load_template(vals, "show_user.html")
    return html
    
  end
  
  def get_password_form()
    
    vals = get_data_by_str("name", get_login_user())
    
    html = load_template(vals[0], "edit_password.html")
    return html
    
  end
  
  def set_password(vals)
    
    name = get_name(vals["id"])
    password = vals["password"]
    
    if password != "" then
      
      apply(vals)
      
      str = "パスワードを変更しました。"
      
    else
    
      str = "パスワードが空白のため、変更できませんでした。"
    
    end
    
    return "<div style='width: 800px; margin: 0px auto;'>#{str}</div>"
    
  end
  
  def get_name(id)
    
    return get_value_by_id("name", id)
    
  end
   
  def get_disp_name(id)
    
    return get_value_by_id("disp_name", id)
    
  end
   
  def get_auth_type()
    
    debug("docUsers.get_auth_type()")
    ans = get_data_by_str("name", get_login_user())
    if ans.length > 0 then
      wk = ans[0]["auth_type"]
    else
      wk = ""
    end
    debug(ans)
    return wk
    
  end
  
  def get_user_select_form(id)
    
    sql = "SELECT * FROM #{@table} WHERE id > 3 ORDER BY name"
    vals = @db.query(sql)
    #vals = get_data_with_order("name")
    
    html = "<SELECT name='user_id'>"
    vals.each do |row|
      tmp = (row["id"].to_i == id.to_i) ? "selected" : ""
      html += "<OPTION value='#{row["id"]}' #{tmp}>#{row["disp_name"]}</OPTION>"
    end
    html += "</SELECT>"
    
    return html
    
  end
  
  def get_auth_select_form(auth_type)
    
    auth_types = ["guest", "user", "admin"]
    
    html = "<SELECT name='auth_type'>"
    auth_types.each do |str|
      tmp = (str==auth_type) ? "selected" : ""
      html += "<OPTION value='#{str}' #{tmp}>#{str}</OPTION>"
    end
    html += "</SELECT>"
    return html
    
  end
  
  def list_all()
    
    return get_list_table(get_data_with_order("name"))
    
  end
  
  def get_add_form()
    
    html = <<EOF
<a href="#" onclick="document.add_user.submit();">
<form method='post' name="add_user">
  <input type="hidden" name="id" value="0" />
  <input type="hidden" name="mode" value="add_user" />
  <p>ユーザー追加</p>
</form>
</a>
EOF
    return html
    
  end
  
  def get_list_table(vals)
    
    html = ""
    #html = get_add_form()
    
    color = "#EEE"
    
    vals.each do |row|
      color = (color == "#FFF") ? "#EEE" : "#FFF"
      
      html += <<EOF
<a href="#" onclick="document.edit_user_#{row["id"]}.submit();">
<form method='post' name="edit_user_#{row["id"]}">
  <input type="hidden" name="id" value="#{row['id']}" />
  <input type="hidden" name="mode" value="edit_user" />
  <h1>#{row["disp_name"]}</h1>
</form>
</a>
EOF
    end
    
    if html != "" then
      html = "<div class='task_list'>#{html}</div>"
    end
    
    return html
    
  end
  
  def is_login()
    
    debug("docUsers.is_login()")
    
    mode = $_POST["mode"].to_s
    flg = false
    
    debug("mode = #{mode}")
    
    if mode == "logout" then
      $session["user"] = ""
      @message = "ログアウトしました"
    elsif mode == "login" then
      $session["user"] = login()
    end
    
    debug("docUsers.is_login()")
    debug("docUsers : is_login() : " + $session["user"].to_s)
    
    if $session["user"].to_s != "" then
      flg = true
    end
    
    $session.close
    set_auth_type()
    
    debug("flg : #{flg}")
    
    return flg
    
  end
  
  def login()
    
    name = $_POST["name"]
    pass = $_POST["pass"]
    
    sql = "SELECT * FROM #{@table} WHERE name = '#{name}' AND password = '#{pass}'"
    #sql = "SELECT * FROM docusers WHERE name = '#{name}'"
    tmp = @db.query(sql)
    
    if tmp.length == 0 then
      name = ""
      @message = "ユーザー名またはパスワードが間違っています"
    end
    
    debug("docUsers : login() : #{name}")
    debug(tmp.to_s)
    
    return name
    
  end
  
  def get_login_form()
    
    html = <<EOF
<form method="post" id="login_form">
  <input type="hidden" name="mode" value="login" />
  <table>
    <tr>
      <td colspan=2><div id="login_message">_%message%_</div></td>
    </tr>
    <tr>
      <th>ユーザー名</th>
      <td><input type="text" name="name" onfocus="getDiv('login_message').innerHTML='&nbsp;'" /></td>
    </tr>
    <tr>
      <th>パスワード</th>
      <td><input type="password" name="pass" /></td>
    </tr>
    <tr>
      <th>&nbsp;</th>
      <td><input type="submit" value="ログイン" /></td>
    </tr>
  </table>
</form>
EOF
    
    return make_html_by_values({"message" => @message}, html)
    
  end
  
  def get_logout_form()
    
    opt = ""
    if !is_guest() then
      opt = <<EOF
<a href="#" onClick="document.change_password.submit();">
<form method="post" name="change_password" style="float: right;">
  <input type="hidden" name="mode" value="change_password" />
  <p>パスワード変更</p>
</form>
</a>
EOF
    end
    
    html = <<EOF
<a href="#" onClick="document.logout.submit();">
<form method="post" name="logout" style="float: right;">
  <input type="hidden" name="mode" value="logout" />
  <p>ログアウト</p>
</form>
</a>
#{opt}
EOF
    
    return html
    
  end
  
end
    
