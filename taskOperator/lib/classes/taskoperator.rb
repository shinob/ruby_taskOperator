class TaskOperator

  def initialize()
    @style = ""
    @page_title = "タスクオペレーター"
    @title = ""
    @foot = "&nbsp;"
    @menu = ""
  end
  
  def main()
    
    tsk = KmrTasks.new()
    pln = KmrPlans.new()
    act = KmrActions.new()
    
    mode = $_POST["mode"]
    id = $_POST["id"].to_i
    task_id = $_POST["task_id"].to_i
    plan_id = $_POST["plan_id"].to_i
    html = ""
    
    #html = $usr.get_logout_form()
    @menu += $usr.get_logout_form()
    
    case mode
    when "find_task"
      word = $_POST["word"]
      @menu += get_list_task_form()
      #@menu += get_user_list_form()
      @style = "#head { display: none; }"
      html += tsk.find(word)
    when "add_task"
      html += tsk.add()
      @menu += get_cancel_form()
      @title = "タスクの追加"
    when "edit_task"
      html += tsk.edit(id)
      @menu += get_show_task_form(id)
      @title = "タスクの編集"
    when "show_task"
      html += tsk.show(id)
      html += pln.list(id)
      @menu += get_list_task_form()
      @menu += get_edit_task_form(id)
      @menu += get_add_plan_form(id)
      @title = "タスクの表示"
    when "apply_task"
      if id < 1 then
        $_POST["add_date"] = Date.today.strftime("%Y-%m-%d")
      end
      debug($_POST.to_s)
      id = tsk.apply($_POST)
      tsk.set_status(id, pln.get_task_status(id))
      
      @menu = ""
      $_POST["id"] = id
      $_POST["mode"] = "show_task"
      html = main()
      #html += tsk.list_all()
    when "list_all_task"
      @menu += get_list_task_form()
      @menu += get_user_list_form()
      @style = "#head { display: none; }"
      html += tsk.list_all()
      #html += tsk.list_not_complete()
    when "list_completed_task"
      @menu += get_list_task_form()
      @menu += get_user_list_form()
      @style = "#head { display: none; }"
      html += tsk.list_completed()
      
      
    when "add_plan"
      html += pln.add(task_id)
      @menu += get_show_task_form(task_id)
      @title = "プランの追加"
    when "edit_plan"
      html += pln.edit(id)
      @menu += get_show_task_form(task_id)
      @menu += get_show_plan_form(id, task_id)
      @title = "プランの編集"
    when "show_plan"
      html += pln.show(id)
      html += act.list(id)
      @menu += get_show_task_form(task_id)
      @menu += get_edit_plan_form(id, task_id)
      @menu += get_add_action_form(id)
      @title = "プランの表示"
    when "apply_plan"
      pln.apply($_POST)
      tsk.set_status(task_id, pln.get_task_status(task_id))
      
      @menu = ""
      $_POST["id"] = task_id
      $_POST["mode"] = "show_task"
      html = main()
    
    when "add_action"
      html = act.add(plan_id)
      task_id = pln.get_task_id(plan_id)
      @menu += get_show_plan_form(plan_id, task_id)
      @title = "アクションの追加"
    when "edit_action"
      html = act.edit(id)
      task_id = pln.get_task_id(plan_id)
      @menu += get_show_plan_form(plan_id, task_id)
      @title = "アクションの編集"
    when "apply_action"
      act.apply($_POST)
      pln.set_status(plan_id, $_POST["status"])
      task_id = pln.get_task_id(plan_id)
      tsk.set_status(task_id, pln.get_task_status(task_id))
      
      @menu = ""
      $_POST["id"] = plan_id
      $_POST["task_id"] = pln.get_task_id(plan_id)
      $_POST["mode"] = "show_plan"
      html = main()
      
    when "add_user"
      @menu += get_user_list_form()
      html += $usr.add()
      @title = "ユーザーの追加"
    when "edit_user"
      @menu += get_user_list_form()
      html += $usr.edit(id)
      @title = "ユーザーの編集"
    when "list_user"
      @menu += get_back_form()
      @menu += $usr.get_add_form()
      @style = "#head { display: none; }"
      html += $usr.list_all()
    when "apply_user"
      if is_admin() then
        $usr.apply($_POST)
      end
      @menu += get_back_form()
      @menu += $usr.get_add_form()
      html += $usr.list_all()
      
    when "change_password"
      html += $usr.get_password_form()
      if id > 0 then
        html += $usr.set_password($_POST)
      end
      @menu += get_cancel_form()
      @title = "&nbsp;"
      
    else
      @menu += get_user_list_form()
      @menu += get_add_task_form()
      @menu += get_list_all_task_form()
      @menu += get_list_completed_task_form()
      @menu += get_find_task_form()
      #html += tsk.list_all()
      @style = <<EOF
#head { display: none; }
div.plan_list { width: 90%; border: 0px solid #0F0;}
div.plan_list div { margin: 0px; padding: 0px; }
div.action_list { width: 100%; }
EOF
      html += tsk.list_not_complete()
    end
    
    return html
    
  end
  
  def output(html)
    
    #menu = "トップ"
    
    wk = {
      "style" => @style,
      "page_title" => @page_title,
      "title" => @title,
      "menu" => @menu,
      "cont" => html,
      "foot" => @foot
    }
    
    html = load_template(wk, "page.html")
    puts html
    
  end
  
  def index()
    
    if $usr.is_login() then
      html = main()
    else
      html = $usr.get_login_form()
      @title = "ログイン"
    end
    
    output(html)
    
  end
  
  def get_cancel_form()
    html = <<EOF
<a href="#" onclick="window.location='./'">
<form>
  <p>キャンセル</p>
</form>
</a>
EOF
    return html
  end
  
  def get_back_form()
    html = <<EOF
<a href="#" onclick="window.location='./'">
<form>
  <p>トップへ戻る</p>
</form>
</a>
EOF
    return html
  end
  
  def get_user_list_form()
    html = ""
    if is_admin() then
      html = <<EOF
<a href="#" onClick="document.list_user.submit();">
<form method="post" name="list_user" style="float: right;">
  <input type="hidden" name="mode" value="list_user" />
  <p>ユーザ一覧</p>
</form>
</a>
EOF
    end
    return html
  end
  
  def get_list_task_form()
    html = <<EOF
<a href="#" onclick="window.location='./'">
<form>
  <p>タスク一覧</p>
</form>
</a>
EOF
    return html
  end
  
  def get_list_all_task_form()
    name = "list_all_task"
    html = <<EOF
<a href="#" onClick="document.#{name}.submit();">
<form method="post" name="#{name}">
  <input type="hidden" name="mode" value="#{name}" />
  <p>全タスク</p>
</form>
</a>
EOF
    return html
  end
  
  def get_list_completed_task_form()
    name = "list_completed_task"
    html = <<EOF
<a href="#" onClick="document.#{name}.submit();">
<form method="post" name="#{name}">
  <input type="hidden" name="mode" value="#{name}" />
  <p>完了タスク</p>
</form>
</a>
EOF
    return html
  end
  
  def get_task_form(id, name, str)
    html = <<EOF
<a href="#" onClick="document.#{name}.submit();">
<form method="post" name="#{name}">
  <input type="hidden" name="mode" value="#{name}" />
  <input type="hidden" name="id" value="#{id}" />
  <p>#{str}</p>
</form>
</a>
EOF
    return html
  end
  
  def get_show_task_form(id)
    return get_task_form(id, "show_task", "タスク表示")
  end
  
  def get_edit_task_form(id)
    return get_task_form(id, "edit_task", "タスク編集")
  end
  
  def get_add_task_form()
    return get_task_form(0, "add_task", "タスク追加")
  end
  
  def get_find_task_form()
    html = <<EOF
<form method="post" name="find_task" id="find_task">
  <input type="hidden" name="mode" value="find_task" />
  <table>
    <tr>
      <td><input type="text" name="word" value="" /></td>
      <td><input type="submit" name="submit" value="検索" /></td>
    </tr>
  </table>
</form>
EOF
    return html
  end
  
  def get_plan_form(id, task_id, name, str)
    html = <<EOF
<a href="#"  onClick="document.#{name}.submit();">
<form method="post" name="#{name}">
  <input type="hidden" name="mode" value="#{name}" />
  <input type="hidden" name="id" value="#{id}" />
  <input type="hidden" name="task_id" value="#{task_id}" />
  <p>#{str}</p>
</form>
</a>
EOF
    return html
  end
  
  def get_show_plan_form(id, task_id)
    return get_plan_form(id, task_id, "show_plan", "プラン表示")
  end
  
  def get_edit_plan_form(id, task_id)
    return get_plan_form(id, task_id, "edit_plan", "プラン編集")
  end
  
  def get_add_plan_form(task_id)
    return get_plan_form(0, task_id, "add_plan", "プラン追加")
  end
  
  def get_add_action_form(plan_id)
    name = "add_action"
    html = <<EOF
<a href="#" onClick="document.#{name}.submit();">
<form method="post" name="#{name}">
  <input type="hidden" name="mode" value="#{name}" />
  <input type="hidden" name="plan_id" value="#{plan_id}" />
  <p>アクション追加</p>
</form>
</a>
EOF
    return html
  end
  
end